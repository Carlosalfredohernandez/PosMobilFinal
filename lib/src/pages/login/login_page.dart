import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/pages/login/login_controller.dart';

//Variables Globales.
LoginController controlador = Get.put(LoginController());

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {

    //Pagina de inicio 'Login'.
    return Scaffold(
      bottomNavigationBar: SizedBox(
        height: 50,
        child: _textoPoweredby()
      ),

      body: Stack(
        children: [
          _fondoPortada(),
          _cajaFormulario(context),
          Column(
            children: [
              _imagenPortada(),
              _textoNombreApp()
            ],
          ),
        ],
      ),
    );
  }

  Widget _fondoPortada() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.4,
      color: Colors.blueAccent,
    );
  }

  Widget _cajaFormulario(BuildContext context){
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.32, left: 50, right: 50),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.blueGrey,
            blurRadius:  15,
            offset: Offset(0, 0.75)
          )
        ]
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _textoIngresaInformacion(),
            _campoTextoRut(),
            _campoTextoClave(),
            _botonAcceder(),
            _textoNoCuenta()
          ],
        ),
      ),
    );
  }

  // Widgets

  Widget _textoIngresaInformacion(){
    return Container(
      margin: const EdgeInsets.only(top:50, bottom:17),
      child: const Text(
        'INGRESA TU INFORMACION',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _campoTextoRut() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controlador.rutController,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          hintText: 'Rut',
          prefixIcon: Icon(Icons.account_box_outlined),
        ),

      ),
    );
  }

  Widget _campoTextoClave() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
      child: TextField(
        controller: controlador.claveController,
        keyboardType: TextInputType.text,
        obscureText: true,
        decoration: const InputDecoration(
          hintText: 'Contraseña',
          prefixIcon: Icon(Icons.lock_outline),
        ),

      ),
    );
  }

  Widget _botonAcceder(){
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: ElevatedButton(
          onPressed: () => controlador.login(),
          child: const Text(
            'ACCEDER'
          )
      ),
    );

  }

  Widget _imagenPortada() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        alignment: Alignment.center,
        child: Image.asset(
          'android/assets/img/Imagen_portada.png',
          width: 170,
          height: 170,

        ),

      ),
    );
  }

  Widget _textoNombreApp(){
    return const Text(
      'PUNTO DE VENTA',
      style: TextStyle(
        fontSize: 23,
        fontWeight: FontWeight.bold,
        color: Colors.white
      ),
    );
  }

  Widget _textoNoCuenta(){

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:[
        const Text(
          '¿No tienes cuenta? ',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17
          ),
        ),
        GestureDetector(
          onTap: () => controlador.irARegistroPage(),
          child: const Text(
              'Registrate Aqui',
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 17,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ],
    );
  }

  Widget _textoPoweredby(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'Powered by',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12
          ),
        ),
        Text(
          'Tecnoalsa',
          style: TextStyle(
            color: Colors.blueAccent,
            fontSize: 15,
            fontWeight: FontWeight.bold
          ),

        ),
      ],
    );
  }

}
