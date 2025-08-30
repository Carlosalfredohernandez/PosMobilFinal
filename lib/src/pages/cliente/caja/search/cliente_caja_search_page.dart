import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/pages/cliente/caja/search/cliente_caja_search_controller.dart';


class ClienteCajaSearchPage extends SearchDelegate<Producto>{
  late ClienteCajaSearchController controlador;
  final List<Producto> productos;
  List<Producto> _filter = []; //inicializador

  ClienteCajaSearchPage(this.productos) {
    controlador = Get.put(ClienteCajaSearchController());
  }


  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.close),
      ),

      IconButton(
        onPressed: () async {
          String barcodeScanRes;
          try {
            barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                '#ff6666', 'Cancelar', true, ScanMode.BARCODE);
            print(barcodeScanRes);
          } on PlatformException {
            barcodeScanRes = 'Fallo!';
          }
          query = barcodeScanRes;
        },
        icon: const Icon(Icons.camera_enhance_outlined),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, Producto());
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
    _filter = productos.where((element) {
      return element.nombreProducto!.toLowerCase().contains(query.trim().toLowerCase())
          || element.codigoBarra!.toLowerCase().contains(query.trim().toLowerCase());
    }).toList();
    return ListView.builder(
      itemCount: _filter.length,
      itemBuilder: (_, index) {
        return ListTile(
          title: Text("${_filter[index].nombreProducto}\n${_filter[index].codigoBarra}"),
          subtitle: Text('Precio: ${_filter[index].precioVenta.toString()}'),
          leading: Icon(Icons.category),
          onTap: () => controlador.addToBag(_filter[index]),
        );
      },
    );
  }

}