
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/environment/environment.dart';
import 'package:posmobilfinal/src/models/response_api.dart';
import 'package:posmobilfinal/src/models/usuario.dart';
import 'package:posmobilfinal/src/models/usuario_empresa.dart';

class UsuariosEmpresaProvider extends GetConnect {
  String url = '${Environment.API_URL}api/usuariosempresa';
  Usuario userSession = Usuario.fromJson(GetStorage().read('usuario') ?? {});

  // Login de usuario empresa
  Future<ResponseApi> login(String rut, String clave) async {
    print('🔐 Iniciando login de empresa...');
    print('📝 RUT: $rut');
    try {
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

      print('📡 Status Code: [34m${response.statusCode}[0m');
      print('📡 Response Body: ${response.body}');
      print('📡 Response Headers: ${response.headers}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('❌ Error HTTP ${response.statusCode}: ${response.body}');
        return ResponseApi(
          success: false,
          message: 'Error del servidor: ${response.statusCode}'
        );
      }

      ResponseApi responseApi;
      if (response.body is Map) {
        responseApi = ResponseApi.fromJson(Map<String, dynamic>.from(response.body));
      } else if (response.body is String) {
        String bodyString = response.body;
        if (!bodyString.startsWith('{') && !bodyString.startsWith('[')) {
          print('❌ Respuesta no es JSON: ${bodyString}');
          return ResponseApi(
            success: false,
            message: 'El servidor devolvió una respuesta inválida'
          );
        }
        responseApi = ResponseApi.fromJson(json.decode(bodyString));
      } else {
        print('❌ Tipo de respuesta no reconocido: ${response.body.runtimeType}');
        return ResponseApi(
          success: false,
          message: 'Formato de respuesta no válido'
        );
      }

      // Procesamiento extra si es necesario
      if (responseApi.success == true && responseApi.data != null) {
        print('✅ Login exitoso empresa');
        // Aquí puedes adaptar los datos si es necesario
      }
      return responseApi;
    } catch (e, stack) {
      print('❗ Excepción en login usuario empresa: $e');
      print('❗ Stacktrace: $stack');
      Get.snackbar('Error', 'No se pudo conectar con el servidor. Detalle: $e');
      return ResponseApi(success: false, message: 'Error de conexión: $e');
    }
  }

  // Crear usuario
  Future<ResponseApi> create(UsuarioEmpresa usuario) async {
    Response response = await post(
      '$url/create',
      usuario.toJson(),
      headers: {'Content-Type': 'application/json'},
    );
    return ResponseApi.fromJson(response.body);
  }

  // Obtener usuarios
  Future<List<UsuarioEmpresa>> findUsers([String? empresaId]) async {
    var id = empresaId ?? userSession.id;
    Response response = await get(
      '$url/findUsers/$id',
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 401) {
      Get.snackbar('Peticion Denegada', 'No esta autorizado para realizar esta peticion');
      return [];
    }
    return UsuarioEmpresa.fromJsonList(response.body);
  }

  // Actualizar usuario
  Future<ResponseApi> update(UsuarioEmpresa usuario, var idRol, var local) async {
    Response response = await put(
      '$url/update/$idRol/$local',
      usuario.toJson(),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo actualizar la informacion');
      return ResponseApi();
    }
    if (response.statusCode == 401) {
      Get.snackbar('Error', 'No esta autorizado para realizar esta peticion');
      return ResponseApi();
    }
    return ResponseApi.fromJson(response.body);
  }

  // Eliminar usuario
  Future<ResponseApi> eliminarUsuario(String id) async {
    Response response = await delete(
      '$url/delete/$id',
      headers: {'Content-Type': 'application/json'},
    );
    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo eliminar el usuario');
      return ResponseApi(success: false, message: 'Respuesta vacía del servidor');
    }
    if (response.statusCode == 401) {
      Get.snackbar('Error', 'No está autorizado para realizar esta petición');
      return ResponseApi(success: false, message: 'No autorizado');
    }
    // Manejar respuesta tipo String o Map
    if (response.body is String) {
      // Intentar decodificar como JSON, si falla, usar como mensaje
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return ResponseApi.fromJson(decoded);
        } else {
          return ResponseApi(success: true, message: response.body);
        }
      } catch (_) {
        return ResponseApi(success: true, message: response.body);
      }
    } else if (response.body is Map) {
      return ResponseApi.fromJson(Map<String, dynamic>.from(response.body));
    } else {
      return ResponseApi(success: false, message: 'Respuesta inesperada del servidor');
    }
  }
}