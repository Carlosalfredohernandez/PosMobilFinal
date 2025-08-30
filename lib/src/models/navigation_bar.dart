import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/models/usuario.dart';
//import 'package:punto_de_venta/src/pages/configuraciones/impresoras.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});


  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {

  Usuario sesionUsuario = Usuario.fromJson(GetStorage().read('usuario'));
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
              accountName: Text(sesionUsuario.nombre.toString()),
              accountEmail: Text(sesionUsuario.rut.toString()),
              currentAccountPicture: CircleAvatar(
              ),

          ),
          ListTile(
            leading: Icon(Icons.add_circle),
            title: Text('Mantenedores'),
            onTap: () => Get.toNamed('/mantenedores/menu'),
          ),
          ListTile(
            leading: Icon(Icons.add_circle),
            title: Text('Punto de Venta'),
            onTap: () => Get.toNamed('/inicio/cliente/caja/create'),
          ),
          ListTile(
            leading: Icon(Icons.add_circle),
            title: Text('Configuraciones'),
            onTap: () => Get.toNamed('/configuraciones/impresora'),
          ),
          ListTile(
            leading: Icon(Icons.add_circle),
            title: Text('Inventarios'),
            onTap: () => Get.toNamed('/inventarios/menu'),
          ),
          ListTile(
            leading: Icon(Icons.add_circle),
            title: Text('Informe General'),
            onTap: () => Get.toNamed('/informes/ventas'),
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Salir'),
            onTap: () => desconectarse(),
          ),
        ],
      ),

    );
  }

  void desconectarse(){
    GetStorage().remove('usuario');
    Get.offNamedUntil('/', (route) => false);
  }

}
