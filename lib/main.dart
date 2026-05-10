import 'package:posmobilfinal/src/pages/empresas/mantenedor_empresas_page.dart';
import 'package:posmobilfinal/src/pages/informes/estadisticas/estadisticas_ventas_page.dart';
import 'package:posmobilfinal/src/pages/mantenedores/local/mantenedores_local_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/pages/cliente/caja/create/cliente_caja_create_antiguo.dart';
import 'package:posmobilfinal/src/pages/cliente/caja/create/cliente_caja_create_binding.dart';
import 'package:posmobilfinal/src/pages/login/login_page.dart';
import 'package:posmobilfinal/src/pages/mantenedores/menu/mantenedores_menu_page.dart';
import 'package:posmobilfinal/src/pages/menu_inicio/menu_inicio_page_backup.dart'
    as menu_backup;
import 'package:posmobilfinal/src/pages/mantenedores/usuariosempresa/usuarios_empresa_page.dart';
import 'package:posmobilfinal/src/pages/mantenedores/productos/mantenedores_productos_page.dart';
import 'package:posmobilfinal/src/pages/menugeneral/menu_general_page.dart';
import 'package:posmobilfinal/src/pages/ventas/ventas_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posmobilfinal/supabase_config.dart';
import 'package:posmobilfinal/src/pages/cliente/productos/crear/cliente_productos_lista_crear_page.dart';
import 'package:posmobilfinal/src/pages/mantenedores/proveedores/crear/crear/mantenedores_proveedores_page.dart';
import 'package:posmobilfinal/src/pages/cliente/categorias/crear/cliente_categorias_crear_page.dart';
import 'package:posmobilfinal/src/pages/informes/detalle_venta/informes_detalle_venta_page.dart';
import 'package:posmobilfinal/src/pages/menugeneral/boleta_pdf_demo_page.dart';
import 'package:posmobilfinal/src/pages/menugeneral/boleta_api_demo_page.dart';
import 'package:posmobilfinal/src/pages/menugeneral/boleta_pdf_pos_page.dart';

// Inventarios
import 'package:posmobilfinal/src/pages/inventarios/menu/inventarios_menu_page.dart';
import 'package:posmobilfinal/src/pages/inventarios/vista/inventarios_vista_page.dart';
import 'package:posmobilfinal/src/pages/inventarios/create/inventarios_create_page.dart';
import 'package:posmobilfinal/src/pages/inventarios/informes/inventarios_informes_page.dart';

