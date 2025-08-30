import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/pages/cliente/local/create/cliente_local_create_controller.dart';

class ClienteLocalCreatePage extends StatelessWidget {

  ClienteLocalCreateController controlador = Get.put(ClienteLocalCreateController());

  ClienteLocalCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('CREAR LOCAL')),
      ),
      bottomNavigationBar: SizedBox(
          height: 80,
          child: _botonCancelar()
      ),
      body: Stack( // POSICIONAR ELEMENTOS UNO ENCIMA DEL OTRO
        children: [
          _backgroundCover(context),
          _boxForm(context),
        ],
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
      height: MediaQuery.of(context).size.height * 0.45,
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1, left: 50, right: 50),
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
            _textFieldNumero(),
            _buttonCreate(context),
            //_dropDownCategories(controlador.categorias)
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
  Widget _textFieldNumero() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: controlador.pos_numero,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            hintText: 'Numero de Local',
            prefixIcon: Icon(Icons.numbers)
        ),
      ),
    );
  }

  // Widget _dropDownCategories(List<Categoria> categories) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 50),
  //     margin: EdgeInsets.only(top: 15),
  //     child: DropdownButton(
  //       underline: Container(
  //         alignment: Alignment.centerRight,
  //         child: Icon(
  //           Icons.arrow_drop_down_circle,
  //           color: Colors.blueAccent,
  //         ),
  //       ),
  //       elevation: 3,
  //       isExpanded: true,
  //       hint: Text(
  //         'Categorias creadas',
  //         style: TextStyle(
  //             fontSize: 15
  //         ),
  //       ),
  //       items: _dropDownItems(categories),
  //       value: controlador.nombreCategoria.value == '' ? null : controlador.nombreCategoria.value,
  //       onChanged: (option) {
  //         print('Mostrar categorias ${option}');
  //         controlador.nombreCategoria.value = option.toString();
  //       },
  //     ),
  //   );
  // }
  //
  // List<DropdownMenuItem<String>> _dropDownItems(List<Categoria> categorias) {
  //   List<DropdownMenuItem<String>> list = [];
  //   categorias.forEach((categoria) {
  //     list.add(DropdownMenuItem(
  //       value: categoria.id!,
  //       child: Text(categoria.nombreCategoria!),
  //     ));
  //   });
  //
  //   return list;
  // }


  Widget _buttonCreate(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: ElevatedButton(
          onPressed: () {
            controlador.createLocal();
          },
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15)
          ),
          child: Text(
            'CREAR LOCAL',
            style: TextStyle(
                color: Colors.black
            ),
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
          onPressed: () => controlador.regresar(),
          child: const Text(
              'CANCELAR'
          )
      ),
    );
  }

}
