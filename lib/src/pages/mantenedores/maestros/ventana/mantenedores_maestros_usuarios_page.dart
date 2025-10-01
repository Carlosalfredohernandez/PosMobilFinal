import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/models/local.dart';
import 'package:posmobil/src/models/usuario.dart';
import 'package:posmobil/src/pages/mantenedores/maestros/ventana/mantenedores_maestros_usuarios_controller.dart';

class MantenedoresMaestrosUsuariosPage extends StatelessWidget {
  final Usuario? usuario;
  late final MantenedoresMaestrosUsuariosController controlador;

  MantenedoresMaestrosUsuariosPage({super.key, required this.usuario}) {
    if (usuario == null) {
      throw Exception('El usuario no puede ser nulo');
    }
    controlador = Get.put(MantenedoresMaestrosUsuariosController(usuario!));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      appBar: AppBar(
        title: const Text(
          'USUARIO ELEGIDO',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _backgroundCover(context),
          _cajaFormulario(context)
        ],
      ),
      bottomNavigationBar: _buttonActualizar(context),
    ));
  }

  Widget _backgroundCover(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.35,
      color: Colors.blueAccent,
    );
  }

  Widget _cajaFormulario(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.03,
        left: 50,
        right: 50,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.blueGrey,
            blurRadius: 15,
            offset: Offset(0, 0.75),
          )
        ],
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
            _dropDownLocales(controlador.locales),
            _dropDownRoles(controlador.roles),
            _campoTextoClave(),
            _campoTextoConfirmarClave(),
          ],
        ),
      ),
    );
  }

  Widget _textName() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        leading: const Icon(Icons.person),
        subtitle: const Text('Nombre'),
        title: Text(usuario!.nombre ?? ''),
      ),
    );
  }

  Widget _textEmail() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        leading: const Icon(Icons.email_outlined),
        subtitle: const Text('Email'),
        title: Text(usuario!.email ?? ''),
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
      padding: const EdgeInsets.symmetric(horizontal: 50),
      margin: const EdgeInsets.only(top: 15),
      child: DropdownButton(
        underline: Container(
          alignment: Alignment.centerRight,
          child: const Icon(
            Icons.arrow_drop_down_circle,
            color: Colors.blueAccent,
          ),
        ),
        elevation: 3,
        isExpanded: true,
        hint: const Text(
          'Seleccionar Local',
          style: TextStyle(fontSize: 15),
        ),
        items: _dropDownItems(locales),
        value: controlador.nombrelocal.value == '' ? null : controlador.nombrelocal.value,
        onChanged: (option) {
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

  Widget _dropDownRoles(List roles) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      margin: const EdgeInsets.only(top: 15),
      child: DropdownButton(
        underline: Container(
          alignment: Alignment.centerRight,
          child: const Icon(
            Icons.arrow_drop_down_circle,
            color: Colors.blueAccent,
          ),
        ),
        elevation: 3,
        isExpanded: true,
        hint: Text(usuario?.roles?[0].nombre ?? 'Elija el Rol', style: const TextStyle(fontSize: 15)),
        items: _dropDownRolItems(roles),
        value: controlador.nombreRol.value == '' ? null : controlador.nombreRol.value,
        onChanged: (option) {
          controlador.rolId = option.toString() == '0' ? 2 : 3;
          controlador.nombreRol.value = option.toString();
        },
      ),
    );
  }

  List<DropdownMenuItem<String>> _dropDownRolItems(List roles) {
    List<DropdownMenuItem<String>> list = [];
    for (int i = 0; i < roles.length; i++) {
      list.add(DropdownMenuItem(
        value: i.toString(),
        child: Text(roles[i]),
      ));
    }
    return list;
  }

  Widget _buttonActualizar(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: ElevatedButton(
        onPressed: () => controlador.actualizar(),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Colors.blueAccent,
        ),
        child: const Text(
          'Actualizar',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}