import 'package:get/get.dart';

class MenuGeneralPageController extends GetxController {

  void goToCategory() async {
    await Get.toNamed('/inicio/cliente/agregar/categoria');
    Get.offNamed('/menugeneral');
  }

  void goToProduct() async {
    await Get.toNamed('/mantenedores/productos');
    Get.offNamed('/menugeneral');
  }

  void goToBodega() async {
    await Get.toNamed('/mantenedores/proveedor');
    Get.offNamed('/menugeneral');
  }

  void goToinformesventas() async {
    await Get.toNamed('/informes/ventas');
    Get.offNamed('/menugeneral');
  }
  void goToEstadisticas() async {
    await Get.toNamed('/informes/estadisticas');
    Get.offNamed('/menugeneral');
  }
  void goToInventarios() async {
    //await Get.toNamed('inventarios/informes');
    await Get.toNamed('inventarios/create');
    Get.offNamed('/menugeneral');
  }

  void goToUser() async {
    //await Get.toNamed('/mantenedores/maestros/busqueda');
    await Get.toNamed('/inicio/cliente/mantenedorlistadorusuarios');
    //await Get.toNamed('/mantenedores/maestros/usuarios');
    
    Get.offNamed('/menugeneral');
  }

  void goToHome() {
    //Get.offNamedUntil('/inicio/cliente', (route) => false);
    Get.offNamed('/inicio/cliente');
  }

  void goToLocal() async {
    await Get.toNamed('/mantenedores/local');
    Get.offNamed('/menugeneral');
  }
}