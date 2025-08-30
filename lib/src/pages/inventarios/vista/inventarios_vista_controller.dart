import 'dart:async';

import 'package:get/get.dart';
import 'package:posmobil/src/models/inventario.dart';
import 'package:posmobil/src/providers/inventario_provider.dart';

class InventariosVistaController extends GetxController{
  List<Inventario> stock = <Inventario>[];
  List<Inventario> filter = <Inventario>[].obs;
  InventarioProvider inventarioProvider = InventarioProvider();
  var texto = ''.obs;
  var total = 0.obs;
  Timer? searchOnStoppedTyping;

  InventariosVistaController(var id){
    getTheStock(id);
    getTotal();
  }

  // void onChangeText(String text){
  //   filter = stock.where((element) {
  //     return element.idProvedor!.toLowerCase().contains(text.trim().toLowerCase())
  //         || element.fecha!.toLowerCase().contains(text.trim().toLowerCase())
  //         || element.codigoProducto!.toLowerCase().contains(text.trim().toLowerCase());
  //   }).toList();
  // }

  void getTheStock(var producto) async {
    var result = await inventarioProvider.getByCodigo(producto);
    stock.clear();
    stock.addAll(result);
    getTotal();
  }
  void getTotal(){
    for (var element in stock) {
      total.value = total.value + element.cantidad!;
      print('${total.value}');
    }
  }

}