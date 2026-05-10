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
    String nombreCategoria = nombreController.text.trim();
    print('Usuario: $usuario');
    print('Nombre: $nombreCategoria');

    if (usuario.isNotEmpty && nombreCategoria.isNotEmpty) {
      // Validar que no exista ya una categoría con ese nombre (case-insensitive)
      bool existe = categorias.any((cat) => cat.nombreCategoria?.toLowerCase() == nombreCategoria.toLowerCase());
      if (existe) {
        Get.snackbar('Categoría duplicada', 'Ya existe una categoría con ese nombre');
        return;
      }
      Categoria categoria = Categoria(
        usuario: usuario,
        nombreCategoria: nombreCategoria
      );

      try {
        ResponseApi responseApi = await categoriasProvider.create(categoria);
        Get.snackbar('Proceso terminado', responseApi.message ?? '');

        if (responseApi.success == true) {
          clearForm();
          getCategorias();
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.back(); // Volver solo una pantalla atrás, más seguro
          });
        }
      } catch (e) {
        Get.snackbar('Error', 'Ocurrió un error al crear la categoría');
      }
    } else {
      Get.snackbar('Formulario no valido', 'Ingresa todos los campos para crear la categoria');
    }
  }

  void clearForm() {
    nombreController.text = '';
  }
  void regresar(){
    Get.offNamedUntil('/inicio/cliente', (route) => false);
  }

}