import 'package:flutter/material.dart' as material;
import 'package:get/get.dart';
import 'package:posmobilfinal/src/models/boleta.dart';
import 'package:posmobilfinal/src/models/producto.dart';
import 'package:posmobilfinal/src/pages/informes/detalle_venta/informes_detalle_venta_page.dart';
import 'package:posmobilfinal/src/pages/inventarios/informes/inventarios_informes_controller.dart';
import 'package:posmobilfinal/src/pages/inventarios/pdf/pdf_page.dart';
import 'package:posmobilfinal/src/pages/inventarios/vista/inventarios_vista_page.dart';

import 'package:excel/excel.dart' as ex;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

//import '../../pdf/pdf_page.dart';

class InventariosInformesPage extends material.StatefulWidget {
  const InventariosInformesPage({super.key});

  @override
  material.State<InventariosInformesPage> createState() => _InventariosInformesPage();
}

class _InventariosInformesPage extends material.State<InventariosInformesPage> {
    // Método auxiliar para formatear números con separador de miles
    String _numberFormat(int x) {
      List<String> parts = x.toString().split('.');
      RegExp re = RegExp(r'\B(?=(\d{3})+(?!\d))');
      parts[0] = parts[0].replaceAll(re, '.');
      if (parts.length == 1) {
        // parts.add('00');
      } else {
        parts[1] = parts[1].padRight(2, '0').substring(0, 2);
      }
      return parts.join(',');
    }
  final InventariosInformesController controlador = Get.put(InventariosInformesController());
  @override
  material.Widget build(material.BuildContext context) {
    return Obx(() => material.Scaffold(
      appBar: material.AppBar(
        elevation: 5,
        title: const material.Text('Informes de Inventario'),
        centerTitle: true,
        actions: [
          material.IconButton(
            icon: const material.Icon(material.Icons.filter_alt_outlined),
            tooltip: 'Filtrar',
            onPressed: () {
              // Aquí puedes abrir un modal de filtros avanzados
              material.ScaffoldMessenger.of(context).showSnackBar(
                const material.SnackBar(content: material.Text('Función de filtro avanzada próximamente')),
              );
            },
          ),
          material.IconButton(
            icon: const material.Icon(material.Icons.picture_as_pdf),
            tooltip: 'Exportar a PDF',
            onPressed: () => exportarPdf(context, controlador.informe),
          ),
          material.IconButton(
            icon: const material.Icon(material.Icons.table_chart),
            tooltip: 'Exportar a Excel',
            onPressed: () async => await exportarExcel(context, controlador.informe),
          ),
        ],
        bottom: material.PreferredSize(
          preferredSize: const material.Size.fromHeight(60),
          child: material.Padding(
            padding: const material.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: material.Row(
              children: [
                material.Expanded(child: _textFieldSearch(context)),
                iconScan(),
              ],
            ),
          ),
        ),
      ),
      body: material.Column(
        children: [
          material.Padding(
                padding: const material.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: material.LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 500) {
                      // Diseño en columna para pantallas pequeñas
                      return material.Column(
                        crossAxisAlignment: material.CrossAxisAlignment.start,
                        children: [
                          material.Row(
                            children: [
                              const material.Text('Fecha Inicial:', style: material.TextStyle(fontWeight: material.FontWeight.bold)),
                              const material.SizedBox(width: 8),
                              material.Expanded(
                                child: material.TextButton(
                                  onPressed: () => searchDateBegin(context),
                                  child: material.Text('${controlador.fechaInicial}'.substring(0,10)),
                                ),
                              ),
                            ],
                          ),
                          const material.SizedBox(height: 8),
                          material.Row(
                            children: [
                              const material.Text('Fecha Final:', style: material.TextStyle(fontWeight: material.FontWeight.bold)),
                              const material.SizedBox(width: 8),
                              material.Expanded(
                                child: material.TextButton(
                                  onPressed: () => searchDateEnd(context),
                                  child: material.Text('${controlador.fechaFinal}'.substring(0,10)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      // Diseño en fila para pantallas grandes
                      return material.Row(
                        children: [
                          const material.Text('Fecha Inicial:', style: material.TextStyle(fontWeight: material.FontWeight.bold)),
                          const material.SizedBox(width: 8),
                          material.Expanded(
                            child: material.TextButton(
                              onPressed: () => searchDateBegin(context),
                              child: material.Text('${controlador.fechaInicial}'.substring(0,10)),
                            ),
                          ),
                          const material.SizedBox(width: 12),
                          const material.Text('Fecha Final:', style: material.TextStyle(fontWeight: material.FontWeight.bold)),
                          const material.SizedBox(width: 8),
                          material.Expanded(
                            child: material.TextButton(
                              onPressed: () => searchDateEnd(context),
                              child: material.Text('${controlador.fechaFinal}'.substring(0,10)),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
          ),
          material.Expanded(
            child: controlador.filter.isNotEmpty
                ? material.Card(
                    margin: const material.EdgeInsets.all(12),
                    elevation: 2,
                    child: material.ListView(
                      children: [
                        material.DataTable(
                          columns: const [
                            material.DataColumn(label: material.Text('Fecha')),
                            material.DataColumn(label: material.Text('Producto')),
                            material.DataColumn(label: material.Text('Código')),
                            material.DataColumn(label: material.Text('Cantidad')),
                            material.DataColumn(label: material.Text('Local')),
                            material.DataColumn(label: material.Text('Proveedor')),
                            material.DataColumn(label: material.Text('Tipo')),
                            material.DataColumn(label: material.Text('Acciones')),
                          ],
                          rows: controlador.filter.map((producto) => material.DataRow(
                            cells: [
                              material.DataCell(material.Text('-')), // No existe fecha en Producto
                              material.DataCell(material.Text(producto.nombreProducto ?? '-')),
                              material.DataCell(material.Text(producto.codigoBarra ?? '-')),
                              // Mostrar cantidad usando numberFormat, asegurando que sea int
                              material.DataCell(material.Text(
                                _numberFormat(
                                  (producto.cantidad is int)
                                      ? (producto.cantidad ?? 0)
                                      : int.tryParse(producto.cantidad?.toString() ?? '') ?? 0
                                ),
                              )),
                              material.DataCell(material.Text('-')), // No existe local en Producto
                              material.DataCell(material.Text(producto.proveedor?.toString() ?? '-')),
                              material.DataCell(material.Text('-')), // No existe tipoMovimiento en Producto
                              material.DataCell(
                                material.Row(
                                  children: [
                                    material.IconButton(
                                      icon: const material.Icon(material.Icons.visibility),
                                      tooltip: 'Ver detalle',
                                      onPressed: () {
                                        material.Navigator.push(
                                          context,
                                          material.MaterialPageRoute(builder: (_) => InventariosVistaPage(id: producto.id)),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )).toList(),
                        ),
                      ],
                    ),
                  )
                : material.Center(
                    child: material.Column(
                      mainAxisAlignment: material.MainAxisAlignment.center,
                      children: const [
                        material.Icon(material.Icons.inbox, size: 64, color: material.Colors.grey),
                        material.SizedBox(height: 16),
                        material.Text('No se han encontrado movimientos de inventario', style: material.TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
          ),
          // Resumen de totales
          material.Container(
            width: double.infinity,
            color: material.Colors.grey[100],
            padding: const material.EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: material.Row(
              mainAxisAlignment: material.MainAxisAlignment.spaceBetween,
              children: [
                material.Text('Total movimientos: ${controlador.filter.length}', style: const material.TextStyle(fontWeight: material.FontWeight.bold)),
                // Puedes agregar más totales aquí
              ],
            ),
          ),
        ],
      ),
    ));
  }

  material.Widget iconScan(){
    return material.IconButton(
      onPressed: () {
        controlador.scanBarcodeNormal(context);
      },
      icon: const material.Icon(material.Icons.camera_enhance_outlined),
    );
  }

  material.Widget _textFieldSearch(material.BuildContext context) {
    return material.SafeArea(
      child: material.SizedBox(
        width: material.MediaQuery.of(context).size.width * 0.75,
        child: material.TextField(
          onChanged: (texto) {
            setState(() {
              controlador.onChangeText(texto);
            });
          },
          decoration: material.InputDecoration(
              hintText: 'Buscar',
              suffixIcon: material.Icon(material.Icons.search, color: material.Colors.white),
              hintStyle: material.TextStyle(
                  fontSize: 17,
                  color: material.Colors.black
              ),
              fillColor: material.Colors.white,
              filled: true,
              enabledBorder: material.OutlineInputBorder(
                  borderRadius: material.BorderRadius.circular(15),
                  borderSide: material.BorderSide(
                      color: material.Colors.grey
                  )
              ),
              focusedBorder: material.OutlineInputBorder(
                  borderRadius: material.BorderRadius.circular(15),
                  borderSide: material.BorderSide(
                      color: material.Colors.grey
                  )
              ),
              contentPadding: material.EdgeInsets.all(15)
          ),
        ),
      ),
    );
  }

  // Stubs para funciones faltantes
  void exportarPdf(material.BuildContext context, dynamic informe) {
    // Implementa la lógica de exportar a PDF aquí
    // Por ahora solo muestra un mensaje
    material.ScaffoldMessenger.of(context).showSnackBar(
      material.SnackBar(content: material.Text('Función exportarPdf no implementada')),
    );
  }

  Future<void> exportarExcel(material.BuildContext context, dynamic informe) async {
    // Implementa la lógica de exportar a Excel aquí
    material.ScaffoldMessenger.of(context).showSnackBar(
      material.SnackBar(content: material.Text('Función exportarExcel no implementada')),
    );
  }


  Future<void> searchDateBegin(material.BuildContext context) async {
    final DateTime? picked = await material.showDatePicker(
      context: context,
      initialDate: controlador.fechaInicial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const material.Locale('es', ''),
    );
    if (picked != null && picked != controlador.fechaInicial) {
      setState(() {
        controlador.fechaInicial = picked;
        controlador.onChangeDate();
      });
    }
  }

  Future<void> searchDateEnd(material.BuildContext context) async {
    final DateTime? picked = await material.showDatePicker(
      context: context,
      initialDate: controlador.fechaFinal ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const material.Locale('es', ''),
    );
    if (picked != null && picked != controlador.fechaFinal) {
      setState(() {
        controlador.fechaFinal = picked;
        controlador.onChangeDate();
      });
    }
  }


}
