import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/pages/inventarios/search/inventario_search_controller.dart';

class InventarioSearchPage extends SearchDelegate<Producto> {
  late InventarioSearchController controlador;
  final List<Producto> productos;
  List<Producto> _filter = [];

  InventarioSearchPage(this.productos) {
    controlador = Get.put(InventarioSearchController());
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
          await controlador.scanBarcodeNormal(context);
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
          title: Text(_filter[index].nombreProducto.toString() + "\n" + _filter[index].codigoBarra.toString()),
          subtitle: Text('Precio: ${_filter[index].precioVenta.toString()}'),
          leading: Icon(Icons.category),
          onTap: () => controlador.addToBag(_filter[index]),
        );
      },
    );
  }
}