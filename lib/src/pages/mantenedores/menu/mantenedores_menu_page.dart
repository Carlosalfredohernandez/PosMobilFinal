import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobilfinal/src/pages/mantenedores/menu/mantenedores_menu_controller.dart';

class MantenedoresMenuPage extends StatelessWidget {
  MantenedoresMenuController controlador = Get.put(MantenedoresMenuController());

  MantenedoresMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MANTENEDORES'),
        centerTitle: true,
      ),
      bottomNavigationBar: _botonCancelar(),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _rectanguloOpcion('CATEGORIAS', Colors.blue, controlador.goToCategory),
              _rectanguloOpcion('PRODUCTOS', Colors.green, controlador.goToProduct),
              _rectanguloOpcion('USUARIOS', Colors.orange, controlador.goToUser),
              _rectanguloOpcion('LOCALES', Colors.purple, controlador.goToLocal),
              _rectanguloOpcion('BODEGA', Colors.red, controlador.goToBodega),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rectanguloOpcion(String texto, Color color, VoidCallback onTap) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              texto,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _botonCancelar() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: ElevatedButton(
        onPressed: () => controlador.goToHome(),
        child: const Text('CANCELAR'),
      ),
    );
  }
}