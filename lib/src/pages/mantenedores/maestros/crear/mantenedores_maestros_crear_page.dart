import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobilfinal/src/models/local.dart';
import 'package:posmobilfinal/src/pages/mantenedores/maestros/crear/mantenedores_maestros_crear_controlador.dart';

class MantenedoresMaestrosCrearPage extends StatelessWidget {

  MantenedoresMaestrosCrearController controlador = Get.put(MantenedoresMaestrosCrearController());

  MantenedoresMaestrosCrearPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'INGRESA TU INFORMACION',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Obx(() => Stack(
        children: [
          _fondoPortada(context),
          _cajaFormulario(context),
        ],
      ))
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
      height: MediaQuery.of(context).size.height * 0.7,
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
            _campoNombre(),
            _campoRut(),
            _campoEmail(),
            _dropDownLocales(controlador.locales),
            _campoTextoClave(),
            _campoTextoConfirmarClave(),
            _botonActualizar()
          ],
        ),
      ),
    );
  }

  Widget _campoNombre() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controlador.nombreController,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          hintText: 'Nombre',
          prefixIcon: Icon(Icons.add),
        ),
      ),
    );
  }
  Widget _campoRut() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controlador.rutController,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          hintText: 'Rut usuario',
          prefixIcon: Icon(Icons.add),
        ),
      ),
    );
  }
  Widget _campoEmail() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controlador.emailController,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          hintText: 'Correo electronico',
          prefixIcon: Icon(Icons.add),
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
  Widget _dropDownLocales(List<Local> locales) {

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 50),
      margin: EdgeInsets.only(top: 15),
      child: DropdownButton(
        underline: Container(
          alignment: Alignment.centerRight,
          child: Icon(
            Icons.arrow_drop_down_circle,
            color: Colors.blueAccent,
          ),
        ),
        elevation: 3,
        isExpanded: true,
        hint: Text(
          'Seleccionar Local',
          style: TextStyle(
              fontSize: 15
          ),
        ),
        items: _dropDownItems(locales),
        value: controlador.nombrelocal.value == '' ? null : controlador.nombrelocal.value,
        onChanged: (option) {
          print('Opcion seleccionada $option');
          controlador.nombrelocal.value = option.toString();
        },
      ),
    );
  }

  List<DropdownMenuItem<String>> _dropDownItems(List<Local> locales) {
    List<DropdownMenuItem<String>> list = [];
    for (var local in locales) {
      list.add(DropdownMenuItem(
        value: local.id,
        child: Text(local.nombreLocal ?? ''),
      ));
    }
    return list;

  }

  Widget _botonActualizar() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: ElevatedButton(
          onPressed: () => controlador.create(),
          child: const Text(
              'CREAR USUARIO'
          )
      ),
    );
  }
}
