import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobilfinal/src/models/response_api.dart';
import 'package:posmobilfinal/src/models/usuario.dart';
import 'package:posmobilfinal/src/providers/usuarios_provider.dart';

class RegistroController extends GetxController{

  TextEditingController nombreController = TextEditingController();
  TextEditingController rutController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController claveController = TextEditingController();
  TextEditingController confirmarClaveController = TextEditingController();

  UsuariosProvider usuariosProvider = UsuariosProvider();

  void registro() async{
    String nombre = nombreController.text;
    String rut = rutController.text.trim();
    String email = emailController.text.trim();
    String clave = claveController.text.trim();
    String confirmarClave = claveController.text.trim();

    if (validador(nombre,clave,confirmarClave,rut,email)){
      Usuario usuario = Usuario(
        nombre: nombre,
        rut: rut,
        email: email,
        clave: clave,
      );
      ResponseApi response = await usuariosProvider.create(usuario,2);
      Get.snackbar('Usuario: ', nombre);
      Get.offNamedUntil('/', (route) => false);

    }

  }

  //Validadores.

  bool validador(
      String nombre,
      String clave,
      String confirmarClave,
      String rut,
      String email
      ){
    if (clave.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu clave');
      return false;
    }
    if (nombre.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu nombre');
      return false;
    }
    if (rut.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu rut');
      return false;
    }
    if (email.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu email');
      return false;
    }
    if (clave.isEmpty||confirmarClave.isEmpty){
      Get.snackbar('Formulario no valido', 'Debes ingresar tu clave');
      return false;
    }
    if (clave!= confirmarClave) {
      Get.snackbar('Formulario no valido', 'Tu clave debes confirmar tu clave');
      return false;
    }
    return true;
  }

}