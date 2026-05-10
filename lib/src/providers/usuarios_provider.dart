import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/environment/environment.dart';
import '../models/response_api.dart';

import '../models/usuario.dart';


class UsuariosProvider extends GetConnect{

  String url = '${Environment.API_URL}api/usuarios';
  
  // ✅ CORREGIDO: No inicializar Usuario al crear el provider
  Usuario? get userSession {
    try {
      final userData = GetStorage().read('usuario');
      if (userData != null) {
        return Usuario.fromJson(Map<String, dynamic>.from(userData));
      }
      return null;
    } catch (e) {
      print('⚠️ Error al obtener usuario de sesión: $e');
      return null;
    }
  }

  Future<ResponseApi> create(Usuario usuario, var rol) async{

    Response response = await post(
        '$url/create/$rol',
        usuario.toJson(),
        headers: {
          'Content-Type': 'application/json'
        }
    );
    // Si response.body ya es un Map, no lo decodifiques de nuevo
    final body = response.body;
    ResponseApi responseApi;
    if (body is String) {
      responseApi = ResponseApi.fromJson(json.decode(body));
    } else if (body is Map<String, dynamic>) {
      responseApi = ResponseApi.fromJson(body);
    } else {
      throw Exception('Respuesta inesperada del backend: ${body.runtimeType}');
    }
    return responseApi;
  }

  Future<ResponseApi> login(String rut, String clave) async{
    
    print('🔐 Iniciando login con base de datos real...');
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

      if(response.body == null){
        Get.snackbar('Error: ', 'No se pudo ejecutar la peticion');
        return ResponseApi();
      }
      
      // 🔍 DEBUGGING: Mostrar respuesta del servidor
      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');
      print('📡 Response Headers: ${response.headers}');
      
      // Verificar si la respuesta es JSON válido
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('❌ Error HTTP ${response.statusCode}: ${response.body}');
        return ResponseApi(
          success: false,
          message: 'Error del servidor: ${response.statusCode}'
        );
      }
      
      // Verificar si el contenido es JSON válido
      // GetConnect automaticamente convierte response.body a Map si es JSON válido
      ResponseApi responseApi;
      
      if (response.body is Map) {
        // Ya es un Map, usar directamente
        responseApi = ResponseApi.fromJson(Map<String, dynamic>.from(response.body));
      } else if (response.body is String) {
        // Es String, verificar si es JSON válido y convertir
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
      
      // 🔄 Si el login es exitoso, procesar los datos para compatibilidad
      if (responseApi.success == true && responseApi.data != null) {
        print('✅ Login exitoso con base de datos');
        
        // Asegurar que los campos sean compatibles con el modelo
        Map<String, dynamic> userData = Map<String, dynamic>.from(responseApi.data);
        
        // Convertir campos críticos a String si es necesario
        if (userData['id'] != null && userData['id'] is int) {
          userData['id'] = userData['id'].toString();
        }
        if (userData['numero'] != null && userData['numero'] is int) {
          userData['numero'] = userData['numero'].toString();
        }
        
        // Asegurar que roles tenga el formato correcto
        if (userData['roles'] != null && userData['roles'] is List) {
          List<dynamic> roles = userData['roles'];
          for (int i = 0; i < roles.length; i++) {
            if (roles[i] is Map && roles[i]['id'] != null && roles[i]['id'] is int) {
              roles[i]['id'] = roles[i]['id'].toString();
            }
            // Agregar ruta si no existe
            if (roles[i] is Map && !roles[i].containsKey('ruta')) {
              roles[i]['ruta'] = null;
            }
          }
        }
        
        return ResponseApi(
          success: true,
          message: responseApi.message,
          data: userData
        );
      }
      
      return responseApi;
      
    } catch (e) {
      print('❌ Error conectando con backend: $e');
      
      // En caso de error de conexión, mostrar mensaje específico
      return ResponseApi(
        success: false,
        message: 'No se pudo conectar con el servidor. Verifique que esté corriendo en el puerto 4400.'
      );
    }
  }

  Future<ResponseApi> update(Usuario user) async {
    Response response = await put(
        '$url/update',
        user.toJson(),
        headers: {
          'Content-Type': 'application/json',
          //'Authorization': userSession?.sessionToken
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

    ResponseApi responseApi = ResponseApi.fromJson(json.decode(response.body));

    return responseApi;
  }

  Future<ResponseApi> updateRol(var idUser, var idRol) async {
    Response response = await get(
        '$url/updateRol/$idUser/$idRol',
        headers: {
          'Content-Type': 'application/json',
          //'Authorization': userSession?.sessionToken
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

    ResponseApi responseApi = ResponseApi.fromJson(json.decode(response.body));

    return responseApi;
  }


  Future<List<Usuario>> findUsers() async {
    var id = userSession?.id;
    if (id == null) {
      Get.snackbar('Error', 'No hay sesión de usuario activa');
      return [];
    }
    
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