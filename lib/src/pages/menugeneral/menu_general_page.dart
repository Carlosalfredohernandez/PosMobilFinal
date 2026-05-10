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
      MenuItem('PRODUCTO', Icons.inventory_2_rounded, Colors.green.shade600),
      MenuItem('CATEGORÍA', Icons.category_rounded, Colors.teal.shade600),
      MenuItem('USUARIOS', Icons.people_rounded, Colors.orange.shade600),
      MenuItem('LOCALES', Icons.store_rounded, Colors.purple.shade600),
      MenuItem('PROVEEDORES', Icons.warehouse_rounded, Colors.red.shade600),
      MenuItem('INFORMES VENTAS', Icons.analytics_rounded, Colors.amber.shade600),
      MenuItem('ESTADÍSTICAS', Icons.bar_chart_rounded, Colors.cyan.shade600),
      MenuItem('INVENTARIOS', Icons.inventory_rounded, Colors.blue.shade600),
      MenuItem('TOTEM', Icons.touch_app_rounded, Colors.deepPurpleAccent),
      MenuItem('PUNTO DE VENTAS', Icons.point_of_sale_rounded, Colors.deepOrangeAccent),
      // Nueva opción para generación de PDF de boletas
      MenuItem('GENERACIÓN PDF DE BOLETAS', Icons.picture_as_pdf_rounded, Colors.pink.shade400),
        MenuItem('GENERACIÓN DE BOLETAS (API SII)', Icons.receipt_long_rounded, Colors.indigo.shade400),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => controlador.logout(),
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'MENÚ GENERAL',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => controlador.logout(),
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 22,
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
                child: const Text(
                  'Panel de Administración',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              // Grid expandido para ocupar el espacio disponible
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                         final crossAxisCount = width < 500 ? 3 : (width < 800 ? 4 : 5); // más columnas
                        final aspectRatio = width < 400 ? 0.65 : (width < 600 ? 0.75 : 0.9); // aún más reducido
                        return GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 2.0, // aún menor
                            mainAxisSpacing: 1.0, // mínima
                            childAspectRatio: aspectRatio,
                          ),
                          itemCount: menuItems.length,
                          itemBuilder: (context, index) {
                            return Center(
                              child: SizedBox(
                                width: 80, // ancho compacto
                                height: 110, // alto aumentado para texto
                                child: _buildMenuCard(menuItems[index], index, controlador),
                              ),
                            );
                          },
                        );
                  },
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
        borderRadius: BorderRadius.circular(14.4), // 20% menos
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
          borderRadius: BorderRadius.circular(14.4),
          onTap: () => _handleMenuTap(index, controller),
          child: Padding(
            padding: const EdgeInsets.all(7.2), // 20% menos
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10.4), // 20% menos
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(8.8), // 20% menos
                  ),
                  child: Icon(
                    item.icon,
                    size: 30.4, // 20% menos
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8.8), // 20% menos
                Flexible(
                  child: Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.2, // 20% menos
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
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
  }

  void _handleMenuTap(int index, MenuGeneralPageController controller) {
    switch (index) {
      case 0:
        controller.goToProduct();
        break;
      case 1:
        controller.goToCategory();
        break;
      case 2:
        controller.goToUser();
        break;
      case 3:
        controller.goToLocal();
        break;
      case 4:
        controller.goToBodega();
        break;
      case 5:
        controller.goToinformesventas();
        break;
      case 6:
        controller.goToEstadisticas();
        break;
      case 7:
        controller.goToInventarios();
        break;
      case 8:
        controller.goToTotem();
        break;
      case 9:
        controller.goToPuntoDeVentas();
        break;
        case 10:
          // Navegar a la página demo de la API de boletas
          Get.toNamed('/boleta_api_demo');
          break;
      case 10:
        // Navegar a la página demo de generación de PDF de boletas
        Get.toNamed('/boleta_pdf_demo');
        break;
    }
  }


class MenuItem {
  final String title;
  final IconData icon;
  final Color color;

  MenuItem(this.title, this.icon, this.color);
}