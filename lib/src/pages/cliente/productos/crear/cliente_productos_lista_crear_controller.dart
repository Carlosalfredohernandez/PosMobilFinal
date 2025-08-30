
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/models/categoria.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/models/response_api.dart';
import 'package:posmobil/src/models/usuario.dart';
import 'package:posmobil/src/providers/categorias_provider.dart';
import 'package:posmobil/src/providers/productos_provider.dart';





class ClienteProductosListaCrearController extends GetxController {

  @override
  String _codigoBarra = 'Desconocido';
  Usuario sesionUsuario = Usuario.fromJson(GetStorage().read('usuario'));
  TextEditingController nombreProductoController = TextEditingController();
  TextEditingController descripcionProductoController = TextEditingController();
  TextEditingController codigoBarraController = TextEditingController();
  TextEditingController precioVentaController = TextEditingController();
  CategoriasProvider categoriasProvider = CategoriasProvider();




  var nombreCategoria = ''.obs;
  List<Categoria> categorias = <Categoria>[].obs;
  ProductosProvider productosProvider = ProductosProvider();

  ClienteProductosListaCrearController() {
    getCategorias();
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancelar', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Fallo!';
    }

    _codigoBarra = barcodeScanRes;
    codigoBarraController.text = _codigoBarra;
  }

  void getCategorias() async {
    var result = await categoriasProvider.getAllByUser();
    categorias.clear();
    categorias.addAll(result);
  }

  void createProduct(BuildContext context) async {

    String usuario = sesionUsuario.id.toString();
    String nombreProducto = nombreProductoController.text.trim();
    String descripcionProducto = descripcionProductoController.text.trim();
    String codigoBarra = codigoBarraController.text.trim();
    String precioCosto = "0";
    String precioVenta = precioVentaController.text.trim();
    String proveedor = "Sin Espesificar";

    // print('NAME: ${nombreProducto}');
    // print('PRICE: ${precioVenta}');
    // print('CATEGORY: ${nombreCategoria}');
    // print('CODE: ${_codigoBarra}');
    // ProgressDialog progressDialog = ProgressDialog(context: context);

    if (isValidForm()) {
      Producto producto = Producto(
        usuario: usuario,
        nombreProducto: nombreProducto,
        descripcionProducto: descripcionProducto,
        codigoBarra: codigoBarra,
        precioCosto: precioCosto,
        precioVenta: precioVenta,
        proveedor: proveedor,
        categoria: nombreCategoria.value
      );
      ResponseApi responseApi = await productosProvider.create(producto);
      getCategorias();
      Get.snackbar('Proceso terminado', responseApi.message ?? '');
      Get.offNamedUntil('/inicio/cliente', (route) => false);
    }
    getCategorias();
  }

  void regresar(){
    Get.offNamedUntil('/mantenedores/productos', (route) => false);
  }

  bool isValidForm() {
    return true;
  }

  void clearForm() {
    nombreProductoController.text = '';
    descripcionProductoController.text = '';
    precioVentaController.text = '';
    nombreCategoria.value = '';
    update();
  }

}