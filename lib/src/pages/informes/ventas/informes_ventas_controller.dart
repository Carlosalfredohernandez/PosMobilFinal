import 'package:get/get.dart';
import 'package:posmobil/src/models/boleta.dart';
import 'package:posmobil/src/providers/boletas_provider.dart';

class InformesVentasController extends GetxController{
  BoletasProvider boletasProvider = BoletasProvider();
  List<Boleta> boletas = <Boleta>[].obs;
  DateTime currentSelectedDate = DateTime.now();
  DateTime fechaInicial = DateTime.now();
  DateTime fechaFinal = DateTime.now();
  var total = 0.obs;
  var cant = 0.obs;

  InformesVentasController(){
    getBoletas();
  }


  void updateBoletas(var fechaInicial, var fechaFinal ) async {
    var result = await boletasProvider.getTrimedDateArray(fechaInicial, fechaFinal);
    boletas.clear();
    boletas.addAll(result);
    getTotal();
  }

  void getBoletas() async {
    var result = await boletasProvider.getAllByUser();
    boletas.clear();
    boletas.addAll(result);
    getTotal();
  }

  void regresar(){
    Get.offNamedUntil('/inicio/cliente', (route) => false);
  }

  void getTotal() {
    total.value = 0;
    cant.value = 0;
    for (var boleta in boletas) {
      total.value = total.value + int.parse('${boleta.valor}');
      cant.value += 1;
    }
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