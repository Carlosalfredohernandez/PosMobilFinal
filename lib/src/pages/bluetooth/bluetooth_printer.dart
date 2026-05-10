import 'package:flutter/material.dart';
import 'package:posmobilfinal/src/models/boleta.dart';
import 'package:posmobilfinal/src/models/producto.dart';

class BluetoothPrinterPage extends StatelessWidget {
  final List<Producto> data;
  final Boleta boleta;

  const BluetoothPrinterPage({super.key, required this.data, required this.boleta});

  @override
  Widget build(BuildContext context) {
    // Aquí va la lógica de impresión y la UI
    return Scaffold(
      appBar: AppBar(
        title: Text('Imprimir Boleta'),
      ),
      body: ListView(
        children: [
          Text('Boleta N°: ${boleta.id ?? boleta.numero}'),
          ...data.map((producto) => ListTile(
            title: Text(producto.nombreProducto ?? ''),
            subtitle: Text('Cantidad: ${producto.cantidad} - Precio: ${producto.precioVenta}'),
          )),
          // Aquí puedes agregar botones para imprimir, etc.
        ],
      ),
    );
  }
}