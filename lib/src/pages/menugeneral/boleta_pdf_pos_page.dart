import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import '../../../utils/boleta_pdf_pos.dart';
import 'package:get/get.dart';

class BoletaPdfPosPage extends StatefulWidget {
  const BoletaPdfPosPage({super.key});

  @override
  State<BoletaPdfPosPage> createState() => _BoletaPdfPosPageState();
}

class _BoletaPdfPosPageState extends State<BoletaPdfPosPage> {
  PdfController? _pdfController;
  String? _pdfPath;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _generarPdfYMostrar();
  }

  Future<void> _generarPdfYMostrar() async {
    final boleta = Get.arguments as Map<String, dynamic>?;
    if (boleta == null) {
      setState(() { _loading = false; });
      return;
    }
    final dir = await getTemporaryDirectory();
    final outputPath = '${dir.path}/boleta_pos_demo.pdf';
    await BoletaPdfPosGenerator.generarPdfDesdeMapa(boleta, outputPath);
    setState(() {
      _pdfPath = outputPath;
      _pdfController = PdfController(document: PdfDocument.openFile(outputPath));
      _loading = false;
    });
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
    );
  }
}
