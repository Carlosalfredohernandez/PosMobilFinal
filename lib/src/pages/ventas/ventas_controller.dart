import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:posmobilfinal/src/models/producto.dart';
import 'package:posmobilfinal/src/providers/productos_provider.dart';
import 'package:posmobilfinal/src/models/categoria.dart';
import 'package:posmobilfinal/src/providers/categorias_provider.dart';

class VentasController extends GetxController {
  final productos = <Producto>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;
  final ProductosProvider productosProvider = ProductosProvider();

  final categorias = <Categoria>[];
  final Map<String, String> categoriaNombreMap = {};
  final CategoriasProvider categoriasProvider = CategoriasProvider();

  @override
  void onInit() {
    super.onInit();
    cargarCategoriasYProductos();
  }

  Future<void> cargarCategoriasYProductos() async {
    try {
      isLoading.value = true;
      error.value = '';
      print('[VENTAS] Iniciando carga de categorías...');
      final cats = await categoriasProvider.getAllByUser();
      categorias.clear();
      categorias.addAll(cats);
      categoriaNombreMap.clear();
      for (final cat in cats) {
        if (cat.id != null && cat.nombreCategoria != null) {
          categoriaNombreMap[cat.id!] = cat.nombreCategoria!;
        }
      }
      print('[VENTAS] Categorías cargadas correctamente.');
      print('[VENTAS] Iniciando carga de productos...');
      final result = await productosProvider.getAllByUser();
      productos.assignAll(result);
      print('[VENTAS] Productos cargados correctamente.');
    } catch (e, s) {
      error.value = 'Error al cargar productos/categorías: $e';
      print('[VENTAS][ERROR] Excepción al cargar productos/categorías: $e');
      print('[VENTAS][STACK] $s');
      Get.snackbar('Error crítico', 'Ocurrió un error al cargar productos/categorías: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFFD32F2F).withOpacity(0.8), colorText: const Color(0xFFFFFFFF));
    } finally {
      isLoading.value = false;
    }
  }
}
