import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobilfinal/src/pages/cliente/perfil/lista/cliente_perfil_lista_page.dart';
import 'package:posmobilfinal/src/pages/mantenedores/maestros/busqueda/mantenedores_maestros_controller.dart';
import 'package:posmobilfinal/src/pages/mantenedores/maestros/crear/mantenedores_maestros_crear_page.dart';
import 'package:posmobilfinal/src/pages/mantenedores/maestros/delegate/mantenedores_maestros_delegate_page.dart';
class MantenedoresMaestrosPage extends StatelessWidget {

  MantenedoresMaestrosController controlador = Get.put(MantenedoresMaestrosController());

  MantenedoresMaestrosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: PreferredSize(
        //   preferredSize: Size.fromHeight(100),
        //   child: AppBar(
        //     flexibleSpace: Container(
        //       margin: EdgeInsets.only(top: 5,left: 10,right: 10),
        //       alignment: Alignment.center,
        //       child: Wrap(
        //         direction: Axis.horizontal,
        //         children: [
        //           _textFieldSearch(context)
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: ListTile(
            onTap: () {
              showSearch(context: context, delegate:MantenedoresMaestrosDelegatePage(controlador.users));
            },
            title: Text('Buscar Empleados', style: TextStyle(color: Colors.white)),
          ),
        ),
        bottomNavigationBar: Row(
          children: [
            _botonCrear(context),
            _botonCancelar()
          ],
        ),
        body: ClientePerfilListaPage(),
        // body: Scrollbar(
        //   child: ListView.builder(
        //     itemBuilder: (context,index){
        //       return _cardUsers(context,controlador.usersE[index]);
        //         },
        //     itemCount: controlador.usersE.length,
        //   ),
        // )
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

  // Widget _cardUsers(BuildContext context, UsuarioEmpresa usuario) {
  //   return GestureDetector(
  //     onTap: () => controlador.openBottomSheet(context, usuario),
  //     child: ListTile(
  //       title: Text(usuario.nombreUsuario ?? ''),
  //       subtitle: Text('Rut: ${usuario.rut ?? ''} \nRol: ${usuario.rol}'),
  //       leading: Icon(Icons.person),
  //     ),
  //   );
  // }

  Widget _botonCrear(BuildContext context){
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MantenedoresMaestrosCrearPage()));
            },
            child: const Text(
                'Crear Usuario'
            )
        ),
      ),
    );
  }

}