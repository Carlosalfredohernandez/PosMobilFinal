import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/environment/environment.dart';
import 'package:posmobilfinal/src/models/response_api.dart';
import 'package:posmobilfinal/src/models/usuario.dart';
import 'package:posmobilfinal/src/models/usuario_empresa.dart';

class UsuariosEmpresaProvider extends GetConnect{
  String url = '${Environment.API_URL}api/usuariosempresa';
  Usuario userSession = Usuario.fromJson(GetStorage().read('usuario') ?? {});

  Future<ResponseApi> create(UsuarioEmpresa usuario) async{
    Response response = await post(
        '$url/create',
        usuario.toJson(),
        headers: {
          'Content-Type': 'application/json'
        }
    );
    ResponseApi responseApi =ResponseApi.fromJson(response.body);
    return responseApi;
  }
  Future<List<UsuarioEmpresa>> findUsers() async {
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

    List<UsuarioEmpresa> users = UsuarioEmpresa.fromJsonList(response.body);
    return users;
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

  Future<ResponseApi> update(UsuarioEmpresa usuario, var idRol, var local) async {
    Response response = await put(
        '$url/update/$idRol/$local',
        usuario.toJson(),
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
  Future<ResponseApi> updateEm(Usuario usuario, var idRol, var local) async {
    Response response = await put(
        '$url/update/$idRol/$local',
        usuario.toJson(),
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
  Future<ResponseApi> updateE(UsuarioEmpresa usuario, var idRol, var local) async {
    Response response = await put(
        '$url/update/$idRol/$local',
        usuario.toJson(),
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
  Future<List<UsuarioEmpresa>> findUsersE() async {
  var id = userSession.id;
  Response response = await get(
    '$url/findUsers/$id',
    headers: {
      'Content-Type': 'application/json'
    }
  );

  if (response.statusCode == 401) {
    Get.snackbar('Peticion Denegada', 'No esta autorizado para realizar esta peticion');
    return [];
  }

  if (response.body == null || response.body is! List) {
    return [];
  }

  List<UsuarioEmpresa> users = UsuarioEmpresa.fromJsonList(response.body);
  return users;
}
  
}