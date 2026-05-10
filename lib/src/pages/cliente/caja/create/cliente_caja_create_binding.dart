import 'package:get/get.dart';
import 'package:posmobilfinal/src/pages/cliente/caja/create/cliente_caja_create_controller.dart';

class ClienteCajaCreateBinding extends Bindings {
  @override
  void dependencies() {
    // Usar put permanente para mantener el controlador vivo
    Get.put<ClienteCajaCreateController>(ClienteCajaCreateController(), permanent: true);
  }
}
