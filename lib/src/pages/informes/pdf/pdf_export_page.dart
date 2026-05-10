import 'dart:typed_data'; // <-- Importación necesaria
import 'package:flutter/material.dart';
import 'package:posmobilfinal/src/models/boleta.dart';
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
        build: (context) {
          final widgets = <pw.Widget>[];
          widgets.add(pw.Text('Informe de Ventas', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)));
          widgets.add(pw.SizedBox(height: 16));
          widgets.add(pw.Text('Total: \$ $total', style: pw.TextStyle(fontSize: 18)));
          widgets.add(pw.SizedBox(height: 16));
          widgets.add(
            pw.Table.fromTextArray(
              headers: ['N°', 'Fecha', 'Valor', 'Método'],
              data: boletas.map((b) => [
                b.id?.toString() ?? '',
                b.fecha?.substring(0, 10) ?? '',
                b.valor?.toString() ?? '',
                b.formaPago ?? '',
              ]).toList(),
            ),
          );
          // Agregar detalle de productos por cada boleta
          for (final b in boletas) {
            if (b.detalle != null && b.detalle!.isNotEmpty) {
              widgets.add(pw.SizedBox(height: 20));
              widgets.add(pw.Text('Detalle de productos de la venta N°: \'${b.numero ?? b.id ?? ''}\'', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)));
              widgets.add(pw.SizedBox(height: 8));
              widgets.add(
                pw.Table.fromTextArray(
                  headers: ['Producto', 'Cantidad', 'Total'],
                  data: b.detalle!.map((d) => [
                    d.nombreProducto ?? '',
                    d.cantidad ?? '',
                    d.totalLinea?.toString() ?? '',
                  ]).toList(),
                ),
              );
            }
          }
          return widgets;
        },
      ),
    );

    return Uint8List.fromList(await pdf.save()); // <-- Conversión necesaria
  }
}