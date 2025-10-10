// 🏠 MENÚ INICIO CON CONTROL DE ACCESO POR ROLES
// Esta página muestra diferentes opciones según el rol del usuario

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MenuInicioPageControlado extends StatefulWidget {
  const MenuInicioPageControlado({Key? key}) : super(key: key);

  @override
  State<MenuInicioPageControlado> createState() => _MenuInicioPageControladoState();
}

class _MenuInicioPageControladoState extends State<MenuInicioPageControlado> {
  final storage = GetStorage();
  Map<String, dynamic>? usuario;
  Map<String, dynamic>? empresa;
  int userRole = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    usuario = storage.read('usuario');
    empresa = storage.read('empresa_logueada') ?? storage.read('empresa');
    
    if (usuario != null) {
      userRole = int.tryParse(usuario!['rol']?.toString() ?? '0') ?? 0;
      print('👤 Usuario cargado: ${usuario!['nombre']} - Rol: $userRole');
    }
    
    // Verificar que el usuario tenga acceso
    if (usuario == null) {
      print('❌ No hay usuario logueado, redirigiendo...');
      Get.offAllNamed('/empresa_login');
      return;
    }
  }

  /// 🎭 Obtener nombre del rol
  String get roleName {
    switch (userRole) {
      case 1:
        return 'Administrador';
      case 3:
        return 'Cajero';
      default:
        return 'Usuario';
    }
  }

  /// 📋 Obtener opciones de menú según el rol
  List<Map<String, dynamic>> getMenuOptions() {
    if (userRole == 1) {
      // ADMINISTRADOR - Acceso completo
      return [
        {
          'title': 'POS / Caja',
          'subtitle': 'Sistema de punto de venta',
          'icon': Icons.shopping_cart,
          'color': Colors.blue,
          'route': '/inicio/cliente/caja/create',
        },
        {
          'title': 'Productos',
          'subtitle': 'Gestionar productos y categorías',
          'icon': Icons.inventory_2,
          'color': Colors.green,
          'route': '/inicio/cliente/productos/crear',
        },
        {
          'title': 'Mantenedores',
          'subtitle': 'Configuración del sistema',
          'icon': Icons.settings,
          'color': Colors.orange,
          'route': '/mantenedores/menu',
        },
        {
          'title': 'Inventarios',
          'subtitle': 'Control de stock',
          'icon': Icons.assignment,
          'color': Colors.purple,
          'route': '/inventarios/menu',
        },
        {
          'title': 'Reportes',
          'subtitle': 'Informes y estadísticas',
          'icon': Icons.analytics,
          'color': Colors.red,
          'route': '/informes/ventas',
        },
        {
          'title': 'Usuarios',
          'subtitle': 'Gestión de usuarios',
          'icon': Icons.people,
          'color': Colors.teal,
          'route': '/inicio/cliente/mantenedorlistadorusuarios',
        },
      ];
    } else if (userRole == 3) {
      // CAJERO - Solo acceso al POS
      return [
        {
          'title': 'POS / Caja',
          'subtitle': 'Sistema de punto de venta',
          'icon': Icons.shopping_cart,
          'color': Colors.blue,
          'route': '/inicio/cliente/caja/create',
        },
      ];
    }
    
    return []; // Sin permisos
  }

  /// 🚪 Cerrar sesión
  void _logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Está seguro que desea cerrar la sesión?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Limpiar datos de sesión
              storage.remove('usuario');
              storage.remove('usuarioempresa');
              storage.remove('empresa');
              storage.remove('empresa_logueada');
              
              // Redirigir al login
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

  @override
  Widget build(BuildContext context) {
    final menuOptions = getMenuOptions();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('POS ${empresa?['razonSocial'] ?? 'Sistema'}'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con información del usuario
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue[700],
                          child: Text(
                            usuario?['nombre']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bienvenido',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                usuario?['nombre'] ?? 'Usuario',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: userRole == 1 ? Colors.green : Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  roleName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (empresa != null) ...[
                      Divider(color: Colors.blue[200]),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.business, color: Colors.blue[700], size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              empresa!['razonSocial'] ?? 'Empresa',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Título del menú
              Text(
                userRole == 3 ? 'Módulo de Caja' : 'Módulos del Sistema',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                userRole == 3 
                    ? 'Accede al sistema de punto de venta'
                    : 'Selecciona el módulo que deseas utilizar',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 24),

              // Grid de opciones
              if (menuOptions.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.lock,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sin Permisos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No tienes permisos para acceder a ningún módulo.',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: userRole == 3 ? 1 : 2, // Una sola columna para cajeros
                    childAspectRatio: userRole == 3 ? 3 : 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: menuOptions.length,
                  itemBuilder: (context, index) {
                    final option = menuOptions[index];
                    return _buildMenuCard(option);
                  },
                ),

              const SizedBox(height: 32),

              // Información adicional para cajeros
              if (userRole == 3)
                Container(
                  padding: const EdgeInsets.all(16),
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
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Información del Cajero',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Como cajero, tienes acceso exclusivo al sistema de punto de venta (POS). '
                        'Puedes procesar ventas, consultar productos y generar boletas electrónicas.',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(Map<String, dynamic> option) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          print('🎯 Navegando a: ${option['route']}');
          Get.toNamed(option['route']);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                option['color'].withOpacity(0.1),
                option['color'].withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: option['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  option['icon'],
                  size: userRole == 3 ? 32 : 28,
                  color: option['color'],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                option['title'],
                style: TextStyle(
                  fontSize: userRole == 3 ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                option['subtitle'],
                style: TextStyle(
                  fontSize: userRole == 3 ? 14 : 12,
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
}