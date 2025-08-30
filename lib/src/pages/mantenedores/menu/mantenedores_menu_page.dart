import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/pages/mantenedores/menu/mantenedores_menu_controller.dart';
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
              _botonCategorias(),
              _botonProductos(),
              _botonMaestros(),
              _botonLocal(),
              _botonBodega()
            ],
          ),
        ],
      ),
    );
  }
  Widget _botonCategorias(){
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: ElevatedButton(
            onPressed: () => controlador.goToCategory(),
            child: const Text(
                'CATEGORIAS'
            )
        ),
      ),
    );
  }

  Widget _botonMaestros(){
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: ElevatedButton(
            onPressed: () => controlador.goToUser(),
            child: const Text(
                'USUARIOS'
            )
        ),
      ),
    );

  }
  Widget _botonLocal(){
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: ElevatedButton(
            onPressed: () => controlador.goToLocal(),
            child: const Text(
                'LOCALES'
            )
        ),
      ),
    );

  }
  Widget _botonProductos(){
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: ElevatedButton(
            onPressed: () => controlador.goToProduct(),
            child: const Text(
                'PRODUCTOS'
            )
        ),
      ),
    );
  }
  Widget _botonBodega(){
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: ElevatedButton(
            onPressed: () => controlador.goToBodega(),
            child: const Text(
                'BODEGA'
            )
        ),
      ),
    );
  }

  Widget _botonCancelar(){
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: ElevatedButton(
          onPressed: () => controlador.goToHome(),
          child: const Text(
              'CANCELAR'
          )
      ),
    );
  }
}
