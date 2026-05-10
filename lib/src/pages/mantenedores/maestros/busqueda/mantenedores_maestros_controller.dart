import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobilfinal/src/models/usuario.dart';
import 'package:posmobilfinal/src/models/usuario_empresa.dart';
import 'package:posmobilfinal/src/pages/mantenedores/maestros/ventana/mantenedores_maestros_usuarios_page.dart';
import 'package:posmobilfinal/src/providers/usuarios_empresa_provider.dart';


class MantenedoresMaestrosController extends GetxController{
  var userName = ''.obs;
  Timer? searchOnStoppedTyping;
  UsuariosEmpresaProvider usuariosProvider = UsuariosEmpresaProvider();
  List<UsuarioEmpresa> users =<UsuarioEmpresa>[].obs;
  MantenedoresMaestrosController(){
    getUsuarios();
  }

  void volver(){
    Get.offNamed('/mantenedores/menu');
  }

  void onChangeText(String text){
    const duration = Duration(milliseconds: 800);
    if (searchOnStoppedTyping != null) {
      searchOnStoppedTyping?.cancel();
    }
    searchOnStoppedTyping = Timer(duration, () {
      userName.value = text;
    });
  }

  void getUsuarios() async{
    var result = await usuariosProvider.findUsers();
    users.clear();
    users.addAll(result);
  }

  void openBottomSheet (BuildContext context, Usuario user) async {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MantenedoresMaestrosUsuariosPage(usuario: user)
    ));
  }
}