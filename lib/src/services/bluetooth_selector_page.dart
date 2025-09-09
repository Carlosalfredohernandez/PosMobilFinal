import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/services/bluetooth_printer_service.dart';

class BluetoothSelectorPage extends StatelessWidget {
  final printerService = Get.find<BluetoothPrinterService>();

  BluetoothSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar impresora')),
      body: FutureBuilder<List<dynamic>>(
        future: printerService.getAvailableDevices(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final devices = snapshot.data ?? [];
          if (devices.isEmpty) {
            return const Center(child: Text('No se encontraron impresoras'));
          }

          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (_, index) {
              final device = devices[index];
              // Compatibilidad con Map y objeto
              final name = device is Map
                  ? (device['name'] ?? 'Sin nombre')
                  : (device.name ?? 'Sin nombre');
              final mac = device is Map
                  ? (device['address'] ?? device['macAddress'] ?? 'MAC desconocida')
                  : (device.address ?? device.macAddress ?? 'MAC desconocida');

              return ListTile(
                title: Text(name),
                subtitle: Text(mac),
                trailing: const Icon(Icons.bluetooth),
                onTap: () {
                  printerService.saveMacAddress(mac);
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
    );
  }
}