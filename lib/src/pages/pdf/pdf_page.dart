import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:posmobil/src/models/boleta.dart';
import 'package:posmobil/src/models/detalle.dart';

class PdfExportPage extends StatefulWidget {
  final List<Boleta> boletas;
  final int total;

  const PdfExportPage({Key? key, required this.boletas, required this.total}) : super(key: key);

  @override
  State<PdfExportPage> createState() => _PdfExportPageState();
}

class _PdfExportPageState extends State<PdfExportPage> {
  late List<DetalleBoleta> detalles;
  late int total;
  Uint8List? archivoPdf;

  @override
  void initState() {
    super.initState();
    total = widget.total;
    detalles = _getDetalles(widget.boletas);
    _generatePdf();
  }

  List<DetalleBoleta> _getDetalles(List<Boleta> boletas) {
    final detalles = <DetalleBoleta>[];
    for (var boleta in boletas) {
      if (boleta.detalle != null) {
        detalles.addAll(boleta.detalle!);
      }
    }
    return detalles;
  }

  String numberFormat(int x) {
    final parts = x.toString().split('.');
    final re = RegExp(r'\B(?=(\d{3})+(?!\d))');
    parts[0] = parts[0].replaceAll(re, '.');
    return parts.join(',');
  }

  Future<void> _generatePdf() async {
    archivoPdf = await _buildPdf();
    setState(() {});
  }

  Future<Uint8List> _buildPdf({bool withDetails = false}) async {
    final pdf = pw.Document();
    final headers = ['Boleta', 'Fecha', 'Valor', 'Metodo'];
    final data = widget.boletas.map((b) => [
      b.id ?? '',
      b.fecha ?? '',
      b.valor ?? '',
      b.formaPago ?? ''
    ]).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a5,
        margin: pw.EdgeInsets.zero,
        build: (context) => [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 20),
            child: pw.Center(
              child: pw.Text(
                'Informe de Ventas por Fecha',
                style: pw.TextStyle(fontSize: 25, color: PdfColors.black),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: pw.Table.fromTextArray(headers: headers, data: data),
          ),
          if (withDetails && detalles.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: pw.Table.fromTextArray(
                headers: ['Boleta', 'Producto', 'Precio', 'Cantidad', 'Total'],
                data: detalles.map((d) => [
                  d.id ?? '',
                  d.nombreProducto ?? '',
                  d.valorLinea ?? '',
                  d.cantidad ?? '',
                  d.totalLinea ?? ''
                ]).toList(),
              ),
            ),
          pw.SizedBox(height: 20),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: pw.Text('Total del informe \$${numberFormat(total)}'),
          ),
        ],
      ),
    );
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 600,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                  child: archivoPdf == null
                      ? const Center(child: CircularProgressIndicator())
                      : PdfPreview(
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
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf, size: 45, color: Colors.red),
                      onPressed: () async {
                        archivoPdf = await _buildPdf(withDetails: true);
                        setState(() {});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf, size: 45, color: Colors.green),
                      onPressed: () async {
                        archivoPdf = await _buildPdf(withDetails: false);
                        setState(() {});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.grey, size: 40),
                      onPressed: archivoPdf == null
                          ? null
                          : () async {
                              await Printing.sharePdf(
                                bytes: archivoPdf!,
                                filename: 'Informe_de_ventas.pdf',
                              );
                            },
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
}