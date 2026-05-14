import 'dart:typed_data';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import '../../../utils/boleta_pdf_pos.dart';
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
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments == null) {
      setState(() { _loading = false; });
      return;
    }
    try {
      final dir = await getTemporaryDirectory();
      final folio = arguments['folio'] ?? 'BOLETA';
      final outputPath = '${dir.path}/boleta_dte_$folio.pdf';
      // Si viene XML string, usar el parser para extraer los datos correctos
      final boleta = arguments['xml_string'] != null
          ? parseBoletaXml(arguments['xml_string'])
          : arguments;
      print('DEBUG boleta_pdf_pos_page.dart: boleta =');
      print(boleta);
      await BoletaPdfPosGenerator.generarPdfDesdeMapa(boleta, outputPath);
      setState(() {
        _pdfPath = outputPath;
        _pdfController = PdfController(
          document: PdfDocument.openFile(outputPath),
        );
        _loading = false;
      });
    } catch (e) {
      print('❌ Error generando PDF: $e');
      setState(() { _loading = false; });
      Get.snackbar(
        '❌ Error',
        'No se pudo generar el PDF: $e',
        duration: Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Boleta PDF POS')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pdfPath == null
              ? const Center(child: Text('No se pudo generar el PDF'))
              : PdfView(controller: _pdfController!),
      floatingActionButton: _loading || _pdfPath == null
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.print),
              label: const Text('Imprimir boleta'),
              onPressed: _imprimirBoletaBluetooth,
            ),
    );

  }

  Future<void> _imprimirBoletaBluetooth() async {
    if (_pdfPath == null) return;
    try {
      // Renderizar la primera página del PDF a imagen
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
      // Enviar imagen a la impresora Bluetooth
      final isConnected = await bluetooth.isConnected ?? false;
      if (!isConnected) {
        Get.snackbar('Bluetooth', 'Conecte la impresora antes de imprimir');
        return;
      }
      await bluetooth.printImageBytes(imageBytes);
      Get.snackbar('Impresión', 'Boleta enviada a la impresora');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo imprimir: $e');
    }
  }
}
