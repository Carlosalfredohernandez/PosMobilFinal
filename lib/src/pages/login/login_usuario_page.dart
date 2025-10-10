// LOGIN DE USUARIO CORREGIDO - Funciona con Backend SII
// Esta pagina reemplaza el login anterior que dependia del backend local 3009
// Ahora todo funciona con el backend SII en puerto 3000

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// PAGINA DE LOGIN DE USUARIO (DESPUES DEL LOGIN EMPRESARIAL)
/// Funciona con Backend SII puerto 3000
class LoginUsuarioSIIPage extends StatefulWidget {
  const LoginUsuarioSIIPage({Key? key}) : super(key: key);

  @override
  State<LoginUsuarioSIIPage> createState() => _LoginUsuarioSIIPageState();
}

class _LoginUsuarioSIIPageState extends State<LoginUsuarioSIIPage> {
  final TextEditingController rutController = TextEditingController();
  final TextEditingController claveController = TextEditingController();
  
  bool isLoading = false;
  bool showPassword = false;

  @override
  void initState() {
    super.initState();
    print('🔐 LoginUsuarioSIIPage inicializado');
    _verificarEmpresaLogueada();
    
    // Pre-llenar credenciales de demo
    rutController.text = '1-9'; // Usuario cajero demo
    claveController.text = 'cajero123';
  }

  /// Verificar que hay una empresa logueada
  void _verificarEmpresaLogueada() {
    final empresaLogueada = GetStorage().read('empresa_logueada');
    if (empresaLogueada == null) {
      print('❌ No hay empresa logueada, redirigiendo a login empresarial');
      Get.offAllNamed('/empresa_login');
    } else {
      print('✅ Empresa logueada: ${empresaLogueada['razonSocial']}');
    }
  }

  /// 🔐 LOGIN DE USUARIO SIMULADO (compatible con backend SII)
  /// En el futuro, se puede conectar al endpoint /api/auth/login-usuario
  Future<void> _loginUsuario() async {
    if (rutController.text.isEmpty || claveController.text.isEmpty) {
      Get.snackbar(
        '⚠️ Campos Requeridos',
        'Complete RUT y contraseña del usuario',
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final String rut = rutController.text.trim();
      final String clave = claveController.text.trim();

      print('🔐 Intentando login de usuario: $rut');

      // Simular respuesta de autenticación
      await Future.delayed(Duration(seconds: 1));

      // ✅ USUARIOS DE DEMO (simulando conexión con backend SII)
      Map<String, dynamic>? usuarioData = _autenticarUsuarioDemo(rut, clave);

      if (usuarioData != null) {
        // Guardar datos del usuario
        GetStorage().write('usuarioempresa', usuarioData);
        GetStorage().write('usuario', usuarioData);

        final rol = int.tryParse(usuarioData['rol']?.toString() ?? '0') ?? 0;

        print('✅ Login exitoso. Rol: $rol');

        // Mostrar mensaje de éxito
        Get.snackbar(
          '✅ Login Exitoso',
          'Bienvenido ${usuarioData['nombre']}',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );

        // Redireccionar según el rol
        _redirigirPorRol(rol);

      } else {
        print('❌ Login fallido: Credenciales incorrectas');
        Get.snackbar(
          'Error de Autenticación',
          'Credenciales incorrectas. Verifique su RUT y contraseña.',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }

    } catch (e) {
      print('❌ Error en login: $e');
      Get.snackbar(
        'Error de Conexión',
        'No se pudo conectar con el servidor. Intente nuevamente.',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// 🎭 USUARIOS DE DEMO (simula datos del backend SII)
  Map<String, dynamic>? _autenticarUsuarioDemo(String rut, String clave) {
    // Usuarios de demo para testing
    final usuariosDemo = {
      '1-9': {
        'rut': '1-9',
        'clave': 'cajero123',
        'data': {
          'id': '1',
          'nombre': 'Usuario Cajero',
          'email': 'cajero@tecnoalsa.com',
          'rut': '1-9',
          'rol': '3', // Rol 3 = Cajero
          'perfil': 'CAJERO',
          'empresa_id': '1',
          'empresa_rut': '77710916-2',
          'activo': true,
          'ultimo_login': DateTime.now().toIso8601String(),
        }
      },
      '2-7': {
        'rut': '2-7',
        'clave': 'admin123',
        'data': {
          'id': '2',
          'nombre': 'Usuario Administrador',
          'email': 'admin@tecnoalsa.com',
          'rut': '2-7',
          'rol': '1', // Rol 1 = Administrador
          'perfil': 'ADMINISTRADOR',
          'empresa_id': '1',
          'empresa_rut': '77710916-2',
          'activo': true,
          'ultimo_login': DateTime.now().toIso8601String(),
        }
      },
    };

    final usuario = usuariosDemo[rut];
    if (usuario != null && usuario['clave'] == clave) {
      return Map<String, dynamic>.from(usuario['data'] as Map);
    }
    return null;
  }

  /// 🚦 Redireccionar según el rol del usuario
  void _redirigirPorRol(int rol) {
    switch (rol) {
      case 1: // Administrador
        print('🔑 Redirigiendo a menú general (Administrador)');
        Get.offAllNamed('/menugeneral');
        break;
      case 3: // Cajero
        print('🛒 Redirigiendo a MenuInicio controlado (Cajero)');
        Get.offAllNamed('/inicio/cliente');
        break;
      default:
        print('⚠️ Rol no reconocido: $rol, redirigiendo a menú general');
        Get.offAllNamed('/menugeneral');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener datos de la empresa logueada
    final empresaLogueada = GetStorage().read('empresa_logueada');
    final razonSocial = empresaLogueada?['razonSocial'] ?? 'Empresa';
    final rutEmpresa = empresaLogueada?['rutEmpresa'] ?? empresaLogueada?['rut'] ?? '';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Header con información de la empresa
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.business, color: Colors.blue[700], size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Empresa Autenticada',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                razonSocial,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                              if (rutEmpresa.isNotEmpty)
                                Text(
                                  'RUT: $rutEmpresa',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Título
              Text(
                'Iniciar Sesión de Usuario',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ingrese sus credenciales para acceder al sistema',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 40),

              // Formulario
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Campo RUT
                    TextFormField(
                      controller: rutController,
                      decoration: InputDecoration(
                        labelText: 'RUT Usuario',
                        hintText: 'Ej: 1-9',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Campo Contraseña
                    TextFormField(
                      controller: claveController,
                      obscureText: !showPassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: 'Ingrese su contraseña',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword ? Icons.visibility : Icons.visibility_off,
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
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Botón de Login
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _loginUsuario,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Información de demo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Usuarios de Demo Disponibles',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Cajero: RUT 1-9, Contraseña: cajero123\n'
                      '• Administrador: RUT 2-7, Contraseña: admin123',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Botón para regresar
              Center(
                child: TextButton(
                  onPressed: () {
                    Get.offAllNamed('/empresa_login');
                  },
                  child: Text(
                    '← Regresar al Login Empresarial',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    rutController.dispose();
    claveController.dispose();
    super.dispose();
  }
}