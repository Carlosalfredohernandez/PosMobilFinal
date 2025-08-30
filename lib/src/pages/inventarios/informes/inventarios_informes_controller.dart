import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/providers/boletas_provider.dart';
import 'package:posmobil/src/providers/inventario_provider.dart';

class InventariosInformesController extends GetxController{
  BoletasProvider boletasProvider = BoletasProvider();
  InventarioProvider inventarioProvider = InventarioProvider();
  List<Producto> informe = <Producto>[].obs;
  List<Producto> filter = <Producto>[].obs;
  DateTime currentSelectedDate = DateTime.now();
  DateTime fechaInicial = DateTime.now();
  DateTime fechaFinal = DateTime.now();
  var total = 0.obs;
  var cant = 0.obs;

  InventariosInformesController(){
    getConsulta();
  }


  void updateBoletas(var fechaInicial, var fechaFinal ) async {
    var result = await inventarioProvider.getAllByDate(fechaInicial, fechaFinal);
    informe.clear();
    informe.addAll(result);
  }


  void getConsulta() async {
    var result = await inventarioProvider.consultaInventario();
    informe.clear();
    filter.clear();
    informe.addAll(result);
    filter.addAll(result);
  }

  void regresar(){
    Get.offNamedUntil('/inicio/cliente', (route) => false);
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancelar', true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Fallo!';
    }
    barcodeScanRes != '-1'  ? onChangeText(barcodeScanRes) : barcodeScanRes = '';
  }
  void onChangeText(String text){
    filter = informe.where((element) {
      return element.nombreProducto!.toLowerCase().contains(text.trim().toLowerCase())
          || element.codigoBarra!.toLowerCase().contains(text.trim().toLowerCase());
    }).toList();
  }
  String numberFormat(int x) {
    List<String> parts = x.toString().split('.');
    RegExp re = RegExp(r'\B(?=(\d{3})+(?!\d))');

    parts[0] = parts[0].replaceAll(re, '.');
    if (parts.length == 1) {
      // parts.add('00');
    } else {
      parts[1] = parts[1].padRight(2, '0').substring(0, 2);
    }
    return parts.join(',');
  }
}