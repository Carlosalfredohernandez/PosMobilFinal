import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobilfinal/src/models/detalle.dart';
import 'package:posmobilfinal/src/pages/informes/estadisticas/estadisticas_ventas_controller.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'pdf_estadisticas_ventas_page.dart';
import 'grafico_torta_estadisticas_page.dart';

class EstadisticasVentasPage extends StatefulWidget {
  EstadisticasVentasPage({super.key});

  @override
  State<EstadisticasVentasPage> createState() => _EstadisticasVentasPageState();
}

class _EstadisticasVentasPageState extends State<EstadisticasVentasPage> {
    String _formatearFecha(DateTime? fecha) {
      if (fecha == null) return 'Todas';
      return fecha.toString().substring(0, 10);
    }
  final EstadisticasVentasController controlador = Get.put(EstadisticasVentasController());
  final TextEditingController productoBusquedaController = TextEditingController();
  final TextEditingController categoriaController = TextEditingController();
  DateTime? fechaDesde;
  DateTime? fechaHasta;

  @override
  void initState() {
    super.initState();
    // Limpiar filtros para mostrar todo y setear fechas por defecto
    controlador.filtroProducto = '';
    final hoy = DateTime.now();
    controlador.fechaInicialFiltro = hoy;
    controlador.fechaFinalFiltro = hoy;
    controlador.mostrarTodos();
  }

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


  void _mostrarTodos() {
    controlador.mostrarTodos();
  }

  void _mostrarPorRango(BuildContext context) {
    final desde = controlador.fechaInicialFiltro;
    final hasta = controlador.fechaFinalFiltro;
    if (desde == null || hasta == null) return;
    controlador.mostrarPorRango(desde, hasta).then((_) {
      setState(() {});
    });
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
    // Obtener los detalles desde el controlador
    final detalles = controlador.detallesBoleta;
    // Aplicar filtro de producto si corresponde
    final detallesFiltrados = controlador.filtroProducto.isNotEmpty && controlador.filtroProducto.length >= 3
      ? detalles.where((d) => (d.nombreProducto ?? '').toLowerCase().contains(controlador.filtroProducto.toLowerCase())).toList()
      : detalles;
    final agrupados = agruparPorProducto(detallesFiltrados);
    final totalVendidos = agrupados.fold(0, (sum, e) => sum + (e['cantidad'] as int));

    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        automaticallyImplyLeading: false,
        title: const Text('ESTADISTICAS'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => controlador.regresar(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            tooltip: 'Ver gráfico de torta',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GraficoTortaEstadisticasPage(
                    controlador: controlador,
                    fechaInicial: controlador.fechaInicialFiltro,
                    fechaFinal: controlador.fechaFinalFiltro,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                controlador.filtroProducto = '';
                productoBusquedaController.clear();
                controlador.fechaInicialFiltro = DateTime.now();
                controlador.fechaFinalFiltro = DateTime.now();
              });
              controlador.mostrarTodos().then((_) {
                setState(() {});
              });
            },
            child: const Text('Todos'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: productoBusquedaController,
            decoration: const InputDecoration(
              labelText: 'Buscar producto (mínimo 3 caracteres)',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                controlador.filtroProducto = value.trim();
              });
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
                      DateTime? picked = await _selectDate(context, controlador.fechaInicialFiltro ?? DateTime.now());
                      if (picked != null) {
                        setState(() {
                          controlador.fechaInicialFiltro = picked;
                        });
                      }
                    },
                    child: Text(
                      controlador.fechaInicialFiltro != null
                          ? controlador.fechaInicialFiltro!.toString().substring(0, 10)
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
                      DateTime? picked = await _selectDate(context, controlador.fechaFinalFiltro ?? DateTime.now());
                      if (picked != null) {
                        setState(() {
                          controlador.fechaFinalFiltro = picked;
                        });
                      }
                    },
                    child: Text(
                      controlador.fechaFinalFiltro != null
                          ? controlador.fechaFinalFiltro!.toString().substring(0, 10)
                          : 'Todas',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  _mostrarPorRango(context);
                },
                child: const Text('Aplicar rango'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    controlador.filtroProducto = '';
                    productoBusquedaController.clear();
                    controlador.fechaInicialFiltro = DateTime.now();
                    controlador.fechaFinalFiltro = DateTime.now();
                  });
                  controlador.mostrarTodos().then((_) {
                    setState(() {});
                  });
                },
                child: const Text('Todos'),
              ),
            ],
          ),
          Expanded(
            child: agrupados.isNotEmpty
                ? ListView.builder(
                    itemCount: agrupados.length,
                    itemBuilder: (context, index) {
                      final producto = agrupados[index];
                      return ListTile(
                        leading: const Icon(Icons.inventory_2),
                        title: Text('${producto['nombre']}'),
                        subtitle: Text(
                          'Código: ${producto['codigo']} - Venta: ${producto['cantidad']}',
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'No se encontraron productos vendidos en el periodo o con los filtros seleccionados.',
                      style: TextStyle(fontSize: 16, color: Colors.redAccent, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'pdf_ventas',
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Exportar PDF'),
        backgroundColor: Colors.red[100],
        foregroundColor: Colors.grey[800],
        splashColor: Colors.black,
        elevation: 0,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PdfEstadisticasVentasPage(
                detalles: detallesFiltrados,
                total: totalVendidos,
                filtroProducto: controlador.filtroProducto,
                fechaInicial: controlador.fechaInicialFiltro,
                fechaFinal: controlador.fechaFinalFiltro,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        backgroundColor: Colors.grey[300],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2, color: Colors.grey[600]),
            label: 'Total productos: ${agrupados.fold(0, (sum, e) => sum + (e['cantidad'] as int))}',
            tooltip: 'Total productos vendidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Productos: ${agrupados.length}',
            tooltip: 'Total productos vendidos',
          ),
        ],
      ),
    );
  }
}