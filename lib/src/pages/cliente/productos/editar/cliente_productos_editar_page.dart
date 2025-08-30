import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/pages/cliente/productos/editar/cliente_productos_editar_controller.dart';


class ClienteProductosEditarPage extends StatelessWidget {
  Producto? producto;
  late ClienteProductosEditarController controlador;

  ClienteProductosEditarPage({super.key, @required this.producto}){
    Get.delete<ClienteProductosEditarController>();
    controlador = Get.put(ClienteProductosEditarController(producto!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EDITAR PRODUCTO'),
        centerTitle: true,
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: 15),
        child: _buttonActualizar(context)
      ),
      body: Stack( // POSICIONAR ELEMENTOS UNO ENCIMA DEL OTRO
        children: [
          _backgroundCover(context),
          _boxForm(context)
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
      height: MediaQuery.of(context).size.height * 0.7,
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1, left: 50, right: 50),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const <BoxShadow>[
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
            _campoCodigoBarra(),
            _buttonDeshabilitar(context)
          ],
        ),
      ),
    );
  }

  Widget _campoCodigoBarra() {
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
              onPressed: () => controlador.scanBarcodeNormal(),
              child: Text('Escanear Codigo de Baras')),
        ],
      ),
    );
  }

  Widget _textFieldName() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          TextField(
            controller: controlador.nombreProductoController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
                hintText: 'Nombre',
                prefixIcon: Icon(Icons.category)
            ),
          ),
        ],
      ),
    );
  }

  Widget _textFieldPrice() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          TextField(
            controller: controlador.precioVentaController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                hintText: 'Precio',
                prefixIcon: Icon(Icons.attach_money)
            ),
          ),
        ],
      ),
    );
  }

  Widget _textFieldDescription() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        children: [
          TextField(
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
        ],
      ),
    );
  }

  // Widget _textCategoria(){
  Widget _buttonActualizar(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 30, right: 30, top: 18),
      child: ElevatedButton(
          onPressed: () {
            controlador.actualizarProducto(context);
          },
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15)
          ),
          child: Text(
            'ACTUALIZAR PRODUCTO',
            style: TextStyle(
                color: Colors.black
            ),
          )
      ),
    );
  }

  Widget _buttonDeshabilitar(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 30, right: 30, top: 18),
      child: ElevatedButton(
          onPressed: () {
            showDialog(
                context: context, 
                builder: (context) => AlertDialog(
                  actions: [
                    Center(
                      child: Text(
                        '¿Estas seguro?',
                        style: TextStyle(
                            color: Colors.cyan
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => controlador.deshabilitar(controlador.productId),
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 5), backgroundColor: Colors.blueAccent
                          ),
                          child: Text(
                            'SI',
                            style: TextStyle(
                                color: Colors.white
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 5), backgroundColor: Colors.blueAccent
                          ),
                          child: Text(
                            'NO',
                            style: TextStyle(
                                color: Colors.white
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15), backgroundColor: Colors.white
          ),
          child: const Text(
            'Deshabilitar',
            style: TextStyle(
                color: Colors.black
            ),
          )
      ),
    );
  }

  Widget _textYourInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 40, bottom: 30),
      child: const Text(
        'INGRESA ESTA INFORMACION',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }
}
