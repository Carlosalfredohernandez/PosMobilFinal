
// ...existing code...
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/models/producto.dart';
import 'package:posmobilfinal/src/pages/cliente/caja/create/cliente_caja_create_controller.dart';
import 'package:posmobilfinal/src/pages/cliente/caja/search/cliente_caja_search_page.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'dart:ui' as ui;
import 'package:posmobilfinal/src/pages/configuraciones/impresora.dart';
import 'package:posmobilfinal/utils/boleta_pdf_pos.dart';
import 'package:posmobilfinal/utils/boleta_xml_parser.dart';
import 'package:posmobilfinal/utils/tspl_utils.dart';
// --- COLOCAR DESPUÉS DE TODOS LOS IMPORTS ---

/// Página de prueba para impresión TSPL de imagen
class PruebaTSPLPage extends StatelessWidget {
      /// Imprime un bloque negro sólido de 384x32 usando TSPL BITMAP (test de formato)
      Future<void> imprimirBloqueNegroTSPL(BuildContext context) async {
        try {
          int widthPx = 384;
          int height = 32;
          int widthBytes = widthPx ~/ 8; // 48
          // Cada byte=0xFF (8 píxeles negros)
          List<int> bitmap = List.filled(widthBytes * height, 0xFF);
          String tspl = '! 0 200 200 ${height + 20} 1\r\n';
          tspl += 'BITMAP 0 0 $widthBytes $height 1 ';
          String hex = bitmap.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
          tspl += hex + '\r\nPRINT\r\n';
          print('TSPL bloque negro (primeros 200 chars):\n' + tspl.substring(0, tspl.length > 200 ? 200 : tspl.length));
          await bluetooth.write(tspl);
          Get.snackbar('Impresión', 'Bloque negro enviado como TSPL BITMAP');
        } catch (e, st) {
          Get.snackbar('Error de impresión', e.toString());
          print('Error impresión bloque negro TSPL: $e\n$st');
        }
      }
    /// Genera una imagen de prueba (texto negro sobre fondo blanco) y la imprime como TSPL BITMAP
    Future<void> imprimirImagenTestTSPL(BuildContext context) async {
      try {
        // Cargar fuente bitmap desde assets
        final fntStr = await rootBundle.loadString('assets/fonts/arial14.fnt');
        final pngBytes = await rootBundle.load('assets/fonts/arial14.png');
        final pngImg = img.decodePng(pngBytes.buffer.asUint8List());
        if (pngImg == null) throw Exception('No se pudo decodificar arial14.png');
        final font = img.BitmapFont.fromFnt(fntStr, pngImg);

        // Crear imagen de 384x120 px, fondo blanco, texto negro
        final img.Image testImg = img.Image(width: 384, height: 120);
        img.fill(testImg, color: img.ColorRgb8(255, 255, 255));
        img.drawLine(testImg, x1: 0, y1: 40, x2: 383, y2: 40, color: img.ColorRgb8(0, 0, 0));
        img.drawString(testImg, 'PRUEBA IMPRESORA', font: font);
        img.drawString(testImg, 'Ancho: 384 px', font: font, y: 60);
        img.drawString(testImg, 'Fecha: ${DateTime.now().toString().substring(0, 16)}', font: font, y: 90);

        // Binarizar (umbral 128)
        int width = testImg.width;
        int height = testImg.height;
        int paddedWidth = (width % 8 == 0) ? width : (width + (8 - width % 8));
        img.Image bw = img.Image(width: paddedWidth, height: height);
        for (int y0 = 0; y0 < height; y0++) {
          for (int x0 = 0; x0 < width; x0++) {
            final pixel = testImg.getPixel(x0, y0);
            final luma = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b).round();
            if (luma > 128) {
              bw.setPixelRgba(x0, y0, 255, 255, 255, 255);
            } else {
              bw.setPixelRgba(x0, y0, 0, 0, 0, 255);
            }
          }
          for (int x0 = width; x0 < paddedWidth; x0++) {
            bw.setPixelRgba(x0, y0, 255, 255, 255, 255);
          }
        }
        int widthBytes = paddedWidth ~/ 8;
        List<int> bitmap = [];
        for (int row = 0; row < height; row++) {
          for (int byte = 0; byte < widthBytes; byte++) {
            int b = 0;
            for (int bit = 0; bit < 8; bit++) {
              int xpix = byte * 8 + bit;
              b <<= 1;
              if (xpix < paddedWidth) {
                final color = bw.getPixel(xpix, row);
                final r = color.r;
                if (r < 128) b |= 1;
              }
            }
            bitmap.add(b);
          }
        }
        String tspl = '! 0 200 200 ${height + 20} 1\r\n';
        tspl += 'BITMAP 0 0 $widthBytes $height 1 ';
        String hex = bitmap.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
        tspl += hex + '\r\nPRINT\r\n';
        print('TSPL generado para imagen de test (primeros 500 chars):\n' + tspl.substring(0, tspl.length > 500 ? 500 : tspl.length));
        await bluetooth.write(tspl);
        Get.snackbar('Impresión', 'Imagen de test enviada como TSPL BITMAP');
      } catch (e, st) {
        Get.snackbar('Error de impresión', e.toString());
        print('Error impresión TSPL test: $e\n$st');
      }
    }
  final BlueThermalPrinter bluetooth;
  final GetStorage storage;
  const PruebaTSPLPage({Key? key, required this.bluetooth, required this.storage}) : super(key: key);

  /// Imprime una imagen PNG de ejemplo desde assets/fonts/TECNOALSA LOGO2.png como TSPL BITMAP redimensionada a 200px de ancho
  Future<void> imprimirImagenTSPL(BuildContext context) async {
    try {
      // Cargar imagen de ejemplo desde assets/fonts/TECNOALSA LOGO2.png
      final ByteData imgBytes = await rootBundle.load('assets/fonts/TECNOALSA LOGO2.png');
      final Uint8List imageData = imgBytes.buffer.asUint8List();

      // --- Lógica de conexión y envío TSPL ---
      final impresoraGuardada = storage.read('impresora');
      if (impresoraGuardada == null || impresoraGuardada['address'] == null) {
        Get.snackbar('Impresión', 'Selecciona una impresora en Configuración');
        return;
      }
      final String address = impresoraGuardada['address'].toString();
      final List<BluetoothDevice> bonded = await bluetooth.getBondedDevices();
      BluetoothDevice? device;
      for (final d in bonded) {
        if (d.address == address) {
          device = d;
          break;
        }
      }
      if (device == null) {
        Get.snackbar('Impresión', 'La impresora guardada no está vinculada');
        return;
      }
      final bool? conectado = await bluetooth.isConnected;
      if (conectado != true) {
        await bluetooth.connect(device);
        await Future.delayed(const Duration(milliseconds: 600));
      }

      // --- Redimensionar la imagen a 384px de ancho (manteniendo aspecto) ---
      final img.Image? original = img.decodeImage(imageData);
      if (original == null) throw Exception('No se pudo decodificar la imagen');
      int targetWidth = 384;
      int targetHeight = (original.height * (targetWidth / original.width)).round();
      img.Image resized = img.copyResize(original, width: targetWidth, height: targetHeight);

      // Asegurar que el ancho sea múltiplo de 8
      int width = resized.width;
      int height = resized.height;
      int paddedWidth = (width % 8 == 0) ? width : (width + (8 - width % 8));
      int widthBytes = paddedWidth ~/ 8;
      int umbral = 180; // UMBRAL alto para que más píxeles sean blancos
      img.Image bw = img.Image(width: paddedWidth, height: height);
      List<int> lumasDebug = [];
      for (int y0 = 0; y0 < height; y0++) {
        for (int x0 = 0; x0 < width; x0++) {
          final pixel = resized.getPixel(x0, y0);
          final r = pixel.r;
          final g = pixel.g;
          final b = pixel.b;
          final luma = (0.299 * r + 0.587 * g + 0.114 * b).round();
          if (lumasDebug.length < 20) lumasDebug.add(luma);
          if (luma > umbral) {
            bw.setPixelRgba(x0, y0, 255, 255, 255, 255); // blanco
          } else {
            bw.setPixelRgba(x0, y0, 0, 0, 0, 255); // negro
          }
        }
        for (int x0 = width; x0 < paddedWidth; x0++) {
          bw.setPixelRgba(x0, y0, 255, 255, 255, 255); // padding blanco
        }
      }
      print('Primeros 20 valores de luma: ' + lumasDebug.toString());
      List<int> bitmap = [];
      for (int row = 0; row < height; row++) {
        for (int byte = 0; byte < widthBytes; byte++) {
          int b = 0;
          for (int bit = 0; bit < 8; bit++) {
            int xpix = byte * 8 + bit;
            b <<= 1;
            if (xpix < paddedWidth) {
              final color = bw.getPixel(xpix, row);
              final r = color.r;
              // bit=1 si es negro
              if (r < 128) b |= 1;
            }
          }
          bitmap.add(b);
        }
      }
      // Debug: mostrar los primeros 100 bytes del bitmap
      print('Primeros 100 bytes del bitmap: ' + bitmap.take(100).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' '));
      String tspl = '! 0 200 200 ${height + 20} 1\r\n';
      tspl += 'BITMAP 0 0 $widthBytes $height 1 ';
      String hex = bitmap.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
      tspl += hex + '\r\nPRINT\r\n';
      print('TSPL generado para imagen (primeros 500 chars):\n' + tspl.substring(0, tspl.length > 500 ? 500 : tspl.length));
      await bluetooth.write(tspl);
      Get.snackbar('Impresión', 'Imagen de ejemplo enviada como TSPL BITMAP (ancho 384, bit=1 negro, umbral 180)');
    } catch (e, st) {
      Get.snackbar('Error de impresión', e.toString());
      print('Error impresión TSPL test: $e\n$st');
    }
  }

  /// Enviar un comando TSPL de texto simple para verificar comunicación
  Future<void> imprimirTSPLTextoSimple(BuildContext context) async {
    try {
      final impresoraGuardada = storage.read('impresora');
      if (impresoraGuardada == null || impresoraGuardada['address'] == null) {
        Get.snackbar('Impresión', 'Selecciona una impresora en Configuración');
        return;
      }
      final String address = impresoraGuardada['address'].toString();
      final List<BluetoothDevice> bonded = await bluetooth.getBondedDevices();
      BluetoothDevice? device;
      for (final d in bonded) {
        if (d.address == address) {
          device = d;
          break;
        }
      }
      if (device == null) {
        Get.snackbar('Impresión', 'La impresora guardada no está vinculada');
        return;
      }
      final bool? conectado = await bluetooth.isConnected;
      if (conectado != true) {
        await bluetooth.connect(device);
        await Future.delayed(const Duration(milliseconds: 600));
      }
      // Ancho 384px (58mm), fuente 9 (la más grande), texto centrado
      String tspl = '! 0 200 200 350 1\r\n';
      tspl += 'TEXT 9 0 30 120 "TEXTO GRANDE"\r\n';
      tspl += 'TEXT 9 0 30 200 "FUENTE 9"\r\n';
      tspl += 'PRINT\r\n';
      print('TSPL de texto grande (fuente 9):\n' + tspl);
      await bluetooth.write(tspl);
      Get.snackbar('Impresión', 'Comando TSPL de texto enviado (fuente 9)');
    } catch (e, st) {
      Get.snackbar('Error de impresión', e.toString());
      print('Error impresión TSPL texto simple: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prueba TSPL Imagen')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.print),
              label: Text('Imprimir imagen TSPL (200px ancho)'),
              onPressed: () => imprimirImagenTSPL(context),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.stop),
              label: Text('Imprimir bloque negro (TSPL)'),
              onPressed: () => imprimirBloqueNegroTSPL(context),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.image),
              label: Text('Imprimir imagen de test (memoria)'),
              onPressed: () => imprimirImagenTestTSPL(context),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.text_fields),
              label: Text('Imprimir texto TSPL simple'),
              onPressed: () => imprimirTSPLTextoSimple(context),
            ),
          ],
        ),
      ),
    );
  }
}



