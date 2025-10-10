// 🎯 PÁGINA PRINCIPAL POS - VERSIÓN SIMPLIFICADA PARA TESTING
// Coloca en: lib/src/pages/menu_inicio/menu_inicio_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MenuInicioPage extends StatelessWidget {
  const MenuInicioPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtener datos de la empresa logueada
    final empresaLogueada = GetStorage().read('empresa_logueada');
    final razonSocial = empresaLogueada?['razonSocial'] ?? 'Empresa no identificada';
    final rutEmpresa = empresaLogueada?['rutEmpresa'] ?? 'Sin RUT';

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS SII - Sistema Empresarial'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _cerrarSesion(),
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏢 INFORMACIÓN DE LA EMPRESA
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.business, color: Colors.blue[700], size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Empresa Autenticada',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Razón Social: $razonSocial',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'RUT: $rutEmpresa',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // ✅ MENSAJE DE ÉXITO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border.all(color: Colors.green.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '¡Migración completada! Sistema de autenticación empresarial funcionando correctamente.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // 🎯 BOTONES PRINCIPALES
            const Text(
              'Funciones Principales:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Grid de botones
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuButton(
                    'Ventas POS',
                    Icons.point_of_sale,
                    Colors.blue,
                    () => _mostrarMensaje('Función POS SII disponible'),
                  ),
                  _buildMenuButton(
                    'Productos',
                    Icons.inventory,
                    Colors.green,
                    () => _mostrarMensaje('Gestión de productos'),
                  ),
                  _buildMenuButton(
                    'Informes',
                    Icons.analytics,
                    Colors.orange,
                    () => _mostrarMensaje('Informes y estadísticas'),
                  ),
                  _buildMenuButton(
                    'Configuración',
                    Icons.settings,
                    Colors.purple,
                    () => _mostrarMensaje('Configuración del sistema'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarMensaje(String mensaje) {
    Get.snackbar(
      'Información',
      mensaje,
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[800],
      duration: const Duration(seconds: 2),
    );
  }

  void _cerrarSesion() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Está seguro que desea cerrar la sesión empresarial?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Limpiar datos de sesión
              GetStorage().remove('empresa_logueada');
              GetStorage().remove('usuario');
              
              // Volver al login
              Get.offAllNamed('/empresa_login');
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
}