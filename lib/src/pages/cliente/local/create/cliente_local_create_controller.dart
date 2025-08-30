import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/models/local.dart';
import 'package:posmobil/src/models/response_api.dart';
import 'package:posmobil/src/models/usuario.dart';
import 'package:posmobil/src/providers/local_provider.dart';

class ClienteLocalCreateController extends GetxController{

  Usuario sesionUsuario = Usuario.fromJson(GetStorage().read('usuario'));
  TextEditingController nombreController = TextEditingController();
  TextEditingController pos_numero = TextEditingController();
  LocalProvider localProvider = LocalProvider();


  // var nombreCategoria = ''.obs;
  // List<Categoria> categorias = <Categoria>[].obs;


  // void getCategorias() async {
  //   var result = await categoriasProvider.getAllByUser();
  //   categorias.clear();
  //   categorias.addAll(result);
  // }

  void createLocal() async {

    String usuario = sesionUsuario.id.toString();
    String nombre = nombreController.text;
    String PNumero = pos_numero.text;

    if (usuario.isNotEmpty && nombre.isNotEmpty && PNumero.isNotEmpty) {
      Local local = Local(
          usuario: usuario,
          nombreLocal: nombre,
        posNumero: PNumero
      );

      ResponseApi responseApi = await localProvider.create(local);
      Get.snackbar('Proceso terminado', responseApi.message ?? '');

      if (responseApi.success == true) {
        clearForm();
        Get.offNamedUntil('/inicio/cliente', (route) => false);
      }

    }
    else {
      Get.snackbar('Formulario no valido', 'Ingresa todos los campos para crear el local');
    }

  }

  void clearForm() {
    nombreController.text = '';
  }
  void regresar(){
    Get.offNamedUntil('/mantenedores/menu', (route) => false);
  }
}