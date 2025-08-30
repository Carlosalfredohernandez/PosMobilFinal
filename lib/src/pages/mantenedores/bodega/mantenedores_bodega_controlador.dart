import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/models/boleta.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/models/response_api.dart';
import 'package:posmobil/src/models/usuario.dart';
import 'package:posmobil/src/pages/Bluetooth/bluetooth_printer.dart';
import 'package:posmobil/src/providers/boletas_provider.dart';
import 'package:posmobil/src/providers/productos_provider.dart';

class MantenedoresBodegaControlador extends GetxController{
  List<Producto> productos = <Producto>[];
  ProductosProvider productosProvider = ProductosProvider();
  List<Producto> selectedProducts = <Producto>[].obs;
  var total = 0.obs;
  var pago = 0.obs;
  var formaPago = '';
  String _codigoBarra = '';
  TextEditingController codigoBarraController = TextEditingController();
  TextEditingController cashController = TextEditingController();
  Usuario sesionUsuario = Usuario.fromJson(GetStorage().read('usuario') ?? {});
  BoletasProvider boletasProvider = BoletasProvider();

  ClienteCajaCreateController(){
    getProductos();
  }

  void onChangeText(String text){
    pago.value = int.parse(text);
  }

  void getTotal() {
    total.value = 0;
    for (var product in selectedProducts) {
      total.value = total.value + (product.cantidad! * int.parse('${product.precioVenta}'));
    }
  }

  void deleteItem(Producto product) {
    selectedProducts.remove(product);
    getTotal();
    product.cantidad = 0;
  }

  void addItem(Producto product) {
    int index = selectedProducts.indexWhere((p) => p.id == product.id);
    selectedProducts.remove(product);
    product.cantidad = product.cantidad! + 1;
    selectedProducts.insert(index, product);
    getTotal();
  }

  void removeItem(Producto product) {
    if (product.cantidad! > 1){
      int index = selectedProducts.indexWhere((p) => p.id == product.id);
      selectedProducts.remove(product);
      product.cantidad = product.cantidad! - 1;
      selectedProducts.insert(index, product);
      getTotal();
    }
  }
  void getProductos() async {
    var result = await productosProvider.getAllByUser();
    productos.clear();
    productos.addAll(result);
  }
  void createBill(BuildContext context) async {
    Boleta boleta = Boleta(
        numero: '1234', //tester
        usuario: sesionUsuario.id,
        localUsuario: sesionUsuario.localOficina ?? 'Santiago',
        valor: '${total.value}',
        formaPago: formaPago,
        productos: selectedProducts
    );
    ResponseApi responseApi = await boletasProvider.create(boleta);
    Fluttertoast.showToast(msg: responseApi.message ?? '', toastLength: Toast.LENGTH_SHORT);
    if (responseApi.success == true){
      boleta.id = responseApi.data;
      boleta.productos = [];
      Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Print(data: selectedProducts, boleta: boleta)) //BluetoothPage(data: selectedProducts, boleta: boleta))
      );
    }
    else{
      Get.snackbar('Proceso fallido', responseApi.message ?? '');
    }
  }

  void addToBag(Producto product){
    int index = selectedProducts.indexWhere((p) => p.id == product.id);
    if (index == -1) {
      if (product.cantidad == null || product.cantidad == 0){
        product.cantidad = 1;
      }
      selectedProducts.add(product);
      getTotal();
    }
    else {
      addItem(selectedProducts[index]);
    }
    //GetStorage().write('shopping_bag', selectedProducts);
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancelar', true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Fallo!';
    }
    _codigoBarra = barcodeScanRes;
    if (_codigoBarra != '-1'){
      var result = await productosProvider.getProduct(_codigoBarra);
      addToBag(result);
    }
  }

  Future<void> code() async {
    _codigoBarra = codigoBarraController.text.trim();
    var result = await productosProvider.getProduct(_codigoBarra);
    addToBag(result);
  }
}