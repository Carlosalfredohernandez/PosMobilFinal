import 'dart:typed_data'; // <-- Importación necesaria
import 'package:flutter/material.dart';
import 'package:posmobil/src/models/boleta.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExportPage extends StatelessWidget {
  final List<Boleta> boletas;
  final int total;

  const PdfExportPage({super.key, required this.boletas, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar PDF'),
        centerTitle: true,
      ),
      body: PdfPreview(
        build: (format) async => await _generatePdf(format, boletas, total),
      ),
    );
  }

  Future<Uint8List> _generatePdf(
    PdfPageFormat format,
    List<Boleta> boletas,
    int total,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        build: (context) => [
          pw.Text('Informe de Ventas', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.Text('Total: \$ $total', style: pw.TextStyle(fontSize: 18)),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: ['N°', 'Fecha', 'Valor', 'Método'],
            data: boletas.map((b) => [
              b.id?.toString() ?? '',
              b.fecha?.substring(0, 10) ?? '',
              b.valor?.toString() ?? '',
              b.formaPago ?? '',
            ]).toList(),
          ),
        ],
      ),
    );

    return Uint8List.fromList(await pdf.save()); // <-- Conversión necesaria
  }
}