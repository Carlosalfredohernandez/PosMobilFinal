import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobilfinal/src/pages/cliente/perfil/editar/cliente_perfil_editar_controller.dart';

class ClientePerfilEditarPage extends StatelessWidget {

  ClientePerfilEditarController controlador = Get.put(ClientePerfilEditarController());

  ClientePerfilEditarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _textoIngresaInformacion() ,
        centerTitle: true,
      ),
      bottomNavigationBar: SizedBox(
          height: 50,
          child: _textoPoweredby()
      ),
      body: Stack(
        children: [
          _fondoPortada(context),
          _cajaFormulario(context)
        ],
      ),
    );
  }
  // Widget _botonAtras(){
  //   return SafeArea(
  //       child: IconButton(
  //         onPressed: () => Get.back(),
  //         icon: const Icon(
  //           Icons.arrow_back_ios,
  //           color: Colors.white,
  //           size: 30,
  //         ),
  //       )
  //   );
  // }

  Widget _fondoPortada(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.35,
      color: Colors.blueAccent,
    );
  }

  Widget _cajaFormulario(BuildContext context){
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1, left: 50, right: 50),
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
            _textName(),
            _textEmail(),
            _campoTextoTelefono(),
            _campoTextoCalle(),
            _campoTextoNumero(),
            _campoTextoComuna(),
            _campoTextoRegion(),
            _campoTextoClave(),
            _campoTextoConfirmarClave(),
            _botonActualizar()
          ],
        ),
      ),
    );
  }

  // Widgets

  Widget _textoIngresaInformacion(){
    return Container(
      margin: const EdgeInsets.only(top:10, bottom:10),
      child: const Text(
        'INGRESA TU INFORMACION',
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _textName(){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        leading: const Icon(Icons.person),
        subtitle: const Text('Nombre'),
        title: Text(controlador.user.nombre ?? ''),
      ),
    );
  }

  Widget _campoTextoTelefono() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controlador.telefonoController,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          hintText: 'Telefono',
          prefixIcon: Icon(Icons.phone),
        ),
      ),
    );
  }
  Widget _campoTextoRegion() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controlador.regionController,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          hintText: 'Region',
          prefixIcon: Icon(Icons.add),
        ),
      ),
    );
  }
  Widget _campoTextoCalle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controlador.calleController,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          hintText: 'Calle',
          prefixIcon: Icon(Icons.add),
        ),
      ),
    );
  }
  Widget _campoTextoNumero() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controlador.numeroController,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          hintText: 'Numero de Hogar',
          prefixIcon: Icon(Icons.add),
        ),
      ),
    );
  }
  Widget _campoTextoComuna() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controlador.comunaController,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          hintText: 'Comuna',
          prefixIcon: Icon(Icons.add),
        ),
      ),
    );
  }
  Widget _textEmail(){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        leading: const Icon(Icons.email_outlined),
        subtitle: const Text('Email'),
        title: Text(controlador.user.email ?? ''),
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

  Widget _botonActualizar() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: ElevatedButton(
          onPressed: () => controlador.actualizar(),
          child: const Text(
              'ACTUALIZAR'
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
