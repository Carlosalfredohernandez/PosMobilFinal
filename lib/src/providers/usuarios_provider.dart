import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/environment/environment.dart';
import '../models/response_api.dart';

import '../models/usuario.dart';


class UsuariosProvider extends GetConnect{

  String url = '${Environment.API_URL}api/usuarios';
  Usuario userSession = Usuario.fromJson(GetStorage().read('usuario') ?? {});

  Future<ResponseApi> create(Usuario usuario, var rol) async{

    Response response = await post(
        '$url/create/$rol',
        usuario.toJson(),
        headers: {
          'Content-Type': 'application/json'
        }
    );
    ResponseApi responseApi =ResponseApi.fromJson(response.body);
    return responseApi;
  }

  Future<ResponseApi> login(String rut, String clave) async{

    Response response = await post(
        '$url/login',
        {
          'rut': rut,
          'clave': clave
        },
        headers: {
          'Content-Type': 'application/json'
        }
    );

    if(response.body == null){
      Get.snackbar('Error: ', 'No se pudo ejecutar la peticion');
      return ResponseApi();
    }
    
    ResponseApi responseApi =ResponseApi.fromJson(response.body);
    return responseApi;
  }

  Future<ResponseApi> update(Usuario user) async {
    Response response = await put(
        '$url/update',
        user.toJson(),
        headers: {
          'Content-Type': 'application/json',
          //'Authorization': userSession.sessionToken!
        }
    );
    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo actualizar la informacion');
      return ResponseApi();
    }
    if (response.statusCode == 401) {
      Get.snackbar('Error', 'No esta autorizado para realizar esta peticion');
      return ResponseApi();
    }

    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }

  Future<ResponseApi> updateRol(var idUser, var idRol) async {
    Response response = await get(
        '$url/updateRol/$idUser/$idRol',
        headers: {
          'Content-Type': 'application/json',
          //'Authorization': userSession.sessionToken!
        }
    );
    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo actualizar la informacion');
      return ResponseApi();
    }
    if (response.statusCode == 401) {
      Get.snackbar('Error', 'No esta autorizado para realizar esta peticion');
      return ResponseApi();
    }

    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }


  Future<List<Usuario>> findUsers() async {
    var id = userSession.id;
    Response response = await get(
        '$url/findUsers/$id',
        headers: {
          'Content-Type': 'application/json'
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    if (response.statusCode == 401) {
      Get.snackbar('Peticion Denegada', 'No esta autorizado para realizar esta peticion');
      return [];
    }

    List<Usuario> users = Usuario.fromJsonList(response.body);
    return users;
  }

}