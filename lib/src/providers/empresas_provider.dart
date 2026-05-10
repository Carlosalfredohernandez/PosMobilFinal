import 'package:get/get.dart';
import 'dart:convert';
import 'package:posmobilfinal/src/models/usuario.dart';
import 'package:posmobilfinal/src/models/response_api.dart';
import 'package:posmobilfinal/src/environment/environment.dart';

class EmpresasProvider extends GetConnect {
  // Función auxiliar para validar si un string es JSON
  bool _isJson(String str) {
    try {
      json.decode(str);
      return true;
    } catch (_) {
      return false;
    }
  }
  String url = '${Environment.API_URL}api/usuarios';

  Future<List<Usuario>> getUsuarios() async {
    // Usar la ruta correcta para obtener todos los usuarios
    final response = await get('$url/all', headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200 && response.body is List) {
      return Usuario.fromJsonList(response.body);
    }
    return [];
  }

  Future<ResponseApi> crearUsuario(String nombre, String rut, String email, String clave) async {
    // Cambiar la ruta para usar create/rol
    final response = await post('$url/create/rol', {
      'nombre': nombre,
      'rut': rut,
      'email': email,
      'clave': clave,
    }, headers: {'Content-Type': 'application/json'});
    if (response.body is String) {
      if (_isJson(response.body)) {
        return ResponseApi.fromJson(json.decode(response.body));
      } else {
        return ResponseApi(success: false, message: response.body, data: null);
      }
    }
    return ResponseApi.fromJson(response.body);
  }

  Future<ResponseApi> editarUsuario(String id, String nombre, String rut, String email) async {
    final response = await put('$url/update/$id', {
      'nombre': nombre,
      'rut': rut,
      'email': email,
    }, headers: {'Content-Type': 'application/json'});
    if (response.body is String) {
      if (_isJson(response.body)) {
        return ResponseApi.fromJson(json.decode(response.body));
      } else {
        return ResponseApi(success: false, message: response.body, data: null);
      }
    }
    return ResponseApi.fromJson(response.body);
  }

  Future<ResponseApi> eliminarUsuario(String id) async {
    // Función auxiliar para validar si un string es JSON
    bool _isJson(String str) {
      try {
        json.decode(str);
        return true;
      } catch (_) {
        return false;
      }
    }
    final response = await delete('$url/delete/$id', headers: {'Content-Type': 'application/json'});
    if (response.body is String) {
      if (_isJson(response.body)) {
        return ResponseApi.fromJson(json.decode(response.body));
      } else {
        return ResponseApi(success: false, message: response.body, data: null);
      }
    }
    return ResponseApi.fromJson(response.body);
  }
}
