import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'menu_general_page_controller.dart';

class MenuGeneralPageModern extends StatefulWidget {
  const MenuGeneralPageModern({super.key});

  @override
  State<MenuGeneralPageModern> createState() => _MenuGeneralPageModernState();
}

class _MenuGeneralPageModernState extends State<MenuGeneralPageModern>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late List<Animation<double>> _cardAnimations;

  final MenuGeneralPageController controlador = Get.put(MenuGeneralPageController());

  final List<MenuItem> menuItems = [
    MenuItem('PRODUCTOS', Icons.inventory_2_rounded, Colors.green.shade600, Colors.green.shade800),
    MenuItem('CATEGORÍAS', Icons.category_rounded, Colors.teal.shade600, Colors.teal.shade800),
    MenuItem('USUARIOS', Icons.people_rounded, Colors.orange.shade600, Colors.orange.shade800),
    MenuItem('LOCALES', Icons.store_rounded, Colors.purple.shade600, Colors.purple.shade800),
    MenuItem('PROVEEDORES', Icons.warehouse_rounded, Colors.red.shade600, Colors.red.shade800),
    MenuItem('INFORMES VENTAS', Icons.analytics_rounded, Colors.amber.shade600, Colors.amber.shade800),
    MenuItem('ESTADÍSTICAS', Icons.bar_chart_rounded, Colors.cyan.shade600, Colors.cyan.shade800),
    MenuItem('INVENTARIOS', Icons.inventory_rounded, Colors.blue.shade600, Colors.blue.shade800),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _cardAnimations = List.generate(
      menuItems.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _cardAnimationController,
        curve: Interval(
          index * 0.1,
          0.6 + (index * 0.1),
          curve: Curves.elasticOut,
        ),
      )),
    );
  }

  void _startAnimations() {
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              _buildHeader(),
              Expanded(child: _buildMenuGrid()),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeInAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Get.offNamedUntil('/inicio/cliente', (route) => false),
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
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.offNamedUntil('/inicio/cliente', (route) => false),
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(25),
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
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Panel de Administración',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
      },
    );
  }

  Widget _buildMenuGrid() {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 500 ? 2 : 3;
    final aspectRatio = width < 400 ? 0.95 : (width < 600 ? 1.1 : 1.3);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: aspectRatio,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _cardAnimations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _cardAnimations[index].value,
                child: Opacity(
                  opacity: _cardAnimations[index].value,
                  child: _buildMenuCard(menuItems[index], index),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMenuCard(MenuItem item, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            item.primaryColor,
            item.secondaryColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: item.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _handleMenuTap(index),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(22), // icono más grande
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    item.icon,
                    size: 48, // icono más grande
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeInAnimation,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: () => Get.offNamedUntil('/inicio/cliente', (route) => false),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.exit_to_app_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'SALIR DEL SISTEMA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleMenuTap(int index) {
    // Animación de feedback al tocar
    _animationController.forward(from: 0.8).then((_) {
      _animationController.forward();
    });

    switch (index) {
      case 0:
        controlador.goToProduct();
        break;
      case 1:
        controlador.goToCategory();
        break;
      case 2:
        controlador.goToUser();
        break;
      case 3:
        controlador.goToLocal();
        break;
      case 4:
        controlador.goToBodega();
        break;
      case 5:
        controlador.goToinformesventas();
        break;
      case 6:
        controlador.goToEstadisticas();
        break;
      case 7:
        controlador.goToInventarios();
        break;
    }
  }
}

class MenuItem {
  final String title;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;

  MenuItem(this.title, this.icon, this.primaryColor, this.secondaryColor);
}