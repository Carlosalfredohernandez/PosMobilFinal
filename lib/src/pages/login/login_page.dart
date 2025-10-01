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
  void initState() {
    super.initState();
    controlador.rutController.text = '';
    controlador.claveController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Permite que el contenido se ajuste con el teclado
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      bottomNavigationBar: SizedBox(
        height: 50,
        child: _textoPoweredby()
      ),
      body: Stack(
        children: [
          _imagenPortadaFondo(),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.08 - 30),
                _cajaFormulario(context),
                SizedBox(height: 30),
                _textoNombreApp(),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagenPortadaFondo() {
    return SizedBox.expand(
      child: Image.asset(
        'android/assets/img/Imagen_portada.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _cajaFormulario(BuildContext context){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _textoIngresaInformacion(),
          _campoTextoRut(),
          _campoTextoClave(),
          _botonAcceder(),
        ],
      ),
    );
  }

  Widget _textoIngresaInformacion(){
    return Container(
      margin: const EdgeInsets.only(top:30, bottom:17),
      child: const Text(
        'INGRESA INFORMACION EMPRESA',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _campoTextoRut() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controlador.rutController,
        keyboardType: TextInputType.text,
        style: const TextStyle(fontSize: 16),
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
        style: const TextStyle(fontSize: 16),
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