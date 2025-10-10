import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/models/usuario.dart';
import 'package:posmobil/src/pages/cliente/caja/create/cliente_caja_create_integrada.dart';
import 'package:posmobil/src/pages/cliente/perfil/mantenedorlistadorusuarios/mantenedor_listar_usuarios_page.dart';
import 'package:posmobil/src/pages/configuraciones/impresora.dart';
import 'package:posmobil/src/pages/informes/estadisticas/estadisticas_ventas_page.dart';
import 'package:posmobil/src/pages/login/empresa_login_page_completa.dart'; // IMPORTACION CORREGIDA
import 'package:posmobil/src/pages/login/login_controller.dart';
// LINEA COMENTADA: import 'package:posmobil/src/pages/login/login_page.dart';
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
// LINEA PROBLEMATICA COMENTADA: import 'package:posmobil/src/pages/login/empresa_login_page.dart' hide EmpresaLoginPageCompleta;
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
// LINEA DUPLICADA COMENTADA: import 'package:posmobil/src/pages/registro/registro_page.dart';
import 'package:posmobil/src/services/pos_sii_auth_service_completo.dart';

// Inicializacion de variables globales
Usuario sesionUsuario = Usuario.fromJson(GetStorage().read('usuario') ?? {});

Map<String, dynamic>? empresaLogueada =
    GetStorage().read('empresa_logueada') != null
        ? Map<String, dynamic>.from(GetStorage().read('empresa_logueada'))
        : null;

bool get isEmpresaAuthenticated => empresaLogueada != null;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // OPCIONAL: Limpiar datos al iniciar (para testing)
  // GetStorage().erase(); // Descomenta si quieres limpiar datos en cada inicio

  print('Iniciando aplicacion POS SII...');
  print('Usuario actual: ${sesionUsuario.id != null ? sesionUsuario.nombre : "Sin sesion"}');
  print('Empresa autenticada: ${isEmpresaAuthenticated ? (empresaLogueada != null ? empresaLogueada!['razonSocial'] : "Sin datos") : "Ninguna"}');

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
    print('MyApp inicializado');
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'POS SII - Sistema Empresarial',

      // CONFIGURACION INICIAL - Servicios
      initialBinding: BindingsBuilder(() {
        print('Inicializando servicios...');
        Get.put(POSSIIAuthServiceCompleto(), permanent: true);
        Get.put(LoginController(), permanent: true);
        print('Servicios inicializados');
      }),

      // CONFIGURACION DE DEBUG
      debugShowCheckedModeBanner: false, // Cambiar de true a false

      // RUTA INICIAL - Siempre empezar en login empresarial
      initialRoute: '/empresa_login',
      
      // CONFIGURACION DE RUTAS
      getPages: [
        // RUTA PRINCIPAL - Login empresarial (NUEVA)
        GetPage(
          name: '/empresa_login',
          page: () => EmpresaLoginPageCompleta(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),
        ),

        // PAGINA PRINCIPAL DEL POS (tu MenuInicioPage)
        GetPage(
          name: '/inicio/cliente',
          page: () => MenuInicioPage(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 400),
        ),

        // RESTO DE RUTAS DEL POS (mantener todas)
        GetPage(name: '/registro', page: () => const RegistroPage()),
        GetPage(
          name: '/inicio/cliente/caja/create',
          page: () => ClienteCajaCreatePageIntegrada(),
          transition: Transition.rightToLeft,
        ),
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

      // TEMA DE LA APLICACION
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,

        // AppBar Theme
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

        // ElevatedButton Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),

        // InputDecoration Theme
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),

        // Card Theme
        cardTheme: const CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),

        // Text Themes
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          titleMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          bodySmall: TextStyle(color: Colors.black),
          labelLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          labelMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          labelSmall: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),

        // SnackBar Theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.grey[800],
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      
      // CONFIGURACIONES ADICIONALES
      navigatorKey: Get.key,

      // Configuraciones de GetX
      defaultTransition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),

      // Configuracion de idioma
      locale: const Locale('es', 'CL'),
      fallbackLocale: const Locale('es', 'CL'),

      // Builder para manejo global de errores
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}