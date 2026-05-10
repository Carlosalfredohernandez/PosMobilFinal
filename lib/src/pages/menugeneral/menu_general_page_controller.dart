import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:posmobilfinal/src/pages/ventas/ventas_page.dart';

class MenuGeneralPageController extends GetxController {
  void goToPuntoDeVentas() async {
    try {
      await Get.toNamed('/inicio/cliente/caja/create_antiguo');
    } catch (e) {
      print('Error navegando a Punto de Ventas: $e');
      _showErrorMessage('Página de Punto de Ventas no disponible');
    }
  }

  void goToTotem() async {
    try {
      // Asegura que el controlador del carrito esté disponible
      if (!Get.isRegistered<CarritoController>()) {
        Get.put(CarritoController());
      }
      await Get.toNamed('/ventas');
      Get.offNamed('/menugeneral');
    } catch (e) {
      print('Error navegando a ventas (totem): $e');
      _showErrorMessage('Página de ventas no disponible');
    }
  }

  void goToCategory() async {
    try {
      await Get.toNamed('/inicio/cliente/agregar/categoria');
      Get.offNamed('/menugeneral');
    } catch (e) {
      print('Error navegando a categorías: $e');
      _showErrorMessage('Página de categorías no disponible');
    }
  }

  void goToProduct() async {
    try {
      await Get.toNamed('/mantenedores/productos');
      Get.offNamed('/menugeneral');
    } catch (e) {
      print('Error navegando a productos: $e');
      _showErrorMessage('Página de productos no disponible');
    }
  }

  void goToBodega() async {
    try {
      await Get.toNamed('/mantenedores/proveedor');
      Get.offNamed('/menugeneral');
    } catch (e) {
      print('Error navegando a bodega: $e');
      _showErrorMessage('Página de bodega no disponible');
    }
  }

  void goToinformesventas() async {
    try {
      await Get.toNamed('/informes/detalle_venta');
      //Get.offNamed('/menugeneral'); // No regreses automáticamente al menú general
    } catch (e) {
      print('Error navegando a informes de ventas: $e');
      _showErrorMessage('Página de informes de ventas no disponible');
    }
  }

  void goToEstadisticas() async {
    try {
      await Get.toNamed('/menu_general/estadisticas');
    } catch (e) {
      print('Error navegando a estadísticas: $e');
      _showErrorMessage('Página de estadísticas no disponible');
    }
  }

  void goToInventarios() async {
    try {
      await Get.toNamed('/inventarios/menu');
    } catch (e) {
      print('Error navegando a inventarios: $e');
      _showErrorMessage('Página de inventarios no disponible');
    }
  }

  void goToUser() async {
    try {
      await Get.toNamed('/usuarios_empresa');
      Get.offNamed('/menugeneral');
    } catch (e) {
      print('Error navegando a usuarios empresa: $e');
      _showErrorMessage('Página de usuarios empresa no disponible');
    }
  }

  void goToHome() {
    try {
      Get.offNamed('/inicio/cliente');
    } catch (e) {
      print('Error navegando a home: $e');
      Get.offNamedUntil('/', (route) => false);
    }
  }

  void goToLocal() async {
    try {
      await Get.toNamed('/mantenedores/local');
      Get.offNamed('/menugeneral');
    } catch (e) {
      print('Error navegando a locales: $e');
      _showErrorMessage('Página de locales no disponible');
    }
  }

  void logout() {
    print('Cerrando sesión y saliendo de la aplicación...');

    // Limpiar TODOS los datos de sesión
    final storage = GetStorage();
    storage.remove('usuario_empresa');
    storage.remove('usuario_rol');
    storage.remove('empresa_data');
    storage.remove('usuarioempresa');
    storage.remove('usuario');
    storage.remove('clear_empresa_login_fields');

    // Mostrar mensaje de despedida
    Get.snackbar(
      '👋 Hasta luego',
      'Cerrando aplicación...',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );

    // Cerrar aplicación después de un breve delay
    Future.delayed(const Duration(seconds: 1), () {
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        exit(0);
      } else {
        SystemNavigator.pop();
      }
    });
  }

  void _showErrorMessage(String message) {
    Get.snackbar(
      'Funcionalidad no disponible',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
