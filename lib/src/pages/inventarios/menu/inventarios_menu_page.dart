import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/pages/inventarios/menu/inventarios_menu_controller.dart';


class InventariosMenuPage extends StatefulWidget {
  const InventariosMenuPage({super.key});

  @override
  State<InventariosMenuPage> createState() => _InventariosMenuPageState();
}

class _InventariosMenuPageState extends State<InventariosMenuPage> {

  InventariosMenuController controlador = Get.put(InventariosMenuController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Inventario'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _botonCreate(),
          _botonVista(),
          _botonInformes()
        ],
      ),
    );
  }

  Widget _botonCreate(){
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: ElevatedButton(
            onPressed: () => controlador.goToCreate(),
            child: const Text(
                'INGRESO DE MERCADERIA'
            )
        ),
      ),
    );

  }
  Widget _botonVista(){
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: ElevatedButton(
            onPressed: () => controlador.goToVista(),
            child: const Text(
                'VISTA DE INVENTARIO'
            )
        ),
      ),
    );

  }
  Widget _botonInformes(){
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: ElevatedButton(
            onPressed: () => controlador.goToInformes(),
            child: const Text(
                'INFORME DE INVENTARIO'
            )
        ),
      ),
    );

  }


}
