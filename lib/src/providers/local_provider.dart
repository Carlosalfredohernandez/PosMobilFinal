import 'package:get/get.dart';
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/environment/environment.dart';
import 'package:posmobilfinal/src/models/local.dart';
import 'package:posmobilfinal/src/models/response_api.dart';
import 'package:posmobilfinal/src/models/usuario.dart';

class LocalProvider extends GetConnect{
    Future<ResponseApi> deleteLocal(String id) async {
      Response response = await super.delete(
        '$url/delete/$id',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        },
      );
      if (response.statusCode == 404) {
        return ResponseApi(success: false, message: 'Local no encontrado (404)');
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
  String url = '${Environment.API_URL}api/locales';
  Usuario userSession = Usuario.fromJson(GetStorage().read('usuario') ?? {});

  Future<ResponseApi> create(Local local) async {
    Response response = await post(
        '$url/create',
        local.toJson(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }
// ...existing code...

  Future<ResponseApi> update(Local local) async {
    Response response = await put(
      '$url/update/${local.id}',
      local.toJson(),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.sessionToken ?? ''
      }
    );

    ResponseApi responseApi = ResponseApi.fromJson(response.body);
    return responseApi;
  }

// ...existing code...
  Future<List<Local>> findLocals() async {
    var usuario = userSession.id;
    Response response = await get(
        '$url/findLocals/$usuario',
        headers: {
          'Content-Type': 'application/json'
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    if (response.statusCode == 401) {
      Get.snackbar('Peticion Denegada', 'No esta autorizado para realizar esta peticion');
      return [];
    }

    List<Local> locales = Local.fromJsonList(response.body);
    return locales;
  }

}