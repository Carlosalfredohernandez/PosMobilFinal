import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/models/response_api.dart';
import 'package:posmobil/src/pages/mantenedores/productos/mantenedores_productos_controller.dart';
import 'package:posmobil/src/providers/productos_provider.dart';

class ClienteProductosEditarController extends GetxController {
  Producto? product;
  var nombreProductoController = TextEditingController();
  var descripcionProductoController = TextEditingController();
  var codigoBarraController = TextEditingController();
  var precioVentaController = TextEditingController();
  ProductosProvider productosProvider = ProductosProvider();
  var productId = '';
  MantenedoresProductosController menu = Get.find();

  ClienteProductosEditarController(Producto producto) {
    product = producto;
    nombreProductoController.text = product?.nombreProducto ?? '';
    descripcionProductoController.text = product?.descripcionProducto ?? '';
    codigoBarraController.text = product?.codigoBarra ?? '';
    precioVentaController.text = product?.precioVenta ?? '';
    productId = product?.id ?? '';
  }

  // Refactor: Usar MobileScanner para escanear código de barras
  Future<void> scanBarcode(BuildContext context) async {
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
              codigoBarraController.text = code;
              Navigator.pop(context);
            }
          }
        },
      ),
    ),
  );
}

  void actualizarProducto(BuildContext context) async {
    String nombre = nombreProductoController.text.trim();
    String descripcion = descripcionProductoController.text.trim();
    String codigo = codigoBarraController.text.trim();
    String precioV = precioVentaController.text.trim();

    if (isValidForm(nombre, descripcion, codigo, precioV)) {
      Producto producto = Producto(
        nombreProducto: nombre,
        id: productId,
        descripcionProducto: descripcion,
        codigoBarra: codigo,
        precioVenta: precioV,
      );
      ResponseApi responseApi = await productosProvider.update(producto);
      if (responseApi.success == true) {
        var result = await productosProvider.getAllByUser();
        menu.productos.clear();
        menu.productos.addAll(result);
        Get.snackbar('Proceso terminado', responseApi.message ?? '');
      } else {
        Get.snackbar('Proceso fallido', responseApi.message ?? '');
      }
    }
  }

  void deshabilitar(var productId) async {
    ResponseApi responseApi = await productosProvider.deshabilitar(productId);
    var result = await productosProvider.getAllByUser();
    menu.productos.clear();
    menu.productos.addAll(result);
    Get.snackbar('Proceso terminado', responseApi.message ?? '');
  }

  bool isValidForm(
    String nombre,
    String descripcion,
    String codigo,
    String precioV,
  ) {
    if (nombre.isEmpty) {
      Get.snackbar('Proceso Denegado', 'El nombre no puede estar vacío');
      return false;
    }
    if (descripcion.isEmpty) {
      Get.snackbar('Proceso Denegado', 'La descripción no puede estar vacía');
      return false;
    }
    if (codigo.isEmpty) {
      Get.snackbar('Proceso Denegado', 'El código de barra no puede estar vacío');
      return false;
    }
    if (precioV.isEmpty) {
      Get.snackbar('Proceso Denegado', 'El precio de venta no puede estar vacío');
      return false;
    }
    return true;
  }
  void scanBarcodeNormal(BuildContext context) async {
  await scanBarcode(context);
}
}