// VERSION SIMPLE Y ESTABLE - SIN MULTIEMPRESAS
// Esta es una version simplificada que funciona con el backend existente

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  print('Iniciando aplicacion POS - VERSION SIMPLE...');

  // Establecer orientacion de pantalla
  await SystemChrome.setPreferredOrientations([
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
    print('MyApp inicializado - Version Simple');
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'POS Simple',

      // CONFIGURACION INICIAL BASICA
      initialBinding: BindingsBuilder(() {
        print('Inicializando servicios basicos...');
        // Get.put(LoginController(), permanent: true); // COMENTADO - causaba auto-login
        print('Servicios basicos inicializados');
      }),

      debugShowCheckedModeBanner: false,

      // RUTA INICIAL SIMPLE
      initialRoute: '/login',

      // RUTAS BASICAS
      getPages: [
        GetPage(
          name: '/mantenedores/local',
          page: () => MantenedoresLocalPage(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/inicio/cliente/productos/crear',
          page: () => ClienteProductosListaCrearPage(),
        ),
        // Login simple
        GetPage(
          name: '/login',
          page: () => LoginPage(),
          transition: Transition.fadeIn,
        ),

        // Menu principal (ahora solo backup)
        GetPage(
          name: '/inicio/cliente',
          page: () => menu_backup.MenuInicioPage(),
          transition: Transition.fadeIn,
        ),

        // PANTALLA BACKUP - AUTENTICACION USUARIO EMPRESA (CON LOGICA DE ROLES)
        GetPage(
          name: '/menu_inicio_backup',
          page: () => menu_backup.MenuInicioPage(),
          transition: Transition.fadeIn,
        ),

        // Mantenedor de Usuarios Empresa
        GetPage(
          name: '/usuarios_empresa',
          page: () => UsuariosEmpresaPage(),
          transition: Transition.rightToLeft,
        ),
        // Mantenedor de Empresas (nuevo)
        GetPage(
          name: '/mantenedor_empresas',
          page: () => const MantenedorEmpresasPage(),
          transition: Transition.rightToLeft,
        ),
        // POS - Caja (INTEGRADA DESHABILITADA TEMPORALMENTE)
        // GetPage(
        //   name: '/inicio/cliente/caja/create',
        //   page: () => ClienteCajaCreatePageIntegrada(),
        //   transition: Transition.rightToLeft,
        // ),
        GetPage(
          name: '/inicio/cliente/caja/create_antiguo',
          page: () => ClienteCajaCreatePage(),
          binding: ClienteCajaCreateBinding(),
          transition: Transition.rightToLeft,
        ),

        // Menu general
        GetPage(
          name: '/menugeneral',
          page: () => MenuGeneralPage(),
          transition: Transition.rightToLeft,
        ),

        // Página de ventas (para totem y acceso directo)
        GetPage(
          name: '/ventas',
          page: () => VentasPage(),
          transition: Transition.rightToLeft,
        ),

        // Página de productos (para menú general)
        GetPage(
          name: '/mantenedores/productos',
          page: () => MantenedoresProductosPage(),
          transition: Transition.rightToLeft,
        ),

        // Página de bodega (proveedores)
        GetPage(
          name: '/mantenedores/proveedor',
          page: () => MantenedoresProveedoresPage(),
          transition: Transition.rightToLeft,
        ),

        // Inventarios
        GetPage(
          name: '/inventarios/menu',
          page: () => InventariosMenuPage(),
          transition: Transition.rightToLeft,
        ),

        // Estadísticas (menú general)
        GetPage(
          name: '/menu_general/estadisticas',
          page: () => EstadisticasVentasPage(),
          transition: Transition.rightToLeft,
        ),
        // Informes Detalle Venta
        GetPage(
          name: '/informes/detalle_venta',
          page: () => const InformesDetalleVentaPage(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/inventarios/vista',
          page: () => InventariosVistaPage(id: null),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/inventarios/create',
          page: () => InventarioCreatePage(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/inventarios/informes',
          page: () => InventariosInformesPage(),
          transition: Transition.rightToLeft,
        ),

        // Página de categorías (para menú general)
        GetPage(
          name: '/inicio/cliente/agregar/categoria',
          page: () => ClienteCategoriasCrearPage(),
          transition: Transition.rightToLeft,
        ),

        // Demo generación PDF de boleta
        // GetPage(
        //   name: '/boleta_pdf_demo',
        //   page: () => BoletaPdfDemoPage(),
        //   transition: Transition.rightToLeft,
        // ),
        GetPage(
          name: '/boleta_api_demo',
          page: () => const BoletaApiDemoPage(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/boleta_pdf_pos',
          page: () => const BoletaPdfPosPage(),
          transition: Transition.rightToLeft,
        ),

        // Rutas basicas adicionales
        GetPage(name: '/home', page: () => const Placeholder()),
        GetPage(name: '/inicio/cajero', page: () => const Placeholder()),
        GetPage(name: '/mantenedores/menu', page: () => MantenedoresMenuPage()),
      ],

      // TEMA SIMPLE
      theme: ThemeData(
        primaryColor: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),

      // Configuraciones basicas
      defaultTransition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      locale: const Locale('es', 'CL'),
      fallbackLocale: const Locale('es', 'CL'),
    );
  }
}
