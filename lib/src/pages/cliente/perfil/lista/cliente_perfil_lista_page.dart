import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobilfinal/src/pages/cliente/perfil/lista/cliente_perfil_lista_controller.dart';
class ClientePerfilListaPage extends StatelessWidget {

  ClientePerfilListaController controlador = Get.put(ClientePerfilListaController());

  ClientePerfilListaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx (() => Stack(
        children: [
          _fondoPortada(context),
          _cajaFormulario(context)
        ],
      )),
    );
  }

  Widget _fondoPortada(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.35,
      color: Colors.blueAccent,
    );
  }

  Widget _cajaFormulario(BuildContext context){
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
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
            _textDireccion(),
            _textRegion(),
            _textPhone(),
            _botonUpdate(context)
          ],
        ),
      ),
    );
  }

  // Widgets
  Widget _botonUpdate(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: ElevatedButton(
          onPressed: () => controlador.goToPerfilEditar(),
          child: const Text(
              'ACTUALIZAR DATOS'
          )
      ),
    );
  }
  Widget _textName(){
    return Container(
      margin: const EdgeInsets.only(top:10),
      child: ListTile(
        leading: const Icon(Icons.person),
        subtitle: const Text('Nombre'),
        title: Text(controlador.user.value.nombre ?? ''),
      ),
    );
  }
  Widget _textEmail(){
    return ListTile(
      leading: const Icon(Icons.email),
      title: Text(controlador.user.value.email ?? ''),
      subtitle: const Text('Email'),
    );
  }
  Widget _textDireccion(){
    return ListTile(
      leading: const Icon(Icons.add),
      title: Text('${controlador.user.value.calle ?? ''} ${controlador.user.value.numero ?? ''}, ${controlador.user.value.comuna ?? ''}'),
      subtitle: const Text('Direccion'),
    );
  }
  Widget _textRegion(){
    return ListTile(
      leading: const Icon(Icons.add),
      title: Text(controlador.user.value.region ?? ''),
      subtitle: const Text('Region'),
    );
  }

  Widget _textPhone(){
    return  ListTile(
      leading: const Icon(Icons.phone),
      subtitle: const Text('Telefono de Contacto'),
      title: Text(controlador.user.value.telefono ?? ''),
    );
  }

}