// ...el resto del código debe estar dentro de la clase ClienteCajaCreatePage o su State

class ClienteCajaCreatePage extends StatefulWidget {
  @override
  State<ClienteCajaCreatePage> createState() => _ClienteCajaCreatePageState();
}

class _ClienteCajaCreatePageState extends State<ClienteCajaCreatePage> {

    /// Genera el PDF de la boleta usando los datos actuales
    Future<pw.Document> generarPdfBoleta() async {
      final pdf = pw.Document();
      // Puedes personalizar el contenido del PDF aquí
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('BOLETA ELECTRONICA', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('Folio: \\${_boletaData?['folio'] ?? ''}'),
                pw.Text('RUT: \\${_boletaData?['rut_emisor'] ?? ''}'),
                pw.Text('Razón Social: \\${_boletaData?['razon_social'] ?? ''}'),
                pw.SizedBox(height: 8),
                pw.Text('Detalle:'),
                if ((_boletaData?['detalle'] as List?) != null)
                  ...((_boletaData!['detalle'] as List).map((item) =>
                    pw.Text('  - \\${item['cantidad']} x \\${item['nombre']} (\$${item['monto']})')
                  )),
                pw.SizedBox(height: 8),
                pw.Text('Total: \\${_boletaData?['total'] ?? ''}'),
              ],
            );
          },
        ),
      );
      return pdf;
    }

