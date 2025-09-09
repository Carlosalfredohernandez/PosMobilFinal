import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// Nuevo plugin moderno
import 'package:posmobil/src/models/boleta.dart';
import 'package:posmobil/src/models/inventario.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/models/usuario.dart';
import 'package:posmobil/src/providers/boletas_provider.dart';
import 'package:posmobil/src/providers/productos_provider.dart';
import 'package:posmobil/src/services/bluetooth_printer_service.dart';

class ClienteCajaCreateController extends GetxController {
  final productosProvider = ProductosProvider();
  final boletasProvider = BoletasProvider();
  final printerService = Get.find<BluetoothPrinterService>();

  final sesionUsuario = Usuario.fromJson(GetStorage().read('usuario') ?? {});
  final codigoBarraController = TextEditingController();
  final cashController = TextEditingController();

  final productos = <Producto>[].obs;
  final selectedProducts = <Producto>[].obs;
  final total = 0.obs;
  final pago = 0.obs;
  String formaPago = '';
  String _codigoBarra = '';

  ClienteCajaCreateController() {
    getProductos();
  }

  void onChangeText(String text) {
    pago.value = int.tryParse(text) ?? 0;
  }

  void getProductos() async {
    final result = await productosProvider.getAllByUser();
    productos.assignAll(result);
  }

  void getTotal() {
    total.value = selectedProducts.fold(0, (sum, p) {
      final precio = int.tryParse('${p.precioVenta}') ?? 0;
      final cantidad = p.cantidad ?? 0;
      return sum + (precio * cantidad);
    });
  }

  void addToBag(Producto product) {
    final index = selectedProducts.indexWhere((p) => p.id == product.id);
    if (index == -1) {
      product.cantidad = 1;
      selectedProducts.add(product);
    } else {
      selectedProducts[index].cantidad = selectedProducts[index].cantidad! + 1;
    }
    getTotal();
  }

  void addItem(Producto product) {
    final index = selectedProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      selectedProducts[index].cantidad = selectedProducts[index].cantidad! + 1;
      getTotal();
    }
  }

  void removeItem(Producto product) {
    final index = selectedProducts.indexWhere((p) => p.id == product.id);
    if (index != -1 && selectedProducts[index].cantidad! > 1) {
      selectedProducts[index].cantidad = selectedProducts[index].cantidad! - 1;
      getTotal();
    }
  }

  void deleteItem(Producto product) {
    selectedProducts.removeWhere((p) => p.id == product.id);
    product.cantidad = 0;
    getTotal();
  }

  // Nuevo método para escanear con mobile_scanner
  void scanBarcodeMobileScanner(String barcode) async {
    if (barcode.isNotEmpty) {
      _codigoBarra = barcode;
      final result = await productosProvider.getProduct(_codigoBarra);
      addToBag(result);
    } else {
      Fluttertoast.showToast(msg: 'Error al escanear código');
    }
  }

  Future<void> code() async {
    _codigoBarra = codigoBarraController.text.trim();
    final result = await productosProvider.getProduct(_codigoBarra);
    addToBag(result);
  }

  Future<void> createBill(BuildContext context) async {
    if (selectedProducts.isEmpty) {
      Get.snackbar('Sin productos', 'Agrega al menos un producto antes de continuar');
      return;
    }

    final inventario = Inventario(
      productos: selectedProducts,
      fecha: '${DateTime.now()}',
      local: int.parse(sesionUsuario.localOficina ?? '0'),
      idCliente: sesionUsuario.roles![0].id == '2' ? sesionUsuario.id : '0',
      idUsuarioE: sesionUsuario.roles![0].id == '3' ? sesionUsuario.id : '0',
    );

    final boleta = Boleta(
      numero: '1234',
      usuario: sesionUsuario.id,
      localUsuario: sesionUsuario.localOficina ?? '0',
      valor: '${total.value}',
      formaPago: formaPago,
      productos: selectedProducts,
      inventario: inventario,
    );

    final responseApi = await boletasProvider.create(boleta);
    Fluttertoast.showToast(msg: responseApi.message ?? '', toastLength: Toast.LENGTH_SHORT);

    if (responseApi.success == true) {
      boleta.id = responseApi.data;
      await printerService.printBoleta(boleta);
    } else {
      Get.snackbar('Proceso fallido', responseApi.message ?? '');
    }
  }
}