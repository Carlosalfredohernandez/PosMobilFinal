import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../models/categoria.dart';
import '../../../../models/response_api.dart';
import '../../../../models/usuario.dart';
import '../../../../providers/categorias_provider.dart';

class ClienteCategoriasCrearController extends GetxController {

  Usuario sesionUsuario = Usuario.fromJson(GetStorage().read('usuario'));
  TextEditingController nombreController = TextEditingController();
  CategoriasProvider categoriasProvider = CategoriasProvider();


  var nombreCategoria = ''.obs;
  List<Categoria> categorias = <Categoria>[].obs;

  ClienteCategoriasCrearController() {
    getCategorias();
  }

  void getCategorias() async {
    var result = await categoriasProvider.getAllByUser();
    categorias.clear();
    categorias.addAll(result);
  }

  void createCategory() async {

    String usuario = sesionUsuario.id.toString();
    String nombreCategoria = nombreController.text;
    print('Usuario: $usuario');
    print('Nombre: $nombreCategoria');

    if (usuario.isNotEmpty && nombreCategoria.isNotEmpty) {
      Categoria categoria = Categoria(
        usuario: usuario,
        nombreCategoria: nombreCategoria
      );

      ResponseApi responseApi = await categoriasProvider.create(categoria);
      Get.snackbar('Proceso terminado', responseApi.message ?? '');

      if (responseApi.success == true) {
        clearForm();
        getCategorias();
        Get.offNamedUntil('/inicio/cliente', (route) => false);
      }

    }
    else {
      Get.snackbar('Formulario no valido', 'Ingresa todos los campos para crear la categoria');
    }
    getCategorias();

  }

  void clearForm() {
    nombreController.text = '';
  }
  void regresar(){
    Get.offNamedUntil('/inicio/cliente', (route) => false);
  }

}