// 🚀 PÁGINA DE LOGIN EMPRESARIAL COMPLETA - VERSIÓN FINAL CORREGIDA
// Compatible con backend y modo offline
// Coloca en: lib/src/pages/login/empresa_login_page_completa.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Importa tu servicio completo cuando esté listo
// import '../../../services/pos_sii_auth_service_completo.dart';

class EmpresaLoginPageCompleta extends StatelessWidget {
  final rutController = TextEditingController(text: '77710916-2'); // TECNOALSA demo
  final passwordController = TextEditingController(text: '9162');
  
  // final authService = Get.find<POSSIIAuthServiceCompleto>(); // Descomenta cuando tengas el servicio

  EmpresaLoginPageCompleta({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Login Empresarial'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Botón para cambiar modo backend/offline
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _mostrarConfiguracion,
            tooltip: 'Configuración del sistema',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[700]!,
              Colors.blue[50]!,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Logo y título
                _buildHeader(),
                const SizedBox(height: 40),
                
                // Formulario de login
                _buildLoginForm(),
                const SizedBox(height: 30),
                
                // Botón de login
                _buildLoginButton(),
                const SizedBox(height: 20),
                
                // Información del sistema
                _buildSystemInfo(),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.business,
            size: 50,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Sistema POS SII',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Autenticación Empresarial',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acceso Empresarial',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ingresa las credenciales de tu empresa',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          
          // Campo RUT Empresa
          TextField(
            controller: rutController,
            decoration: InputDecoration(
              labelText: 'RUT Empresa',
              hintText: 'Ej: 77710916-2',
              prefixIcon: const Icon(Icons.business_center, color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 20),
          
          // Campo Contraseña
          TextField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              hintText: 'Contraseña de la empresa',
              prefixIcon: const Icon(Icons.lock, color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            obscureText: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 4,
          shadowColor: Colors.blue.withOpacity(0.3),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 26),
            SizedBox(width: 12),
            Text(
              'INICIAR SESIÓN',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text(
            '🔐 Credenciales Demo TECNOALSA',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text(
              'RUT: 77710916-2 | Password: 9162',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Estado del sistema
          // Reemplazado Obx por Widget normal ya que no hay variables observables
          Builder(
            builder: (context) {
              // final info = authService.getServiceInfo(); // Descomenta cuando tengas el servicio
              
              // Datos temporales (eliminar cuando descomentes la línea de arriba)
              final info = {
                'backend_mode': true,
                'backend_url': 'http://localhost:3000',
                'service_version': '2.0.0'
              };
              
              final backendMode = info['backend_mode'] as bool;
              final backendUrl = info['backend_url'] as String;
            
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      backendMode ? Icons.cloud_done : Icons.offline_pin,
                      size: 18,
                      color: backendMode ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      backendMode ? 'Modo Backend Activo' : 'Modo Offline',
                      style: TextStyle(
                        fontSize: 13,
                        color: backendMode ? Colors.green.shade700 : Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (backendMode) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Servidor: $backendUrl',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            );
            }
          ),
        ],
      ),
    );
  }

  // 🔐 Manejar el login
  void _handleLogin() async {
    final rut = rutController.text.trim();
    final password = passwordController.text.trim();

    // Validación de campos
    if (rut.isEmpty || password.isEmpty) {
      Get.snackbar(
        '⚠️ Campos Requeridos',
        'Por favor completa todos los campos',
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange[700],
        icon: const Icon(Icons.warning, color: Colors.orange),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    // Mostrar loading
    Get.dialog(
      PopScope(
        canPop: false,
        child: const Center(
          child: Card(
            elevation: 8,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Autenticando...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Verificando credenciales empresariales',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      print('🔐 Iniciando proceso de login...');
      
      // Simulación del login (reemplazar con el servicio real)
      await Future.delayed(const Duration(seconds: 2));
      
      // Simular respuesta exitosa
      final result = await _simulateLogin(rut, password);
      
      print('📋 Resultado del login: $result');
      
      // Verificar que result no sea null y tenga la estructura esperada
      if (result.isEmpty) {
        throw Exception('Respuesta vacía del servidor');
      }
      
      // Cerrar loading
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      if (result['success'] == true) {
        // Login exitoso - verificar que los datos existen
        final usuario = result['usuario'] as Map<String, dynamic>?;
        final empresa = result['empresa'] as Map<String, dynamic>?;
        final nombreUsuario = usuario?['nombre'] ?? 'Usuario';
        final razonSocial = empresa?['razonSocial'] ?? 'Empresa';
        
        print('✅ Login exitoso para: $nombreUsuario');
        
        // Guardar datos en GetStorage
        await _guardarSesion(usuario, empresa);
        
        Get.snackbar(
          '✅ Login Exitoso',
          'Bienvenido $nombreUsuario\n$razonSocial',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green[700],
          icon: const Icon(Icons.check_circle, color: Colors.green),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );

          // Pequeña pausa para mostrar el mensaje de éxito
          await Future.delayed(const Duration(milliseconds: 800));

          // Navegar al login de usuario (CORREGIDO)
          print('🚀 Navegando a login de usuario...');
          Get.offAllNamed('/login_usuario');      } else {
        // Login fallido
        final mensaje = result['message']?.toString() ?? 'Error desconocido';
        print('❌ Login fallido: $mensaje');
        
        Get.snackbar(
          '❌ Error de Login',
          mensaje,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[700],
          icon: const Icon(Icons.error, color: Colors.red),
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }

    } catch (e) {
      print('💥 Error capturado en _handleLogin: $e');
      
      // Asegurar que el loading se cierre
      if (Get.isDialogOpen == true) {
        try {
          Get.back();
        } catch (closeError) {
          print('⚠️ Error cerrando loading: $closeError');
        }
      }
      
      Get.snackbar(
        '💥 Error de Conexión',
        'No se pudo conectar con el servidor.\nVerificando modo offline...',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[700],
        icon: const Icon(Icons.error, color: Colors.red),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  // 🧪 Simulación del login (reemplazar con authService.loginEmpresa)
  Future<Map<String, dynamic>> _simulateLogin(String rut, String password) async {
    try {
      print('🔐 Simulando login para: $rut');
      
      // Credenciales demo TECNOALSA
      if (rut == '77710916-2' && password == '9162') {
        final usuario = {
          'id': '1',
          'nombre': 'Administrador TECNOALSA',
          'email': 'admin@tecnoalsa.com',
          'rut': rut,
          'perfil': 'ADMINISTRADOR',
          'fechaLogin': DateTime.now().toIso8601String(),
        };
        
        final empresa = {
          'rut': rut,
          'razonSocial': 'TECNOALSA DEMO S.A.',
          'tipoEmpresa': 'DEMO',
          'giro': 'Tecnología y Servicios',
          'direccion': 'Santiago, Chile',
          'telefono': '+56 2 2345 6789',
          'email': 'contacto@tecnoalsa.com',
          'fechaCreacion': DateTime.now().toIso8601String(),
        };

        print('✅ Login simulado exitoso');
        return {
          'success': true,
          'message': 'Login exitoso',
          'usuario': usuario,
          'empresa': empresa,
          'timestamp': DateTime.now().toIso8601String(),
        };
      }

      print('❌ Credenciales incorrectas');
      return {
        'success': false,
        'message': 'RUT o contraseña incorrectos.\nVerifica tus credenciales e intenta nuevamente.',
        'usuario': null,
        'empresa': null,
      };
      
    } catch (e) {
      print('💥 Error en simulateLogin: $e');
      return {
        'success': false,
        'message': 'Error interno del sistema: ${e.toString()}',
        'usuario': null,
        'empresa': null,
      };
    }
  }

  // 💾 Guardar sesión en GetStorage
  Future<void> _guardarSesion(Map<String, dynamic>? usuario, Map<String, dynamic>? empresa) async {
    try {
      if (usuario != null) {
        await GetStorage().write('usuario', usuario);
        print('✅ Usuario guardado en storage: ${usuario['nombre']}');
      }
      
      if (empresa != null) {
        await GetStorage().write('empresa_logueada', empresa);
        print('✅ Empresa guardada en storage: ${empresa['razonSocial']}');
      }
      
      // Guardar marca de tiempo de la sesión
      await GetStorage().write('session_timestamp', DateTime.now().toIso8601String());
      
    } catch (e) {
      print('⚠️ Error guardando sesión: $e');
    }
  }

  // ⚙️ Mostrar configuración del sistema
  void _mostrarConfiguracion() {
    // final authService = Get.find<POSSIIAuthServiceCompleto>(); // Descomenta cuando tengas el servicio
    final backendEnabled = true; // Temporal: reemplazar con authService.useBackend
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.settings, color: Colors.blue),
            SizedBox(width: 8),
            Text('Configuración del Sistema'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estado del Sistema:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            
            // Toggle Backend/Offline
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.cloud,
                color: backendEnabled ? Colors.green : Colors.grey,
              ),
              title: const Text('Modo Backend'),
              subtitle: const Text('Usar servidor para autenticación'),
              trailing: Switch(
                value: backendEnabled,
                onChanged: (value) {
                  // authService.toggleModoBackend(); // Descomenta cuando tengas el servicio
                  Get.back();
                  Get.snackbar(
                    'ℹ️ Configuración',
                    value ? 'Modo Backend activado' : 'Modo Offline activado',
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    colorText: Colors.blue[700],
                    duration: const Duration(seconds: 2),
                  );
                },
              ),
            ),
            
            const Divider(),
            
            // Información del servidor
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline, color: Colors.blue),
              title: const Text('Servidor Backend'),
              subtitle: const Text('http://localhost:3000'),
            ),
            
            const Divider(),
            
            // Información de la versión
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info, color: Colors.green),
              title: const Text('Versión del Sistema'),
              subtitle: const Text('POS SII v2.0.0'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Limpiar datos de prueba
              _limpiarDatosDemo();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Limpiar Datos'),
          ),
        ],
      ),
    );
  }

  // 🧹 Limpiar datos demo
  void _limpiarDatosDemo() {
    Get.dialog(
      AlertDialog(
        title: const Text('⚠️ Confirmar Acción'),
        content: const Text('¿Estás seguro de que quieres limpiar todos los datos almacenados?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await GetStorage().erase();
              Get.back();
              Get.snackbar(
                '✅ Datos Limpiados',
                'Todos los datos han sido eliminados',
                backgroundColor: Colors.green.withOpacity(0.1),
                colorText: Colors.green[700],
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }
}