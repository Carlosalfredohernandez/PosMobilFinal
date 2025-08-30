import 'package:get/get.dart';

class MantenedoresMenuController extends GetxController{
  void goToCategory() {
    Get.toNamed('/inicio/cliente/agregar/categoria');
  }
  void goToProduct() {
    Get.offNamedUntil('/mantenedores/productos', (route) => false);
  }
  void goToBodega() {
    Get.offNamedUntil('/mantenedores/proveedor', (route) => false);
  }
  void goToUser() {
    Get.offNamedUntil('/mantenedores/maestros/busqueda', (route) => false);
  }
  void goToHome() {
    Get.offNamedUntil('/inicio/cliente', (route) => false);
  }
  void goToLocal() {
    Get.offNamedUntil('/mantenedores/local', (route) => false);
  }
}