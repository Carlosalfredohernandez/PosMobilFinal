import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/models/response_api.dart';
import 'package:posmobilfinal/src/models/usuario.dart';
import 'package:posmobilfinal/src/pages/cliente/perfil/lista/cliente_perfil_lista_controller.dart';
import 'package:posmobilfinal/src/providers/usuarios_provider.dart';


class ClientePerfilEditarController extends GetxController{
  var user = Usuario.fromJson(GetStorage().read('usuario'));
  ClientePerfilListaController info = Get.find();

  TextEditingController telefonoController = TextEditingController();
  TextEditingController claveController = TextEditingController();
  TextEditingController confirmarClaveController = TextEditingController();
  TextEditingController comunaController = TextEditingController();
  TextEditingController numeroController = TextEditingController();
  TextEditingController regionController = TextEditingController();
  TextEditingController calleController = TextEditingController();


  UsuariosProvider usuariosProvider = UsuariosProvider();

  ClientePerfilEditarController(){
    telefonoController.text = user.telefono ?? '';
    comunaController.text = user.comuna ?? '';
    numeroController.text = user.numero ?? '';
    regionController.text = user.region ?? '';
    calleController.text = user.calle ?? '';
  }

  void actualizar() async{
    String telefono = telefonoController.text.trim();
    String clave = claveController.text.trim();
    String confirmarClave = claveController.text.trim();
    String region = regionController.text.trim();
    String calle = calleController.text.trim();
    String numero = numeroController.text.trim();
    String comuna = comunaController.text.trim();

    if (validador(telefono,clave,confirmarClave,region,comuna,numero,calle)){
      Usuario usuario = Usuario(
        telefono: telefono,
        clave: clave,
        region: region,
        numero: numero,
        comuna: comuna,
        calle: calle,
        id: user.id,
        rut: user.rut
      );
      ResponseApi responseApi = await usuariosProvider.update(usuario);
      Get.snackbar('Proceso terminado', responseApi.message ?? '');
      print('Usuario a actualizar: ${responseApi.data}');
      if (responseApi.success == true ){
        GetStorage().write('usuario',responseApi.data);
        info.user.value = Usuario.fromJson(GetStorage().read('usuario') ?? {});
      }
      else {
        Get.snackbar('Registro fallido', responseApi.message ?? '');
      }
      Get.snackbar('Formulario valido', 'Vuelve a la pagina anterior');
    }
  }

  //Validadores.

  bool validador(
      String telefono,
      String clave,
      String confirmarClave,
      String region,
      String comuna,
      String numero,
      String calle
      ){
    if (clave.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu clave');
      return false;
    }
    if (telefono.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu numero telefonico');
      return false;
    }
    if (comuna.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu comuna de residencia');
      return false;
    }
    if (numero.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu numero de residencia');
      return false;
    }
    if (calle.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu calle de residencia');
      return false;
    }
    if (region.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu region de residencia');
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