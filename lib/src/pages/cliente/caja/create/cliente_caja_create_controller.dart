import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/models/boleta.dart';
import 'package:posmobil/src/models/inventario.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/models/usuario.dart';
import 'package:posmobil/src/providers/boletas_provider.dart';
import 'package:posmobil/src/providers/productos_provider.dart';

class ClienteCajaCreateController extends GetxController {
  final productosProvider = ProductosProvider();
  final boletasProvider = BoletasProvider();

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
    selectedProducts.refresh();
  }

  void addItem(Producto product) {
    final index = selectedProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      selectedProducts[index].cantidad = selectedProducts[index].cantidad! + 1;
      selectedProducts.refresh();
      getTotal();
    }
  }

  void removeItem(Producto product) {
    final index = selectedProducts.indexWhere((p) => p.id == product.id);
    if (index != -1 && selectedProducts[index].cantidad! > 1) {
      selectedProducts[index].cantidad = selectedProducts[index].cantidad! - 1;
      selectedProducts.refresh();
      getTotal();
    }
  }

  void deleteItem(Producto product) {
    selectedProducts.removeWhere((p) => p.id == product.id);
    selectedProducts.refresh();
    product.cantidad = 0;
    getTotal();
  }

  // Método para procesar el código escaneado con mobile_scanner
  // ...existing code...

 Future<void> scanBarcodeMobileScanner(String barcode) async {
  if (barcode.isNotEmpty) {
    _codigoBarra = barcode;
    final result = await productosProvider.getProduct(_codigoBarra);
    if (result != null) {
      final index = selectedProducts.indexWhere((p) => p.id == result.id);
      if (index == -1) {
        // Agrega el producto con cantidad 1
        final nuevoProducto = Producto.fromJson(result.toJson());
        nuevoProducto.cantidad = 0;
        selectedProducts.add(nuevoProducto);
        // Parche: si por doble callback la cantidad es mayor a 1, la fuerza a 1
        final idx = selectedProducts.indexWhere((p) => p.id == nuevoProducto.id);
        if (idx != -1 && selectedProducts[idx].cantidad! > 1) {
          selectedProducts[idx].cantidad = 1;
        }
      } else {
        // Si ya está, suma solo 1 a la cantidad
        selectedProducts[index].cantidad = (selectedProducts[index].cantidad ?? 1) + 0;
        // Parche: si por doble callback la cantidad subió más de 1, solo suma 1
        if (selectedProducts[index].cantidad! > ((selectedProducts[index].cantidad ?? 2) - 1)) {
          selectedProducts[index].cantidad = (selectedProducts[index].cantidad ?? 2) - 1 + 1;
        }
      }
      getTotal();
      selectedProducts.refresh();
    } else {
      Fluttertoast.showToast(msg: 'Producto no encontrado');
    }
    update();
  } else {
    Fluttertoast.showToast(msg: 'Error al escanear código');
  }
}

// ...existing code...

  // Método para procesar el código ingresado manualmente o por escaneo
  Future<void> code() async {
    _codigoBarra = codigoBarraController.text.trim();
    final result = await productosProvider.getProduct(_codigoBarra);
    if (result != null) {
      addToBag(result);
    } else {
      Fluttertoast.showToast(msg: 'Producto no encontrado');
    }
    update();
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
  }
}