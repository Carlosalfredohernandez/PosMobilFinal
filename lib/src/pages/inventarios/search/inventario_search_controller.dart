import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/pages/inventarios/create/inventarios_create_controller.dart';
import 'package:posmobil/src/providers/productos_provider.dart';

class InventarioSearchController extends GetxController {

  ProductosProvider productosProvider = ProductosProvider();
  InventariosCreateController caja = Get.find();

  Future<String> scanBarcodeNormal(String codigoBarra) async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancelar', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Fallo!';
    }
    codigoBarra = barcodeScanRes;
    return codigoBarra;
  }


  void addToBag(Producto product){
    caja.addToBag(product);
    Fluttertoast.showToast(msg: 'Producto agregado');
  }
}