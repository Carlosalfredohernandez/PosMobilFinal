import 'package:excel/excel.dart' as ex;
      // ...existing code...

import 'package:flutter/material.dart' as material;
import 'package:get/get.dart';
import 'dart:async';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:posmobilfinal/src/models/inventario.dart';
import 'package:posmobilfinal/src/providers/inventario_provider.dart';
import 'package:posmobilfinal/src/providers/productos_provider.dart';
import 'package:posmobilfinal/src/models/producto.dart';
import 'inventario_filtrado_page_real.dart';
import 'package:posmobilfinal/src/pages/inventarios/detalle/detalle_movimientos_page.dart';
import '../pdf/pdf_page.dart';
import 'package:posmobilfinal/src/pages/inventarios/menu/inventarios_menu_page.dart';
import 'inventarios_vista_controller.dart';


// Función para exportar a Excel desde la vista de inventario (comentada temporalmente)
/*
Future<void> exportarExcel(material.BuildContext context, List<Producto> productos) async {
  final excel = ex.Excel.createExcel();
  final sheet = excel['Inventario'];
  sheet.appendRow([
    ex.CellValue('Producto'),
    ex.CellValue('Codigo'),
    ex.CellValue('Cantidad'),
  ]);
  for (var producto in productos) {
    sheet.appendRow([
      ex.CellValue(producto.nombreProducto ?? ''),
      ex.CellValue(producto.codigoBarra ?? ''),
      ex.CellValue(producto.cantidad?.toString() ?? ''),
    ]);
  }

  final now = DateTime.now();
  final fechaHora =
      '${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  final fileName = 'inventario_$fechaHora.xlsx';

  final List<int>? fileBytes = excel.encode();
  if (fileBytes == null) return;

  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsBytes(fileBytes, flush: true);

  await Share.shareXFiles([XFile(file.path)], text: 'Informe de inventario');
}
*/




class InventariosVistaPage extends material.StatelessWidget {
  final dynamic id;
  const InventariosVistaPage({material.Key? key, this.id}) : super(key: key);


