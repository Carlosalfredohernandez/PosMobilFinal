// 🎯 PÁGINA PRINCIPAL POS - INTERFAZ MODERNA Y PRESENTABLE
// Menú principal del sistema POS

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MenuInicioPage extends StatelessWidget {
  const MenuInicioPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtener datos del usuario logueado
    final usuarioData = GetStorage().read('usuario');
    final nombreUsuario = usuarioData?['nombre'] ?? 'Usuario';
    final rolUsuario = GetStorage().read('usuario_rol') ?? 1;
    final nombreRol = rolUsuario == 1 ? 'Administrador' : rolUsuario == 3 ? 'Cajero' : 'Usuario';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.storefront, size: 24),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POS Sistema',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Panel Principal',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Información del usuario
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    nombreUsuario.isNotEmpty ? nombreUsuario[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      nombreUsuario,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      nombreRol,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  onPressed: () => _mostrarDialogoCerrarSesion(),
                  tooltip: 'Cerrar Sesión',
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de bienvenida
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[800]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.waving_hand,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Bienvenido, $nombreUsuario!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sistema POS listo para usar',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
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

            const SizedBox(height: 24),

            // Título de funciones
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Funciones Principales',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Grid de funciones principales
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildModernMenuCard(
                  'Punto de Venta',
                  'Realizar ventas y cobros',
                  Icons.point_of_sale_rounded,
                  Colors.green,
                  () => Get.toNamed('/inicio/cliente/caja/create'),
                ),
                _buildModernMenuCard(
                  'Productos',
                  'Gestión de inventario',
                  Icons.inventory_2_rounded,
                  Colors.orange,
                  () => _mostrarMensaje('Gestión de productos', 'Función disponible próximamente'),
                ),
                _buildModernMenuCard(
                  'Reportes',
                  'Informes y estadísticas',
                  Icons.analytics_rounded,
                  Colors.purple,
                  () => _mostrarMensaje('Reportes', 'Informes y estadísticas del sistema'),
                ),
                _buildModernMenuCard(
                  'Configuración',
                  'Ajustes del sistema',
                  Icons.settings_rounded,
                  Colors.blue,
                  () => _mostrarMensaje('Configuración', 'Ajustes y configuraciones'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Accesos rápidos
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.orange[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Accesos Rápidos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Botones de acceso rápido
            Row(
              children: [
                Expanded(
                  child: _buildQuickAccessButton(
                    'Nueva Venta',
                    Icons.add_shopping_cart_rounded,
                    Colors.green,
                    () => Get.toNamed('/inicio/cliente/caja/create'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAccessButton(
                    'Ver Reportes',
                    Icons.bar_chart_rounded,
                    Colors.blue,
                    () => _mostrarMensaje('Reportes', 'Acceso a reportes del sistema'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModernMenuCard(
    String titulo,
    String descripcion,
    IconData icono,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 8,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icono,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                descripcion,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton(
    String titulo,
    IconData icono,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 6,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 20),
          const SizedBox(width: 8),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarMensaje(String titulo, String mensaje) {
    Get.snackbar(
      titulo,
      mensaje,
      backgroundColor: Colors.blue[600],
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.info_outline, color: Colors.white),
    );
  }

  void _mostrarDialogoCerrarSesion() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red[600]),
            const SizedBox(width: 12),
            const Text('Cerrar Sesión'),
          ],
        ),
        content: const Text(
          '¿Estás seguro que deseas cerrar la sesión?\n\nTendrás que volver a iniciar sesión para acceder al sistema.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Cerrar diálogo
              Get.back();
              
              // Limpiar todos los datos de sesión
              final storage = GetStorage();
              storage.remove('usuario');
              storage.remove('usuario_rol');
              storage.remove('empresa_logueada');
              storage.remove('empresa_data');
              storage.remove('usuario_empresa');
              
              // Mostrar mensaje de confirmación
              Get.snackbar(
                'Sesión cerrada',
                'Has cerrado sesión exitosamente',
                backgroundColor: Colors.green[600],
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              );
              
              // Navegar al login y limpiar historial
              Get.offAllNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}