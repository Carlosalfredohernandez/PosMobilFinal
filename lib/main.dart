import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/models/usuario.dart';
import 'package:posmobil/src/pages/cliente/caja/create/cliente_caja_create_page.dart';
import 'package:posmobil/src/pages/cliente/perfil/mantenedorlistadorusuarios/mantenedor_listar_usuarios_page.dart';
import 'package:posmobil/src/pages/configuraciones/impresora.dart';
import 'package:posmobil/src/pages/informes/estadisticas/estadisticas_ventas_page.dart';
import 'package:posmobil/src/pages/login/login_page.dart';
import 'package:posmobil/src/pages/agregar/agregar_page.dart';
import 'package:posmobil/src/pages/cliente/categorias/crear/cliente_categorias_crear_page.dart';
import 'package:posmobil/src/pages/cliente/perfil/editar/cliente_perfil_editar_page.dart';
import 'package:posmobil/src/pages/cliente/productos/crear/cliente_productos_lista_crear_page.dart';
import 'package:posmobil/src/pages/cliente/productos/editar/cliente_productos_editar_page.dart';
import 'package:posmobil/src/pages/cliente/perfil/lista/cliente_perfil_lista_page.dart';
import 'package:posmobil/src/pages/informes/ventas/informes_ventas_page.dart';
import 'package:posmobil/src/pages/inventarios/create/inventarios_create_page.dart';
import 'package:posmobil/src/pages/inventarios/informes/inventarios_informes_page.dart';
import 'package:posmobil/src/pages/inventarios/menu/inventarios_menu_page.dart';
import 'package:posmobil/src/pages/inventarios/vista/inventarios_vista_page.dart';
import 'package:posmobil/src/pages/home/home_page.dart';
import 'package:posmobil/src/pages/mantenedores/bodega/mantenedores_bodega_page.dart';
import 'package:posmobil/src/pages/mantenedores/local/mantenedores_local_page.dart';
import 'package:posmobil/src/pages/mantenedores/maestros/busqueda/mantenedores_maestros_page.dart';
import 'package:posmobil/src/pages/mantenedores/maestros/ventana/mantenedores_maestros_usuarios_page.dart';
import 'package:posmobil/src/pages/mantenedores/menu/mantenedores_menu_page.dart';
import 'package:posmobil/src/pages/mantenedores/proveedores/crear/crear/mantenedores_proveedores_page.dart';
import 'package:posmobil/src/pages/mantenedores/productos/mantenedores_productos_page.dart';
import 'package:posmobil/src/pages/menu_inicio/menu_inicio_cajero_page.dart';
import 'package:posmobil/src/pages/menu_inicio/menu_inicio_page.dart';
import 'package:posmobil/src/pages/menugeneral/menu_general_page.dart';
import 'package:posmobil/src/pages/registro/registro_page.dart';
//import 'package:posmobil/src/services/bluetooth_printer_service.dart';
import 'package:posmobil/src/pages/registro/registro_page.dart';

//import 'src/pages/configuraciones/impresoras.dart';

Usuario sesionUsuario = Usuario.fromJson(GetStorage().read('usuario') ?? {});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  GetStorage().erase(); // Borra datos guardados al iniciar

  // Establecer orientación de pantalla
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Registro del servicio Bluetooth (si lo usas)
  //Get.put(BluetoothPrinterService());

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
      debugShowCheckedModeBanner: true,
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/menugeneral', page: () => MenuGeneralPage()),
        GetPage(name: '/menu_general/usuarios', page: () => Placeholder()),
        GetPage(name: '/menu_general/productos', page: () => Placeholder()),
        GetPage(name: '/menu_general/informes_ventas', page: () => Placeholder()),
        GetPage(name: '/menu_general/estadisticas', page: () => Placeholder()),
        GetPage(name: '/menu_general/inventarios', page: () => Placeholder()),
        // ...otras rutas reales...
        GetPage(name: '/', page: () => const LoginPage()),
        GetPage(name: '/registro', page: () => const RegistroPage()),
        GetPage(name: '/inicio/cliente', page: () => const MenuInicioPage()),
        GetPage(name: '/inicio/cliente/caja/create', page: () => ClienteCajaCreatePage()),
        GetPage(name: '/inicio/cajero', page: () => const MenuInicioCajeroPage()),
        GetPage(name: '/inicio/cliente/agregar/categoria', page: () => ClienteCategoriasCrearPage()),
        GetPage(name: '/inicio/cliente/mantenedorlistadorusuarios', page: () => MantenedorListarUsuariosPage()),
        GetPage(name: '/inicio/cliente/productos/crear', page: () => ClienteProductosListaCrearPage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/inicio/cliente/agregar/producto', page: () => ClienteProductosListaCrearPage()),
        GetPage(name: '/inicio/cliente/perfil/editar', page: () => ClientePerfilEditarPage()),
        GetPage(name: '/inicio/cliente/perfil/lista', page: () => ClientePerfilListaPage()),
        GetPage(name: '/inicio/cliente/productos/editar', page: () => ClienteProductosEditarPage(producto: null,)),
        GetPage(name: '/mantenedores/menu', page: () => MantenedoresMenuPage()),
        GetPage(name: '/mantenedores/productos', page: () => MantenedoresProductosPage()),
        GetPage(name: '/mantenedores/maestros/busqueda', page: () => MantenedoresMaestrosPage()),
        GetPage(name: '/mantenedores/maestros/usuarios', page: () => MantenedoresMaestrosUsuariosPage(usuario: sesionUsuario)),
        GetPage(name: '/mantenedores/local', page: () => MantenedoresLocalPage()),
        GetPage(name: '/mantenedores/proveedor', page: () => MantenedoresProveedoresPage()),
        GetPage(name: '/informes/ventas', page: () => InformesVentasPage()),
        GetPage(name: '/inventarios/menu', page: () => InventariosMenuPage()),
        GetPage(name: '/inventarios/vista', page: () => InventariosVistaPage(id: null)),
        GetPage(name: '/inventarios/create', page: () => InventarioCreatePage()),
        GetPage(name: '/inventarios/informes', page: () => InventariosInformesPage()),
        GetPage(name: '/configuraciones/impresora', page: () => ImpresorasPage()),
        GetPage(name: '/agregar', page: () => const AgregarPage()),
        GetPage(name: '/informes/estadisticas', page: () => EstadisticasVentasPage()),
      ],
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
        colorScheme: const ColorScheme(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
          brightness: Brightness.light,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
          error: Colors.red,
          onError: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          bodySmall: TextStyle(color: Colors.black),
          displayLarge: TextStyle(color: Colors.black),
          displayMedium: TextStyle(color: Colors.black),
          displaySmall: TextStyle(color: Colors.black),
          headlineLarge: TextStyle(color: Colors.black),
          headlineMedium: TextStyle(color: Colors.black),
          headlineSmall: TextStyle(color: Colors.black),
          titleLarge: TextStyle(color: Colors.black),
          titleMedium: TextStyle(color: Colors.black),
          titleSmall: TextStyle(color: Colors.black),
          labelLarge: TextStyle(color: Colors.black),
          labelMedium: TextStyle(color: Colors.black),
          labelSmall: TextStyle(color: Colors.black),
        ),
      ),
      navigatorKey: Get.key,
    );
  }
}