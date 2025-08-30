import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/models/response_api.dart';
import 'package:posmobil/src/pages/mantenedores/productos/mantenedores_productos_controller.dart';
import 'package:posmobil/src/providers/productos_provider.dart';

class ClienteProductosEditarController extends GetxController{

  Producto? product;
  String _codigoBarra = 'Desconocido';
  var nombreProductoController = TextEditingController();
  var descripcionProductoController = TextEditingController();
  var codigoBarraController = TextEditingController();
  var precioVentaController = TextEditingController();
  ProductosProvider productosProvider = ProductosProvider();
  var productId = '';
  //List<Producto> productos = <Producto>[];
  MantenedoresProductosController menu = Get.find();


  ClienteProductosEditarController(Producto producto) {
    product = producto;
    nombreProductoController.text = product?.nombreProducto ?? '';
    descripcionProductoController.text = product?.descripcionProducto ?? '';
    codigoBarraController.text = product?.codigoBarra ?? '';
    precioVentaController.text = product?.precioVenta ?? '';
    productId = product?.id ?? '';
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
    codigoBarraController.text = _codigoBarra;
  }

  void actualizarProducto(BuildContext context) async {
    String nombre = nombreProductoController.text.trim();
    String descripcion = descripcionProductoController.text.trim();
    String codigo = codigoBarraController.text.trim();
    String precioV = precioVentaController.text.trim();

    if (isValidForm(nombre,descripcion,codigo,precioV)) {

      Producto producto = Producto(
          nombreProducto: nombre,
          id: productId,
          descripcionProducto: descripcion,
          codigoBarra: codigo,
          precioVenta: precioV,
      );
      ResponseApi responseApi = await productosProvider.update(producto);
      if (responseApi.success == true){
        var result = await productosProvider.getAllByUser();
        menu.productos.clear();
        menu.productos.addAll(result);
        Get.snackbar('Proceso terminado', responseApi.message ?? '');
      }
      else{
        Get.snackbar('Proceso fallido', responseApi.message ?? '');
      }
    }
  }

  void deshabilitar(var productId) async{
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
      String precioV
      ) {
    if (nombre.isEmpty == true){
      Get.snackbar('Proceso Denegado', '');
      return false;
    }
    if (descripcion.isEmpty == true){
      Get.snackbar('Proceso Denegado', '');
      return false;
    }
    if (codigo.isEmpty == true){
      Get.snackbar('Proceso Denegado', '');
      return false;
    }
    if (precioV.isEmpty == true){
      Get.snackbar('Proceso Denegado', '');
      return false;
    }
    return true;
  }


}