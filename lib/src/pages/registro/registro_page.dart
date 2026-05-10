import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobilfinal/src/pages/registro/registro_controller.dart';

//Variables Globales.
RegistroController controlador = Get.put(RegistroController());

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SizedBox(
          height: 50,
          child: _textoPoweredby()
      ),

      body: Stack(
        children: [
          _fondoPortada(),
          _cajaFormulario(context),
          _botonAtras()
        ],
      ),
    );
  }

  Widget _fondoPortada() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.35,
      color: Colors.blueAccent,
    );
  }

  Widget _cajaFormulario(BuildContext context){
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15, left: 50, right: 50),
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
            _campoTextoNombre(),
            _campoTextoRut(),
            _campoTextoEmail(),
            _campoTextoClave(),
            _campoTextoConfirmarClave(),
            _botonRegistrarse()
          ],
        ),
      ),
    );
  }

  // Widgets

  Widget _botonAtras(){
    return SafeArea(
        child: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 30,
          ),
        )
    );
  }



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

  Widget _campoTextoNombre() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controlador.nombreController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Nombre y Apellido',
          prefixIcon: Icon(Icons.person),
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

  Widget _campoTextoEmail() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controlador.emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          hintText: 'Email',
          prefixIcon: Icon(Icons.email_outlined),
        ),

      ),
    );
  }

  Widget _campoTextoClave() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
  Widget _campoTextoConfirmarClave() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controlador.confirmarClaveController,
        keyboardType: TextInputType.text,
        obscureText: true,
        decoration: const InputDecoration(
          hintText: 'Confirmar Contraseña',
          prefixIcon: Icon(Icons.lock_outline),
        ),

      ),
    );
  }

  Widget _botonRegistrarse() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: ElevatedButton(
          onPressed: () => controlador.registro(),
          child: const Text(
              'REGISTRARSE'
          )
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
