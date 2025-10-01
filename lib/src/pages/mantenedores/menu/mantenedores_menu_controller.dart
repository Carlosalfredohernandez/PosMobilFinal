import 'package:get/get.dart';

class MantenedoresMenuController extends GetxController {
  void goToCategory() async {
    await Get.toNamed('/inicio/cliente/agregar/categoria');
    Get.offNamed('/mantenedores/menu');
  }

  void goToProduct() async {
    await Get.toNamed('/mantenedores/productos');
    Get.offNamed('/mantenedores/menu');
  }

  void goToBodega() async {
    await Get.toNamed('/mantenedores/proveedor');
    Get.offNamed('/mantenedores/menu');
  }

  void goToUser() async {
    await Get.toNamed('/mantenedores/maestros/busqueda');
    Get.offNamed('/mantenedores/menu');
  }

  void goToHome() {
    Get.offNamedUntil('/inicio/cliente', (route) => false);
  }

  void goToLocal() async {
    await Get.toNamed('/mantenedores/local');
    Get.offNamed('/mantenedores/menu');
  }
}