import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:posmobil/src/pages/cliente/caja/create/cliente_caja_create_controller.dart';
import 'package:posmobil/src/pages/cliente/caja/search/cliente_caja_search_page.dart';
import 'package:posmobil/src/models/producto.dart';

class ClienteCajaCreatePage extends StatefulWidget {
  @override
  State<ClienteCajaCreatePage> createState() => _ClienteCajaCreatePageState();
}

class _ClienteCajaCreatePageState extends State<ClienteCajaCreatePage> {
  final ClienteCajaCreateController controlador = Get.put(ClienteCajaCreateController());

  void _resetPage() {
    controlador.selectedProducts.clear();
    controlador.total.value = 0;
    controlador.pago.value = 0;
    controlador.formaPago = '';
    controlador.codigoBarraController.clear();
    controlador.update();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: _campoCodigoBarra()),
            _iconSearch(context),
          ],
        ),
        actions: [
          _iconScanMobile(context),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: controlador.selectedProducts.isNotEmpty
                ? ListView(
                    children: controlador.selectedProducts
                        .where((product) => product != null)
                        .map((Producto product) => _cardProduct(product))
                        .toList(),
                  )
                : const Center(child: Text('No hay ningun producto agregado aun')),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: _totalToPay(context),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _iconScanMobile(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
      tooltip: 'Escanear código',
      onPressed: () async {
        final barcode = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (_) => _BarcodeScannerView()),
        );
        if (barcode != null && barcode.isNotEmpty) {
          controlador.codigoBarraController.text = barcode;
          await controlador.code();
          controlador.codigoBarraController.clear();
          controlador.update();
          setState(() {});
        }
      },
    );
  }

  Widget _totalToPay(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              'TOTAL: \$${controlador.total.value}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            alignment: Alignment.center,
            child: ElevatedButton(
                onPressed: () {
                  dialogPagar(context);
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)
                ),
                child: const Text(
                  'PAGAR',
                  style: TextStyle(
                      color: Colors.black
                  ),
                )
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () {
                exit(0); // Finaliza la app en Android
              },
              icon: const Icon(Icons.exit_to_app, color: Colors.red, size: 32),
              tooltip: 'Salir',
            ),
          ),
        ),
      ],
    );
  }

  void dialogPagar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Métodos de Pago'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Débito'),
              onTap: () async {
                controlador.formaPago = 'DEBITO';
                await controlador.createBill(context);
                Navigator.of(context).pop();
                _resetPage();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Venta registrada con Débito'))
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card_rounded),
              title: const Text('Crédito'),
              onTap: () async {
                controlador.formaPago = 'CREDITO';
                await controlador.createBill(context);
                Navigator.of(context).pop();
                _resetPage();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Venta registrada con Crédito'))
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.money_off_rounded),
              title: const Text('Efectivo'),
              onTap: () {
                Navigator.of(context).pop(); // Cierra el modal actual
                _dialogPagoEfectivo(context); // Abre el modal de efectivo
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _dialogPagoEfectivo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Obx(() => AlertDialog(
        title: const Text('Terminar venta al contado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Cantidad recibida', style: TextStyle(color: Colors.blue, fontSize: 14)),
            TextField(onChanged: controlador.onChangeText),
            const SizedBox(height: 10),
            Text(
              'TOTAL: \$${controlador.total.value}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              (controlador.pago.value >= controlador.total.value)
                  ? 'PAGO: \$${controlador.pago.value}' : 'PAGO: \$ ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              (controlador.pago.value >= controlador.total.value)
                  ? 'CAMBIO: \$${controlador.pago.value - controlador.total.value}'
                  : 'CAMBIO: \$ ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              controlador.formaPago = 'EFECTIVO';
              await controlador.createBill(context);
              Navigator.of(context).pop();
              _resetPage();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Venta registrada con Efectivo'))
              );
            },
            child: const Text('Terminar Venta')
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      )),
    );
  }

  Widget _cardProduct(Producto product) {
    final nombre = product.nombreProducto ?? '';
    final precioVenta = int.tryParse(product.precioVenta ?? '0') ?? 0;
    final cantidad = product.cantidad ?? 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          const SizedBox(width: 5),
          Container(
            width: MediaQuery.of(context).size.height * 0.14,
            child: Text(
              nombre.isNotEmpty
                ? (nombre.length > 30 ? nombre.substring(0, 30) : nombre)
                : '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const Spacer(),
          Container(
            width: MediaQuery.of(context).size.height * 0.10, // achicado para mejor ajuste
            child: _buttonsAddOrRemove(product),
          ),
          const Spacer(),
          Container(
            width: MediaQuery.of(context).size.height * 0.05,
            child: Text(
              product.precioVenta ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const Spacer(),
          Container(
            width: MediaQuery.of(context).size.height * 0.05,
            child: Text(
              '${precioVenta * cantidad}',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const Spacer(),
          Container(
            width: MediaQuery.of(context).size.height * 0.04,
            child: _iconDelete(product),
          ),
        ],
      ),
    );
  }

  Widget _iconDelete(Producto product) {
    return IconButton(
        onPressed: () => controlador.deleteItem(product),
        icon: const Icon(
          Icons.delete,
          color: Colors.red,
        )
    );
  }

  Widget _iconSearch(BuildContext context) {
    return IconButton(
      onPressed: () {
        showSearch(context: context, delegate: ClienteCajaSearchPage(controlador.productos));
      },
      icon: const Icon(
        Icons.search,
        color: Colors.black,
        size: 20,
      ),
      tooltip: 'Buscar producto',
    );
  }

  Widget _buttonsAddOrRemove(Producto product) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => controlador.removeItem(product),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: const Text('-'),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          color: Colors.grey[200],
          child: Text('${product.cantidad ?? 0}'),
        ),
        GestureDetector(
          onTap: () => controlador.addItem(product),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: const Text('+'),
          ),
        ),
      ],
    );
  }

  Widget _campoCodigoBarra() {
    return Container(
      margin: const EdgeInsets.only(left: 10, top: 5, right: 10),
      child: SizedBox(
        width: 180.0,
        height: 40.0,
        child: TextField(
          controller: controlador.codigoBarraController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Codigo de barra',
              suffixIcon: IconButton(
                onPressed: () async {
                  controlador.codigoBarraController.text = controlador.codigoBarraController.text.trim();
                  await controlador.code();
                  controlador.codigoBarraController.clear();
                  controlador.update();
                  setState(() {});
                },
                icon: const Icon(Icons.search),
              ),
              hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.black
              ),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                      color: Colors.grey
                  )
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                      color: Colors.grey
                  )
              ),
              contentPadding: const EdgeInsets.all(7)
          ),
        ),
      ),
    );
  }
}

// Vista de escaneo con mobile_scanner
class _BarcodeScannerView extends StatefulWidget {
  @override
  State<_BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<_BarcodeScannerView> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    final controlador = Get.find<ClienteCajaCreateController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear código')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_scanned) return;
          final barcode = capture.barcodes.first;
          final String? code = barcode.rawValue;
          if (code != null && code.isNotEmpty) {
            _scanned = true;
            controlador.scanBarcodeMobileScanner(code);
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) Navigator.pop(context, code);
            });
          }
        },
      ),
    );
  }
}