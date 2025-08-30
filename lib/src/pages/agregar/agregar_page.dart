import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';

class AgregarPage extends StatefulWidget {
  const AgregarPage({super.key});

  @override
  State<AgregarPage> createState() => _AgregarPageState();
}

class _AgregarPageState extends State<AgregarPage> {

  @override
  String _codigoBarra = 'Desconocido';

  @override
  void initState() {
    super.initState();
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;

    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancelar', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Fallo!';
    }

    if (!mounted) return;

    setState(() {
      _codigoBarra = barcodeScanRes;
    });
  }

  //Pantalla
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
            _campoCodigoBarra(),
            _campoTextoRut(),
            //_campoTextoDireccion(),
            //_campoTextoComuna(),
            //_campoTextoRegion(),
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

  Widget _campoCodigoBarra() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Codigo de Barra',
              prefixIcon: Icon(Icons.person),
            ),

          ),
          ElevatedButton(
              onPressed: () => scanBarcodeNormal(),
              child: Text('Escanear Codigo de Baras')),
        ],
      ),
    );
  }

  Widget _campoTextoRut() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          hintText: 'Rut',
          prefixIcon: Icon(Icons.account_box_outlined),
        ),

      ),
    );
  }
/*
  Widget _campoTextoDireccion() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: const TextField(
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Direccion',
          prefixIcon: Icon(Icons.home_outlined),
        ),

      ),
    );
  }
  Widget _campoTextoComuna() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: const TextField(
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Comuna',
          prefixIcon: Icon(Icons.home_outlined),
        ),

      ),
    );
  }
  Widget _campoTextoRegion() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: const TextField(
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Region',
          prefixIcon: Icon(Icons.home_outlined),
        ),

      ),
    );
  }

 */

  Widget _campoTextoEmail() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
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
          onPressed: () {},
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
