import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:posmobil/src/models/boleta.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/models/response_api.dart';
import 'package:posmobil/src/models/usuario.dart';
import 'package:posmobil/src/pages/bluetooth/bluetooth_printer.dart';
import 'package:posmobil/src/providers/boletas_provider.dart';
import 'package:posmobil/src/providers/productos_provider.dart';

class MantenedoresLocalControlador extends GetxController {
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

  MantenedoresLocalControlador() {
    getProductos();
  }

  void onChangeText(String text) {
    pago.value = int.tryParse(text) ?? 0;
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
    if (product.cantidad! > 1) {
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
      productos: selectedProducts,
    );
    ResponseApi responseApi = await boletasProvider.create(boleta);
    Fluttertoast.showToast(msg: responseApi.message ?? '', toastLength: Toast.LENGTH_SHORT);
    if (responseApi.success == true) {
      boleta.id = responseApi.data;
      boleta.productos = [];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BluetoothPrinterPage(data: selectedProducts, boleta: boleta),
        ),
      );
    } else {
      Get.snackbar('Proceso fallido', responseApi.message ?? '');
    }
  }

  void addToBag(Producto? product) {
    if (product == null) {
      Fluttertoast.showToast(msg: 'Producto no encontrado');
      return;
    }
    int index = selectedProducts.indexWhere((p) => p.id == product.id);
    if (index == -1) {
      if (product.cantidad == null || product.cantidad == 0) {
        product.cantidad = 1;
      }
      selectedProducts.add(product);
      getTotal();
    } else {
      addItem(selectedProducts[index]);
    }
    //GetStorage().write('shopping_bag', selectedProducts);
  }

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
                _codigoBarra = code;
                codigoBarraController.text = code;
                var result = await productosProvider.getProduct(_codigoBarra);
                addToBag(result);
                Navigator.pop(context);
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> code() async {
    _codigoBarra = codigoBarraController.text.trim();
    var result = await productosProvider.getProduct(_codigoBarra);
    addToBag(result);
  }
}