  @override
  material.Widget build(material.BuildContext context) {
    final InventariosVistaController controller = Get.put(InventariosVistaController(id));
    return material.Scaffold(
      appBar: material.AppBar(
        title: const material.Text('Vista de Inventario'),
        actions: [
          material.IconButton(
            icon: material.Icon(material.Icons.filter_list),
            tooltip: 'Ver inventario filtrado',
            onPressed: () {
              material.Navigator.of(context).push(
                material.MaterialPageRoute(builder: (_) => InventarioFiltradoPageReal()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: material.Column(
        mainAxisSize: material.MainAxisSize.min,
        crossAxisAlignment: material.CrossAxisAlignment.end,
        children: [
          material.FloatingActionButton(
            heroTag: 'excel_vista',
            tooltip: 'Exportar a Excel',
            backgroundColor: material.Colors.white,
            foregroundColor: material.Colors.green[800],
            splashColor: material.Colors.green,
            elevation: 2,
            child: material.Icon(material.Icons.table_chart),
            onPressed: () async {
              final controller = Get.find<InventariosVistaController>();
              final stockAgrupado = controller.stockAgrupadoPorProducto;
              final List<Producto> productosExcel = stockAgrupado.entries.map((entry) {
                final codigo = entry.key;
                final total = entry.value;
                final producto = controller.productos.firstWhereOrNull(
                  (p) => p.id?.toString().trim() == codigo?.toString().trim(),
                );
                return Producto(
                  id: codigo?.toString(),
                  nombreProducto: producto?.nombreProducto ?? codigo?.toString(),
                  cantidad: total,
                  codigoBarra: producto?.codigoBarra,
                  categoria: producto?.categoria,
                );
              }).toList();
              // await exportarExcel(context, productosExcel); // Comentado temporalmente para evitar error de método indefinido
            },
          ),
          material.SizedBox(height: 12),
          material.FloatingActionButton.extended(
            heroTag: 'pdf_vista',
            icon: const material.Icon(material.Icons.picture_as_pdf),
            label: const material.Text('Exportar PDF'),
            onPressed: () {
              final controller = Get.find<InventariosVistaController>();
              final stockAgrupado = controller.stockAgrupadoPorProducto;
              final List<Producto> productosPDF = stockAgrupado.entries.map((entry) {
                final codigo = entry.key;
                final total = entry.value;
                final producto = controller.productos.firstWhereOrNull(
                  (p) => p.id?.toString().trim() == codigo?.toString().trim(),
                );
                return Producto(
                  id: codigo?.toString(),
                  nombreProducto: producto?.nombreProducto ?? codigo?.toString(),
                  cantidad: total,
                  codigoBarra: producto?.codigoBarra,
                  categoria: producto?.categoria,
                );
              }).toList();
              material.Navigator.of(context).push(
                material.MaterialPageRoute(
                  builder: (_) => PdfInventarioPage(
                    productos: productosPDF,
                    total: productosPDF.fold<int>(0, (prev, p) => prev + (p.cantidad ?? 0)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.cargandoDatos.value) {
          return const material.Center(child: material.CircularProgressIndicator());
        }
        final stockAgrupado = controller.stockAgrupadoPorProducto;
        final totalStock = controller.stock.length;
        final categoria = controller.categoriaSeleccionada.value;
        final categorias = controller.categorias;
        return material.DefaultTabController(
          length: categorias.isEmpty ? 1 : categorias.length + 1,
          child: material.Column(
            crossAxisAlignment: material.CrossAxisAlignment.start,
            children: [
              material.Padding(
                padding: const material.EdgeInsets.all(8.0),
                child: Obx(() => material.Row(
                  children: [
                    material.Expanded(
                      child: material.Column(
                        crossAxisAlignment: material.CrossAxisAlignment.start,
                        children: [
                          const material.Text('Fecha actual:', style: material.TextStyle(fontSize: 12)),
                          material.TextButton(
                            onPressed: () async {
                              final picked = await material.showDatePicker(
                                context: context,
                                initialDate: controller.fechaDesde.value ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                controller.setFechaDesde(picked);
                              }
                            },
                            child: material.Text(
                              controller.fechaDesde.value != null
                                  ? controller.fechaDesde.value!.toString().substring(0,10)
                                  : 'Fecha actual',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const material.SizedBox(width: 8),
                    material.Expanded(
                      child: material.Column(
                        crossAxisAlignment: material.CrossAxisAlignment.start,
                        children: [
                          const material.Text('Fecha hasta:', style: material.TextStyle(fontSize: 12)),
                          material.TextButton(
                            onPressed: () async {
                              final picked = await material.showDatePicker(
                                context: context,
                                initialDate: controller.fechaHasta.value ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                controller.setFechaHasta(picked);
                              }
                            },
                            child: material.Text(
                              controller.fechaHasta.value != null
                                  ? controller.fechaHasta.value!.toString().substring(0,10)
                                  : 'Fecha hasta',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const material.SizedBox(width: 8),
                    material.ElevatedButton(
                      onPressed: () {
                        controller.aplicarFiltroPorFecha();
                      },
                      child: const material.Text('Filtrar'),
                    ),
                  ],
                )),
              ),
              material.TabBar(
                isScrollable: true,
                tabs: <material.Tab>[
                  const material.Tab(text: 'Todas'),
                  ...categorias.map((cat) => material.Tab(text: controller.nombreCategorias[cat] ?? cat)).toList(),
                ],
                onTap: (index) {
                  if (index == 0) {
                    controller.categoriaSeleccionada.value = '';
                  } else if (categorias.isNotEmpty && index - 1 < categorias.length) {
                    controller.categoriaSeleccionada.value = categorias[index - 1];
                  } else {
                    controller.categoriaSeleccionada.value = '';
                  }
                },
                labelColor: material.Colors.blue,
                unselectedLabelColor: material.Colors.black,
              ),
              material.Expanded(
                child: stockAgrupado.isEmpty
                    ? const material.Center(child: material.Text('No hay inventario para mostrar'))
                    : material.ListView.builder(
                        itemCount: stockAgrupado.length,
                        itemBuilder: (context, index) {
                          final codigo = stockAgrupado.keys.elementAt(index);
                          final total = stockAgrupado[codigo] ?? 0;
                          final producto = controller.productos.firstWhereOrNull(
                            (p) => p.id?.toString().trim() == codigo?.toString().trim(),
                          );
                          final nombre = producto?.nombreProducto ?? codigo?.toString() ?? '';
                          return material.ListTile(
                            title: material.Text(nombre),
                            subtitle: material.Text('Total stock: $total'),
                            onTap: () {
                              material.Navigator.of(context).push(
                                material.MaterialPageRoute(
                                  builder: (_) => DetalleMovimientosPage(
                                    producto: producto ?? Producto(id: codigo?.toString()),
                                    fechaDesde: controller.fechaDesde.value,
                                    fechaHasta: controller.fechaHasta.value,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ); // <-- Cierra material.DefaultTabController
      }),
    ); // <-- Cierra material.Scaffold
  }
}

