import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/models/response_api.dart';
import 'package:posmobil/src/models/usuario.dart';

import '../../providers/usuarios_provider.dart';

class LoginController extends GetxController{

  TextEditingController rutController = TextEditingController();
  TextEditingController claveController = TextEditingController();

  UsuariosProvider usuariosProvider = UsuariosProvider();



  void irARegistroPage(){
    Get.toNamed('/registro');
  }

  void login() async{
    String rut = rutController.text.trim();
    String clave = claveController.text.trim();

    if(validador(clave,rut)){
      ResponseApi responseApi = await usuariosProvider.login(rut, clave);

      if (responseApi.success == true){
        GetStorage().write('usuario', responseApi.data);
        Usuario sesionUsuario = Usuario.fromJson(GetStorage().read('usuario') ?? {});
        sesionUsuario.tipoContrato == 'NO'
            ? Get.snackbar('El usuario no esta autorizado', 'Contacta al administrador')
            : sesionUsuario.roles![0].id == '3' ? irAHomePageCajero() : irAHomePage();
      }
      else{
        Get.snackbar('Fallido ', responseApi.message ?? '');
      }
    }
  }

  void irAHomePage(){
    Get.offNamedUntil('/inicio/cliente', (route) => false);
  }
  void irAHomePageCajero(){
    Get.offNamedUntil('/inicio/cajero', (route) => false);
  }


  //Validadores.

  bool validador(String clave, String rut){
    if (rut.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar el rut de tu empresa o usuario');
      return false;
    }
    if (clave.isEmpty){
      Get.snackbar('Formulario no valido', 'Debes ingresar tu clave');
      return false;
    }
    return true;
  }
  void logout() {
    GetStorage().erase();
    Get.offAllNamed('/login'); // Navega al login y limpia el historial
  }
}
