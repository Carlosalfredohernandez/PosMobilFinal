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
  Future<List<UsuarioEmpresa>> findUsers([String? empresaId]) async {
    // Si se pasa empresaId, usarlo, si no usar el id de sesión
    var id = empresaId ?? userSession.id;
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

    if (response.body == null) {
      Get.snackbar('Error: ', 'No se pudo ejecutar la petición');
      return ResponseApi();
    }

    // Aceptar tanto 200 como 201 como éxito
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Si el backend responde con el formato esperado para ResponseApi
      if (response.body is Map && response.body.containsKey('success')) {
        return ResponseApi.fromJson(response.body);
      } else {
        // Si el backend responde solo con los datos del usuario/empresa
        return ResponseApi(
          success: true,
          message: 'Login exitoso',
          data: response.body,
        );
      }
    } else {
      // Otros códigos de estado
      String msg = response.body is Map && response.body['message'] != null
          ? response.body['message']
          : 'Error de conexión o credenciales';
      Get.snackbar('Error', msg);
      return ResponseApi(success: false, message: msg);
    }
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