import 'package:flutter/material.dart';
import 'package:posmobilfinal/src/pages/cliente/perfil/lista/cliente_perfil_lista_page.dart';

//Variables Globales.
// HomeController controlador = Get.put(HomeController());

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {

  // HomeController controlador = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ClientePerfilListaPage(),
      ),

    );
  }

  // Widget _botonAtras(){
  //   return SafeArea(
  //       child: IconButton(
  //         onPressed: () => controlador.desconectarse(),
  //         icon: const Icon(
  //           Icons.arrow_back_ios,
  //           color: Colors.white,
  //           size: 30,
  //         ),
  //       )
  //   );
  // }
}
