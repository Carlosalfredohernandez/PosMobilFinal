import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io' as io;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Convierte una imagen PNG (Uint8List) a BITMAP TSPL y la imprime (robusto)
Future<void> imprimirImagenComoTSPL(Uint8List imageBytes, {int x = 0, int y = 0}) async {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  final GetStorage storage = GetStorage();
  try {
    // Decodificar la imagen
    final img.Image? original = img.decodeImage(imageBytes);
    if (original == null) throw Exception('No se pudo decodificar la imagen');

    // Asegurar que el ancho sea múltiplo de 8 (TSPL lo requiere)
    int width = original.width;
    int height = original.height;
    int paddedWidth = (width % 8 == 0) ? width : (width + (8 - width % 8));
    img.Image bw = img.Image(width: paddedWidth, height: height);

    // Convertir a blanco y negro puro (umbral manual)
    for (int y0 = 0; y0 < height; y0++) {
      for (int x0 = 0; x0 < width; x0++) {
        final pixel = original.getPixel(x0, y0);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        final gray = (r * 0.3 + g * 0.59 + b * 0.11).round().toInt();
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
    try {
      // Solicitar permiso de almacenamiento si es necesario
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          print('Permiso de almacenamiento denegado');
        }
      }
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
    } catch (e) {
      print('No se pudo guardar imagen de depuración en Descargas: ' + e.toString());
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
          dynamic r;
          // Soporta tanto Pixel (objeto) como int (ARGB)
          if (pixel is int) {
            r = ((pixel as int) >> 16) & 0xFF;
          } else if (pixel is img.Pixel) {
            r = pixel.r;
            if (r is num) r = r.toInt();
          } else {
            throw Exception('Tipo de pixel no soportado: \\${pixel.runtimeType}');
          }
          if (r < 128) {
            byte |= (1 << (7 - bit));
          }
        }
        tsplBytes.add(byte);
      }
    }

    // Comando TSPL
    String tspl = '! 0 200 200 ${height + 20} 1\r\n';
    tspl += 'BITMAP $x $y $widthBytes $height 1 ';
    String hex = tsplBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
    tspl += hex + '\r\nPRINT\r\n';
    print('TSPL generado (primeros 200 chars):\n' + tspl.substring(0, tspl.length > 200 ? 200 : tspl.length));
    await bluetooth.write(tspl);
    Get.snackbar('Impresión', 'Imagen enviada como TSPL BITMAP');
  } catch (e, st) {
    Get.snackbar('Error de impresión', e.toString());
    print('Error impresión TSPL: $e\n$st');
  }
}
