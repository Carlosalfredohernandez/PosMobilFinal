// pages/login/empresa_login_page.dart
// 🔐 LOGIN EMPRESARIAL para integrar con tu app POS existente

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Importa tu servicio mejorado (copia el archivo a tu proyecto)
// import 'package:posmobil/src/services/pos_sii_service_mejorado_demo.dart';

class EmpresaLoginController extends GetxController {
  final rutController = TextEditingController();
  final passwordController = TextEditingController();
  final loading = false.obs;
  final showPassword = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-llenar TECNOALSA para pruebas rápidas
    rutController.text = '77710916-2';
    passwordController.text = '9162';
  }

  Future<void> login() async {
    if (rutController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        '⚠️ Campos Requeridos', 
        'Complete RUT y contraseña de la empresa',
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
      );
      return;
    }

    loading.value = true;

    try {
      // TODO: Cuando copies pos_sii_service_mejorado_demo.dart, descomenta esto:
      /*
      final resultado = await POSSIIServiceMejoradoDemo.loginEmpresa(
        rut: rutController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (resultado['success'] == true) {
        // Guardar sesión empresarial en AuthState
        final authState = Get.find<AuthState>();
        authState.guardarSesionEmpresarial(resultado['empresa']);
        
        Get.snackbar(
          '✅ Login Exitoso',
          'Empresa: ${resultado['empresa']['nombreFantasia']}',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        
        // Ir al login de usuario (tu flujo actual)
        Get.offNamed('/login');
      } else {
        Get.snackbar(
          '❌ Error de Login',
          resultado['error'] ?? 'Credenciales incorrectas',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
      */
      
      // SIMULACIÓN para testing - Elimina cuando implementes el servicio real
      await Future.delayed(Duration(seconds: 1));
      
      if (rutController.text.trim() == '77710916-2' && passwordController.text.trim() == '9162') {
        Get.snackbar(
          '✅ Login Exitoso (DEMO)',
          'Empresa: TECNOALSA',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        
        // Ir al login de usuario (tu flujo actual)
        Get.offNamed('/login');
      } else {
        Get.snackbar(
          '❌ Error de Login',
          'Credenciales incorrectas. Use: 77710916-2 / 9162',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
      
    } catch (e) {
      Get.snackbar(
        '❌ Error de Conexión', 
        'No se pudo conectar con el servidor',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    rutController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

class EmpresaLoginPage extends StatelessWidget {
  const EmpresaLoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmpresaLoginController());
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Título empresarial
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.business,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Text(
                  'Login Empresarial',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'Seleccione su empresa para acceder al POS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Card con formulario
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Card(
                    elevation: 12,
                    shadowColor: Colors.blue.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          // Campo RUT Empresa
                          TextFormField(
                            controller: controller.rutController,
                            decoration: InputDecoration(
                              labelText: 'RUT de la Empresa',
                              hintText: '77710916-2',
                              prefixIcon: const Icon(Icons.business, color: Colors.blue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.blue, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            keyboardType: TextInputType.text,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Campo Contraseña
                          Obx(() => TextFormField(
                            controller: controller.passwordController,
                            decoration: InputDecoration(
                              labelText: 'Contraseña Empresarial',
                              hintText: 'Ingrese la contraseña',
                              prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.showPassword.value 
                                    ? Icons.visibility_off 
                                    : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  controller.showPassword.value = 
                                    !controller.showPassword.value;
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.blue, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            obscureText: !controller.showPassword.value,
                          )),
                          
                          const SizedBox(height: 32),
                          
                          // Botón Login
                          Obx(() => SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: controller.loading.value 
                                ? null 
                                : controller.login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                shadowColor: Colors.blue.withOpacity(0.4),
                              ),
                              child: controller.loading.value
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Text(
                                        'Autenticando...',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.login),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Acceder al POS',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Info de prueba con mejor diseño
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade600,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Datos de Prueba',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text('RUT: ', style: TextStyle(fontWeight: FontWeight.w500)),
                                  Text(
                                    '77710916-2',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text('Password: ', style: TextStyle(fontWeight: FontWeight.w500)),
                                  Text(
                                    '9162',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Empresa: TECNOALSA',
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}