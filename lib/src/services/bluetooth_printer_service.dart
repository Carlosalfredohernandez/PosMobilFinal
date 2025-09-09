import 'dart:io';
import 'package:blue_print_pos/receipt/receipt_text_style_type.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/sockets/src/sockets_html.dart';
import 'package:get_storage/get_storage.dart';
import 'package:blue_print_pos/blue_print_pos.dart';
import 'package:blue_print_pos/receipt/receipt_section_text.dart'; // Importa la clase del plugin
import 'package:posmobil/src/models/boleta.dart';

class BluetoothPrinterService extends GetxService {
  final _storage = GetStorage();
  final _macKey = 'printer_mac';
  final BluePrintPos _printer = BluePrintPos.instance;

  final savedMac = ''.obs;

  BluetoothPrinterService() {
    savedMac.value = _storage.read(_macKey) ?? '';
  }

  void saveMacAddress(String mac) {
    _storage.write(_macKey, mac);
    savedMac.value = mac;
    Fluttertoast.showToast(msg: 'Impresora guardada');
  }

  bool get isSimulatedEnvironment {
    return Platform.isAndroid && Platform.environment.containsKey('ANDROID_EMULATOR_BUILD');
  }

  Future<List<dynamic>> getAvailableDevices() async {
    if (isSimulatedEnvironment) {
      return [
        {
          'name': 'Simulador BT',
          'address': '00:00:00:00:00:00',
          'type': 'android',
        }
      ];
    }
    try {
      final devices = await _printer.scan();
      return devices;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error al buscar dispositivos: $e');
      return [];
    }
  }

  Future<void> printBoleta(Boleta boleta) async {
    final macAddress = savedMac.value;
    if (macAddress.isEmpty) {
      Get.snackbar('Impresora no configurada', 'Selecciona una impresora primero');
      return;
    }

    if (isSimulatedEnvironment) {
      print('🧪 Simulación de impresión:\n${boleta.toJson()}');
      Fluttertoast.showToast(msg: 'Modo emulador: impresión simulada');
      return;
    }

    final dispositivos = await getAvailableDevices();
    dynamic dispositivo;
    try {
      dispositivo = dispositivos.firstWhere((d) {
        if (d is Map) return d['address'] == macAddress;
        if (d != null && d.address != null) return d.address == macAddress;
        return false;
      });
    } catch (_) {
      dispositivo = null;
    }

    String address = '';
    if (dispositivo is Map) {
      address = dispositivo['address'] ?? '';
    } else if (dispositivo != null && dispositivo.address != null) {
      address = dispositivo.address;
    }

    if (address.isEmpty) {
      Get.snackbar('Dispositivo no encontrado', 'No se pudo encontrar la impresora guardada');
      return;
    }

    final productosTexto = (boleta.productos ?? [])
        .map((p) => '${p.nombreProducto ?? 'Sin nombre'} x${p.cantidad ?? 0} - \$${p.precioVenta ?? '0'}')
        .join('\n');

  final receipt = ReceiptSectionText();
receipt.addText('Boleta Nº: ${boleta.numero}', style: ReceiptTextStyleType.bold);
receipt.addText('Usuario: ${boleta.usuario}');
receipt.addText('Local: ${boleta.localUsuario}');
receipt.addText('Forma de pago: ${boleta.formaPago}');
receipt.addText('Total: \$${boleta.valor}', style: ReceiptTextStyleType.bold);
receipt.addSpacer();
receipt.addText('Productos:');
receipt.addText(productosTexto);
receipt.addSpacer();
receipt.addText('Gracias por su compra!');
    try {
      final result = await _printer.connect(dispositivo);
      if (result != ConnectionStatus.connected) {
        Get.snackbar('Error de conexión', 'No se pudo conectar con la impresora');
        return;
      }

      // Imprime cada sección del recibo por separado
      await _printer.printReceiptText(receipt);
     await _printer.disconnect();
     Fluttertoast.showToast(msg: 'Boleta enviada a la impresora');
    } catch (e) {
      Get.snackbar('Error de impresión', e.toString());
    }
  }
}