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

  @override
  void initState() {
    super.initState();
    _startScan();
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
          : ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (c, i) {
                return ListTile(
                  leading: Icon(Icons.print),
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