
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:posmobilfinal/src/pages/informes/pdf/pdf_export_page.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:posmobilfinal/src/models/boleta.dart';
import 'package:posmobilfinal/src/providers/boletas_provider.dart';

class InformesDetalleVentaPage extends StatefulWidget {
  const InformesDetalleVentaPage({super.key});

  @override
  State<InformesDetalleVentaPage> createState() => _InformesDetalleVentaPageState();
}

class _InformesDetalleVentaPageState extends State<InformesDetalleVentaPage> {
  final List<Boleta> boletasFiltradas = [];
  final BoletasProvider boletasProvider = BoletasProvider();
  bool cargando = false;
  DateTime? fechaInicial;
  DateTime? fechaFinal;

  double get totalVentas {
    double total = 0;
    for (var b in boletasFiltradas) {
      total += double.tryParse(b.valor ?? '0') ?? 0;
    }
    return total;
  }

  String _formatearFecha(DateTime fecha) {
    return "${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
  }

  String _formatearFechaVisual(String? fecha) {
    if (fecha == null || fecha.length < 10) return '';
    final partes = fecha.substring(0, 10).split('-');
    if (partes.length != 3) return fecha;
    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  Future<void> seleccionarFechaInicial() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaInicial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        fechaInicial = picked;
      });
    }
  }

  Future<void> seleccionarFechaFinal() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaFinal ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        fechaFinal = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    filtrarVentas();
  }

  Future<void> filtrarVentas() async {
    setState(() {
      cargando = true;
    });
    boletasFiltradas.clear();
    try {
      // Si no hay fechas, trae todo, si hay fechas, filtra
      if (fechaInicial != null && fechaFinal != null) {
        final ventas = await boletasProvider.getTrimedDateArray(
          _formatearFecha(fechaInicial!),
          _formatearFecha(fechaFinal!)
        );
        boletasFiltradas.addAll(ventas);
      } else {
        final ventas = await boletasProvider.getAllByUser();
        boletasFiltradas.addAll(ventas);
      }
    } catch (e) {
      // Manejo simple de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar ventas: $e')),
      );
    }
    setState(() {
      cargando = false;
    });
  }

  Future<void> exportarListadoPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          final desde = fechaInicial != null ? _formatearFecha(fechaInicial!) : '-';
          final hasta = fechaFinal != null ? _formatearFecha(fechaFinal!) : '-';
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Informe de Ventas', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Desde: $desde  Hasta: $hasta'),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('N°', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Fecha', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Valor', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...boletasFiltradas.map((b) => pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(b.numero ?? '')),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(_formatearFechaVisual(b.fecha))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(b.valor ?? '')),
                    ],
                  ))
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Total ventas: ${totalVentas.toStringAsFixed(0)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/informe_ventas.pdf");
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF generado en: ${file.path}')),
    );
  }

  Future<void> exportarDetalleBoletaPDF(Boleta boleta) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Detalle de Venta', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('N°: ${boleta.numero ?? ''}'),
              pw.Text('Fecha: ${_formatearFechaVisual(boleta.fecha)}'),
              pw.Text('Valor: ${boleta.valor ?? ''}'),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Producto', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Cantidad', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...?boleta.detalle?.map((detalle) => pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(detalle.nombreProducto ?? '')),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(detalle.cantidad ?? '')),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(detalle.totalLinea?.toString() ?? '')),
                    ],
                  ))
                ],
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/detalle_boleta_${boleta.numero ?? 'venta'}.pdf");
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF generado en: ${file.path}')),
    );
  }

  void mostrarDetalleBoleta(Boleta boleta) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalle productos venta #${boleta.numero ?? ''}'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: boleta.detalle == null || boleta.detalle!.isEmpty
                ? const Text('Sin productos en esta venta')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text('Producto', style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 8),
                          Text('Cant.', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Divider(),
                      ...boleta.detalle!.map((detalle) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                Expanded(child: Text(detalle.nombreProducto ?? '')),
                                SizedBox(width: 8),
                                Text(detalle.cantidad ?? ''),
                                SizedBox(width: 8),
                                Text(detalle.totalLinea?.toString() ?? ''),
                              ],
                            ),
                          )),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PdfExportPage(
                                boletas: [boleta],
                                total: double.tryParse(boleta.valor ?? '0')?.toInt() ?? 0,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Exportar PDF'),
                      ),
                    ],
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VENTAS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: seleccionarFechaInicial,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Fecha inicial',
                          hintText: 'Selecciona fecha',
                        ),
                        controller: TextEditingController(
                          text: fechaInicial == null ? '' : _formatearFecha(fechaInicial!),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: seleccionarFechaFinal,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Fecha final',
                          hintText: 'Selecciona fecha',
                        ),
                        controller: TextEditingController(
                          text: fechaFinal == null ? '' : _formatearFecha(fechaFinal!),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: (fechaInicial != null && fechaFinal != null && !cargando)
                      ? filtrarVentas
                      : null,
                  child: cargando ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Filtrar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: cargando
                  ? const Center(child: CircularProgressIndicator())
                  : boletasFiltradas.isEmpty
                      ? const Center(child: Text('No hay ventas para mostrar'))
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: boletasFiltradas.length + 1,
                                itemBuilder: (context, index) {
                                  if (index < boletasFiltradas.length) {
                                    final boleta = boletasFiltradas[index];
                                    return ListTile(
                                      dense: true,
                                      visualDensity: VisualDensity.compact,
                                      title: Text('#${boleta.numero ?? ''}   ${_formatearFechaVisual(boleta.fecha)}   ${boleta.valor ?? ''}'),
                                      onTap: () => mostrarDetalleBoleta(boleta),
                                    );
                                  } else {
                                    // Último item: total
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          'Total ventas: ${totalVentas.toStringAsFixed(0)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: boletasFiltradas.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PdfExportPage(
                      boletas: boletasFiltradas,
                      total: totalVentas.toInt(),
                    ),
                  ),
                );
              },
              icon: Icon(Icons.picture_as_pdf),
              label: Text('Exportar PDF'),
            )
          : null,
    );
  }
}

// ...existing code...