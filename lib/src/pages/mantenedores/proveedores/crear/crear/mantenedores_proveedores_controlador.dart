import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/models/proveedores.dart';
import 'package:posmobil/src/models/response_api.dart';
import 'package:posmobil/src/providers/proveedor_provider.dart';

class MantenedoresProveedoresControlador extends GetxController{
  TextEditingController nombreController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController direccionController = TextEditingController();
  ProveedorProvider proveedorProvider = ProveedorProvider();

  void crearProveedor() async {
    String nombre = nombreController.text;
    String telefono = telefonoController.text;
    String direccion = direccionController.text;
    String email = emailController.text;
    if (validador(nombre, telefono, direccion, email)){
      Proveedor proveedor = Proveedor(
        nombre: nombre,
        telefono: telefono,
        direccion: direccion,
        email: email,
        contrato: 'SI',
      );
      ResponseApi responseApi = await proveedorProvider.create(proveedor);
      if (responseApi.success == true ){
        Get.snackbar('Proceso terminado', responseApi.message ?? '');
      }
      else {
        Get.snackbar('Registro fallido', responseApi.message ?? '');
      }
      Get.snackbar('Formulario valido', 'Vuelve a la pagina anterior');
    }
  }

  bool validador(
      String nombre,
      String telefono,
      String direccion,
      String email
      ){
    if (direccion.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar la direccion');
      return false;
    }
    if (nombre.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu nombre');
      return false;
    }
    if (telefono.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar el telefono');
      return false;
    }
    if (email.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu email');
      return false;
    }
    return true;
  }

  void volver(){
    Get.offNamed('/mantenedores/menu');
  }

}