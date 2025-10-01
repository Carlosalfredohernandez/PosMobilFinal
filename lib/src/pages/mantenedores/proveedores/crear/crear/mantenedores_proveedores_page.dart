import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:posmobil/src/pages/mantenedores/poveedores/crear/mantenedores_proveedores_controlador.dart';
import 'package:posmobil/src/pages/mantenedores/proveedores/crear/crear/mantenedores_proveedores_controlador.dart';

class MantenedoresProveedoresPage extends StatelessWidget {

  MantenedoresProveedoresControlador controlador = Get.put(MantenedoresProveedoresControlador());

  MantenedoresProveedoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Proveedor'),
        centerTitle: true,
      ),
      body: _cajaFormulario(context),
      bottomNavigationBar: _botonCancelar(),
    );
  }

  Widget _cajaFormulario(BuildContext context){
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
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
            _campoTextoNombre(),
            _campoTextoTelefono(),
            _campoTextoEmail(),
            _campoTextoDireccion(),
            _botonCrear(),
          ],
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
          hintText: 'Nombre de Proveedor',
          prefixIcon: Icon(Icons.person),
        ),

      ),
    );
  }

  Widget _campoTextoTelefono(){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controlador.telefonoController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Telefono',
          prefixIcon: Icon(Icons.phone),
        ),

      ),
    );
  }
  Widget _campoTextoEmail() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controlador.emailController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Email',
          prefixIcon: Icon(Icons.alternate_email_outlined),
        ),

      ),
    );
  }
  Widget _campoTextoDireccion() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controlador.direccionController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Direccion',
          prefixIcon: Icon(Icons.add),
        ),

      ),
    );
  }

  Widget _botonCrear() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: ElevatedButton(
          onPressed: () => controlador.crearProveedor(),
          child: const Text(
              'Añadir'
          )
      ),
    );
  }

  Widget _botonCancelar(){
    return Container(
      //width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: ElevatedButton(
          onPressed: () => controlador.volver(),
          child: const Text(
              'REGRESAR'
          )
      ),
    );
  }

}
