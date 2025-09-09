import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:posmobil/src/pages/cliente/caja/create/cliente_caja_create_controller.dart';
import 'package:posmobil/src/widgets/printer_status_indicator.dart';
import 'package:posmobil/src/pages/bluetooth/bluetooth_selector_page.dart';
import 'package:posmobil/src/widgets/simulador_mode_banner.dart';

class ClienteCajaCreatePage extends StatelessWidget {
  final controller = Get.put(ClienteCajaCreateController());

  ClienteCajaCreatePage({super.key});

  void _showScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: 400,
        child: MobileScanner(
          onDetect: (capture) {
            final barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final code = barcodes.first.rawValue ?? '';
              if (code.isNotEmpty) {
                controller.scanBarcodeMobileScanner(code);
                Navigator.pop(context); // Cierra el scanner
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caja'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth_searching),
            tooltip: 'Cambiar impresora',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BluetoothSelectorPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PrinterStatusIndicator(),
            SimulatorModeBanner(),
            const SizedBox(height: 16),
            // Escaneo y entrada manual
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.codigoBarraController,
                    decoration: const InputDecoration(
                      labelText: 'Código de barra manual',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: controller.code,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showScanner(context),
                  icon: const Icon(Icons.camera_alt),
                  tooltip: 'Escanear código',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Lista de productos seleccionados
            Expanded(
              child: Obx(() {
                if (controller.selectedProducts.isEmpty) {
                  return const Center(child: Text('No hay productos seleccionados'));
                }
                return ListView.builder(
                  itemCount: controller.selectedProducts.length,
                  itemBuilder: (_, index) {
                    final product = controller.selectedProducts[index];
                    return ListTile(
                      title: Text(product.nombreProducto ?? 'Sin nombre'),
                      subtitle: Text('Cantidad: ${product.cantidad ?? 0} - Precio: \$${product.precioVenta ?? '0'}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => controller.removeItem(product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => controller.addItem(product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => controller.deleteItem(product),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 8),
            // Totales y forma de pago
            Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total: \$${controller.total.value}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.cashController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Pago en efectivo',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: controller.onChangeText,
                ),
              ],
            )),
            const SizedBox(height: 16),
            // Botón para crear boleta e imprimir
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => controller.createBill(context),
                icon: const Icon(Icons.print),
                label: const Text('Generar boleta e imprimir'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}