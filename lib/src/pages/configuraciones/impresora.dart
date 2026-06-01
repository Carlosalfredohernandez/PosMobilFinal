import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class ImpresorasPage extends StatefulWidget {
  const ImpresorasPage({super.key});

  @override
  State<ImpresorasPage> createState() => _ImpresorasPageState();
}

class _ImpresorasPageState extends State<ImpresorasPage> {
  List<BluetoothDevice> _devices = [];
  String _devicesMsg = 'Buscando impresoras...';
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  final GetStorage _storage = GetStorage();
  late int _printableWidth;

  @override
  void initState() {
    super.initState();
    final dynamic savedWidth = _storage.read('printable_width');
    _printableWidth = savedWidth is int ? savedWidth : 376;
    _startScan();
  }

  void _savePrintableWidth(int value) {
    final int clamped = value.clamp(320, 384);
    setState(() {
      _printableWidth = clamped;
    });
    _storage.write('printable_width', clamped);
    Get.snackbar(
      'Impresora',
      'Ancho imprimible guardado: $clamped px',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _startScan() async {
    setState(() {
      _devicesMsg = 'Buscando impresoras...';
      _devices.clear();
    });

    List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
    setState(() {
      _devices = devices;
      _devicesMsg = _devices.isEmpty ? 'No se han encontrado impresoras' : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seleccionar impresora')),
      body: _devices.isEmpty
          ? Center(child: Text(_devicesMsg))
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.straighten),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text('Ancho imprimible: $_printableWidth px'),
                        ),
                        IconButton(
                          onPressed: () => _savePrintableWidth(_printableWidth - 4),
                          icon: const Icon(Icons.remove),
                        ),
                        IconButton(
                          onPressed: () => _savePrintableWidth(_printableWidth + 4),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (c, i) {
                      return ListTile(
                        leading: const Icon(Icons.print),
                        title: Text(_devices[i].name ?? ''),
                        subtitle: Text(_devices[i].address ?? ''),
                        onTap: () async {
                          savePrinter(_devices[i]);
                          // Intentar conectar a la impresora
                          try {
                            await bluetooth.connect(_devices[i]);
                            Get.snackbar('Impresora', 'Conectado a ${_devices[i].name}', snackPosition: SnackPosition.BOTTOM);
                          } catch (e) {
                            Get.snackbar('Error', 'No se pudo conectar: $e', snackPosition: SnackPosition.BOTTOM);
                          }
                          Navigator.pop(context, _devices[i]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startScan,
        tooltip: 'Buscar impresoras',
        child: Icon(Icons.refresh),
      ),
    );
  }

  void savePrinter(BluetoothDevice device) {
    GetStorage().write('impresora', {
      'name': device.name,
      'address': device.address,
    });
  }
}