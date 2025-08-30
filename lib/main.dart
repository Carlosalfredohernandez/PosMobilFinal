import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/models/usuario.dart';
import 'package:posmobil/src/pages/login/login_page.dart';
/*
import 'package:punto_de_venta/src/models/usuario.dart';
import 'package:punto_de_venta/src/pages/agregar/agregar_page.dart';
import 'package:punto_de_venta/src/pages/cliente/categorias/crear/cliente_categorias_crear_page.dart';
import 'package:punto_de_venta/src/pages/cliente/caja/create/cliente_caja_create_page.dart';
import 'package:punto_de_venta/src/pages/cliente/perfil/editar/cliente_perfil_editar_page.dart';
import 'package:punto_de_venta/src/pages/cliente/productos/crear/cliente_productos_lista_crear_page.dart';
import 'package:punto_de_venta/src/pages/cliente/productos/editar/cliente_productos_editar_page.dart';
import 'package:punto_de_venta/src/pages/cliente/perfil/lista/cliente_perfil_lista_page.dart';
import 'package:punto_de_venta/src/pages/informes/ventas/informes_ventas_page.dart';
import 'package:punto_de_venta/src/pages/inventarios/create/inventarios_create_page.dart';
import 'package:punto_de_venta/src/pages/inventarios/informes/inventarios_informes_page.dart';
import 'package:punto_de_venta/src/pages/inventarios/menu/inventarios_menu_page.dart';
import 'package:punto_de_venta/src/pages/inventarios/vista/inventarios_vista_page.dart';
import 'package:punto_de_venta/src/pages/login/login_page.dart';
import 'package:punto_de_venta/src/pages/mantenedores/bodega/mantenedores_bodega_page.dart';
import 'package:punto_de_venta/src/pages/mantenedores/local/mantenedores_local_page.dart';
import 'package:punto_de_venta/src/pages/mantenedores/maestros/busqueda/mantenedores_maestros_page.dart';
import 'package:punto_de_venta/src/pages/mantenedores/maestros/ventana/mantenedores_maestros_usuarios_page.dart';
import 'package:punto_de_venta/src/pages/mantenedores/menu/mantenedores_menu_page.dart';
import 'package:punto_de_venta/src/pages/mantenedores/poveedores/crear/mantenedores_proveedores_page.dart';
import 'package:punto_de_venta/src/pages/mantenedores/productos/mantenedores_productos_page.dart';
import 'package:punto_de_venta/src/pages/menu_inicio/menu_inicio_cajero_page.dart';
import 'package:punto_de_venta/src/pages/menu_inicio/menu_inicio_page.dart';
import 'package:punto_de_venta/src/pages/registro/registro_page.dart';

import 'src/pages/configuraciones/impresoras.dart';
*/
Usuario sesionUsuario = Usuario.fromJson(GetStorage().read('usuario') ?? {});
void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Punto de venta',
      //Mientras la aplicacion este en pruebas se mantendra la etiqueta 'Debug'.
      debugShowCheckedModeBanner: true,
      initialRoute: sesionUsuario.tipoContrato == 'NO'
          ? '/'
          : sesionUsuario.id != null ? '/inicio/cliente' : '/',
      // initialRoute: '/informes/ventas',
      //Rutas de pages.
      getPages: [
        GetPage(name: '/', page: () => const LoginPage()),
        /*GetPage(name: '/registro', page: () => const RegistroPage()),
        GetPage(name: '/inicio/cliente', page: () => const MenuInicioPage()),
        GetPage(name: '/inicio/cajero', page: () => const MenuInicioCajeroPage()),
        GetPage(name: '/inicio/cliente/agregar/categoria', page: () => ClienteCategoriasCrearPage()),
        GetPage(name: '/inicio/cliente/agregar/producto', page: () => ClienteProductosListaCrearPage()),
        GetPage(name: '/inicio/cliente/perfil/editar', page: () => ClientePerfilEditarPage()),
        GetPage(name: '/inicio/cliente/perfil/lista', page: () => ClientePerfilListaPage()),
        GetPage(name: '/inicio/cliente/productos/editar', page: () => ClienteProductosEditarPage()),
        GetPage(name: '/inicio/cliente/caja/create', page: () => ClienteCajaCreatePage()),
        GetPage(name: '/mantenedores/menu', page: () => MantenedoresMenuPage()),
        GetPage(name: '/mantenedores/productos', page: () => MantenedoresProductosPage()),
        GetPage(name: '/mantenedores/maestros/busqueda', page: () => MantenedoresMaestrosPage()),
        GetPage(name: '/mantenedores/maestros/usuarios', page: () => MantenedoresMaestrosUsuariosPage()),
        GetPage(name: '/mantenedores/local', page: () => MantenedoresLocalPage()),
        GetPage(name: '/mantenedores/proveedor', page: () => MantenedoresProveedoresPage()),
        GetPage(name: '/informes/ventas', page: () => InformesVentasPage()),
        GetPage(name: '/inventarios/menu', page: () => InventariosMenuPage()),
        // GetPage(name: '/inventarios/vista', page: () => InventariosVistaPage()),
        GetPage(name: '/inventarios/create', page: () => InventarioCreatePage()),
        GetPage(name: '/inventarios/informes', page: () => InventariosInformesPage()),
        GetPage(name: '/configuraciones/impresora', page: () => ImpresorasPage()),
        GetPage(name: '/agregar', page: () => const AgregarPage()),
*/
      ],
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
        colorScheme: const ColorScheme(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
          brightness: Brightness.light,
          onPrimary: Colors.black,
          onSecondary: Colors.grey,
          surface: Colors.grey,
          onSurface: Colors.grey,
          error: Colors.grey,
          onError: Colors.grey
        )

      ),
      navigatorKey: Get.key,
    );
  }
}

