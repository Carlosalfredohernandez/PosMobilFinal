import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class EmpresaLoginPageCompleta extends StatelessWidget {
  EmpresaLoginPageCompleta({Key? key}) : super(key: key);

  final rutController = TextEditingController(text: '77710916-2');
  final passwordController = TextEditingController(text: '9162');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS SII - Login Empresarial'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.business,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 30),
            const Text(
              'Sistema Empresarial POS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: rutController,
              decoration: const InputDecoration(
                labelText: 'RUT Empresa',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Iniciar Sesión',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Migración Gradual Completada',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() {
    print('🚀 Iniciando login empresarial...');
    
    // Simular login exitoso
    GetStorage().write('empresa_logueada', {
      'rut': rutController.text,
      'razonSocial': 'TECNOALSA DEMO S.A.',
      'id': 1,
    });
    
    GetStorage().write('usuario', {
      'id': 1,
      'nombre': 'Administrador',
      'email': 'admin@tecnoalsa.cl',
    });
    
    print('✅ Login exitoso');
    
    // Navegar al menú principal
    Get.offNamed('/inicio/cliente');
  }
}