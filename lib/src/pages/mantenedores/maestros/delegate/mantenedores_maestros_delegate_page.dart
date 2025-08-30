import 'package:flutter/material.dart';
import 'package:posmobil/src/models/usuario.dart';
import 'package:posmobil/src/models/usuario_empresa.dart';


class MantenedoresMaestrosDelegatePage extends SearchDelegate<Usuario>{
  final List<UsuarioEmpresa> users;

  List<UsuarioEmpresa> _filter= [];
  MantenedoresMaestrosDelegatePage(this.users);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.close),
      ),
      // IconButton(
      //   onPressed: () async {
      //     String barcodeScanRes;
      //     try {
      //       barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      //           '#ff6666', 'Cancelar', true, ScanMode.BARCODE);
      //       print(barcodeScanRes);
      //     } on PlatformException {
      //       barcodeScanRes = 'Fallo!';
      //     }
      //     query = barcodeScanRes;
      //   },
      //   icon: const Icon(Icons.camera_enhance_outlined),
      // ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, Usuario());
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _filter = users.where((element) {
       return element.nombreUsuario!.toLowerCase().contains(query.trim().toLowerCase())
           || element.rut!.toLowerCase().contains(query.trim().toLowerCase());
    }).toList();
    return ListView.builder(
      itemCount: _filter.length,
      itemBuilder: (_, index) {
        return ListTile(
          title: Text(_filter[index].nombreUsuario.toString()),
          subtitle: Text('Rut: ${_filter[index].rut.toString()}\nRol: ${_filter[index].rol == '3' ? 'CAJERO' : 'USUARIO'}'),
          leading: Icon(Icons.person),
          onTap: () {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => MantenedoresMaestrosUsuariosPage(usuario: _filter[index]))
            // );
          },
        );
      },
    );
  }

}