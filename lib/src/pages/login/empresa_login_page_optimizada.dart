// 🚀 PÁGINA DE LOGIN EMPRESARIAL OPTIMIZADA - COMPACTA SIN SCROLL
// Diseño optimizado para que se vea completa en pantalla
// Coloca en: lib/src/pages/login/empresa_login_page_optimizada.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/services/pos_sii_auth_service_completo.dart';

class EmpresaLoginPageOptimizada extends StatelessWidget {
  final rutController = TextEditingController(text: '77710916-2');
  final passwordController = TextEditingController(text: '9162');
  final loading = false.obs;

  EmpresaLoginPageOptimizada({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue[700]!, Colors.blue[50]!],
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // 🎨 HEADER ULTRA COMPACTO
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 16 : 24,
                        horizontal: 20,
                      ),
                      child: Column(
                        children: [
                          // Logo/Icono más pequeño
                          Container(
                            width: isSmallScreen ? 50 : 70,
                            height: isSmallScreen ? 50 : 70,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.business,
                              size: isSmallScreen ? 25 : 35,
                              color: Colors.blue[700],
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 6 : 10),
                          // Título compacto
                          Text(
                            'POS SII',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 22 : 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Login Empresarial',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 📝 FORMULARIO ULTRA COMPACTO
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isSmallScreen ? 8 : 16,
                        ),
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // RUT Input compacto
                            _buildCompactInput(
                              controller: rutController,
                              label: 'RUT Empresa',
                              icon: Icons.business_center,
                              isSmall: isSmallScreen,
                            ),
                            
                            SizedBox(height: isSmallScreen ? 10 : 14),
                            
                            // Password Input compacto
                            _buildCompactInput(
                              controller: passwordController,
                              label: 'Contraseña',
                              icon: Icons.lock,
                              isPassword: true,
                              isSmall: isSmallScreen,
                            ),

                            SizedBox(height: isSmallScreen ? 14 : 20),

                            // Botón de login compacto
                            Obx(() => SizedBox(
                              width: double.infinity,
                              height: isSmallScreen ? 42 : 48,
                              child: ElevatedButton(
                                onPressed: loading.value ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[700],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                                child: loading.value
                                    ? SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Iniciar Sesión',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            )),

                            SizedBox(height: isSmallScreen ? 10 : 14),

                            // Datos de prueba ultra compactos
                            Container(
                              padding: EdgeInsets.all(isSmallScreen ? 6 : 10),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.info_outline, 
                                           color: Colors.blue[700], 
                                           size: isSmallScreen ? 14 : 16),
                                      SizedBox(width: 6),
                                      Text(
                                        'Datos de Prueba',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue[700],
                                          fontSize: isSmallScreen ? 11 : 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'RUT: 77710916-2 | Contraseña: 9162',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 10 : 11,
                                      color: Colors.blue[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'TECNOALSA DEMO',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 9 : 10,
                                      color: Colors.blue[500],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 📱 FOOTER MINIMALISTA
                    Padding(
                      padding: EdgeInsets.only(bottom: isSmallScreen ? 6 : 12),
                      child: Text(
                        'Sistema POS integrado con SII',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 9 : 11,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🎨 WIDGET PARA INPUT COMPACTO
  Widget _buildCompactInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isSmall = false,
  }) {
    return Container(
      height: isSmall ? 40 : 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(fontSize: isSmall ? 13 : 15),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon, 
            color: Colors.blue[700], 
            size: isSmall ? 18 : 20,
          ),
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: isSmall ? 11 : 13,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: isSmall ? 8 : 10,
          ),
        ),
      ),
    );
  }

  // 🔐 LÓGICA DE LOGIN CON VALIDACIÓN REAL
  Future<void> _handleLogin() async {
    loading.value = true;

    try {
      // Validaciones básicas
      if (rutController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
        Get.snackbar(
          '⚠️ Campos requeridos',
          'Por favor ingrese RUT y contraseña',
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange[800],
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      // 🌐 AUTENTICACIÓN REAL CON BACKEND
      final authService = Get.find<POSSIIAuthServiceCompleto>();
      final resultado = await authService.loginEmpresa(
        rutController.text.trim(),
        passwordController.text.trim(),
      );

      if (resultado['success'] == true) {
        // Login exitoso
        final usuario = resultado['usuario'];
        final empresa = resultado['empresa'];
        final modo = resultado['modo'] ?? 'backend';
        
        Get.snackbar(
          '✅ Login Exitoso',
          'Bienvenido ${usuario['nombre']} (${modo})',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green[800],
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
        );

        // Pequeña pausa para que se vea el mensaje
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Navegar al menú principal
        Get.offAllNamed('/inicio/cliente');

      } else {
        // Login fallido
        Get.snackbar(
          '❌ Error de Login',
          resultado['message'] ?? 'Credenciales incorrectas',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        );
      }

    } catch (e) {
      // Error general
      Get.snackbar(
        '⚠️ Error',
        'Error durante el login: $e',
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange[800],
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
      print('❌ Error en _handleLogin: $e');
    } finally {
      loading.value = false;
    }
  }
}