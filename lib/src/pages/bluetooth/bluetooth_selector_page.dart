import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/services/bluetooth_printer_service.dart';

class BluetoothSelectorPage extends StatefulWidget {
  const BluetoothSelectorPage({Key? key}) : super(key: key);

  @override
  State<BluetoothSelectorPage> createState() => _BluetoothSelectorPageState();
}

class _BluetoothSelectorPageState extends State<BluetoothSelectorPage> {
  final printerService = Get.find<BluetoothPrinterService>();
  List devices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final result = await printerService.getAvailableDevices();
    setState(() {
      devices = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar impresora')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : devices.isEmpty
              ? const Center(child: Text('No se encontraron impresoras'))
              : ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (_, index) {
                    final device = devices[index];
                    final name = device['name'] ?? 'Sin nombre';
                    final mac = device['macAddress'] ?? '';

                    return ListTile(
                      title: Text(name),
                      subtitle: Text(mac),
                      trailing: const Icon(Icons.bluetooth),
                      onTap: () {
                        printerService.saveMacAddress(mac);
                        Get.snackbar('Impresora seleccionada', '$name ($mac)');
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
    );
  }
}