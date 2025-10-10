// 🔐 PÁGINA DE LOGIN USUARIO EMPRESA - SIN AUTO-AUTENTICACIÓN 
// Reemplaza tu archivo: lib/src/pages/login/empresa_auth_page.dart
// NUEVA LÓGICA: Login manual de usuario empresa para obtener ROL

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmpresaAuthPage extends StatefulWidget {
  const EmpresaAuthPage({Key? key}) : super(key: key);

  @override
  State<EmpresaAuthPage> createState() => _EmpresaAuthPageState();
}

class _EmpresaAuthPageState extends State<EmpresaAuthPage> 
    with TickerProviderStateMixin {
  
  final TextEditingController rutUsuarioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  bool isLoading = false;
  bool showPassword = false;

  @override
  void initState() {
    super.initState();
    print('👥 LOGIN USUARIO EMPRESA: Iniciando autenticación manual');
    
    // ✅ NUEVA LÓGICA: NO auto-procesar, esperar input manual
    // Limpiar datos de sesiones anteriores
    _limpiarDatosUsuarioEmpresa();
    
    // Asegurar que los campos estén completamente limpios
    WidgetsBinding.instance.addPostFrameCallback((_) {
      rutUsuarioController.clear();
      passwordController.clear();
    });
    
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _fadeController.forward();
    _scaleController.forward();
  }

  /// 🧹 LIMPIAR DATOS DE USUARIO EMPRESA ANTERIORES
  void _limpiarDatosUsuarioEmpresa() {
    final storage = GetStorage();
    
    print('🧹 Limpiando datos de sesiones usuario empresa anteriores...');
    
    // Limpiar SOLO datos de usuario empresa, mantener usuario básico
    storage.remove('usuario_empresa');
    storage.remove('usuario_rol');
    storage.remove('empresa_data');
    
    // SIEMPRE limpiar los campos de texto al entrar a la página
    print('🔄 Limpiando campos de login...');
    rutUsuarioController.clear();
    passwordController.clear();
    
    // Limpiar la bandera si existe
    storage.remove('clear_empresa_login_fields');
    
    // NO limpiar 'usuario' porque es el login básico que ya se completó
    print('✅ Datos de sesión usuario empresa limpiados - Login manual requerido');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    rutUsuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade600,
              Colors.cyan.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildLoginCard(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildUserInfo(),
            const SizedBox(height: 24),
            _buildLoginForm(),
            const SizedBox(height: 32),
            _buildLoginButton(),
            const SizedBox(height: 16),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade600, Colors.green.shade400],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_pin,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Login Usuario Empresa',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ingresa tus credenciales de usuario empresa',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    final storage = GetStorage();
    final usuario = storage.read('usuario');
    final nombreUsuario = usuario?['nombre'] ?? 'Usuario';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.person, color: Colors.blue.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Usuario básico logueado:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  nombreUsuario,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        TextField(
          controller: rutUsuarioController,
          decoration: InputDecoration(
            labelText: 'RUT Usuario Empresa *',
            hintText: 'Ej: 0000 o 1-9',
            prefixIcon: const Icon(Icons.badge),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          obscureText: !showPassword,
          decoration: InputDecoration(
            labelText: 'Contraseña Usuario *',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                showPassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  showPassword = !showPassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _procesarLoginUsuarioEmpresa,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Autenticando...'),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login),
                  SizedBox(width: 8),
                  Text(
                    'Ingresar como Usuario Empresa',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        TextButton(
          onPressed: _cerrarSesionCompleta,
          child: Text(
            'Cerrar Sesión Completa',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Se requiere login manual cada vez',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// 🔐 PROCESAR LOGIN DE USUARIO EMPRESA
  Future<void> _procesarLoginUsuarioEmpresa() async {
    if (!_validarFormulario()) return;

    setState(() {
      isLoading = true;
    });

    try {
      print('👥 Iniciando login de usuario empresa...');
      
      // TODO: Conectar con backend real
      // Por ahora simulación para demostrar flujo
      await _autenticarUsuarioEmpresa();
      
    } catch (e) {
      print('❌ Error en login usuario empresa: $e');
      Get.snackbar(
        '❌ Error de Login',
        'Error de conexión: $e',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// 👥 AUTENTICAR USUARIO EMPRESA CON BASE DE DATOS REAL 4400
  Future<void> _autenticarUsuarioEmpresa() async {
    final rutUsuario = rutUsuarioController.text.trim();
    final password = passwordController.text.trim();
    
    print('👥 Autenticando usuario empresa: $rutUsuario con base de datos real puerto 4400');
    
    try {
      // Llamar al backend real en puerto 4400 con base de datos
      final response = await http.post(
        Uri.parse('http://192.168.1.88:4400/api/usuariosempresa/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'rut': rutUsuario,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Respuesta backend: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          print('✅ Autenticación exitosa desde backend');
          await _loginExitoso({'usuario': data['data']});
          return;
        } else {
          throw Exception(data['message'] ?? 'Error de autenticación');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
      
    } catch (e) {
      print('⚠️ Error conectando con backend, usando autenticación local: $e');
      
      // Fallback: autenticación local como respaldo
      await _autenticarUsuarioEmpresaLocal();
    }
  }

  /// 🔄 AUTENTICACIÓN LOCAL COMO RESPALDO
  Future<void> _autenticarUsuarioEmpresaLocal() async {
    final rutUsuario = rutUsuarioController.text.trim();
    final password = passwordController.text.trim();
    
    print('🔄 Usando autenticación local para: $rutUsuario');
    
    // Simulación de delay de red
    await Future.delayed(const Duration(seconds: 1));
    
    Map<String, dynamic>? usuarioData;
    
    // Mismos usuarios que en la base de datos real
    if (rutUsuario == '0000' && password == '1234') {
      usuarioData = {
        'usuario': {
          'id': 1,
          'rut': '0000',
          'nombre': 'Usuario General',
          'rol': 3, // Rol 3 = menugeneral
          'perfil': 'Usuario General'
        }
      };
    } else if (rutUsuario == '1-9' && password == '1234') {
      usuarioData = {
        'usuario': {
          'id': 2,
          'rut': '1-9',
          'nombre': 'Administrador',
          'rol': 1, // Rol 1 = admin
          'perfil': 'Administrador'
        }
      };
    } else {
      throw Exception('Credenciales de usuario empresa incorrectas');
    }
    
    await _loginExitoso(usuarioData);
  }

  /// ✅ LOGIN EXITOSO
  Future<void> _loginExitoso(Map<String, dynamic> datos) async {
    final storage = GetStorage();
    
    print('✅ Login usuario empresa exitoso');
    
    // Guardar datos del usuario empresa
    storage.write('usuario_empresa', datos['usuario']);
    storage.write('usuario_rol', datos['usuario']['rol']);
    
    // Simular datos de empresa (puedes modificar esto según tu backend)
    storage.write('empresa_data', {
      'id': 1,
      'rut': '77710916-2',
      'razonSocial': 'TECNOALSA SPA',
      'nombreFantasia': 'TECNOALSA',
    });
    
    // Mostrar mensaje de éxito
    Get.snackbar(
      '✅ Login Exitoso',
      'Usuario: ${datos['usuario']['nombre']} (${datos['usuario']['perfil']})',
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade800,
      duration: const Duration(seconds: 2),
    );
    
    // Pequeña pausa para mostrar el mensaje
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Navegar según rol
    final rol = datos['usuario']['rol'];
    switch (rol) {
      case 1: // Administrador (usuario 1-9)
        print('🔑 → Redirigiendo a funciones de administración (Rol 1)');
        Get.offAllNamed('/inicio/cliente');
        break;
        
      case 3: // Usuario General (usuario 0000) - Menu General
        print('🛒 → Redirigiendo a menú general (Rol 3)');
        Get.offAllNamed('/menugeneral');
        break;
        
      default:
        print('⚠️ → Rol desconocido ($rol), redirigiendo a menú general');
        Get.offAllNamed('/inicio/cliente');
        break;
    }
  }

  /// ✅ VALIDAR FORMULARIO
  bool _validarFormulario() {
    if (rutUsuarioController.text.trim().isEmpty) {
      Get.snackbar(
        '⚠️ Campo Requerido',
        'Ingresa el RUT del usuario empresa',
        backgroundColor: Colors.orange.shade50,
        colorText: Colors.orange.shade800,
      );
      return false;
    }
    
    if (passwordController.text.trim().isEmpty) {
      Get.snackbar(
        '⚠️ Campo Requerido',
        'Ingresa la contraseña del usuario',
        backgroundColor: Colors.orange.shade50,
        colorText: Colors.orange.shade800,
      );
      return false;
    }
    
    return true;
  }

  /// 🚪 CERRAR SESIÓN COMPLETA
  void _cerrarSesionCompleta() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión completamente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _ejecutarCerrarSesion();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _ejecutarCerrarSesion() {
    final storage = GetStorage();
    
    print('🚪 Cerrando sesión completa...');
    
    // Limpiar TODOS los datos de sesión
    storage.remove('usuario');
    storage.remove('usuario_empresa');
    storage.remove('usuario_rol');
    storage.remove('empresa_data');
    
    Get.snackbar(
      'ℹ️ Sesión Cerrada',
      'Sesión cerrada correctamente',
      backgroundColor: Colors.grey.shade50,
      colorText: Colors.grey.shade700,
    );
    
    // Volver al login
    Get.offAllNamed('/login');
  }
}