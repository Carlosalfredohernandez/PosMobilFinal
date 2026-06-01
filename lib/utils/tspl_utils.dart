import 'dart:typed_data';
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Convierte una imagen PNG (Uint8List) a BITMAP TSPL y la imprime (robusto)
/// [printableWidth] permite calibrar recorte lateral (ej: 372, 376, 380).
Future<void> imprimirImagenComoTSPL(
  Uint8List imageBytes, {
  int x = 0,
  int y = 0,
  int? printableWidth,
}) async {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  final GetStorage storage = GetStorage();
  try {
    // Decodificar la imagen
    final img.Image? original = img.decodeImage(imageBytes);
    if (original == null) throw Exception('No se pudo decodificar la imagen');

    // Margen de seguridad: algunas impresoras de 80mm recortan el borde derecho en 384px.
    // Se deja configurable para calibrar por modelo.
    final dynamic savedPrintableWidth = storage.read('printable_width');
    final int resolvedPrintableWidth = printableWidth ?? (savedPrintableWidth is int ? savedPrintableWidth : 376);
    final int safePrintableWidth = resolvedPrintableWidth.clamp(320, 384);
    final img.Image source = original.width > safePrintableWidth
      ? img.copyResize(original, width: safePrintableWidth)
      : original;

    // Asegurar que el ancho sea múltiplo de 8 (TSPL lo requiere)
    int width = source.width;
    int height = source.height;
    int paddedWidth = (width % 8 == 0) ? width : (width + (8 - width % 8));
    img.Image bw = img.Image(width: paddedWidth, height: height);

    // Convertir a blanco y negro puro (umbral manual), manejando transparencia
    for (int y0 = 0; y0 < height; y0++) {
      for (int x0 = 0; x0 < width; x0++) {
        final pixel = source.getPixel(x0, y0);
        final int a = pixel.a.toInt();
        final int r = pixel.r.toInt();
        final int g = pixel.g.toInt();
        final int b = pixel.b.toInt();
        // Si el pixel es transparente, lo tratamos como blanco
        if (a < 128) {
          bw.setPixel(x0, y0, img.ColorRgb8(255, 255, 255));
          continue;
        }
        final gray = (r * 0.3 + g * 0.59 + b * 0.11).round();
        final bwColor = gray > 160 ? 255 : 0;
        bw.setPixel(x0, y0, img.ColorRgb8(bwColor, bwColor, bwColor));
      }
      for (int x0 = width; x0 < paddedWidth; x0++) {
        bw.setPixel(x0, y0, img.ColorRgb8(255, 255, 255));
      }
    }

    // Guardar imagen original (antes de binarizar) en Descargas para depuración
    try {
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else {
        downloadsDir = await getDownloadsDirectory();
      }
      if (downloadsDir != null) {
        final originalPath = '${downloadsDir.path}/debug_original.png';
        final originalBytes = img.encodePng(original);
        final originalFile = File(originalPath);
        await originalFile.writeAsBytes(originalBytes);
        print('Imagen original guardada en Descargas: ' + originalPath);
      } else {
        print('No se pudo obtener la carpeta de Descargas para original');
      }
    } catch (e) {
      print('No se pudo guardar imagen original en Descargas: ' + e.toString());
    }

    // Guardar imagen binarizada en Descargas para depuración
    // Solicitar permiso de almacenamiento de forma robusta
    bool permisoOk = true;
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        final legacyStatus = await Permission.storage.request();
        if (!legacyStatus.isGranted) {
          permisoOk = false;
          print('Permiso de almacenamiento denegado. No se guardará la imagen en Descargas.');
          Get.snackbar('Permiso requerido', 'Debes otorgar permiso de almacenamiento para guardar la imagen en Descargas.');
        }
      }
    }
    if (permisoOk) {
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else {
        downloadsDir = await getDownloadsDirectory();
      }
      if (downloadsDir != null) {
        final debugPath = '${downloadsDir.path}/debug_bw.png';
        final debugBytes = img.encodePng(bw);
        final debugFile = File(debugPath);
        await debugFile.writeAsBytes(debugBytes);
        print('Imagen binarizada guardada en Descargas: ' + debugPath);
      } else {
        print('No se pudo obtener la carpeta de Descargas');
      }
    }

    // Convertir a bytes TSPL (1 bit por pixel, 8 píxeles por byte)
    int widthBytes = paddedWidth ~/ 8;
    List<int> tsplBytes = [];
    for (int y0 = 0; y0 < height; y0++) {
      for (int bx = 0; bx < widthBytes; bx++) {
        int byte = 0;
        for (int bit = 0; bit < 8; bit++) {
          int px = bx * 8 + bit;
          final pixel = bw.getPixel(px, y0);
          final int r = pixel.r.toInt();
          // Esta impresora interpreta el bit en polaridad inversa: 0=negro, 1=blanco.
          // Por eso marcamos 1 para blanco y dejamos 0 para negro.
          if (r >= 128) {
            byte |= (1 << (7 - bit));
          }
        }
        tsplBytes.add(byte);
      }
    }

    // Comando CPCL/TSPL: enviar BITMAP con payload binario (no hex en texto)
    final header = '! 0 200 200 ${height + 20} 1\r\nBITMAP $x $y $widthBytes $height 0 ';
    final footer = '\r\nPRINT\r\n';
    final builder = BytesBuilder();
    builder.add(latin1.encode(header));
    builder.add(tsplBytes);
    builder.add(latin1.encode(footer));
    final rawCommand = builder.toBytes();
    print('Comando BITMAP binario generado: ${rawCommand.length} bytes');
    await bluetooth.writeBytes(rawCommand);
    Get.snackbar('Impresión', 'Imagen enviada como TSPL BITMAP');
  } catch (e, st) {
    Get.snackbar('Error de impresión', e.toString());
    print('Error impresión TSPL: $e\n$st');
  }
}
