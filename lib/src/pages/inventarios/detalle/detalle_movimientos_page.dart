import 'package:flutter/material.dart';
import 'package:posmobilfinal/src/models/producto.dart';
import 'package:posmobilfinal/src/models/inventario.dart';
import 'package:posmobilfinal/src/providers/inventario_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'dart:core';
import 'dart:async';

class DetalleMovimientosPage extends StatefulWidget {
  final Producto producto;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;
  const DetalleMovimientosPage({
    super.key,
    required this.producto,
    this.fechaDesde,
    this.fechaHasta,
  });

  @override
  @override
  @override
  @override
  @override
  State<DetalleMovimientosPage> createState() => _DetalleMovimientosPageState();
}

class _DetalleMovimientosPageState extends State<DetalleMovimientosPage> {
  Future<Uint8List> _generarPdfDetalle(
    PdfPageFormat format,
    List<Inventario> movimientos,
    Producto producto,
    int stockFinal,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        build: (context) => [
          pw.Text(
            'Detalle de Movimientos',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Producto: \\${producto.nombreProducto ?? producto.id ?? ''}',
            style: pw.TextStyle(fontSize: 16),
          ),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: ['Fecha', 'N° Doc', 'Cantidad'],
            data: movimientos
                .map(
                  (m) => [
                    m.fecha ?? '',
                    m.nroDocumento?.toString() ?? '',
                    m.cantidad?.toString() ?? '',
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                'Stock final: ',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              pw.Text(
                stockFinal.toString(),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 16,
                  color: PdfColors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return pdf.save();
  }

  late Future<List<Inventario>> movimientosFuture;

  @override
  @override
  @override
  @override
  @override
  void initState() {
    super.initState();
    movimientosFuture = _cargarMovimientos();
  }

  Future<List<Inventario>> _cargarMovimientos() async {
    final provider = InventarioProvider();
    final movimientos = await provider.getMovimientosPorProducto(
      widget.producto.id ?? widget.producto.codigoBarra ?? '',
    );
    if (widget.fechaDesde != null || widget.fechaHasta != null) {
      return movimientos.where((m) {
        if (m.fecha == null) return false;
        final fechaMov = DateTime.tryParse(m.fecha!);
        if (fechaMov == null) return false;
        if (widget.fechaDesde != null && fechaMov.isBefore(widget.fechaDesde!))
          return false;
        if (widget.fechaHasta != null && fechaMov.isAfter(widget.fechaHasta!))
          return false;
        return true;
      }).toList();
    }
    return movimientos;
  }

  @override
  @override
  @override
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Movimientos de ${widget.producto.nombreProducto ?? widget.producto.id ?? ''}',
        ),
      ),
      body: FutureBuilder<List<Inventario>>(
        future: movimientosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar movimientos'));
          }
          final movimientos = snapshot.data ?? [];
          if (movimientos.isEmpty) {
            return Center(child: Text('No hay movimientos para este producto'));
          }
          final stockFinal = movimientos.fold<int>(
            0,
            (sum, mov) => sum + (mov.cantidad ?? 0),
          );
          return ListView.separated(
            itemCount: movimientos.length + 1,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, index) {
              if (index < movimientos.length) {
                final mov = movimientos[index];
                return ListTile(
                  title: Row(
                    children: [
                      Text(
                        'Fecha: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        mov.fecha != null && mov.fecha!.length >= 10
                            ? mov.fecha!.substring(0, 10)
                            : (mov.fecha ?? ''),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Doc: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        mov.nroDocumento != null
                            ? mov.nroDocumento.toString()
                            : '-',
                        style: TextStyle(fontSize: 13, color: Colors.black),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Cant: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        mov.cantidad != null ? mov.cantidad.toString() : '-',
                        style: TextStyle(fontSize: 13, color: Colors.blue),
                      ),
                    ],
                  ),
                );
              } else {
                // Última fila: stock final
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 20.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Stock final: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        stockFinal.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FutureBuilder<List<Inventario>>(
        future: movimientosFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true))
            return SizedBox.shrink();
          final movimientos = snapshot.data!;
          return FloatingActionButton(
            tooltip: 'Exportar a PDF',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: SizedBox(
                    width: 400,
                    height: 600,
                    child: PdfPreview(
                      build: (format) => _generarPdfDetalle(
                        format,
                        movimientos,
                        widget.producto,
                        movimientos.fold<int>(
                          0,
                          (sum, mov) => sum + (mov.cantidad ?? 0),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            child: Icon(Icons.picture_as_pdf),
          );
        },
      ),
    );
  }
}
