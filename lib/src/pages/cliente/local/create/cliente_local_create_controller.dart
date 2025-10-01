import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/models/local.dart';
import 'package:posmobil/src/models/response_api.dart';
import 'package:posmobil/src/models/usuario.dart';
import 'package:posmobil/src/providers/local_provider.dart';

class ClienteLocalCreateController extends GetxController {
  Usuario sesionUsuario = Usuario.fromJson(GetStorage().read('usuario'));
  final LocalProvider localProvider = LocalProvider();

  var locales = <Local>[].obs;

  TextEditingController nombreController = TextEditingController();
  TextEditingController posNumeroController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    cargarLocales();
  }

  Future<void> cargarLocales() async {
    try {
      final result = await localProvider.findLocals();
      locales.value = result;
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los locales');
    }
  }

  Future<ResponseApi?> crearLocal(String nombre, String numero) async {
    try {
      Local nuevoLocal = Local(
        usuario: sesionUsuario.id.toString(),
        nombreLocal: nombre,
        posNumero: numero,
      );
      ResponseApi response = await localProvider.create(nuevoLocal);
      if (response.success == true) {
        Get.snackbar('Éxito', response.message ?? 'Local creado correctamente');
        await cargarLocales();
      } else {
        Get.snackbar('Error', response.message ?? 'No se pudo crear el local');
      }
      return response;
    } catch (e) {
      Get.snackbar('Error', 'No se pudo crear el local');
      return null;
    }
  }

  Future<ResponseApi?> editarLocal(Local local, String nombre, String numero) async {
    try {
      local.nombreLocal = nombre;
      local.posNumero = numero;
      ResponseApi response = await localProvider.update(local);
      if (response.success == true) {
        Get.snackbar('Éxito', response.message ?? 'Local actualizado correctamente');
        await cargarLocales();
      } else {
        Get.snackbar('Error', response.message ?? 'No se pudo actualizar el local');
      }
      return response;
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar el local');
      return null;
    }
  }

  void clearForm() {
    nombreController.text = '';
    posNumeroController.text = '';
  }

  void regresar() {
    Get.offNamedUntil('/mantenedores/menu', (route) => false);
  }
}