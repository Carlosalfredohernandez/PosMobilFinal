import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/services/auth_unificado_service.dart';

/// 🔐 PÁGINA DE LOGIN UNIFICADO - NUEVA LÓGICA DE NEGOCIO CORRECTA
/// 
/// Flujo de autenticación:
/// 1. Login principal con tabla USUARIOS → obtiene empresa + usuario principal
/// 2. Si hay múltiples usuarios en la empresa → login adicional con tabla USUARIOSEMPRESA
/// 3. Discriminación de roles → cajero vs administrador
/// 4. Acceso a datos por empresa_id
class LoginUnificadoPage extends StatefulWidget {
  const LoginUnificadoPage({super.key});

  @override
  State<LoginUnificadoPage> createState() => _LoginUnificadoPageState();
}

class _LoginUnificadoPageState extends State<LoginUnificadoPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController rutController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthUnificadoService authService = Get.find<AuthUnificadoService>();
  
  bool isLoading = false;
  bool isPasswordVisible = false;
  
  // Estado del flujo de autenticación
  bool esLoginPrincipal = true; // true = tabla usuarios, false = tabla usuariosempresa
  Map<String, dynamic>? empresaData;
  String? empresaId;

  @override
  void initState() {
    super.initState();
    print('🔐 LoginUnificadoPage inicializado');
    
    // 🚫 TODOS LOS AUTO-LOGINS DESHABILITADOS PARA DEPURACIÓN
    // SOLO LOGIN MANUAL PERMITIDO
    
    print('🛡️ Auto-login completamente deshabilitado para depuración');
    print('📱 Solo login manual permitido');
    
    // 🧹 LIMPIAR CAMPOS AL INICIALIZAR
    _limpiarCampos();
  }

  @override
  void dispose() {
    rutController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// 🧹 Limpiar campos de usuario y contraseña
  void _limpiarCampos() {
    rutController.clear();
    passwordController.clear();
    print('🧹 Campos de usuario y contraseña limpiados');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(esLoginPrincipal ? 'Login Empresarial' : 'Seleccionar Usuario'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header con logo
                _buildHeader(),
                
                const SizedBox(height: 32),
                
                // Información del paso actual
                _buildStepInfo(),
                
                const SizedBox(height: 24),
                
                // Campo RUT
                _buildCampoRut(),
                
                const SizedBox(height: 16),
                
                // Campo Contraseña
                _buildCampoPassword(),
                
                const SizedBox(height: 24),
                
                // Botón de login
                _buildBotonLogin(),
                
                const SizedBox(height: 16),
                
                // Opciones adicionales
                _buildOpcionesAdicionales(),
                
                const SizedBox(height: 24),
                
                // Info de credenciales demo
                _buildCredencialesDemo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🎨 Header con logo
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: Colors.blue[700],
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.business,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Sistema POS SII',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
      ],
    );
  }

  /// 📋 Información del paso actual
  Widget _buildStepInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Text(
            esLoginPrincipal ? '🏢 Paso 1: Login Empresarial' : '👤 Paso 2: Seleccionar Usuario',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            esLoginPrincipal 
              ? 'Ingrese las credenciales de su empresa'
              : 'Seleccione su usuario dentro de la empresa',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// 📝 Campo RUT
  Widget _buildCampoRut() {
    return TextFormField(
      controller: rutController,
      decoration: InputDecoration(
        labelText: esLoginPrincipal ? 'RUT Empresa' : 'RUT Usuario',
        hintText: esLoginPrincipal ? 'Ej: 77710916-2' : 'Ej: 1-9',
        prefixIcon: const Icon(Icons.business),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'RUT es requerido';
        }
        return null;
      },
    );
  }

  /// 🔐 Campo Contraseña
  Widget _buildCampoPassword() {
    return TextFormField(
      controller: passwordController,
      obscureText: !isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        hintText: 'Ingrese su contraseña',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Contraseña es requerida';
        }
        return null;
      },
    );
  }

  /// 🚀 Botón de login
  Widget _buildBotonLogin() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
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
          : Text(
              esLoginPrincipal ? 'Acceder' : 'Seleccionar Usuario',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
      ),
    );
  }

  /// 🔄 Opciones adicionales
  Widget _buildOpcionesAdicionales() {
    return Column(
      children: [
        if (!esLoginPrincipal) ...[
          TextButton(
            onPressed: () {
              setState(() {
                esLoginPrincipal = true;
                empresaData = null;
                empresaId = null;
              });
              _limpiarCampos(); // Limpiar campos al cambiar de empresa
            },
            child: const Text('Cambiar Empresa'),
          ),
        ],
        
        // 🧹 BOTÓN PARA LIMPIAR STORAGE Y RESOLVER LOOPS
        TextButton(
          onPressed: _limpiarStorageCompleto,
          style: TextButton.styleFrom(
            foregroundColor: Colors.red[700],
          ),
          child: const Text('🧹 Limpiar Storage (Debug)'),
        ),
      ],
    );
  }

  /// 📱 Información de credenciales demo
  Widget _buildCredencialesDemo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Text(
            'Credenciales de Prueba',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 8),
          
          if (esLoginPrincipal) ...[
            Text(
              '🏢 Principal: RUT 77710916-2, Contraseña: 9162',
              style: TextStyle(fontSize: 12, color: Colors.blue[700]),
            ),
          ] else ...[
            Text(
              '👤 Cajero: RUT 1-9, Contraseña: clave123',
              style: TextStyle(fontSize: 12, color: Colors.blue[700]),
            ),
            Text(
              '👨‍💼 Admin: RUT 2-7, Contraseña: admin123',
              style: TextStyle(fontSize: 12, color: Colors.blue[700]),
            ),
          ],
        ],
      ),
    );
  }

  /// 🔐 Manejar el proceso de login
  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (esLoginPrincipal) {
        await _loginPrincipal();
      } else {
        await _loginUsuarioEmpresa();
      }
    } catch (e) {
      print('❌ Error en login: $e');
      _mostrarError('Error de conexión: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// 🏢 Login principal (tabla usuarios)
  Future<void> _loginPrincipal() async {
    final rut = rutController.text.trim();
    final password = passwordController.text.trim();

    print('🔐 Intentando login principal: $rut');

    try {
      final response = await authService.loginPrincipal(rut, password);

      if (response['success'] == true) {
        // ✅ CORREGIDO: Adaptar a la nueva estructura de respuesta
        print('✅ Login principal exitoso');
        print('👤 Usuario: ${response['data']['nombre']}');
        print('🏢 Empresa ID: ${response['data']['empresa_id']}');

        // Verificar si necesita login adicional de usuario o ir directo al menú
        _verificarSiguientePaso();

      } else {
        _mostrarError(response['message'] ?? 'Error en login principal');
      }
    } catch (e) {
      print('❌ Error en login principal: $e');
      _mostrarError('Error de conexión: $e');
    }
  }

  /// 👥 Login usuario empresa (tabla usuariosempresa)
  Future<void> _loginUsuarioEmpresa() async {
    final rutUsuario = rutController.text.trim();
    final password = passwordController.text.trim();

    print('👥 Intentando login usuario empresa: $rutUsuario');

    try {
      final response = await authService.loginUsuarioEmpresa(rutUsuario, password);

      if (response['success'] == true) {
        final usuario = response['data']['usuario'];
        final rol = usuario['rol'];
        final perfil = usuario['perfil'];

        print('✅ Login usuario empresa exitoso');
        print('👤 Usuario: ${usuario['nombre']} - Rol: $rol ($perfil)');

        // Navegar según el rol
        _navegarSegunRol(rol, perfil);

      } else {
        _mostrarError(response['message'] ?? 'Error en login de usuario');
      }
    } catch (e) {
      print('❌ Error en login usuario empresa: $e');
      _mostrarError('Error de conexión: $e');
    }
  }

  /// 🔍 Verificar siguiente paso después del login principal
  void _verificarSiguientePaso() {
    // ✅ CORREGIDO: Usar estructura de la respuesta del servidor
    final usuarioPrincipal = authService.usuarioPrincipal.value;
    
    if (usuarioPrincipal != null) {
      // Verificar el rol según la lógica antigua
      final rolId = usuarioPrincipal['rol']?.toString() ?? '';
      
      if (rolId == '3') {
        // Cajero - ir al menú de cajero
        print('🛒 Usuario cajero detectado, navegando al menú de cajero');
        _navegarSegunRol(3, 'cajero');
      } else if (rolId == '1') {
        // Administrador - ir al menú completo
        print('🔑 Usuario administrador detectado, navegando al menú completo');
        _navegarSegunRol(1, 'administrador');
      } else {
        // Otro rol - pedir login de usuario empresa
        setState(() {
          esLoginPrincipal = false;
        });
        
        _limpiarCampos();
        _mostrarMensaje('Empresa autenticada. Seleccione su usuario.');
      }
    } else {
      // Error - no hay datos de usuario
      _mostrarError('Error: No se encontraron datos de usuario');
    }
  }

  /// 🎯 Navegar según rol del usuario
  void _navegarSegunRol(int rol, String perfil) {
    print('🎯 Navegando según rol: $rol ($perfil)');
    
    // Guardar rol para control de acceso
    final storage = GetStorage();
    storage.write('usuario_rol', rol);
    storage.write('usuario_perfil', perfil);
    
    switch (rol) {
      case 1: // Administrador
        print('🔑 Navegando a menú completo (Administrador)');
        Get.offAllNamed('/inicio/cliente'); // Menú completo
        break;
        
      case 3: // Cajero
        print('🛒 Navegando a menú de cajero');
        Get.offAllNamed('/inicio/cliente'); // Menú filtrado por MenuInicioPageControlado
        break;
        
      default:
        print('⚠️ Rol no reconocido: $rol');
        _mostrarError('Rol de usuario no válido');
    }
  }

  /// 🧹 Limpiar storage completo para depuración
  void _limpiarStorageCompleto() async {
    print('🧹 Limpiando storage completo...');
    
    try {
      // Usar el método del servicio que ya hace todo
      await authService.limpiarStorageCompleto();
      
      // Reset local state y limpiar campos
      setState(() {
        esLoginPrincipal = true;
        empresaData = null;
        empresaId = null;
      });
      
      // 🧹 LIMPIAR CAMPOS DE USUARIO Y CONTRASEÑA
      _limpiarCampos();
      
      _mostrarMensaje('✅ Storage limpiado completamente. Campos reseteados.');
      
      print('✅ Storage y campos limpiados completamente');
      
    } catch (e) {
      print('❌ Error limpiando storage: $e');
      _mostrarError('Error limpiando storage: $e');
    }
  }

  /// 📢 Mostrar mensaje
  void _mostrarMensaje(String mensaje) {
    Get.snackbar(
      'Información',
      mensaje,
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[800],
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
    );
  }

  /// ❌ Mostrar error
  void _mostrarError(String error) {
    Get.snackbar(
      'Error',
      error,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[800],
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
    );
  }
}