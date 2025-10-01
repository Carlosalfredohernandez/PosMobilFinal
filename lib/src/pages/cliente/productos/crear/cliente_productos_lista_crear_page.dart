import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/models/categoria.dart';

import 'cliente_productos_lista_crear_controller.dart';

class ClienteProductosListaCrearPage extends StatelessWidget {

  ClienteProductosListaCrearController controlador = Get.put(ClienteProductosListaCrearController());

  ClienteProductosListaCrearPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _botonCancelar(),
      appBar: AppBar(
        title: Text('NUEVO PRODUCTO'),
        titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 23,
            color: Colors.black
        ),
        centerTitle: true,
      ),
      body: Obx(() => Stack( // POSICIONAR ELEMENTOS UNO ENCIMA DEL OTRO
        children: [
          _backgroundCover(context),
          _boxForm(context),
        ],
      )),
    );
  }
  Widget _botonCancelar(){
    return Container(
      //width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: ElevatedButton(
          onPressed: () => controlador.regresar(),
          child: const Text(
              'CANCELAR'
          )
      ),
    );
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
      height: MediaQuery.of(context).size.height * 0.7,
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03, left: 50, right: 50),
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
            _textFieldDescription(),
            _textFieldPrice(),
            _campoCodigoBarra(context),
            _dropDownCategories(controlador.categorias),
            _buttonCreate(context)
          ],
        ),
      ),
    );
  }
  // Widget _botonAtras(){
  //   return SafeArea(
  //       child: IconButton(
  //         onPressed: () => controlador.regresar(),
  //         icon: const Icon(
  //           Icons.arrow_back_ios,
  //           color: Colors.white,
  //           size: 30,
  //         ),
  //       )
  //   );
  // }

  Widget _campoCodigoBarra(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          TextField(
            controller: controlador.codigoBarraController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Codigo de barra',
              prefixIcon: Icon(Icons.person),
            ),

          ),
          ElevatedButton(
              onPressed: () => controlador.scanBarcodeNormal(context),
              child: Text('Escanear Codigo de Baras')),
        ],
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
          'Seleccionar categoria',
          style: TextStyle(
            fontSize: 15
          ),
        ),
        items: _dropDownItems(categories),
        value: controlador.nombreCategoria.value == '' ? null : controlador.nombreCategoria.value,
        onChanged: (option) {
          print('Opcion seleccionada $option');
          controlador.nombreCategoria.value = option.toString();
        },
      ),
    );
  }

  List<DropdownMenuItem<String>> _dropDownItems(List<Categoria> categorias) {
    List<DropdownMenuItem<String>> list = [];
    for (var categoria in categorias) {
      list.add(DropdownMenuItem(
          value: categoria.id,
          child: Text(categoria.nombreCategoria ?? ''),
      ));
    }

    return list;
  }


  Widget _textFieldName() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: controlador.nombreProductoController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            hintText: 'Nombre',
            prefixIcon: Icon(Icons.category)
        ),
      ),
    );
  }

  Widget _textFieldPrice() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: controlador.precioVentaController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            hintText: 'Precio',
            prefixIcon: Icon(Icons.attach_money)
        ),
      ),
    );
  }

  Widget _textFieldDescription() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: TextField(
        controller: controlador.descripcionProductoController,
        keyboardType: TextInputType.text,
        maxLines: 3,
        decoration: InputDecoration(
            hintText: 'Descripcion',
            prefixIcon: Container(
              margin: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.description)
            )
        ),
      ),
    );
  }

  Widget _buttonCreate(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 30, right: 30, top: 18),
      child: ElevatedButton(
          onPressed: () {
            controlador.createProduct(context);
          },
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15)
          ),
          child: Text(
            'CREAR PRODUCTO',
            style: TextStyle(
                color: Colors.black
            ),
          )
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

}
