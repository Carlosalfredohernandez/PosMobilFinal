import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'inventarios_vista_controller.dart';

class InventarioFiltradoPageReal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventariosVistaController>(
      builder: (controller) {
        final productos = controller.stock.map((inv) {
          final producto = controller.productos.firstWhereOrNull((p) => p.codigoBarra == inv.codigoProducto);
          return {
            'nombre': (producto?.nombreProducto ?? inv.codigoProducto ?? '').toString(),
            'categoria': (producto?.categoria ?? '').toString(),
            'cantidad': (inv.cantidad ?? 0).toString(),
          };
        }).toList();
        final categorias = controller.categorias;
        final categoriaSeleccionada = controller.categoriaSeleccionada.value;
        final productosFiltrados = categoriaSeleccionada.isEmpty
            ? productos
            : productos.where((p) => p['categoria'] == categoriaSeleccionada).toList();
        return Scaffold(
          appBar: AppBar(title: Text('Inventario filtrado')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  value: categoriaSeleccionada,
                  hint: Text('Filtrar por categoría'),
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: '',
                      child: Text('Todas las categorías'),
                    ),
                    ...categorias.map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(controller.nombreCategorias[cat] ?? cat),
                        ))
                  ],
                  onChanged: (value) {
                    controller.categoriaSeleccionada.value = value ?? '';
                    controller.update();
                  },
                ),
              ),
              Expanded(
                child: productosFiltrados.isEmpty
                    ? Center(child: Text('No hay productos'))
                    : ListView.builder(
                        itemCount: productosFiltrados.length,
                        itemBuilder: (context, index) {
                          final prod = productosFiltrados[index];
                          return ListTile(
                            title: Text(prod['nombre'] ?? ''),
                            subtitle: Text('Categoría: ' + (prod['categoria'] ?? '')),
                            trailing: Text('Cantidad: ' + (prod['cantidad'] ?? '0')),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
