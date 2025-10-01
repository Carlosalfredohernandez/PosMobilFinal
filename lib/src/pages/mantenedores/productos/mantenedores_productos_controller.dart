import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/models/categoria.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/pages/cliente/productos/editar/cliente_productos_editar_page.dart';
import 'package:posmobil/src/providers/categorias_provider.dart';
import 'package:posmobil/src/providers/productos_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MantenedoresProductosController extends GetxController {
  final ProductosProvider productosProvider = ProductosProvider();
  final CategoriasProvider categoriasProvider = CategoriasProvider();
  final TextEditingController searchText = TextEditingController();

  List<Categoria> categorias = <Categoria>[].obs;
  List<Producto> productos = <Producto>[];
  List<Producto> filter = <Producto>[].obs;

  MantenedoresProductosController() {
    getProductos();
    getCategorias();
  }

  void getCategorias() async {
    var result = await categoriasProvider.getAllByUser();
    categorias.clear();
    categorias.addAll(result);
  }

  void getProductos() async {
    var result = await productosProvider.getAllByUser();
    productos.clear();
    productos.addAll(result);
    filter.clear();
    filter.addAll(result);
  }

  void updateProductos(String idCategory) {
    filter = productos.where((element) {
      return element.categoria?.toLowerCase().contains(idCategory.trim().toLowerCase()) ?? false;
    }).toList();
  }

  void onChangeText(String text) {
    filter = productos.where((element) {
      return (element.nombreProducto?.toLowerCase().contains(text.trim().toLowerCase()) ?? false) ||
             (element.codigoBarra?.toLowerCase().contains(text.trim().toLowerCase()) ?? false);
    }).toList();
  }

  Future<void> scanBarcode(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: 400,
        child: MobileScanner(
          onDetect: (capture) async {
            final barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final code = barcodes.first.rawValue ?? '';
              if (code.isNotEmpty) {
                goTo(context, code);
                Navigator.pop(context);
              }
            }
          },
        ),
      ),
    );
  }

  void goTo(BuildContext context, String codigoBarra) {
    final producto = productos.where((element) => element.codigoBarra == codigoBarra).toList();
    if (producto.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ClienteProductosEditarPage(producto: producto[0])),
      );
    } else {
      Get.snackbar('Producto no encontrado', 'No existe un producto con ese código de barra');
    }
  }

  void volver() {
    Get.offNamed('/mantenedores/menu');
  }

  void goToProduct() {
   // Get.offNamedUntil('/inicio/cliente/productos/crear', (route) => false);
   Get.toNamed('/inicio/cliente/productos/crear');
  }
  // ...existing code...

void scanBarcodeNormal(BuildContext context) async {
  await scanBarcode(context);
}

// ...existing code...
}