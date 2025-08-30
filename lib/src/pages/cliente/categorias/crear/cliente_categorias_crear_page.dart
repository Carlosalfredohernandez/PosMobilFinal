import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/models/categoria.dart';
import 'cliente_categorias_crear_controller.dart';

class ClienteCategoriasCrearPage extends StatelessWidget {

  ClienteCategoriasCrearController controlador = Get.put(ClienteCategoriasCrearController());

  ClienteCategoriasCrearPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      bottomNavigationBar: SizedBox(
          height: 80,
          child: _botonCancelar()
      ),
      body: Stack( // POSICIONAR ELEMENTOS UNO ENCIMA DEL OTRO
        children: [
          _backgroundCover(context),
          _boxForm(context),
          _textNewCategory(context)
        ],
      ),
    ));
  }

  Widget _backgroundCover(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.35,
      color: Colors.blueAccent,
    );
  }

  Widget _boxForm(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.3, left: 50, right: 50),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black54,
                blurRadius: 15,
                offset: Offset(0, 0.75)
            )
          ]
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _textYourInfo(),
            _textFieldName(),
            _buttonCreate(context),
            _dropDownCategories(controlador.categorias)
          ],
        ),
      ),
    );
  }



  Widget _textFieldName() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: controlador.nombreController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            hintText: 'Nombre',
            prefixIcon: Icon(Icons.category)
        ),
      ),
    );
  }

  Widget _dropDownCategories(List<Categoria> categories) {
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
          'Categorias creadas',
          style: TextStyle(
              fontSize: 15
          ),
        ),
        items: _dropDownItems(categories),
        value: controlador.nombreCategoria.value == '' ? null : controlador.nombreCategoria.value,
        onChanged: (option) {
          print('Mostrar categorias $option');
          controlador.nombreCategoria.value = option.toString();
        },
      ),
    );
  }

  List<DropdownMenuItem<String>> _dropDownItems(List<Categoria> categorias) {
    List<DropdownMenuItem<String>> list = [];
    for (var categoria in categorias) {
      list.add(DropdownMenuItem(
        value: categoria.id!,
        child: Text(categoria.nombreCategoria!),
      ));
    }

    return list;
  }


  Widget _buttonCreate(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: ElevatedButton(
          onPressed: () {
            controlador.createCategory();
          },
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15)
          ),
          child: Text(
            'CREAR CATEGORIA',
            style: TextStyle(
                color: Colors.black
            ),
          )
      ),
    );
  }

  Widget _textNewCategory(BuildContext context) {

    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(top: 15),
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Icon(Icons.category, size: 100),
            Text(
              'NUEVA CATEGORIA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 23
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textYourInfo() {
    return Container(
      margin: EdgeInsets.only(top: 40, bottom: 30),
      child: Text(
        'INGRESA ESTA INFORMACION',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _botonCancelar(){
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text(
              'CANCELAR'
          )
      ),
    );
  }

}
