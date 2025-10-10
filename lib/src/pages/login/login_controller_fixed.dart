import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/models/response_api.dart';
import 'package:posmobil/src/models/usuario.dart';
import 'package:posmobil/src/providers/usuarios_provider.dart';

class LoginController extends GetxController {

  TextEditingController rutController = TextEditingController();
  TextEditingController claveController = TextEditingController();

  UsuariosProvider usuariosProvider = UsuariosProvider();

  void login() async {
    String rut = rutController.text.trim();
    String password = claveController.text.trim();

    print('🔐 Intentando login: $rut');

    if (isValidForm(rut, password)) {
      print('📡 Enviando datos al backend...');

      ResponseApi responseApi = await usuariosProvider.login(rut, password);

      print('📦 Respuesta recibida: ${responseApi.success}');

      if (responseApi.success == true) {
        print('✅ Login exitoso');

        // Obtener datos del usuario del backend
        Map<String, dynamic> usuarioData = responseApi.data;

        // Convertir tipos si es necesario
        if (usuarioData['id'] != null && usuarioData['id'] is int) {
          usuarioData['id'] = usuarioData['id'].toString();
        }
        if (usuarioData['numero'] != null && usuarioData['numero'] is int) {
          usuarioData['numero'] = usuarioData['numero'].toString();
        }

        // Agregar campos faltantes con valores por defecto
        usuarioData['tipoContrato'] = usuarioData['tipoContrato'] ?? 'SI';
        usuarioData['activo'] = usuarioData['activo'] ?? true;

        Usuario sesionUsuario = Usuario.fromJson(usuarioData);

        // Guardar datos en storage
        GetStorage().write('usuario', usuarioData);

        // Obtener el rol del usuario
        int rolUsuario = usuarioData['rol'] ?? 1;
        GetStorage().write('usuario_rol', rolUsuario);

        print('👥 Usuario guardado en storage: ${sesionUsuario.nombre}');
        print('🔑 Rol de usuario: $rolUsuario');

        // Verificar tipo de contrato
        if (sesionUsuario.tipoContrato == 'NO') {
          Get.snackbar('Usuario no autorizado', 'Contacta al administrador');
        } else {
          // ✅ NAVEGACIÓN CORREGIDA: Ahora va a menu_inicio (que funciona)
          print('🏠 Navegando a menu_inicio (pantalla que funciona correctamente)...');
          irAHomePage();
        }
      } else {
        print('❌ Login fallido: ${responseApi.message}');
        Get.snackbar('Login fallido', responseApi.message ?? 'Error desconocido');
      }
    }
  }

  void irAHomePage(){
    print('🏠 Navegando a /menu_inicio');
    Get.offNamedUntil('/menu_inicio', (route) => false);
  }

  void irAHomePageCajero(){
    print('🛒 Navegando a /menu_inicio (modo cajero)');
    Get.offNamedUntil('/menu_inicio', (route) => false);
  }

  // ✅ MÉTODO CORREGIDO: Ahora navega a menu_inicio que funciona
  void irAPantallaEmpresa(){
    print('🏠 Navegando a /menu_inicio (pantalla que funciona correctamente)');
    Get.offNamedUntil('/menu_inicio', (route) => false);
  }

  bool isValidForm(String rut, String password) {
    if (rut.isEmpty) {
      Get.snackbar('Formulario no válido', 'Ingresa el RUT');
      return false;
    }

    if (password.isEmpty) {
      Get.snackbar('Formulario no válido', 'Ingresa la contraseña');
      return false;
    }

    return true;
  }
}