import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/models/local.dart';
import 'package:posmobilfinal/src/models/response_api.dart';
import 'package:posmobilfinal/src/models/usuario.dart';
import 'package:posmobilfinal/src/models/usuario_empresa.dart';
import 'package:posmobilfinal/src/providers/local_provider.dart';
import 'package:posmobilfinal/src/providers/usuarios_empresa_provider.dart';
import 'package:posmobilfinal/src/providers/usuarios_provider.dart';


class MantenedoresMaestrosCrearController extends GetxController{
  var nombrelocal = ''.obs;
  List<Local> locales = <Local>[].obs;

  TextEditingController claveController = TextEditingController();
  TextEditingController confirmarClaveController = TextEditingController();
  TextEditingController rutController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nombreController = TextEditingController();

  Usuario userSession = Usuario.fromJson(GetStorage().read('usuario') ?? {});
 
  LocalProvider localProvider = LocalProvider();
  UsuariosEmpresaProvider usuariosEmpresaProvider = UsuariosEmpresaProvider();
  UsuariosProvider usuariosProvider = UsuariosProvider();

  MantenedoresMaestrosCrearController() {
    getLocales();
  }

  void getLocales() async {
    var result = await localProvider.findLocals();
    locales.clear();
    locales.addAll(result);
  }

  void create() async {
    String clave = claveController.text.trim();
    String confirmarClave = claveController.text.trim();
    String rut = rutController.text.trim();
    String email = emailController.text.trim();
    String nombre = nombreController.text.trim();

    if (validador(clave,confirmarClave,rut,email,nombre,nombrelocal.value)){
      UsuarioEmpresa usuarioEmpresa = UsuarioEmpresa(
          rut: rut,
          nombreUsuario: nombre,
          localAsignado: nombrelocal.value,
          empresa: userSession.id,
          rol: 'CAJERO',
          password: clave
      );
      print(nombrelocal);
      ResponseApi responseApi = await usuariosEmpresaProvider.create(usuarioEmpresa);
      responseApi.success == true
          ? Get.snackbar('Registro fallido', responseApi.message ?? '')
          : Get.snackbar('Formulario valido', 'Vuelve a la pagina anterior');
    }
  }
  bool validador(
      String clave,
      String confirmarClave,
      String rut,
      String email,
      String nombre,
      String local
      ){
    if (clave.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu clave');
      return false;
    }
    if (nombre.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar el nombre del usuario');
      return false;
    }
    // if (email.isEmpty) {
    //   Get.snackbar('Formulario no valido', 'Debes ingresar el mail del usuario');
    //   return false;
    // }
    if (rut.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar el rut del Usuario');
      return false;
    }
    if (local.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar el local del Usuario');
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