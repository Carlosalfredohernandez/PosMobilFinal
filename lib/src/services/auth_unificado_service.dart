import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// 🔐 SERVICIO DE AUTENTICACIÓN UNIFICADO - NUEVA LÓGICA CORRECTA
/// 
/// Maneja la autenticación con la lógica de negocio correcta:
/// 1. Login principal → tabla USUARIOS (empresa + usuario principal) - Backend Local puerto 4400
/// 2. Login usuarios → tabla USUARIOSEMPRESA (usuarios + roles) - Backend Local puerto 4400  
/// 3. Acceso a datos → por empresa_id
class AuthUnificadoService extends GetxController {
  final String baseUrl = 'https://backendposmobil-production.up.railway.app/api'; // Railway backend
  final storage = GetStorage();
  
  // Estados observables
  var isAuthenticated = false.obs;
  var isEmpresaAuthenticated = false.obs;
  var isUsuarioAuthenticated = false.obs;
  
  // Datos de la sesión
  Rx<Map<String, dynamic>?> usuarioPrincipal = Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> empresaData = Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> usuarioEmpresa = Rx<Map<String, dynamic>?>(null);
  
  var tokenPrincipal = ''.obs;
  var tokenUsuario = ''.obs;
  var empresaId = ''.obs;
  var usuarioRol = 0.obs;
  var usuarioPerfil = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('🔐 AuthUnificadoService inicializado');
    _cargarSesionGuardada();
  }

  /// 📱 Cargar sesión guardada
  void _cargarSesionGuardada() {
    try {
      final usuarioPrincipalData = storage.read('usuario_principal');
      final empresaGuardada = storage.read('empresa_data');
      final usuarioEmpresaData = storage.read('usuario_empresa');
      final tokenPrincipalData = storage.read('token_principal');
      final tokenUsuarioData = storage.read('token_usuario');
      final rolData = storage.read('usuario_rol');
      final perfilData = storage.read('usuario_perfil');

      if (usuarioPrincipalData != null) {
        usuarioPrincipal.value = Map<String, dynamic>.from(usuarioPrincipalData);
        isEmpresaAuthenticated.value = true;
      }

      if (empresaGuardada != null) {
        empresaData.value = Map<String, dynamic>.from(empresaGuardada);
        empresaId.value = empresaData.value!['id'] ?? '';
      }

      if (usuarioEmpresaData != null) {
        usuarioEmpresa.value = Map<String, dynamic>.from(usuarioEmpresaData);
        isUsuarioAuthenticated.value = true;
        isAuthenticated.value = true;
      }

      if (tokenPrincipalData != null) {
        tokenPrincipal.value = tokenPrincipalData.toString();
      }

      if (tokenUsuarioData != null) {
        tokenUsuario.value = tokenUsuarioData.toString();
      }

      if (rolData != null) {
        usuarioRol.value = int.tryParse(rolData.toString()) ?? 0;
      }

      if (perfilData != null) {
        usuarioPerfil.value = perfilData.toString();
      }

      print('📱 Sesión cargada:');
      print('  🏢 Empresa: ${isEmpresaAuthenticated.value}');
      print('  👤 Usuario: ${isUsuarioAuthenticated.value}');
      print('  🎯 Rol: ${usuarioRol.value} (${usuarioPerfil.value})');
      
    } catch (e) {
      print('⚠️ Error cargando sesión: $e');
    }
  }

  /// 🏢 Login principal (tabla usuarios)
  Future<Map<String, dynamic>> loginPrincipal(String rut, String password) async {
    print('🔐 Iniciando login principal: $rut');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'rut': rut,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (data['success'] == true) {
        // Guardar datos
        usuarioPrincipal.value = data['data']['usuario'];
        empresaData.value = data['data']['empresa'];
        tokenPrincipal.value = data['data']['token'];
        empresaId.value = empresaData.value!['id'];
        
        // Persistir en storage
        await storage.write('usuario_principal', usuarioPrincipal.value);
        await storage.write('empresa_data', empresaData.value);
        await storage.write('token_principal', tokenPrincipal.value);
        
        isEmpresaAuthenticated.value = true;
        
        print('✅ Login principal exitoso');
        print('🏢 Empresa: ${empresaData.value!['razonSocial']}');
        print('👤 Usuario: ${usuarioPrincipal.value!['nombre']}');
        
        return {
          'success': true,
          'message': 'Login principal exitoso',
          'data': data['data']
        };
      } else {
        print('❌ Login principal fallido: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Error en login principal'
        };
      }
    } catch (e) {
      print('❌ Error en login principal: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
    }
  }

  /// 👥 Login usuario empresa (tabla usuariosempresa)
  Future<Map<String, dynamic>> loginUsuarioEmpresa(String rutUsuario, String password) async {
    print('👥 Iniciando login usuario empresa: $rutUsuario');
    
    if (empresaId.value.isEmpty) {
      return {
        'success': false,
        'message': 'Debe autenticar empresa primero'
      };
    }
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login-usuario-empresa'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'empresa_id': empresaId.value,
          'rut_usuario': rutUsuario,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (data['success'] == true) {
        // Guardar datos del usuario
        usuarioEmpresa.value = data['data']['usuario'];
        tokenUsuario.value = data['data']['token'];
        usuarioRol.value = usuarioEmpresa.value!['rol'];
        usuarioPerfil.value = usuarioEmpresa.value!['perfil'];
        
        // Persistir en storage
        await storage.write('usuario_empresa', usuarioEmpresa.value);
        await storage.write('token_usuario', tokenUsuario.value);
        await storage.write('usuario_rol', usuarioRol.value);
        await storage.write('usuario_perfil', usuarioPerfil.value);
        
        isUsuarioAuthenticated.value = true;
        isAuthenticated.value = true;
        
        print('✅ Login usuario empresa exitoso');
        print('👤 Usuario: ${usuarioEmpresa.value!['nombre']}');
        print('🎯 Rol: ${usuarioRol.value} (${usuarioPerfil.value})');
        
        return {
          'success': true,
          'message': 'Login usuario exitoso',
          'data': data['data'],
          'rol': usuarioRol.value,
          'perfil': usuarioPerfil.value
        };
      } else {
        print('❌ Login usuario empresa fallido: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Error en login de usuario'
        };
      }
    } catch (e) {
      print('❌ Error en login usuario empresa: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
    }
  }

  /// 📦 Obtener productos por empresa
  Future<List<Map<String, dynamic>>> obtenerProductos() async {
    if (empresaId.value.isEmpty) {
      print('❌ No hay empresa autenticada');
      return [];
    }
    
    try {
      print('📦 Obteniendo productos para empresa: ${empresaId.value}');
      
      final response = await http.get(
        Uri.parse('$baseUrl/empresa/${empresaId.value}/productos'),
        headers: _getHeaders(),
      );

      final data = json.decode(response.body);

      if (data['success'] == true) {
        final productos = List<Map<String, dynamic>>.from(data['data']);
        print('✅ Productos obtenidos: ${productos.length}');
        return productos;
      } else {
        print('❌ Error obteniendo productos: ${data['message']}');
        return [];
      }
    } catch (e) {
      print('❌ Error obteniendo productos: $e');
      return [];
    }
  }

  /// 🏪 Obtener locales por empresa
  Future<List<Map<String, dynamic>>> obtenerLocales() async {
    if (empresaId.value.isEmpty) {
      print('❌ No hay empresa autenticada');
      return [];
    }
    
    try {
      print('🏪 Obteniendo locales para empresa: ${empresaId.value}');
      
      final response = await http.get(
        Uri.parse('$baseUrl/empresa/${empresaId.value}/locales'),
        headers: _getHeaders(),
      );

      final data = json.decode(response.body);

      if (data['success'] == true) {
        final locales = List<Map<String, dynamic>>.from(data['data']);
        print('✅ Locales obtenidos: ${locales.length}');
        return locales;
      } else {
        print('❌ Error obteniendo locales: ${data['message']}');
        return [];
      }
    } catch (e) {
      print('❌ Error obteniendo locales: $e');
      return [];
    }
  }

  /// 📑 Obtener categorías por empresa
  Future<List<Map<String, dynamic>>> obtenerCategorias() async {
    if (empresaId.value.isEmpty) {
      print('❌ No hay empresa autenticada');
      return [];
    }
    
    try {
      print('📑 Obteniendo categorías para empresa: ${empresaId.value}');
      
      final response = await http.get(
        Uri.parse('$baseUrl/empresa/${empresaId.value}/categorias'),
        headers: _getHeaders(),
      );

      final data = json.decode(response.body);

      if (data['success'] == true) {
        final categorias = List<Map<String, dynamic>>.from(data['data']);
        print('✅ Categorías obtenidas: ${categorias.length}');
        return categorias;
      } else {
        print('❌ Error obteniendo categorías: ${data['message']}');
        return [];
      }
    } catch (e) {
      print('❌ Error obteniendo categorías: $e');
      return [];
    }
  }

  /// 🛡️ Verificar permisos según rol
  bool tienePermiso(String permiso) {
    switch (usuarioRol.value) {
      case 1: // Administrador
        return true; // Acceso completo
        
      case 3: // Cajero
        final permisosKajero = [
          'pos', 'caja', 'ventas', 'productos_lectura'
        ];
        return permisosKajero.contains(permiso);
        
      default:
        return false;
    }
  }

  /// 🎯 Obtener ruta inicial según rol
  String obtenerRutaInicialSegunRol() {
    switch (usuarioRol.value) {
      case 1: // Administrador
        return '/inicio/cliente'; // Menú completo
        
      case 3: // Cajero
        return '/inicio/cliente/caja/create'; // Directo al POS
        
      default:
        return '/login_unificado';
    }
  }

  /// 🗂️ Obtener headers para las peticiones
  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    
    if (tokenUsuario.value.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${tokenUsuario.value}';
    } else if (tokenPrincipal.value.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${tokenPrincipal.value}';
    }
    
    return headers;
  }

  /// 🚪 Logout completo
  Future<void> logout() async {
    print('🚪 Cerrando sesión...');
    
    // Limpiar estado
    isAuthenticated.value = false;
    isEmpresaAuthenticated.value = false;
    isUsuarioAuthenticated.value = false;
    
    usuarioPrincipal.value = null;
    empresaData.value = null;
    usuarioEmpresa.value = null;
    
    tokenPrincipal.value = '';
    tokenUsuario.value = '';
    empresaId.value = '';
    usuarioRol.value = 0;
    usuarioPerfil.value = '';
    
    // Limpiar storage
    await storage.remove('usuario_principal');
    await storage.remove('empresa_data');
    await storage.remove('usuario_empresa');
    await storage.remove('token_principal');
    await storage.remove('token_usuario');
    await storage.remove('usuario_rol');
    await storage.remove('usuario_perfil');
    
    print('✅ Sesión cerrada');
    
    // Navegar al login
    Get.offAllNamed('/login_unificado');
  }

  /// 🧹 Limpiar storage completo (para depuración)
  Future<void> limpiarStorageCompleto() async {
    print('🧹 Limpiando storage completo...');
    
    await logout(); // Usar el logout normal que ya hace todo
    
    print('✅ Storage completamente limpio');
  }

  /// 📊 Obtener información de la sesión
  Map<String, dynamic> obtenerInfoSesion() {
    return {
      'empresa_autenticada': isEmpresaAuthenticated.value,
      'usuario_autenticado': isUsuarioAuthenticated.value,
      'empresa_nombre': empresaData.value?['razonSocial'] ?? 'N/A',
      'usuario_nombre': usuarioEmpresa.value?['nombre'] ?? usuarioPrincipal.value?['nombre'] ?? 'N/A',
      'usuario_rol': usuarioRol.value,
      'usuario_perfil': usuarioPerfil.value,
      'empresa_id': empresaId.value,
    };
  }
}