/// Convierte una imagen PNG (Uint8List) a BITMAP TSPL y la imprime (robusto)

  /// Imprime la boleta en formato TSPL usando datos reales y el TED como imagen
  void imprimirBoletaTSPL() async {
    try {
      final impresoraGuardada = _storage.read('impresora');
      if (impresoraGuardada == null || impresoraGuardada['address'] == null) {
        Get.snackbar('Impresión', 'Selecciona una impresora en Configuración');
        return;
      }
      final String address = impresoraGuardada['address'].toString();
      final List<BluetoothDevice> bonded = await _bluetooth.getBondedDevices();
      BluetoothDevice? device;
      for (final d in bonded) {
        if (d.address == address) {
          device = d;
          break;
        }
      }
      if (device == null) {
        Get.snackbar('Impresión', 'La impresora guardada no está vinculada');
        return;
      }
      final bool? conectado = await _bluetooth.isConnected;
      if (conectado != true) {
        await _bluetooth.connect(device);
        await Future.delayed(const Duration(milliseconds: 600));
      }

      // --- DATOS REALES DEL MODELO ---
      final boleta = _boletaData;
      if (boleta == null) {
        Get.snackbar('Impresión', 'No hay datos de boleta para imprimir');
        return;
      }
      final detalle = (boleta['detalle'] as List?) ?? [];
      final String folio = boleta['folio']?.toString() ?? '';
      final String rut = boleta['rut_emisor']?.toString() ?? '';
      final String razonSocial = boleta['razon_social']?.toString() ?? '';
      final int total = boleta['total'] ?? 0;
      final String fecha = DateTime.now().toString().substring(0, 16);
      final String ted = boleta['ted_dd']?.toString() ?? '';


      // --- TSPL optimizado para 58mm sin BOX ---
      // Ancho 384px, fuente 2, sin márgenes, tabla simple
      String tspl = '! 0 200 200 900 1\r\n';
      tspl += 'TEXT 2 0 0 20 "BOLETA ELECTRONICA"\r\n';
      tspl += 'TEXT 2 0 0 50 "RUT: $rut"\r\n';
      tspl += 'TEXT 2 0 180 50 "N° $folio"\r\n';
      tspl += 'TEXT 2 0 0 75 "$razonSocial"\r\n';
      tspl += 'TEXT 2 0 0 100 "Fecha: ${fecha.split(' ')[0]}  Hora: ${fecha.split(' ')[1]}"\r\n';

      // Encabezado tabla
      tspl += 'LINE 0 130 380 130 1\r\n';
      tspl += 'TEXT 2 0 0 135 "Cant"\r\n';
      tspl += 'TEXT 2 0 70 135 "P.Unit"\r\n';
      tspl += 'TEXT 2 0 170 135 "Total"\r\n';
      tspl += 'LINE 0 160 380 160 1\r\n';

      int y = 165;
      for (final item in detalle) {
        final nombre = (item['nombre'] ?? item['descripcion'] ?? '').toString();
        final cantidad = (item['cantidad'] ?? 1).toString();
        final monto = (item['monto'] ?? item['total'] ?? 0).toString();
        final punit = item['punit']?.toString() ?? item['precioVenta']?.toString() ?? '';
        // Nombre en dos líneas si es largo
        String nombre1 = nombre;
        String nombre2 = '';
        if (nombre.length > 18) {
          nombre1 = nombre.substring(0, 18);
          nombre2 = nombre.substring(18, nombre.length > 36 ? 36 : nombre.length);
        }
        tspl += 'TEXT 2 0 0 $y "$nombre1"\r\n';
        if (nombre2.isNotEmpty) {
          y += 20;
          tspl += 'TEXT 2 0 0 $y "$nombre2"\r\n';
        }
        y += 20;
        tspl += 'TEXT 2 0 0 $y "$cantidad"\r\n';
        tspl += 'TEXT 2 0 70 $y "$punit"\r\n';
        tspl += 'TEXT 2 0 170 $y "$monto"\r\n';
        y += 20;
        tspl += 'LINE 0 $y 380 $y 1\r\n';
        y += 5;
      }
      y += 5;
      tspl += 'TEXT 2 0 100 $y "TOTAL: $total"\r\n';
      y += 25;
      tspl += 'TEXT 2 0 0 $y "IVA: 0"\r\n';
      y += 20;
      // Código de barras PDF417 para TED
      if (ted.isNotEmpty) {
        tspl += 'PDF417 0 $y 380 60 0 2 6 0 0 "$ted"\r\n';
        y += 70;
      }
      tspl += 'TEXT 2 0 0 $y "Timbre Electronico SII"\r\n';
      tspl += 'PRINT\r\n';

      // --- Enviar TSPL (texto) ---
      await _bluetooth.write(tspl);

      // --- Imprimir TED como imagen si existe ---
      if (ted.isNotEmpty) {
        // Cargar fuente bitmap desde assets (igual que imprimirPruebaEscPos)
        final fntStr = await rootBundle.loadString('assets/fonts/arial14.fnt');
        final pngBytes = await rootBundle.load('assets/fonts/arial14.png');
        final pngImg = img.decodePng(pngBytes.buffer.asUint8List());
        if (pngImg != null) {
          final font = img.BitmapFont.fromFnt(fntStr, pngImg);
          final img.Image tedImg = img.Image(width: 380, height: 80);
          img.fill(tedImg, color: img.ColorRgb8(255, 255, 255));
          img.drawString(tedImg, ted.length > 100 ? ted.substring(0, 100) : ted, font: font);
          final Uint8List tedBytes = Uint8List.fromList(img.encodePng(tedImg));
          await _bluetooth.printImageBytes(tedBytes);
        }
      }

      Get.snackbar('Impresión', 'Boleta enviada a la impresora');
    } catch (e, st) {
      Get.snackbar('Error de impresión', e.toString());
      print('Error impresión TSPL: $e\n$st');
    }
  }
    final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;
    final GetStorage _storage = GetStorage();

    /// Imprime un ticket básico usando comandos TSPL (para impresoras que no soportan ESC/POS)
    void imprimirTSPL() async {
      try {
        final impresoraGuardada = _storage.read('impresora');
        if (impresoraGuardada == null || impresoraGuardada['address'] == null) {
          Get.snackbar('Impresión', 'Selecciona una impresora en Configuración');
          return;
        }
        final String address = impresoraGuardada['address'].toString();
        final List<BluetoothDevice> bonded = await _bluetooth.getBondedDevices();
        BluetoothDevice? device;
        for (final d in bonded) {
          if (d.address == address) {
            device = d;
            break;
          }
        }
        if (device == null) {
          Get.snackbar('Impresión', 'La impresora guardada no está vinculada');
          return;
        }
        final bool? conectado = await _bluetooth.isConnected;
        if (conectado != true) {
          await _bluetooth.connect(device);
          await Future.delayed(const Duration(milliseconds: 600));
        }

        // Comando TSPL
        String tspl = '! 0 200 200 210 1\r\n'
                      'TEXT 4 0 30 40 Hola Mundo\r\n'
                      'PRINT\r\n';

        // Enviar como bytes
        await _bluetooth.write(tspl);

        Get.snackbar('Impresión', 'Comando TSPL enviado');
      } catch (e, st) {
        Get.snackbar('Error de impresión', e.toString());
        print('Error impresión TSPL: $e\n$st');
      }
    }
  _ClienteCajaCreatePageState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Caja'),
        actions: [
          IconButton(
            icon: Icon(Icons.bluetooth),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ImpresorasPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.print),
            tooltip: 'Prueba TSPL',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PruebaTSPLPage(
                    bluetooth: _bluetooth,
                    storage: _storage,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.label),
            tooltip: 'Imprimir TSPL',
            onPressed: () {
              imprimirTSPL();
            },
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _campoCodigoBarra(context)),
                    _iconSearch(context),
                    _iconScan(),
                  ],
                ),
                _indicadorFolios(),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: controlador.selectedProducts.length > 0
                  ? ListView.builder(
                      padding: EdgeInsets.only(top: 8),
                      itemCount: controlador.selectedProducts.length,
                      itemBuilder: (context, index) {
                        final product = controlador.selectedProducts[index];
                        return _cardProduct(product);
                      },
                    )
                  : Center(child: Text('No hay ningun producto agregado aun')),
            ),
          ),
          _footerPagos(context),
        ],
      ),
    );
  }

  // Cargar fuente bitmap desde assets

  // Prueba real para impresora TSC: imprime una imagen de test (ancho 384 px, binarizada)
  void imprimirPruebaEscPos() async {
    try {
      // Cargar fuente bitmap desde assets
      final fntStr = await rootBundle.loadString('assets/fonts/arial14.fnt');
      final pngBytes = await rootBundle.load('assets/fonts/arial14.png');
      final pngImg = img.decodePng(pngBytes.buffer.asUint8List());
      if (pngImg == null) throw Exception('No se pudo decodificar arial14.png');
      final font = img.BitmapFont.fromFnt(fntStr, pngImg);
      // Crear imagen de test (384x120 px, texto y líneas)
      final img.Image testImg = img.Image(width: 384, height: 120);
      img.fill(testImg, color: img.ColorRgb8(255, 255, 255));
      img.drawLine(testImg, x1: 0, y1: 40, x2: 383, y2: 40, color: img.ColorRgb8(0, 0, 0));
      img.drawString(testImg, 'PRUEBA IMPRESORA', font: font);
      img.drawString(testImg, 'Ancho: 384 px', font: font);
      img.drawString(testImg, 'Fecha: ${DateTime.now().toString().substring(0, 16)}', font: font);
      // Binarizar (umbral manual)
      final bw = img.grayscale(testImg);
      for (int y = 0; y < bw.height; y++) {
        for (int x = 0; x < bw.width; x++) {
          final pixel = bw.getPixel(x, y);
          final luma = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b).round();
          if (luma > 128) {
            bw.setPixelRgba(x, y, 255, 255, 255, 255);
          } else {
            bw.setPixelRgba(x, y, 0, 0, 0, 255);
          }
        }
      }
      final Uint8List finalBytes = Uint8List.fromList(img.encodePng(bw));
      final impresoraGuardada = _storage.read('impresora');
      if (impresoraGuardada == null || impresoraGuardada['address'] == null) {
        Get.snackbar('Impresión', 'Selecciona una impresora en Configuración');
        return;
      }
      final String address = impresoraGuardada['address'].toString();
      final List<BluetoothDevice> bonded = await _bluetooth.getBondedDevices();
      BluetoothDevice? device;
      for (final d in bonded) {
        if (d.address == address) {
          device = d;
          break;
        }
      }
      if (device == null) {
        Get.snackbar('Impresión', 'La impresora guardada no está vinculada');
        return;
      }
      final bool? conectado = await _bluetooth.isConnected;
      if (conectado != true) {
        await _bluetooth.connect(device);
        await Future.delayed(const Duration(milliseconds: 600));
      }
      await _bluetooth.printImageBytes(finalBytes);
      Get.snackbar('Impresión', 'Imagen de prueba enviada a la impresora');
    } catch (e, st) {
      Get.snackbar('Error de impresión', e.toString());
      print('Error impresión prueba: $e\n$st');
    }
  }

  /// Imprime un PDF como imagen en la impresora Bluetooth
  Future<void> _imprimirPdfComoImagen(pw.Document pdf) async {
    try {
      // Renderiza la primera página del PDF a imagen
      final pdfBytes = await pdf.save();
      final rasterStream = Printing.raster(pdfBytes, pages: [0]);
      final raster = await rasterStream.first;
      final Uint8List imageBytes = await raster.toPng();
      if (imageBytes.isEmpty) throw Exception('No se pudo renderizar el PDF a imagen');
      // Llama a la nueva función para imprimir como TSPL BITMAP
      await imprimirImagenComoTSPL(imageBytes);
      // Si quieres mantener la opción de imprimir como imagen directa, puedes dejar la línea siguiente comentada:
      // await _bluetooth.printImageBytes(imageBytes);
      // Get.snackbar('Impresión', 'PDF impreso como imagen');
    } catch (e, st) {
      Get.snackbar('Error de impresión', e.toString());
      print('Error impresión PDF como imagen: $e\n$st');
    }
  }

  Future<void> _imprimirPdfBoletaPosDirecto() async {
    try {
      final xmlString = controlador.dteXmlString;
      if (xmlString == null || xmlString.isEmpty) {
        Get.snackbar('Impresión', 'No hay XML de boleta para generar el PDF real');
        return;
      }

      final boleta = parseBoletaXml(xmlString);
      final dir = await getTemporaryDirectory();
      final folio = (controlador.dteBoletaId ?? boleta['folio'] ?? 'BOLETA').toString();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${dir.path}/boleta_pos_${folio}_$ts.pdf';

      await BoletaPdfPosGenerator.generarPdfDesdeMapa(boleta, outputPath);

      final pdfBytes = await File(outputPath).readAsBytes();
      final rasterStream = Printing.raster(pdfBytes, pages: [0], dpi: 200);
      final raster = await rasterStream.first;
      final Uint8List imageBytes = await raster.toPng();
      if (imageBytes.isEmpty) {
        throw Exception('No se pudo renderizar el PDF real a imagen');
      }

      await imprimirImagenComoTSPL(imageBytes);
      controlador.limpiarCarrito();
      controlador.codigoBarraController.clear();
      Get.snackbar('Impresión', 'Boleta impresa desde PDF real');
      Get.offAllNamed('/inicio/cliente/caja/create_antiguo');
    } catch (e, st) {
      Get.snackbar('Error de impresión', e.toString());
      print('Error imprimiendo PDF real de boleta: $e\n$st');
    }
  }
  // Asegura que el controlador esté inicializado
  late final ClienteCajaCreateController controlador;

  @override
  void initState() {
    super.initState();
    controlador = ClienteCajaCreateController();
    controlador.cargarConfiguracionFolios();
    controlador.refrescarFoliosDisponibles();
  }
  // final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;
  // final GetStorage _storage = GetStorage();
  Map<String, dynamic>? _boletaData;
  // Función para generar el PDF de la boleta con firma SII simulada
  Future<void> _generarYMostrarBoletaPDF(BuildContext context) async {
    final pdf = pw.Document();
    // Datos reales de boleta para impresión Bluetooth
    _boletaData = {
      'folio': controlador.dteBoletaId ?? 'SIN_FOLIO',
      'rut_emisor': '76.123.456-7',
      'razon_social': 'Empresa de Ejemplo SpA',
      'total': controlador.total.value,
      'detalle': controlador.selectedProducts.map((p) => {
        'nombre': p.nombreProducto ?? '',
        'cantidad': p.cantidad ?? 1,
        'monto': int.tryParse(p.precioVenta ?? '0') != null ? (int.parse(p.precioVenta!) * (p.cantidad ?? 1)) : 0,
      }).toList(),
      'ted_dd': controlador.dteXmlString ?? '',
    };
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _imprimirBluetooth() async {
    try {
      if (_boletaData == null) {
        Get.snackbar('Impresión', 'No hay datos de boleta para imprimir');
        return;
      }
      final impresoraGuardada = _storage.read('impresora');
      if (impresoraGuardada == null || impresoraGuardada['address'] == null) {
        Get.snackbar('Impresión', 'Selecciona una impresora en Configuración');
        return;
      }
      final String address = impresoraGuardada['address'].toString();
      final List<BluetoothDevice> bonded = await _bluetooth.getBondedDevices();
      BluetoothDevice? device;
      for (final d in bonded) {
        if (d.address == address) {
          device = d;
          break;
        }
      }
      if (device == null) {
        Get.snackbar('Impresión', 'La impresora guardada no está vinculada');
        return;
      }
      final bool? conectado = await _bluetooth.isConnected;
      if (conectado != true) {
        await _bluetooth.connect(device);
        await Future.delayed(const Duration(milliseconds: 600));
      }
      final boleta = _boletaData!;
      final detalle = (boleta['detalle'] as List?) ?? [];
      await _bluetooth.printCustom('BOLETA ELECTRONICA', 2, 1);
      await _bluetooth.printCustom('Folio: ${boleta['folio'] ?? ''}', 1, 1);
      await _bluetooth.printCustom('RUT: ${boleta['rut_emisor'] ?? ''}', 1, 0);
      await _bluetooth.printCustom('${boleta['razon_social'] ?? ''}', 1, 0);
      await _bluetooth.printNewLine();
      for (final item in detalle) {
        final nombre = (item['nombre'] ?? '').toString();
        final cantidad = (item['cantidad'] ?? 1).toString();
        final monto = (item['monto'] ?? 0).toString();
        await _bluetooth.printCustom('$cantidad x $nombre', 0, 0);
        await _bluetooth.printCustom('S/ $monto', 0, 2);
      }
      await _bluetooth.printNewLine();
      await _bluetooth.printCustom('TOTAL: ${boleta['total'] ?? 0}', 2, 2);
    } catch (e, st) {
      Get.snackbar('Error de impresión', e.toString());
      print('Error impresión prueba: $e\n$st');
    }
  }

  Future<bool> _hayImpresoraDisponible({bool mostrarMensajes = true}) async {
    try {
      final impresoraGuardada = _storage.read('impresora');
      if (impresoraGuardada == null || impresoraGuardada['address'] == null) {
        if (mostrarMensajes) {
          Get.snackbar('Impresión', 'Selecciona una impresora en Configuración');
        }
        return false;
      }

      final String address = impresoraGuardada['address'].toString();
      final List<BluetoothDevice> bonded = await _bluetooth.getBondedDevices();
      BluetoothDevice? device;
      for (final d in bonded) {
        if (d.address == address) {
          device = d;
          break;
        }
      }

      if (device == null) {
        if (mostrarMensajes) {
          Get.snackbar('Impresión', 'La impresora guardada no está vinculada');
        }
        return false;
      }

      final bool? conectado = await _bluetooth.isConnected;
      if (conectado != true) {
        await _bluetooth.connect(device);
        await Future.delayed(const Duration(milliseconds: 600));
      }

      final bool? conectadoFinal = await _bluetooth.isConnected;
      if (conectadoFinal != true) {
        if (mostrarMensajes) {
          Get.snackbar('Impresión', 'No se pudo establecer conexión con la impresora');
        }
        return false;
      }

      return true;
    } catch (e) {
      if (mostrarMensajes) {
        Get.snackbar('Impresión', 'Error validando impresora: $e');
      }
      return false;
    }
  }

  Future<void> _abrirConfiguracionUmbralFolios() async {
    final TextEditingController umbralController = TextEditingController(
      text: controlador.umbralAlertaFolios.value.toString(),
    );

    final resultado = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Umbral de alerta de folios'),
        content: TextField(
          controller: umbralController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: 'Ej: 10',
            helperText: 'Rango permitido: 1 a 200',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final valor = int.tryParse(umbralController.text.trim());
              if (valor == null || valor < 1 || valor > 200) {
                Get.snackbar('Validación', 'Ingresa un umbral entre 1 y 200');
                return;
              }
              Navigator.of(context).pop(valor);
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );

    if (resultado != null) {
      await controlador.actualizarUmbralAlertaFolios(resultado);
      Get.snackbar('Folios', 'Umbral actualizado a $resultado');
    }
  }

  Widget _indicadorFolios() {
    return Obx(() {
      final int? folios = controlador.foliosDisponibles.value;
      final bool cargando = controlador.foliosConsultaEnCurso.value;
      final int umbral = controlador.umbralAlertaFolios.value;

      Color color;
      String texto;
      IconData icono;

      if (cargando) {
        color = Colors.blueGrey;
        icono = Icons.hourglass_top;
        texto = 'Folios afecta (39): consultando...';
      } else if (folios == null) {
        color = Colors.blueGrey;
        icono = Icons.help_outline;
        texto = 'Folios afecta (39): no disponible';
      } else if (folios <= 0) {
        color = Colors.red;
        icono = Icons.error_outline;
        texto = 'Folios afecta (39): agotados';
      } else if (folios <= umbral) {
        color = Colors.orange;
        icono = Icons.warning_amber_rounded;
        texto = 'Folios afecta (39): $folios (bajo)';
      } else {
        color = Colors.green;
        icono = Icons.verified_outlined;
        texto = 'Folios afecta (39): $folios';
      }

      return Container(
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icono, color: color, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '$texto · umbral: $umbral',
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              tooltip: 'Refrescar folios',
              icon: Icon(Icons.refresh, size: 18, color: color),
              onPressed: cargando
                  ? null
                  : () {
                      controlador.refrescarFoliosDisponibles(mostrarMensajes: true);
                    },
            ),
            IconButton(
              tooltip: 'Configurar umbral',
              icon: Icon(Icons.tune, size: 18, color: color),
              onPressed: _abrirConfiguracionUmbralFolios,
            ),
          ],
        ),
      );
    });
  }

  Widget _footerPagos(BuildContext context) {
    bool hayProductos = controlador.selectedProducts.isNotEmpty;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Color.fromRGBO(245, 245, 245, 1),
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Línea 1: Pagar Efectivo
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.attach_money, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                shape: StadiumBorder(),
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: hayProductos
                  ? () {
                      controlador.formaPago = 'EFECTIVO';
                      _cashBack(context);
                    }
                  : () {
                      Get.snackbar('Sin productos', 'Agrega productos antes de pagar');
                    },
              label: Text(
                'Pagar Efectivo  ·  TOTAL: \$${controlador.total.value.toStringAsFixed(0)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 6),
          // Línea 2: Pagar Débito
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.credit_card, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                shape: StadiumBorder(),
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: hayProductos
                  ? () async {
                      controlador.formaPago = 'DEBITO';
                      // TODO: Implementar flujo de pago débito
                      Get.snackbar('Débito', 'Funcionalidad en desarrollo');
                      final pdf = pw.Document();
                      pdf.addPage(
                        pw.Page(
                          build: (pw.Context context) {
                            return pw.Center(child: pw.Text('Pago Débito'));
                          },
                        ),
                      );
                      await _imprimirPdfComoImagen(pdf);
                    }
                  : () {
                      Get.snackbar('Sin productos', 'Agrega productos antes de pagar');
                    },
              label: Text(
                'Pagar Débito',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 6),
          // Línea 3: Pagar Crédito
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.credit_score, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700],
                shape: StadiumBorder(),
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: hayProductos
                  ? () {
                      controlador.formaPago = 'CREDITO';
                      // TODO: Implementar flujo de pago crédito
                      Get.snackbar('Crédito', 'Funcionalidad en desarrollo');
                    }
                  : () {
                      Get.snackbar('Sin productos', 'Agrega productos antes de pagar');
                    },
              label: Text(
                'Pagar Crédito',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _cashBack(BuildContext context) {
    double pagoLocal = controlador.pago.value;
    String? errorMsg;
    final TextEditingController pagoController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        double total = controlador.total.value;
        double cambio = pagoLocal - total;
        return StatefulBuilder(
          builder: (context, setState) {
            bool falta = pagoLocal < total;
            final media = MediaQuery.of(context);
            final double maxDialogContentHeight =
                (media.size.height - media.viewInsets.bottom - 180)
                    .clamp(220.0, media.size.height * 0.9)
                    .toDouble();
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Center(
                child: Text('Venta al contado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxDialogContentHeight),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    // Input con icono y limpiar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.attach_money, color: Colors.grey[700]),
                          ),
                          Expanded(
                            child: TextField(
                              controller: pagoController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '¿Con cuánto paga?',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  pagoLocal = double.tryParse(value) ?? 0.0;
                                  cambio = pagoLocal - total;
                                  errorMsg = null;
                                });
                              },
                            ),
                          ),
                          if ((pagoController.text.isNotEmpty))
                            IconButton(
                              icon: Icon(Icons.clear, size: 20),
                              onPressed: () {
                                pagoController.clear();
                                setState(() {
                                  pagoLocal = 0.0;
                                  cambio = -total;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18),
                    // Resumen de montos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total:', style: TextStyle(fontSize: 16)),
                        Text('${total.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pago:', style: TextStyle(fontSize: 16)),
                        Text('${pagoLocal.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                      ],
                    ),
                    if (falta)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Falta:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)),
                          Text('₲${(total - pagoLocal).toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 18)),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Cambio:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700], fontSize: 16)),
                          Text('₲${(cambio).toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700], fontSize: 18)),
                        ],
                      ),
                    if (errorMsg != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorMsg!,
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    SizedBox(height: 18),
                    // Botón Emitir Boleta
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.receipt_long, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          final parentContext = this.context;

                          if (controlador.isLoading.value) {
                            return;
                          }

                          if (pagoLocal < total) {
                            setState(() {
                              errorMsg = 'El monto recibido debe ser mayor o igual al total.';
                            });
                            return;
                          }

                          final errorValidacion = controlador.validarVentaAntesDeEmitir(
                            montoRecibido: pagoLocal,
                          );
                          if (errorValidacion != null) {
                            setState(() {
                              errorMsg = errorValidacion;
                            });
                            return;
                          }

                          await controlador.emitirBoletaSii(context: parentContext);
                          if ((controlador.dteXmlString ?? '').isNotEmpty) {
                            // --- Asignar datos de boleta para impresión ---
                            _boletaData = {
                              'folio': controlador.dteBoletaId ?? 'SIN_FOLIO',
                              'rut_emisor': '76.123.456-7',
                              'razon_social': 'Empresa de Ejemplo SpA',
                              'total': controlador.total.value is int ? controlador.total.value : (controlador.total.value as num).round(),
                              'detalle': controlador.selectedProducts.map((p) => {
                                'nombre': p.nombreProducto ?? '',
                                'cantidad': p.cantidad is int ? p.cantidad : (p.cantidad ?? 1).round(),
                                'monto': int.tryParse(p.precioVenta ?? '0') != null ? (int.parse(p.precioVenta!) * ((p.cantidad is int ? p.cantidad : (p.cantidad ?? 1).round()) as int)) : 0,
                                'punit': p.precioVenta ?? '0',
                              }).toList(),
                              'ted_dd': controlador.dteXmlString ?? '',
                            };
                            Navigator.of(context).pop();

                            final impresoraDisponible = await _hayImpresoraDisponible(
                              mostrarMensajes: false,
                            );
                            if (!mounted) return;

                            final opcion = await showDialog<String>(
                              context: parentContext,
                              builder: (dialogContext) => AlertDialog(
                                title: Text('¿Qué desea hacer?'),
                                content: Text(
                                  impresoraDisponible
                                      ? '¿Ver PDF de la boleta o imprimir por Bluetooth?'
                                      : 'No hay una impresora Bluetooth disponible. Puedes ver el PDF y configurar la impresora desde el botón Bluetooth.',
                                ),
                                actions: [
                                  if (!impresoraDisponible)
                                    TextButton(
                                      onPressed: () => Navigator.of(dialogContext).pop('configurar_impresora'),
                                      child: Text('Configurar impresora'),
                                    ),
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop('pdf'),
                                    child: Text('Ver PDF'),
                                  ),
                                  if (impresoraDisponible)
                                    TextButton(
                                      onPressed: () => Navigator.of(dialogContext).pop('imprimir'),
                                      child: Text('Imprimir'),
                                    ),
                                ],
                              ),
                            );
                            if (opcion == 'pdf') {
                              await Get.toNamed('/boleta_pdf_pos', arguments: {
                                'folio': controlador.dteBoletaId ?? 'SIN_FOLIO',
                                'xml_string': controlador.dteXmlString ?? '',
                              });
                              controlador.limpiarCarrito();
                              controlador.codigoBarraController.clear();
                            } else if (opcion == 'configurar_impresora') {
                              await Navigator.of(parentContext).push(
                                MaterialPageRoute(
                                  builder: (context) => ImpresorasPage(),
                                ),
                              );
                            } else if (opcion == 'imprimir') {
                              await _imprimirPdfBoletaPosDirecto();
                            }
                          }
                        },
                        label: Text('Emitir Boleta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Botón Volver
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.arrow_back, color: Colors.black87),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          side: BorderSide(color: Colors.grey[400]!),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        label: Text('Volver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      ),
                    ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Widget cashBack(){
  Widget _cardProduct(Producto product) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          SizedBox(width: 5),
          Container(
            width: MediaQuery.of(context).size.height * 0.14,
            child: Text(product.nombreProducto!.length > 30
                ? product.nombreProducto!.substring(0,30)
                : product.nombreProducto ?? '' ,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Spacer(),

          Container(width: MediaQuery.of(context).size.height * 0.12, child: _buttonsAddOrRemove(product)),
          Spacer(),

          Container(width: MediaQuery.of(context).size.height * 0.05, child: Text(product.precioVenta ?? '', style: TextStyle(fontWeight: FontWeight.bold))),
          Spacer(),

          Container(width: MediaQuery.of(context).size.height * 0.05, child: _textPrice(product)),
          Spacer(),

          Container(width: MediaQuery.of(context).size.height * 0.04, child: _iconDelete(product))
        ],
      ),
    );
  }

  Widget _iconDelete(Producto product) {
    return IconButton(
        onPressed: () {
          setState(() {
            controlador.deleteItem(product);
          });
        },
        icon: Icon(
          Icons.delete,
          color: Colors.red,
        )
    );
  }

  Widget _iconScan() {
    return Container(
      margin: EdgeInsets.only(left: 5, right: 5),
      child: IconButton(
        onPressed: () async {
          String? barcode = await _scanBarcodeMobileScanner(context);
          if (barcode != null && barcode.isNotEmpty) {
            await controlador.scanBarcodeMobileScanner(
              barcode,
              context,
              (codigo) async {
                await controlador.showProductoNoExisteDialog(context, codigo);
              },
            );
          }
        },
        icon: Container(
          child: Icon(
            Icons.qr_code_scanner,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  /// Escaneo real usando MobileScanner
  Future<String?> _scanBarcodeMobileScanner(BuildContext context) async {
    String? scannedCode;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text('Escanear código de barras'),
            actions: [
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
          body: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                scannedCode = barcodes.first.rawValue;
                Navigator.of(context).pop();
              }
            },
          ),
        );
      },
    );
    return scannedCode;
  }



  Widget _iconSearch(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 5, right: 5),
      child: IconButton(
        onPressed: () async {
          final Producto? result = await showSearch<Producto>(
            context: context,
            delegate: ClienteCajaSearchPage(controlador.productos),
          );
          if (result != null && result.nombreProducto != null && result.nombreProducto!.isNotEmpty) {
            setState(() {
              controlador.addItem(result);
            });
            FocusScope.of(context).unfocus(); // Cierra el teclado automáticamente
          }
        },
        icon: Icon(
          Icons.search,
          color: Colors.black,
          size: 20,
        ),
      ),
    );
  }

  Widget _textPrice(Producto product) {
    return Text(
      '${int.parse(product.precioVenta!) * product.cantidad!}',
      style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold
      ),
    );
  }

  Widget _buttonsAddOrRemove(Producto product) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => controlador.removeItem(product),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Text('-', style: TextStyle(fontSize: 15)),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          color: Colors.grey[200],
          child: Text('${product.cantidad ?? 0}', style: TextStyle(fontSize: 15)),
        ),
        GestureDetector(
          onTap: () => controlador.addItem(product),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Text('+', style: TextStyle(fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _campoCodigoBarra(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8, top: 5, right: 8),
      child: SizedBox(
        width: 340.0,
        height: 44.0,
        child: TextField(
          controller: controlador.codigoBarraController,
          keyboardType: TextInputType.text,
          style: TextStyle(fontSize: 18),
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Código de barra',
              suffixIcon: IconButton(
                onPressed: () async {
                  await controlador.code(context);
                  setState(() {
                    controlador.codigoBarraController.clear();
                  });
                  FocusScope.of(context).unfocus(); // Oculta el teclado
                },
                icon: Icon(Icons.search),
              ),
              hintStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.black
              ),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color: Colors.grey
                  )
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color: Colors.grey
                  )
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)
          ),
        ),
      ),
    );
  }
}
