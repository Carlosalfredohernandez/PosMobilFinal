import 'package:get/get.dart';


class InventariosMenuController extends GetxController{

  void goToCreate() {
    Get.toNamed('/inventarios/create');
  }
  void goToVista() {
    Get.toNamed('/inventarios/vista', arguments: {'id': ''});
  }
  void goToInformes() {
    Get.toNamed('/inventarios/informes');
  }
}