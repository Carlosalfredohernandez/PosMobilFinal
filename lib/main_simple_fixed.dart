import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/models/usuario.dart';
import 'package:posmobilfinal/src/pages/cliente/caja/create/cliente_caja_create_antiguo.dart';
import 'package:posmobilfinal/src/pages/login/login_page.dart';
import 'package:posmobilfinal/src/pages/login/login_controller.dart';
//import 'package:posmobilfinal/src/pages/menu_inicio/menu_inicio_page.dart';
import 'package:posmobilfinal/src/pages/menugeneral/menu_general_page.dart';

// VERSION SIMPLE Y ESTABLE - SIN MULTIEMPRESAS
// Esta es una version simplificada que funciona con el backend existente

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

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
        Get.put(LoginController(), permanent: true);
        print('Servicios basicos inicializados');
      }),

      debugShowCheckedModeBanner: false,

      // RUTA INICIAL SIMPLE
      initialRoute: '/login',

      // RUTAS BASICAS
      getPages: [
        // Login simple
        GetPage(
          name: '/login',
          page: () => LoginPage(),
          transition: Transition.fadeIn,
        ),

        // Menu principal
       /* GetPage(
          name: '/inicio/cliente',
          page: () => MenuInicioPage(),
          transition: Transition.fadeIn,
        ),
*/
        // POS - Caja (INTEGRADA DESHABILITADA TEMPORALMENTE)
        // GetPage(
        //   name: '/inicio/cliente/caja/create',
        //   page: () => ClienteCajaCreatePageIntegrada(),
        //   transition: Transition.rightToLeft,
        // ),
        GetPage(
          name: '/inicio/cliente/caja/create_antiguo',
          page: () => ClienteCajaCreatePage(),
          transition: Transition.rightToLeft,
        ),

        // Menu general
        GetPage(
          name: '/menugeneral',
          page: () => MenuGeneralPage(),
          transition: Transition.rightToLeft,
        ),

        // Rutas basicas adicionales
        GetPage(name: '/home', page: () => const Placeholder()),
        GetPage(name: '/inicio/cajero', page: () => const Placeholder()),
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