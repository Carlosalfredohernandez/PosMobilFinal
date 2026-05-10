import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/environment/environment.dart';
import 'package:posmobilfinal/src/models/proveedores.dart';
import 'package:posmobilfinal/src/models/response_api.dart';
import 'package:posmobilfinal/src/models/usuario.dart';

class ProveedorProvider extends GetConnect{
    Future<ResponseApi> deleteProveedor(String id) async {
      Response response = await super.delete(
        '$url/delete/$id',
        headers: {
          'Content-Type': 'application/json'
        },
      );
      if (response.statusCode == 404) {
        return ResponseApi(success: false, message: 'Proveedor no encontrado (404)');
      }
      dynamic data = response.body;
      if (data is String) {
        try {
          data = json.decode(data);
        } catch (e) {
          return ResponseApi(success: false, message: data.toString());
        }
      }
      return ResponseApi.fromJson(data);
    }
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

    dynamic data = response.body;
    if (data is String) {
      try {
        data = json.decode(data);
      } catch (e) {
        return ResponseApi(success: false, message: data.toString());
      }
    }
    return ResponseApi.fromJson(data);
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

  Future<ResponseApi> update(Proveedor proveedor) async {
    final body = proveedor.toJson();
    print('Enviando al backend (update):');
    print(body);
    Response response = await put(
      '$url/update', // <--- sin /${proveedor.id}
      body,
      headers: {
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 404) {
      return ResponseApi(success: false, message: 'Proveedor no encontrado (404)');
    }
    dynamic data = response.body;
    if (data is String) {
      try {
        data = json.decode(data);
      } catch (e) {
        return ResponseApi(success: false, message: data.toString());
      }
    }
    return ResponseApi.fromJson(data);
  }
}

