import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/models/detalle.dart';
import 'package:posmobil/src/pages/informes/estadisticas/estadisticas_ventas_controller.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class EstadisticasVentasPage extends StatelessWidget {
  EstadisticasVentasPage({super.key});

  final EstadisticasVentasController controlador = Get.put(EstadisticasVentasController());
  final TextEditingController codigoBarraController = TextEditingController();
  final TextEditingController productoBusquedaController = TextEditingController();

  Future<DateTime?> _selectDate(BuildContext context, DateTime? initialDate) {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      lastDate: DateTime.now(),
      firstDate: DateTime(2022),
      builder: (context, child) {
        return Theme(data: ThemeData.dark(), child: child!);
      },
    );
  }

  void _filtrarInventario() {
    controlador.filtrarInventario(codigoBarraController.text.trim());
  }

  Future<void> _escanearCodigoBarra(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Escanear código de barra'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: MobileScanner(
              onDetect: (BarcodeCapture capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final String? code = barcodes.first.rawValue;
                  if (code != null && code.isNotEmpty) {
                    codigoBarraController.text = code;
                    Navigator.of(context).pop();
                    _filtrarInventario();
                  }
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  // Agrupa productos por idProducto y suma cantidades
  List<Map<String, dynamic>> agruparPorProducto(List<DetalleBoleta> detalles) {
    final Map<String, int> agrupados = {};
    final Map<String, String> nombres = {};

    for (var det in detalles) {
      String codigo = det.idProducto ?? '-';
      String nombre = det.nombreProducto ?? codigo;
      int cantidad = int.tryParse(det.cantidad ?? '0') ?? 0;
      agrupados[codigo] = (agrupados[codigo] ?? 0) + cantidad;
      nombres[codigo] = nombre;
    }

    return agrupados.entries.map((e) => {
      'codigo': e.key,
      'nombre': nombres[e.key] ?? e.key,
      'cantidad': e.value,
    }).toList();
  }

  Future<void> _exportarPDF(List<Map<String, dynamic>> agrupados, String filtroProducto, DateTime? fechaInicialFiltro, DateTime? fechaFinalFiltro) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Estadísticas X Producto', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text(
            fechaInicialFiltro != null && fechaFinalFiltro != null
              ? 'Periodo: ${fechaInicialFiltro.toString().substring(0, 10)} - ${fechaFinalFiltro.toString().substring(0, 10)}'
              : 'Periodo: Todos'
          ),
          pw.Text('Filtro producto: ${filtroProducto.isEmpty ? "Sin filtro" : filtroProducto}'),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Código', 'Producto', 'Cantidad Vendida'],
            data: agrupados.map((e) => [
              e['codigo'],
              e['nombre'],
              e['cantidad'].toString(),
            ]).toList(),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Total productos vendidos: ${agrupados.fold(0, (sum, e) => sum + (e['cantidad'] as int))}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EstadisticasVentasController>(
      builder: (controller) {
        // Filtrar detalles por fechas y producto si corresponde
        List<DetalleBoleta> detallesFiltrados = controller.detallesBoleta;

        if (controller.fechaInicialFiltro != null && controller.fechaFinalFiltro != null) {
          detallesFiltrados = detallesFiltrados.where((det) {
            final fecha = DateTime.tryParse(det.fecha ?? '');
            if (fecha == null) return false;
            return !fecha.isBefore(controller.fechaInicialFiltro!) && !fecha.isAfter(controller.fechaFinalFiltro!);
          }).toList();
        }

        if (controller.filtroProducto.length >= 3) {
          detallesFiltrados = detallesFiltrados.where((det) =>
            (det.idProducto ?? '').toLowerCase().contains(controller.filtroProducto.toLowerCase()) ||
            (det.nombreProducto ?? '').toLowerCase().contains(controller.filtroProducto.toLowerCase())
          ).toList();
        }

        final agrupados = agruparPorProducto(detallesFiltrados);

        return Scaffold(
          appBar: AppBar(
            elevation: 5,
            automaticallyImplyLeading: false,
            title: const Text('Estadísticas X Producto'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => controller.regresar(),
            ),
          ),
          body: Column(
            children: [
              Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: codigoBarraController,
                              decoration: const InputDecoration(
                                labelText: 'Código de Barra',
                                prefixIcon: Icon(Icons.qr_code),
                              ),
                              onSubmitted: (_) => _filtrarInventario(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.camera_alt),
                            tooltip: 'Escanear código',
                            onPressed: () => _escanearCodigoBarra(context),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            tooltip: 'Buscar código',
                            onPressed: _filtrarInventario,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: productoBusquedaController,
                        decoration: const InputDecoration(
                          labelText: 'Buscar producto (mínimo 3 caracteres)',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          controller.filtroProducto = value.trim();
                          controller.update();
                        },
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Fecha Inicial', style: TextStyle(color: Colors.black)),
                              TextButton(
                                onPressed: () async {
                                  DateTime? picked = await _selectDate(context, controller.fechaInicialFiltro ?? DateTime.now());
                                  if (picked != null) {
                                    controller.fechaInicialFiltro = picked;
                                    controller.update();
                                  }
                                },
                                child: Text(
                                  controller.fechaInicialFiltro != null
                                    ? '${controller.fechaInicialFiltro!.toString().substring(0, 10)}'
                                    : 'Todas',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Fecha Final', style: TextStyle(color: Colors.black)),
                              TextButton(
                                onPressed: () async {
                                  DateTime? picked = await _selectDate(context, controller.fechaFinalFiltro ?? DateTime.now());
                                  if (picked != null) {
                                    controller.fechaFinalFiltro = picked;
                                    controller.update();
                                  }
                                },
                                child: Text(
                                  controller.fechaFinalFiltro != null
                                    ? '${controller.fechaFinalFiltro!.toString().substring(0, 10)}'
                                    : 'Todas',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: _filtrarInventario,
                            child: const Text('Filtrar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: agrupados.isNotEmpty
                    ? ListView.builder(
                        itemCount: agrupados.length,
                        itemBuilder: (context, index) {
                          final producto = agrupados[index];
                          return ListTile(
                            leading: const Icon(Icons.inventory_2),
                            title: Text('Producto: ${producto['nombre']}'),
                            subtitle: Text(
                              'Código: ${producto['codigo']} - Cantidad Vendida: ${producto['cantidad']}',
                            ),
                          );
                        },
                      )
                    : const Center(child: Text('No se han encontrado movimientos')),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.centerRight,
                child: Text(
                  'Total productos vendidos: ${agrupados.fold(0, (sum, e) => sum + (e['cantidad'] as int))}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.grey[800],
            splashColor: Colors.black,
            elevation: 0,
            child: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportarPDF(
              agrupados,
              controller.filtroProducto,
              controller.fechaInicialFiltro,
              controller.fechaFinalFiltro,
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            elevation: 10,
            backgroundColor: Colors.grey[300],
            items: [
              BottomNavigationBarItem(
                label: 'Total productos: ${agrupados.fold(0, (sum, e) => sum + (e['cantidad'] as int))}',
                icon: Icon(Icons.inventory_2, color: Colors.grey[600]),
                tooltip: 'Total productos vendidos',
              ),
              BottomNavigationBarItem(
                label: 'Productos: ${agrupados.length}',
                icon: Icon(Icons.list_alt, color: Colors.grey[600]),
                tooltip: 'Cantidad de productos',
              ),
              BottomNavigationBarItem(
                label: 'Exportar',
                icon: Icon(Icons.picture_as_pdf),
                tooltip: 'Exportar informe a PDF',
              )
            ],
          ),
        );
      },
    );
  }
}