import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:posmobilfinal/src/models/detalle.dart';

class PdfEstadisticasVentasPage extends StatefulWidget {
  final List<DetalleBoleta> detalles;
  final int total;
  final String? filtroProducto;
  final DateTime? fechaInicial;
  final DateTime? fechaFinal;

  const PdfEstadisticasVentasPage({
    Key? key,
    required this.detalles,
    required this.total,
    this.filtroProducto,
    this.fechaInicial,
    this.fechaFinal,
  }) : super(key: key);

  @override
  State<PdfEstadisticasVentasPage> createState() => _PdfEstadisticasVentasPageState();
}

class _PdfEstadisticasVentasPageState extends State<PdfEstadisticasVentasPage> {
  Uint8List? archivoPdf;

  @override
  void initState() {
    super.initState();
    _initPDF();
  }

  Future<void> _initPDF() async {
    final pdfData = await _generarPdf();
    setState(() {
      archivoPdf = pdfData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Estadísticas Ventas'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.black,
        elevation: 1,
      ),
      body: SafeArea(
        child: archivoPdf == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 600,
                      width: double.maxFinite,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 25,
                        ),
                        child: PdfPreview(
                          build: (format) => archivoPdf!,
                          useActions: false,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              archivoPdf = await _generarPdf();
                              setState(() {
                                archivoPdf = archivoPdf;
                              });
                            },
                            child: const Icon(
                              Icons.picture_as_pdf,
                              size: 45,
                              color: Colors.red,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await Printing.sharePdf(
                                bytes: archivoPdf!,
                                filename: 'Estadisticas_ventas.pdf',
                              );
                            },
                            child: const Icon(
                              Icons.share,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<Uint8List> _generarPdf() async {
    final pdf = pw.Document();
    final headers = ['Producto', 'Código', 'Cantidad'];

    // Agrupar por producto y sumar cantidades
    final Map<String, Map<String, dynamic>> agrupados = {};
    for (var detalle in widget.detalles) {
      final codigo = detalle.idProducto ?? '-';
      final nombre = detalle.nombreProducto ?? codigo;
      final cantidad = int.tryParse(detalle.cantidad ?? '0') ?? 0;
      if (!agrupados.containsKey(codigo)) {
        agrupados[codigo] = {
          'nombre': nombre,
          'codigo': codigo,
          'cantidad': 0,
        };
      }
      agrupados[codigo]!['cantidad'] += cantidad;
    }
    final data = agrupados.values
        .map((e) => [e['nombre'], e['codigo'], e['cantidad'].toString()])
        .toList();

    final now = DateTime.now();
    final fechaHora =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}  ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a5,
        margin: pw.EdgeInsets.zero,
        build: (context) => [
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(vertical: 20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'Estadísticas de Ventas',
                  style: pw.TextStyle(fontSize: 25, color: PdfColors.black),
                  textAlign: pw.TextAlign.center,
                ),
                if (widget.filtroProducto != null && widget.filtroProducto!.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Filtro producto: ${widget.filtroProducto}',
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.blueGrey800),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
                if (widget.fechaInicial != null && widget.fechaFinal != null) ...[
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Periodo: ${widget.fechaInicial!.toString().substring(0, 10)} - ${widget.fechaFinal!.toString().substring(0, 10)}',
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.blueGrey800),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
                pw.SizedBox(height: 8),
                pw.Text(
                  'Emitido: $fechaHora',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: pw.Table.fromTextArray(headers: headers, data: data),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Total productos vendidos: ${widget.total}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
    return pdf.save();
  }
}
