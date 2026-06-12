import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/models/response_api.dart';
//import 'package:posmobilfinal/src/models/usuario.dart';
import 'package:posmobilfinal/src/providers/usuarios_provider.dart';
//import 'package:posmobilfinal/src/pages/ventas/ventas_page.dart';
//import 'dart:convert';
//import 'package:http/http.dart' as http;
//import 'package:posmobilfinal/src/environment/environment.dart';
import 'package:posmobilfinal/src/pages/menu_inicio/menu_inicio_page_backup.dart';

class LoginController extends GetxController {

  TextEditingController rutController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  UsuariosProvider usuariosProvider = UsuariosProvider();

  /*Map<String, dynamic>? _extraerEmpresaDesdeRespuesta(dynamic parsed, String empresaIdStr) {
    Map<String, dynamic>? toMap(dynamic value) {
      if (value is Map) return Map<String, dynamic>.from(value);
      return null;
    }

    if (parsed is Map && parsed.containsKey('data')) {
      final dynamic d = parsed['data'];
      if (d is List && d.isNotEmpty) {
        final match = d.firstWhere(
          (e) => e is Map && e['id']?.toString() == empresaIdStr,
          orElse: () => d[0],
        );
        return toMap(match);
      } else if (d is Map) {
        return toMap(d);
      }
    } else if (parsed is List && parsed.isNotEmpty) {
      final match = parsed.firstWhere(
        (e) => e is Map && e['id']?.toString() == empresaIdStr,
        orElse: () => parsed[0],
      );
      return toMap(match);
    } else if (parsed is Map) {
      return toMap(parsed);
    }

    return null;
  }
  */
void login() async {
  String rut = rutController.text.trim();
  String password = passwordController.text.trim();

  print('🔐 Intentando login (empresa rut): $rut');

  if (!isValidForm(rut, password)) return;

  ResponseApi responseApi;
  try {
    responseApi = await usuariosProvider.login(rut, password);
  } catch (err) {
    print('❌ Error conectando al backend: $err');
    Get.snackbar('Error', 'No se pudo conectar al servidor.');
    return;
  }

  if (responseApi.success != true) {
    print('❌ Login fallido: ${responseApi.message}');
    Get.snackbar('Login fallido', responseApi.message ?? 'Error desconocido');
    return;
  }

  final storage = GetStorage();

  // Limpiar storage para dejar solo la nueva sesión   ***** antes
  /*try {
    await storage.erase();
    print('🧹 GetStorage limpiado antes de persistir nueva sesión');
  } catch (e) {
    print('⚠️ No fue posible limpiar GetStorage: $e');
  }*/
  // Limpiar sólo claves de sesión antiguas (preserva empresa_data / usuarioempresa)
  try {
    final keysToRemove = [
      'usuario',
      'token_principal',
      'token_usuario',
      'token',
      'session_token',
      'sessionToken',
      'usuario_rol',
      'rut_empresa',
      'rut_emisor'
    ];
    for (final k in keysToRemove) {
      await storage.remove(k);
    }
    print('🧹 Eliminadas claves de sesión antiguas (empresa preservada)');
  } catch (e) {
    print('⚠️ No fue posible limpiar GetStorage: $e');
  }
  // Persistir usuario desde la respuesta
  Map<String, dynamic> usuarioData = Map<String, dynamic>.from(responseApi.data ?? {});

  if (usuarioData['id'] != null && usuarioData['id'] is int) {
    usuarioData['id'] = usuarioData['id'].toString();
  }
  if (usuarioData['numero'] != null && usuarioData['numero'] is int) {
    usuarioData['numero'] = usuarioData['numero'].toString();
  }

  await storage.write('usuario', usuarioData);

  // Persistir posibles tokens que venga en distintos campos
  final tokenCandidates = ['token_principal', 'token_usuario', 'token', 'session_token', 'sessionToken'];
  for (final key in tokenCandidates) {
    if (usuarioData.containsKey(key) && usuarioData[key] != null && usuarioData[key].toString().isNotEmpty) {
      await storage.write(key, usuarioData[key].toString());
    }
  }

  // Guardar RUT validado por el backend
  final String rutLogin = (usuarioData['rut'] ?? rut).toString().trim();
  if (rutLogin.isNotEmpty) {
    await storage.write('rut_empresa', rutLogin);
    await storage.write('rut_emisor', rutLogin);
  }

  // Si el objeto empresa viene embebido, persistirlo (opcional)
  if (usuarioData['empresa'] is Map) {
    final empresaMap = Map<String, dynamic>.from(usuarioData['empresa']);
    await storage.write('empresa_data', empresaMap);
    if (empresaMap['id'] != null) await storage.write('empresa_id', empresaMap['id'].toString());
  }

  // Imprimir contenido clave del storage para debugging
  print('📦 STORAGE ASIGNADO:');
  final keysToShow = [
    'usuario',
    'empresa_data',
    'empresa_id',
    'token_principal',
    'token_usuario',
    'token',
    'session_token',
    'usuarioempresa',
    'rut_empresa',
    'rut_emisor',
    'usuario_rol'
  ];
  for (final k in keysToShow) {
    print(' - $k: ${storage.read(k)}');
  }

  // Navegar SIEMPRE a menu_inicio_page_backup (elimina navegación por roles)
  Get.offAll(() => MenuInicioPage());
}
// void anteriorrr ********
  /*void login() async {
    String rut = rutController.text.trim();
    String password = passwordController.text.trim();

    print('🔐 Intentando login: $rut');

    if (!isValidForm(rut, password)) return;

    print('📡 Enviando datos al backend...');

    ResponseApi responseApi;
    try {
      responseApi = await usuariosProvider.login(rut, password);
    } catch (err) {
      print('❌ Error conectando al backend: $err');
      Get.snackbar('Error', 'No se pudo conectar al servidor.');
      return;
    }

    print('📦 Respuesta recibida: ${responseApi.success}');

    if (responseApi.success != true) {
      print('❌ Login fallido: ${responseApi.message}');
      Get.snackbar('Login fallido', responseApi.message ?? 'Error desconocido');
      return;
    }

    // Procesar usuario
    Map<String, dynamic> usuarioData = Map<String, dynamic>.from(responseApi.data ?? {});
    if (usuarioData['id'] != null && usuarioData['id'] is int) {
      usuarioData['id'] = usuarioData['id'].toString();
    }
    if (usuarioData['numero'] != null && usuarioData['numero'] is int) {
      usuarioData['numero'] = usuarioData['numero'].toString();
    }
    usuarioData['tipoContrato'] = usuarioData['tipoContrato'] ?? 'SI';
    usuarioData['activo'] = usuarioData['activo'] ?? true;

    final storage = GetStorage();
    await storage.write('usuario', usuarioData);

    // Guardar RUT validado por el backend
    try {
      final String rutLogin = (usuarioData['rut'] ?? rut).toString().trim();
      if (rutLogin.isNotEmpty) {
        await storage.write('rut_empresa', rutLogin);
        await storage.write('rut_emisor', rutLogin);
        print('🔖 RUT guardado desde login success: $rutLogin');
      }
    } catch (err) {
      print('⚠️ No se pudo guardar RUT desde login: $err');
    }

    // Rol
    int rolUsuario = usuarioData['rol'] ?? 1;
    await storage.write('usuario_rol', rolUsuario);

    // Persistir empresa: preferir objeto si viene, si no intentar obtener por id
    final dynamic empresaRaw = usuarioData['empresa'] ?? usuarioData['empresa_data'] ?? responseApi.data?['empresa'];

    Future<void> persistEmpresaFromMap(Map<String, dynamic> empresaMap) async {
      if (empresaMap == null) return;
      await storage.write('empresa_data', empresaMap);
      if (empresaMap['id'] != null) await storage.write('empresa_id', empresaMap['id'].toString());
      if (empresaMap['api_key'] != null && empresaMap['api_key'].toString().isNotEmpty) {
        final usuarioempresaFallback = {
          'api_key': empresaMap['api_key'].toString(),
          'rut': empresaMap['rut'] ?? empresaMap['rut_emisor'] ?? '',
          'empresa': empresaMap['id'] ?? ''
        };
        await storage.write('usuarioempresa', usuarioempresaFallback);
      }
      print('✅ empresa_data guardada desde login: ${empresaMap['id'] ?? '<unknown>'}');
    }

    if (empresaRaw is Map) {
      await persistEmpresaFromMap(Map<String, dynamic>.from(empresaRaw));
    } else if (empresaRaw != null) {
      final String empresaIdStr = empresaRaw.toString();
      await storage.write('empresa_id', empresaIdStr);
      print('🏢 empresa_id guardado desde login: $empresaIdStr');

      try {
        final uri = Uri.parse('${Environment.API_URL}api/usuarios/findUsers/$empresaIdStr');
        final String tokenPrincipal = storage.read('token_principal')?.toString() ?? storage.read('token_usuario')?.toString() ?? '';
        final Map<String, String> headers = {'Content-Type': 'application/json'};
        if (tokenPrincipal.isNotEmpty) headers['Authorization'] = 'Bearer $tokenPrincipal';
        final resp = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
        if (resp.statusCode >= 200 && resp.statusCode < 300 && resp.body.isNotEmpty) {
          final parsed = json.decode(resp.body);
          final Map<String, dynamic>? empresaObj = _extraerEmpresaDesdeRespuesta(parsed, empresaIdStr);
          if (empresaObj != null && empresaObj['id']?.toString() == empresaIdStr) {
            final String apiKeyFound = (empresaObj['api_key'] ?? '').toString();
            final String rutFound = (empresaObj['rut'] ?? empresaObj['rut_emisor'] ?? '').toString();
            if (apiKeyFound.isNotEmpty && rutFound.isNotEmpty) {
              await persistEmpresaFromMap(empresaObj);
            } else {
              Get.snackbar('Error', 'Datos de empresa incompletos. Contacta al administrador.');
              return;
            }
          } else {
            Get.snackbar('Error', 'Empresa recibida no coincide. Contacta al administrador.');
          }
        } else if (resp.statusCode == 401) {
          Get.snackbar('Error', 'No autorizado al obtener empresa. Vuelve a iniciar sesión.');
          return;
        } else {
          print('⚠️ GET findUsers status: ${resp.statusCode}');
        }
      } catch (err) {
        print('⚠️ Error obteniendo empresa por id (findUsers): $err');
      }
    } else {
      print('ℹ️ No se detectó objeto empresa en la respuesta de login.');
    }

    // Navegación final
    Usuario sesionUsuario = Usuario.fromJson(usuarioData);
    print('👥 Usuario guardado en storage: ${sesionUsuario.nombre}');
    print('🔑 Rol de usuario: $rolUsuario');

    if (sesionUsuario.tipoContrato == 'NO') {
      Get.snackbar('Usuario no autorizado', 'Contacta al administrador');
      return;
    }

    bool esEmpresa = false;
    if (sesionUsuario.roles != null && sesionUsuario.roles!.isNotEmpty) {
      esEmpresa = sesionUsuario.roles!.any((r) => r.id == '4' || r.id == 4);
    }
    if (esEmpresa) {
      Get.offAll(() => VentasPage());
    } else {
      irAHomePage();
    }
  }
*/

  void irAHomePage(){
    print('🏠 Navegando a /inicio/cliente');
    Get.offNamedUntil('/inicio/cliente', (route) => false);
  }

  void irAMenuInicioBackup(){
    print('🏠 Navegando a /menu_inicio_backup');
    Get.offNamedUntil('/menu_inicio_backup', (route) => false);
  }

  void irAHomePageCajero(){
    print('🛒 Navegando a /inicio/cliente (modo cajero)');
    Get.offNamedUntil('/inicio/cliente', (route) => false);
  }

  // ✅ MÉTODO CORREGIDO: Ahora navega a /inicio/cliente que existe
  void irAPantallaEmpresa(){
    print('🏠 Navegando a /inicio/cliente (pantalla que existe en rutas)');
    Get.offNamedUntil('/inicio/cliente', (route) => false);
  }

  bool isValidForm(String rut, String password) {
    if (rut.isEmpty) {
      Get.snackbar('Formulario no válido', 'Ingresa el RUT');
      return false;
    }

    if (password.isEmpty) {
      Get.snackbar('Formulario no válido', 'Ingresa la contraseña');
      return false;
    }

    return true;
  }
}