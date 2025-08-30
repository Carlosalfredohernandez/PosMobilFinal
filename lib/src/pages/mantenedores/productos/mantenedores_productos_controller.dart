import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/models/categoria.dart';
//import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/pages/cliente/productos/editar/cliente_productos_editar_page.dart';
import 'package:posmobil/src/providers/categorias_provider.dart';
import 'package:posmobil/src/providers/productos_provider.dart';

class MantenedoresProductosController extends GetxController{

  ProductosProvider productosProvider = ProductosProvider();
  TextEditingController searchText = TextEditingController();
  // String _codigoBarra = 'Desconocido';
  List<Categoria> categorias = <Categoria>[].obs;
  CategoriasProvider categoriasProvider = CategoriasProvider();
  List<Producto> productos = <Producto>[];
  List<Producto> filter = <Producto>[].obs;
  //Timer? searchOnStoppedTyping;
  // var productName = ''.obs;
  // var idCategory = '';
  MantenedoresProductosController(){
    getProductos();
    getCategorias();
  }
  void getCategorias() async {
    var result = await categoriasProvider.getAllByUser();
    categorias.clear();
    categorias.addAll(result);
  }

  void getProductos() async {
    var result = await productosProvider.getAllByUser();
    productos.clear();
    productos.addAll(result);
    filter.clear();
    filter.addAll(result);
    //GetStorage().write('editing_bag',productos);
  }
  void updateProductos(var idCategory) async{
    filter = productos.where((element) {
      return element.categoria!.toLowerCase().contains(idCategory.trim());
    }).toList();
  }
  // void updateSearch(String text) async {
  //   var result = await productosProvider.findProductsOnText(text);
  //   productos.clear();
  //   productos.addAll(result);
  // }

  Future<void> scanBarcodeNormal(BuildContext context) async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancelar', true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Fallo!';
    }
    barcodeScanRes != '-1'  ? goTo(context,barcodeScanRes) : barcodeScanRes = '';
  }
  void onChangeText(String text){
    filter = productos.where((element) {
      return element.nombreProducto!.toLowerCase().contains(text.trim().toLowerCase())
          || element.codigoBarra!.toLowerCase().contains(text.trim().toLowerCase());
    }).toList();
  }

  void goTo(BuildContext context,String text){
    final producto = productos.where((element){
      return element.codigoBarra == text;
    }).toList();

    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ClienteProductosEditarPage(producto: producto[0]))
    );
  }

  // Future<void> actualizar(String productName, var category) async {
  //   if (productName.isEmpty) {
  //     var result = await productosProvider.getAllByUser();
  //     productos.clear();
  //     productos.addAll(result);
  //   }
  //   else if (idCategory != ''){
  //     var result = await productosProvider.findProductsOnTextWithCategory(productName.toString(),idCategory);
  //     productos.clear();
  //     productos.addAll(result);
  //   }
  //   else{
  //     var result = await productosProvider.findProductsOnText(productName.toString());
  //     productos.clear();
  //     productos.addAll(result);
  //   }
  // }


  void volver(){
    Get.offNamed('/mantenedores/menu');
  }
  void goToProduct() {
    Get.offNamedUntil('/inicio/cliente/agregar/producto', (route) => false);
  }

}