import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InventarioFiltradoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventarioFiltradoController>(
      init: InventarioFiltradoController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Inventario con Filtro'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  value: controller.categoriaSeleccionada,
                  hint: Text('Filtrar por categoría'),
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: '',
                      child: Text('Todas las categorías'),
                    ),
                    ...controller.categorias.map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                  ],
                  onChanged: (value) {
                    controller.filtrarPorCategoria(value ?? '');
                  },
                ),
              ),
              Expanded(
                child: controller.productosFiltrados.isEmpty
                    ? Center(child: Text('No hay productos'))
                    : ListView.builder(
                        itemCount: controller.productosFiltrados.length,
                        itemBuilder: (context, index) {
                          final prod = controller.productosFiltrados[index];
                          return ListTile(
                            title: Text(prod['nombre'] ?? ''),
                            subtitle: Text('Categoría: ' + (prod['categoria'] ?? '')),
                            trailing: Text('Cantidad: ' + (prod['cantidad']?.toString() ?? '0')),
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

class InventarioFiltradoController extends GetxController {
  List<Map<String, dynamic>> productos = [];
  List<Map<String, dynamic>> productosFiltrados = [];
  List<String> categorias = [];
  String categoriaSeleccionada = '';

  @override
  void onInit() {
    super.onInit();
    cargarInventario();
  }

  void cargarInventario() async {
    // TODO: Reemplazar por llamada real al provider/API
    productos = [
      {'nombre': 'Producto A', 'categoria': 'Bebidas', 'cantidad': 10},
      {'nombre': 'Producto B', 'categoria': 'Snacks', 'cantidad': 5},
      {'nombre': 'Producto C', 'categoria': 'Bebidas', 'cantidad': 8},
      {'nombre': 'Producto D', 'categoria': 'Limpieza', 'cantidad': 2},
    ];
    categorias = productos.map((e) => e['categoria'] as String).toSet().toList();
    productosFiltrados = List.from(productos);
    update();
  }

  void filtrarPorCategoria(String categoria) {
    categoriaSeleccionada = categoria;
    if (categoria.isEmpty) {
      productosFiltrados = List.from(productos);
    } else {
      productosFiltrados = productos.where((p) => p['categoria'] == categoria).toList();
    }
    update();
  }
}
