import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:posmobilfinal/src/models/producto.dart';
import 'package:posmobilfinal/src/pages/cliente/caja/search/cliente_caja_search_controller.dart';


class ClienteCajaSearchPage extends SearchDelegate<Producto>{
  late ClienteCajaSearchController controlador;
  final List<Producto> productos;
  List<Producto> _filter = []; //inicializador
  bool _isLoading = false;
  List<Producto> _results = [];

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
    String barcodeScanRes = '';
    try {
      //barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      //  '#ff6666', 'Cancelar', true, ScanMode.BARCODE
      //);
      if (barcodeScanRes != '-1') {
        query = barcodeScanRes;
      }
    } on PlatformException {
      barcodeScanRes = 'Fallo!';
    }
    print('Código escaneado: $barcodeScanRes');
  },
  icon: const Icon(Icons.camera_enhance_outlined),
),
      //IconButton(
      //  onPressed: () async {
      //    String barcodeScanRes;
      //    try {
      //      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      //          '#ff6666', 'Cancelar', true, ScanMode.BARCODE);
      //      print(barcodeScanRes);
      //    } on PlatformException {
      //      barcodeScanRes = 'Fallo!';
      //    }
      //    query = barcodeScanRes;
      //  },
      //  icon: const Icon(Icons.camera_enhance_outlined),
      //),
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
    if (query.trim().length < 3) {
      return const Center(
        child: Text('Escribe al menos 3 letras para buscar'),
      );
    }

    return FutureBuilder<List<Producto>>(
      future: controlador.productosProvider.findProductsOnText(query.trim()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error al buscar productos'));
        }
        final productos = snapshot.data ?? [];
        if (productos.isEmpty) {
          return const Center(child: Text('No se encontraron productos'));
        }
        return ListView.builder(
          itemCount: productos.length,
          itemBuilder: (_, index) {
            return ListTile(
              title: Text("${productos[index].nombreProducto}\n${productos[index].codigoBarra}"),
              subtitle: Text('Precio: \\${productos[index].precioVenta.toString()}'),
              leading: const Icon(Icons.category),
              onTap: () => close(context, productos[index]),
            );
          },
        );
      },
    );
  }

}