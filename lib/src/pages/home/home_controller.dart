import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/models/usuario.dart';


class HomeController extends GetxController{

  Usuario usuario = Usuario.fromJson(GetStorage().read('usuario') ?? {});

  HomeController(){
    print ('USUARIO DE SESION: ${usuario.toJson()}');
  }

  void desconectarse(){
    GetStorage().remove('usuario');
    Get.offNamedUntil('/', (route) => false);
  }



}