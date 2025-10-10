// 🔄 LoginController COMPATIBILIDAD - Para evitar errores de referencia
// Coloca este archivo en: lib/src/pages/login/login_controller.dart
// O el path donde estaba tu LoginController original

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  // Controladores como tu login original
  final rutController = TextEditingController();
  final claveController = TextEditingController();
  
  // Estados
  final loading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Limpiar campos al iniciar
    rutController.text = '';
    claveController.text = '';
  }

  /// 🔄 Método login compatible con tu app original
  /// NOTA: Este método ya NO se usa porque vas directo al login empresarial
  /// Pero lo mantenemos para evitar errores de referencia
  Future<void> login() async {
    print('⚠️ LoginController.login() - Este método ya no se usa');
    print('   Se mantiene solo para compatibilidad');
    
    // Si alguien llama a este método por error, redirigir al login empresarial
    Get.snackbar(
      'ℹ️ Redirección', 
      'Redirigiendo al login empresarial...',
      backgroundColor: Colors.blue.withOpacity(0.1),
      colorText: Colors.blue,
    );
    
    // Redirigir al login empresarial
    Get.offNamed('/empresa_login');
  }
  
  /// 🔄 Simular validación de credenciales (compatibilidad)
  Future<bool> validarCredenciales(String rut, String clave) async {
    print('⚠️ validarCredenciales() - Método legacy, redirigir a login empresarial');
    return false; // Siempre false para forzar uso del nuevo login
  }
  
  /// 🔄 Obtener usuario actual
  Map<String, dynamic>? get usuarioActual {
    return GetStorage().read('usuario');
  }
  
  /// 🔄 Verificar si hay sesión activa
  bool get isLoggedIn {
    final usuario = GetStorage().read('usuario');
    return usuario != null && usuario['id'] != null;
  }
  
  /// 🔄 Cerrar sesión
  Future<void> logout() async {
    // Limpiar datos guardados
    GetStorage().remove('usuario');
    GetStorage().remove('empresa');
    
    // Limpiar controladores
    rutController.clear();
    claveController.clear();
    
    Get.snackbar(
      'ℹ️ Sesión Cerrada',
      'Sesión cerrada correctamente',
      backgroundColor: Colors.grey.withOpacity(0.1),
      colorText: Colors.grey[700],
    );
    
    // Ir al login empresarial
    Get.offAllNamed('/empresa_login');
  }

  @override
  void onClose() {
    rutController.dispose();
    claveController.dispose();
    super.onClose();
  }
}

// Variable global como en tu app original (si la usabas)
LoginController get controlador => Get.find<LoginController>();