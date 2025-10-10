import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'menu_general_page_controller.dart';

class MenuGeneralPage extends StatelessWidget {
  const MenuGeneralPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MenuGeneralPageController controlador = Get.put(MenuGeneralPageController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('MENÚ GENERAL'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              
              _rectanguloOpcion('PRODUCTOS', Colors.green, controlador.goToProduct),
              _rectanguloOpcion('USUARIOS', Colors.orange, controlador.goToUser),
              _rectanguloOpcion('LOCALES', Colors.purple, controlador.goToLocal),
              _rectanguloOpcion('BODEGA', Colors.red, controlador.goToBodega),
              _rectanguloOpcion('Informe Ventas', Colors.amber, controlador.goToinformesventas),
              _rectanguloOpcion('Estadisticas', Colors.cyan, controlador.goToEstadisticas),
              _rectanguloOpcion('Inventarios', Colors.blue, controlador.goToInventarios),
              //_rectanguloRuta(context, 'Usuarios', Colors.blue, '/mantenedores/maestros/usuarios'),
              //_rectanguloRuta(context, 'Productos', Colors.green, '/mantenedores/productos'),
              //_rectanguloRuta(context, 'Informes de Ventas', Colors.orange, controlador.goToinformesventas),
              //_rectanguloRuta(context, 'Estadísticas', Colors.purple, '/informes/ventas'),
              //_rectanguloRuta(context, 'Inventarios', Colors.red, '/inventarios/informes'),
              const SizedBox(height: 30),
              _botonVolver(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rectanguloOpcion(String texto, Color color, VoidCallback onTap) {
    return Container(
      width: 320,
      margin: const EdgeInsets.symmetric(vertical: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _rectanguloRuta(BuildContext context, String texto, Color color, String ruta) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      margin: const EdgeInsets.symmetric(vertical: 14),
      child: InkWell(
        onTap: () => Get.toNamed(ruta),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _botonVolver() {
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        onPressed: () => Get.offNamedUntil('/inicio/cliente', (route) => false),
        icon: const Icon(Icons.arrow_back),
        label: const Text('Salir'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}