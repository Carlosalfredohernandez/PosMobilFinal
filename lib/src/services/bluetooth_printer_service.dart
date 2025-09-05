import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:blue_print_pos/blue_print_pos.dart';
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

  Future<List<BluePrintPosDevice>> getAvailableDevices() async {
    if (isSimulatedEnvironment) {
      return [
        BluePrintPosDevice(name: 'Simulador BT', address: '00:00:00:00:00:00', type: 'android'),
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
    final dispositivo = dispositivos.firstWhere(
      (d) => d.address == macAddress,
      orElse: () => BluePrintPosDevice(name: '', address: '', type: 'unknown'),
    );

    if (dispositivo.address.isEmpty) {
      Get.snackbar('Dispositivo no encontrado', 'No se pudo encontrar la impresora guardada');
      return;
    }

    final productosTexto = (boleta.productos ?? [])
        .map((p) => '${p.nombreProducto ?? 'Sin nombre'} x${p.cantidad ?? 0} - \$${p.precioVenta ?? '0'}')
        .join('\n');

    final content = '''
Boleta Nº: ${boleta.numero}
Usuario: ${boleta.usuario}
Local: ${boleta.localUsuario}
Forma de pago: ${boleta.formaPago}
Total: \$${boleta.valor}
-------------------------
Productos:
$productosTexto
-------------------------
Gracias por su compra!
''';

    try {
      final result = await _printer.connect(dispositivo);
      if (result != true) {
        Get.snackbar('Error de conexión', 'No se pudo conectar con la impresora');
        return;
      }

      await _printer.printText(content, isBold: true, isCentered: false, fontSize: 1);
      await _printer.disconnect();
      Fluttertoast.showToast(msg: 'Boleta enviada a la impresora');
    } catch (e) {
      Get.snackbar('Error de impresión', e.toString());
    }
  }