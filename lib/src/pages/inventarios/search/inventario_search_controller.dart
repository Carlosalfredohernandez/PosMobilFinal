import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:posmobilfinal/src/models/producto.dart';
import 'package:posmobilfinal/src/pages/inventarios/create/inventarios_create_controller.dart';
import 'package:posmobilfinal/src/providers/productos_provider.dart';

class InventarioSearchController extends GetxController {

  ProductosProvider productosProvider = ProductosProvider();
  InventariosCreateController caja = Get.find();

 // ...existing code...

Future<void> scanBarcodeNormal(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => SizedBox(
      height: 400,
      child: MobileScanner(
        onDetect: (capture) async {
          final barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final code = barcodes.first.rawValue ?? '';
            if (code.isNotEmpty) {
              var result = await productosProvider.getProduct(code);
              if (result != null) {
                addToBag(result);
                Fluttertoast.showToast(msg: 'Producto agregado');
              } else {
                Fluttertoast.showToast(msg: 'Producto no encontrado');
              }
              Navigator.pop(context);
            }
          }
        },
      ),
    ),
  );
}

void addToBag(Producto product) {
  caja.addToBag(product);
  Fluttertoast.showToast(msg: 'Producto agregado');
}

// ...existing code...
  }

  
