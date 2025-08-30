import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/environment/environment.dart';
import 'package:posmobil/src/models/proveedores.dart';
import 'package:posmobil/src/models/response_api.dart';
import 'package:posmobil/src/models/usuario.dart';

class ProveedorProvider extends GetConnect{
  String url = '${Environment.API_URL}api/proveedores';
  Usuario userSession = Usuario.fromJson(GetStorage().read('usuario') ?? {});

  Future<ResponseApi> create(Proveedor proveedor) async {
    proveedor.idUsuario = int.parse(userSession.id!);
    Response response = await post(
        '$url/create',
        proveedor.toJson(),
        headers: {
          'Content-Type': 'application/json'
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }

  Future<List<Proveedor>> getProveedor() async {
    var usuario = userSession.id;
    Response response = await get(
        '$url/getProveedor/$usuario',
        headers: {
          'Content-Type': 'application/json'
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    if (response.statusCode == 401) {
      Get.snackbar('Peticion Denegada', 'No esta autorizado para realizar esta peticion');
      return [];
    }

    List<Proveedor> proveedores = Proveedor.fromJsonList(response.body);
    return proveedores;
  }

}