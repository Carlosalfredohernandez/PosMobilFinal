
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:posmobil/src/models/response_api.dart';
import 'package:posmobil/src/models/usuario.dart';
import 'package:posmobil/src/providers/usuarios_empresa_provider.dart';


Usuario sesionUsuario = Usuario.fromJson(GetStorage().read('usuario'));

class MenuInicioCajeroPage extends StatefulWidget {
  const MenuInicioCajeroPage({super.key});

  @override
  State<MenuInicioCajeroPage> createState() => _MenuInicioCajeroPageState();
}

class _MenuInicioCajeroPageState extends State<MenuInicioCajeroPage> {
  TextEditingController rutController = TextEditingController();
  TextEditingController claveController = TextEditingController();

  UsuariosEmpresaProvider usuariosEmpresaProvider = UsuariosEmpresaProvider();



  void irARegistroPage(){
    Get.toNamed('/registro');
  }

  void login() async{
    String rut = rutController.text.trim();
    String clave = claveController.text.trim();

    if(validador(clave,rut)){
      ResponseApi responseApi = await usuariosEmpresaProvider.login(rut, clave);

      print('Response Api: ${responseApi.toJson()}');

      if (responseApi.success == true){
        GetStorage().write('usuarioempresa', responseApi.data);
        irAHomePage();
      }
      else{
        Get.snackbar('Fallido ', responseApi.message ?? '');
      }
    }
  }

  void irAHomePage(){
    Get.toNamed('/inicio/cliente/caja/create');
  }


  //Validadores.

  bool validador(String clave, String rut){
    if (rut.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar el rut de tu empresa o usuario');
      return false;
    }
    if (clave.isEmpty){
      Get.snackbar('Formulario no valido', 'Debes ingresar tu clave');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blueAccent.shade700,
                Colors.blueAccent,
              ],
            ),
          ),
        ),
        title: Text(sesionUsuario.nombre.toString()),
        centerTitle: true,

      ),
      body: Stack(
        children: [
          _fondoPortada(),
          _cajaFormulario(context),
        ],
      ),
      bottomNavigationBar: Container(
        child: ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Salir'),
          onTap: () => desconectarse(),
        ),
      ),

    );
  }
  Widget _fondoPortada() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.4,
      color: Colors.blueAccent,
    );
  }

  Widget _cajaFormulario(BuildContext context){
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
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
            _campoTextoRut(),
            _campoTextoClave(),
            _botonAcceder()
          ],
        ),
      ),
    );
  }

  Widget _textoIngresaInformacion(){
    return Container(
      margin: const EdgeInsets.only(top:50, bottom:17),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'INGRESA TU INFORMACION',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
            ),
          ),
          Text(
            'DE USUARIO',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoTextoRut() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: rutController,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          hintText: 'Rut',
          prefixIcon: Icon(Icons.account_box_outlined),
        ),

      ),
    );
  }

  Widget _campoTextoClave() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
      child: TextField(
        controller: claveController,
        keyboardType: TextInputType.text,
        obscureText: true,
        decoration: const InputDecoration(
          hintText: 'Contraseña',
          prefixIcon: Icon(Icons.lock_outline),
        ),

      ),
    );
  }

  Widget _botonAcceder(){
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: ElevatedButton(
          onPressed: () => login(),
          child: const Text(
              'ACCEDER'
          )
      ),
    );

  }

  void desconectarse(){
    GetStorage().remove('usuario');
    Get.offNamedUntil('/', (route) => false);
  }


}
