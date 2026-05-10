import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/pages/cliente/caja/create/cliente_caja_create_controller.dart';
import 'package:posmobilfinal/src/models/producto.dart';
import 'package:posmobilfinal/src/providers/productos_provider.dart' as prov;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ClienteCajaSearchController extends GetxController {
  prov.ProductosProvider productosProvider = prov.ProductosProvider();
  ClienteCajaCreateController caja = Get.find();

  /// Abre una pantalla de escaneo y retorna el código escaneado
  Future<String?> scanBarcodeNormal(BuildContext context) async {
    String? barcodeScanRes;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Escanear código')),
          body: MobileScanner(
  onDetect: (capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      barcodeScanRes = barcodes.first.rawValue;
      Navigator.of(context).pop(); // Cierra el escáner
    }
  },
),
        ),
      ),
    );
    return barcodeScanRes;
  }

  void addToBag(Producto product) {
    caja.addItem(product);
    Fluttertoast.showToast(msg: 'Producto agregado');
  }
}