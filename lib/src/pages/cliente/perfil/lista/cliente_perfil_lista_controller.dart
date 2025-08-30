import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/models/usuario.dart';

class ClientePerfilListaController extends GetxController {

  var user = Usuario.fromJson(GetStorage().read('usuario') ?? {}).obs;

  void goToPerfilEditar() {
    Get.toNamed('/inicio/cliente/perfil/editar');
  }

}