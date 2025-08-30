import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/environment/environment.dart';
import 'package:posmobil/src/models/inventario.dart';
import 'package:posmobil/src/models/response_api.dart';
import 'package:posmobil/src/models/usuario.dart';

import '../models/producto.dart';

class InventarioProvider extends GetConnect{
  String url = '${Environment.API_URL}api/inventario';
  Usuario userSession = Usuario.fromJson(GetStorage().read('usuario') ?? {});

  Future<ResponseApi> create(Inventario inventario) async {
    Response response = await post(
        '$url/create',
        inventario.toJson(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }

  Future<List<Inventario>> getAllByUser() async {
    var usuario = userSession.id;
    Response response = await get(
        '$url/getAllByUser/$usuario',
        headers: {
          'Content-Type': 'application/json'
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    if (response.statusCode == 401) {
      Get.snackbar('Peticion Denegada', 'No esta autorizado para realizar esta peticion');
      return [];
    }

    List<Inventario> inventario = Inventario.fromJsonList(response.body);
    return inventario;
  }

  Future<List<Inventario>> getByCodigo(var producto) async {
    var usuario = userSession.id;
    Response response = await get(
        '$url/getByCodigo/$usuario/$producto',
        headers: {
          'Content-Type': 'application/json'
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    if (response.statusCode == 401) {
      Get.snackbar('Peticion Denegada', 'No esta autorizado para realizar esta peticion');
      return [];
    }

    List<Inventario> inventario = Inventario.fromJsonList(response.body);
    return inventario;
  }

  Future<List<Producto>> consultaInventario() async {
    String userID = userSession.id.toString();
    Response response = await get(
        '$url/consultaInventario/$userID',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    if (response.statusCode == 401) {
      Get.snackbar('Peticion denegada', 'Tu usuario no tiene permitido leer esta informacion');
      return [];
    }

    List<Producto> productos = Producto.fromJsonList(response.body);
    print(productos);
    return productos;
  }

  Future<List<Producto>> getAllByDate(var inicial, var fin) async {
    String userID = userSession.id.toString();
    Response response = await get(
        '$url/getAllByDate/$userID/$inicial/$fin',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    if (response.statusCode == 401) {
      Get.snackbar('Peticion denegada', 'Tu usuario no tiene permitido leer esta informacion');
      return [];
    }

    List<Producto> productos = Producto.fromJsonList(response.body);
    print(productos);
    return productos;
  }

}