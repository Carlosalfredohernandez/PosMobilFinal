import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import '../../../utils/boleta_pdf_pos.dart';
import 'package:posmobilfinal/utils/tspl_utils.dart';
import 'package:get/get.dart';
import '../../../utils/boleta_xml_parser.dart';
class BoletaPdfPosPage extends StatefulWidget {
  const BoletaPdfPosPage({super.key});

  @override
  State<BoletaPdfPosPage> createState() => _BoletaPdfPosPageState();
}

class _BoletaPdfPosPageState extends State<BoletaPdfPosPage> {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  PdfController? _pdfController;
  String? _pdfPath;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _generarPdfYMostrar();
  }

  Future<void> _generarPdfYMostrar() async {
    print('[PDF] Iniciando generación de PDF...');
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments == null) {
      print('[PDF] Error: No se recibieron argumentos');
      setState(() { _loading = false; });
      Get.snackbar('Error', 'No se recibieron argumentos para generar el PDF');
      return;
    }
    try {
      final dir = await getTemporaryDirectory();
      final folio = arguments['folio'] ?? 'BOLETA';
      final outputPath = '${dir.path}/boleta_dte_$folio.pdf';
      final boleta = arguments['xml_string'] != null
          ? parseBoletaXml(arguments['xml_string'])
          : arguments;
      print('[PDF] Generando PDF en: $outputPath');
      await BoletaPdfPosGenerator.generarPdfDesdeMapa(boleta, outputPath);
      final pdfFile = File(outputPath);
      final exists = await pdfFile.exists();
      final size = exists ? await pdfFile.length() : 0;
      print('[PDF] Archivo generado: existe=$exists, tamaño=$size bytes');
      if (!exists || size < 100) {
        print('[PDF] Error: El PDF generado está vacío o corrupto');
        setState(() { _loading = false; });
        Get.snackbar('Error', 'El PDF generado está vacío o corrupto');
        return;
      }
      try {
        final controller = PdfController(
          document: PdfDocument.openFile(outputPath),
        );
        setState(() {
          _pdfPath = outputPath;
          _pdfController = controller;
          _loading = false;
        });
        print('[PDF] PDF listo y controlador inicializado');
      } catch (e) {
        print('[PDF] Error al abrir el PDF: $e');
        setState(() { _loading = false; });
        Get.snackbar('Error', 'No se pudo abrir el PDF: $e');
      }
    } catch (e) {
      print('[PDF] Error inesperado: $e');
      setState(() { _loading = false; });
      Get.snackbar('Error', 'No se pudo generar el PDF: $e');
    }
  }

  Future<void> _imprimirBoletaBluetooth() async {
    if (_pdfPath == null) return;
    try {
      final pdfBytes = await File(_pdfPath!).readAsBytes();
      final pages = await Printing.raster(pdfBytes, pages: [0], dpi: 200);
      Uint8List? imageBytes;
      await for (final page in pages) {
        imageBytes = await page.toPng();
        break;
      }
      if (imageBytes == null) {
        Get.snackbar('Error', 'No se pudo renderizar la imagen del PDF');
        return;
      }
      final img.Image? originalImg = img.decodeImage(imageBytes);
      if (originalImg == null) {
        Get.snackbar('Error', 'No se pudo decodificar la imagen generada del PDF');
        return;
      }
      img.Image resizedImg = originalImg;
      if (originalImg.width != 384) {
        resizedImg = img.copyResize(originalImg, width: 384);
      }
      final resizedBytes = img.encodePng(resizedImg);
      await imprimirImagenComoTSPL(resizedBytes);
      Get.offAllNamed('/cliente/caja/create');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo imprimir: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Boleta PDF POS')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_pdfPath == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Boleta PDF POS')),
        body: const Center(child: Text('No se pudo generar el PDF')),
      );
    }
    if (_pdfController == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Boleta PDF POS')),
        body: const Center(child: Text('No se pudo abrir el PDF')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Boleta PDF POS')),
      body: PdfView(controller: _pdfController!),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.print),
        label: const Text('Imprimir boleta'),
        onPressed: _imprimirBoletaBluetooth,
      ),
    );
  }
}
