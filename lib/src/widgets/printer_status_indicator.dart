import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/services/bluetooth_printer_service.dart';
import 'package:posmobil/src/pages/bluetooth/bluetooth_selector_page.dart'; // Corrige el import

class PrinterStatusIndicator extends StatelessWidget {
  final printerService = Get.find<BluetoothPrinterService>();

  @override
  Widget build(BuildContext context) {
    // Usar Obx para que el widget se actualice si cambia el estado de la impresora
    return Obx(() {
      final mac = printerService.savedMac.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: mac != null && mac.isNotEmpty ? Colors.green[50] : Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: mac != null && mac.isNotEmpty ? Colors.green : Colors.red),
        ),
        child: Row(
          children: [
            Icon(
              mac != null && mac.isNotEmpty ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
              color: mac != null && mac.isNotEmpty ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                mac != null && mac.isNotEmpty
                    ? 'Impresora conectada: $mac'
                    : 'Sin impresora configurada',
                style: TextStyle(
                  color: mac != null && mac.isNotEmpty ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BluetoothSelectorPage()),
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text('Cambiar'),
            ),
          ],
        ),
      );
    });
  }
}