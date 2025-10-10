import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/models/navigation_bar.dart';
import 'package:posmobil/src/models/response_api.dart';
import 'package:posmobil/src/models/usuario.dart';
import 'package:posmobil/src/providers/usuarios_empresa_provider.dart';
import 'dart:async';

// Usuario sesionUsuario = Usuario.fromJson(GetStorage().read('usuario') ?? {});
Usuario? sesionUsuario;

class MenuInicioPage extends StatefulWidget {
  const MenuInicioPage({super.key});

  @override
  State<MenuInicioPage> createState() => _MenuInicioPageState();
}

class _MenuInicioPageState extends State<MenuInicioPage> with TickerProviderStateMixin {
  TextEditingController rutController = TextEditingController();
  TextEditingController claveController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  UsuariosEmpresaProvider usuariosEmpresaProvider = UsuariosEmpresaProvider();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    
    // Limpiar campos de login de usuario empresa
    _limpiarCamposLogin();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  void _limpiarCamposLogin() {
    print('🔄 Iniciando limpieza de campos...');
    print('🔍 Estado inicial - RUT: "${rutController.text}", Clave: "${claveController.text}"');
    
    // Verificar si se debe limpiar los campos (cuando viene de logout)
    final storage = GetStorage();
    if (storage.read('clear_empresa_login_fields') == true) {
      print('🔄 Limpiando campos de login por logout...');
      
      // Limpiar TODOS los posibles datos persistentes de credenciales
      storage.remove('saved_rut');
      storage.remove('saved_password');
      storage.remove('login_rut');
      storage.remove('login_password');
      storage.remove('usuarioempresa_credentials');
      storage.remove('last_login_data');
      
      // RECREAR los controladores completamente para evitar auto-llenado
      rutController.dispose();
      claveController.dispose();
      rutController = TextEditingController();
      claveController = TextEditingController();
      
      storage.remove('clear_empresa_login_fields');
    } else {
      // SIEMPRE limpiar los campos al entrar a la página
      print('🔄 Limpiando campos de login...');
      rutController.clear();
      claveController.clear();
    }
    
    print('✅ Estado después de limpieza - RUT: "${rutController.text}", Clave: "${claveController.text}"');
  }

  String _getSafeUserName() {
    try {
      final userData = GetStorage().read('usuario');
      if (userData != null) {
        final usuario = Usuario.fromJson(userData);
        return usuario.nombre ?? "Usuario";
      }
    } catch (e) {
      print('Error leyendo usuario: $e');
    }
    return "Usuario";
  }  @override
  void dispose() {
    _animationController.dispose();
    rutController.dispose();
    claveController.dispose();
    super.dispose();
  }

  void irARegistroPage() {
    Get.toNamed('/registro');
  }

  void login() async {
    String rut = rutController.text.trim();
    String clave = claveController.text.trim();

    if (validador(clave, rut)) {
      setState(() {
        _isLoading = true;
      });

      try {
        ResponseApi responseApi = await usuariosEmpresaProvider.login(rut, clave);

        print('Response Api: ${responseApi.toJson()}');

        if (responseApi.success == true) {
          GetStorage().write('usuarioempresa', responseApi.data);

          final usuarioEmpresa = responseApi.data;
          // Refactor: Si el rol es 1 va a caja del cliente, en caso contrario va al menú general
          if (usuarioEmpresa != null && int.tryParse(usuarioEmpresa['rol'].toString()) == 1) {
            irAHomePage();
          } else {
            Get.toNamed('/menugeneral');
          }
        } else {
          Get.snackbar(
            '❌ Error de Autenticación',
            responseApi.message ?? 'Credenciales incorrectas',
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            snackPosition: SnackPosition.TOP,
          );
        }
      } catch (e) {
        Get.snackbar(
          '⚠️ Error de Conexión',
          'No se pudo conectar con el servidor',
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
          snackPosition: SnackPosition.TOP,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void irAHomePage() {
    Get.offNamedUntil('/inicio/cliente/caja/create', (route) => false);
  }

  bool validador(String clave, String rut) {
    if (rut.isEmpty) {
      Get.snackbar(
        '📝 Campo requerido',
        'Debes ingresar el RUT de tu empresa o usuario',
        backgroundColor: Colors.amber.shade100,
        colorText: Colors.amber.shade800,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
    if (clave.isEmpty) {
      Get.snackbar(
        '🔐 Campo requerido',
        'Debes ingresar tu clave',
        backgroundColor: Colors.amber.shade100,
        colorText: Colors.amber.shade800,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Hola, ${_getSafeUserName()}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade600,
              Colors.indigo.shade700,
              Colors.purple.shade600,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    _buildWelcomeSection(),
                    const SizedBox(height: 40),
                    _buildLoginCard(context),
                    const SizedBox(height: 24),
                    _buildBackButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.business_center_rounded,
            size: 64,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Autenticación de Usuario',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: const Offset(0, 2),
                blurRadius: 4,
                color: Colors.black.withOpacity(0.3),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Ingresa tus credenciales empresariales',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField(
              controller: rutController,
              label: 'RUT o Usuario',
              hint: 'Ingresa tu RUT empresarial',
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 24),
            _buildInputField(
              controller: claveController,
              label: 'Contraseña',
              hint: 'Ingresa tu contraseña',
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              keyboardType: TextInputType.visiblePassword,
            ),
            const SizedBox(height: 32),
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isPassword ? _obscurePassword : false,
            autocorrect: false,
            enableSuggestions: false,
            autofillHints: null,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey.shade500,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade600,
            Colors.indigo.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'ACCEDER',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBackButton() {
    return TextButton.icon(
      onPressed: () {
        Get.offNamed('/login');
      },
      icon: const Icon(
        Icons.arrow_back_ios_rounded,
        color: Colors.white,
        size: 18,
      ),
      label: const Text(
        'Volver al Login Principal',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
    );
  }
}