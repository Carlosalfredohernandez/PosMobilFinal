import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:posmobilfinal/src/models/producto.dart';
import 'package:posmobilfinal/src/providers/boletas_provider.dart';
import 'package:posmobilfinal/src/providers/inventario_provider.dart';

class InventariosInformesController extends GetxController {
  BoletasProvider boletasProvider = BoletasProvider();
  InventarioProvider inventarioProvider = InventarioProvider();
  List<Producto> informe = <Producto>[].obs;
  List<Producto> filter = <Producto>[].obs;

  void onChangeDate() async {
    try {
      await updateBoletas(fechaInicial, fechaFinal);
      filter.clear();
      filter.addAll(informe);
      update();
    } catch (e, stack) {
      // Mostrar mensaje de error usando Get.snackbar
      Get.snackbar(
        'Error al actualizar',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      // Opcional: imprimir el stacktrace en consola para depuración
      print('Error en onChangeDate: ${e.toString()}\nStacktrace: $stack');
    }
  }
  DateTime fechaInicial = DateTime.now();
  DateTime fechaFinal = DateTime.now();
  var total = 0.obs;
  var cant = 0.obs;

  InventariosInformesController() {
    getConsulta();
  }

  Future<void> updateBoletas(var fechaInicial, var fechaFinal) async {
    // Asegurarse que los parámetros sean int (timestamp) para la API
    int fechaInicialInt = fechaInicial is DateTime ? fechaInicial.millisecondsSinceEpoch : int.tryParse(fechaInicial.toString()) ?? 0;
    int fechaFinalInt = fechaFinal is DateTime ? fechaFinal.millisecondsSinceEpoch : int.tryParse(fechaFinal.toString()) ?? 0;
    var result = await inventarioProvider.getAllByDate(fechaInicialInt, fechaFinalInt);
    informe.clear();
    informe.addAll(result);
  }

  void getConsulta() async {
    var result = await inventarioProvider.consultaInventario();
    if (result is List<Producto>) {
      informe.clear();
      filter.clear();
      informe.addAll(result);
      filter.addAll(result);
    } else {
      // Manejo de error: muestra un mensaje y evita que la app se quede pegada
      String mensaje = 'Error desconocido';
      // --- Bloque comentado temporalmente por error de análisis ---
      /*
      if (result is Map && result['message'] != null) {
        mensaje = result['message'].toString();
      }
      */
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text('No se pudo obtener el inventario: $mensaje'),
            backgroundColor: Colors.red,
          ),
        );
      }
      informe.clear();
      filter.clear();
      update();
    }
  }

  void regresar() {
    Get.offNamedUntil('/inicio/cliente', (route) => false);
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
                onChangeText(code);
                Navigator.pop(context);
              }
            }
          },
        ),
      ),
    );
  }

  void onChangeText(String text) {
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