import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/pages/cliente/caja/create/cliente_caja_create_controller.dart';
import 'package:posmobil/src/providers/productos_provider.dart';

class ClienteCajaSearchController extends GetxController {

  ProductosProvider productosProvider = ProductosProvider();
  ClienteCajaCreateController caja = Get.find();

 // List<Producto> selectedProducts = [];

  // ClienteCajaSearchController(){
  //   if (GetStorage().read('shopping_bag') != null){
  //     if (GetStorage().read('shopping_bag') is List<Producto>){
  //       var result = GetStorage().read('shopping_bag');
  //       selectedProducts.clear();
  //       selectedProducts.addAll(result);
  //     }
  //     else{
  //       var result = Producto.fromJsonList(GetStorage().read('shopping_bag')).toList();
  //       selectedProducts.clear();
  //       selectedProducts.addAll(result);
  //     }
  //     caja.getTotal();
  //   }
  // }

  Future<String> scanBarcodeNormal(String _codigoBarra) async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancelar', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Fallo!';
    }
    _codigoBarra = barcodeScanRes;
    return _codigoBarra;
  }


  void addToBag(Producto product){
    caja.addToBag(product);
    Fluttertoast.showToast(msg: 'Producto agregado');
    // int index = selectedProducts.indexWhere((p) => p.id == product.id);
    // if (index == -1) {
    //   if (product.cantidad == null){
    //     product.cantidad = 1;
    //   }
    //   selectedProducts.add(product);
    //   GetStorage().write('shopping_bag', selectedProducts);
    //   Fluttertoast.showToast(msg: 'Producto agregado_1');
    //
    //   var result = GetStorage().read('shopping_bag');
    //   caja.selectedProducts.clear();
    //   caja.selectedProducts.addAll(result);
    //   caja.getTotal();
    // }
    // else {
    //   if (product.cantidad == 0){
    //     selectedProducts.remove(product);
    //     product.cantidad = 1;
    //     selectedProducts.add(product);
    //     GetStorage().write('shopping_bag', selectedProducts);
    //     Fluttertoast.showToast(msg: 'Producto agregado_2');
    //
    //     var result = GetStorage().read('shopping_bag');
    //     caja.selectedProducts.clear();
    //     caja.selectedProducts.addAll(result);
    //     caja.getTotal();
    //   }
    //   else {
    //     caja.addItem(selectedProducts[index]);
    //     Fluttertoast.showToast(msg: 'Producto agregado_3');
    //   }
    //}
  }
}