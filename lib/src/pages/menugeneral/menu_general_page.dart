import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'menu_general_page_controller.dart';

class MenuGeneralPage extends StatelessWidget {
  const MenuGeneralPage({super.key});

  @override
  Widget build(BuildContext context) {
    late final MenuGeneralPageController controlador;
    try {
      controlador = Get.find<MenuGeneralPageController>();
    } catch (e) {
      controlador = Get.put(MenuGeneralPageController());
    }

    final List<MenuItem> menuItems = [
      MenuItem('PRODUCTOS', Icons.inventory_2_rounded, Colors.green.shade600),
      MenuItem('USUARIOS', Icons.people_rounded, Colors.orange.shade600),
      MenuItem('LOCALES', Icons.store_rounded, Colors.purple.shade600),
      MenuItem('BODEGA', Icons.warehouse_rounded, Colors.red.shade600),
      MenuItem('INFORMES VENTAS', Icons.analytics_rounded, Colors.amber.shade600),
      MenuItem('ESTADÍSTICAS', Icons.bar_chart_rounded, Colors.cyan.shade600),
      MenuItem('INVENTARIOS', Icons.inventory_rounded, Colors.blue.shade600),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3C72),
              Color(0xFF2A5298),
              Color(0xFF3D5AF1),
              Color(0xFF7B68EE),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header - Fijo y simple
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => controlador.logout(),
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Text(
                      'MENÚ GENERAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    IconButton(
                      onPressed: () => controlador.logout(),
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Subtítulo
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white70,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Panel de Administración',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Grid expandido para ocupar el espacio disponible
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      return _buildMenuCard(menuItems[index], index, controlador);
                    },
                  ),
                ),
              ),
              
              // Footer - Fijo y compacto
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => controlador.logout(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    icon: const Icon(Icons.exit_to_app_rounded, size: 20),
                    label: const Text(
                      'SALIR DEL SISTEMA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
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

  Widget _buildMenuCard(MenuItem item, int index, MenuGeneralPageController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            item.color,
            item.color.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleMenuTap(index, controller),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuTap(int index, MenuGeneralPageController controller) {
    switch (index) {
      case 0:
        controller.goToProduct();
        break;
      case 1:
        controller.goToUser();
        break;
      case 2:
        controller.goToLocal();
        break;
      case 3:
        controller.goToBodega();
        break;
      case 4:
        controller.goToinformesventas();
        break;
      case 5:
        controller.goToEstadisticas();
        break;
      case 6:
        controller.goToInventarios();
        break;
    }
  }
}

class MenuItem {
  final String title;
  final IconData icon;
  final Color color;

  MenuItem(this.title, this.icon, this.color);
}