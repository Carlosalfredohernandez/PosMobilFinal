import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/models/boleta.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/models/usuario.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class Print extends StatefulWidget {
  final List<Producto>? data;
  final Boleta? boleta;

  const Print({Key? key, this.data, this.boleta}) : super(key: key);

  @override
  State<Print> createState() => _PrintState();
}

class _PrintState extends State<Print> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  String _devicesMsg = 'Buscando impresoras...';
  late Usuario sesionUsuario;
  BluetoothDevice? impresoraAsignada;

  @override
  void initState() {
    super.initState();
    sesionUsuario = Usuario.fromJson(GetStorage().read('usuario') ?? {});
    _initBluetooth();
  }

  void _initBluetooth() async {
    bool? isOn = await bluetooth.isOn;
    if (isOn == true) {
      _getDevices();
    } else {
      setState(() => _devicesMsg = '¡Bluetooth desconectado!');
    }
  }

  void _getDevices() async {
    List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
    setState(() {
      _devices = devices;
      _devicesMsg = devices.isEmpty ? "No se encontraron dispositivos" : '';
    });

    // Si hay impresora guardada, intenta imprimir automáticamente
    final impresoraGuardada = GetStorage().read('impresora');
    if (impresoraGuardada != null && impresoraGuardada is Map) {
      final device = devices.firstWhereOrNull(
        (d) => d.address == impresoraGuardada['address'],
      );
      if (device != null) {
        _startPrint(device);
        Get.offNamedUntil('/inicio/cliente/caja/create', (route) => false);
      }
    }
  }

  void _startPrint(BluetoothDevice device) async {
    // Guarda la impresora seleccionada
    GetStorage().write('impresora', {
      'name': device.name,
      'address': device.address,
    });

    await bluetooth.connect(device);
    bluetooth.printNewLine();
    bluetooth.printCustom("TECNOALSA", 3, 1);
    bluetooth.printCustom("RUT ${sesionUsuario.rut}", 1, 0);
    bluetooth.printCustom("Boleta electrónica Nº ${widget.boleta?.id ?? ''}", 1, 0);
    bluetooth.printCustom("${sesionUsuario.nombre}", 1, 0);
    bluetooth.printCustom("${sesionUsuario.localOficina ?? 'Santiago'}", 1, 0);
    bluetooth.printCustom("${sesionUsuario.calle} ${sesionUsuario.numero}, ${sesionUsuario.comuna}", 1, 0);
    bluetooth.printCustom("${sesionUsuario.region}", 1, 0);
    bluetooth.printNewLine();

    for (final producto in widget.data ?? []) {
      bluetooth.printCustom("${producto.codigoBarra} ${producto.nombreProducto}", 1, 0);
      bluetooth.printCustom("${producto.precioVenta} x ${producto.cantidad}", 1, 2);
    }

    bluetooth.printCustom("TOTAL: ${widget.boleta?.valor ?? ''}", 2, 2);
    bluetooth.printCustom("Forma de pago: ${widget.boleta?.formaPago ?? ''}", 1, 0);
    bluetooth.printNewLine();
    bluetooth.paperCut();
    await bluetooth.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona impresora'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _devices.isEmpty
          ? Center(child: Text(_devicesMsg))
          : ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, i) {
                final device = _devices[i];
                return ListTile(
                  leading: const Icon(Icons.print),
                  title: Text(device.name ?? 'Sin nombre'),
                  subtitle: Text(device.address ?? ''),
                  onTap: () {
                    _startPrint(device);
                    Get.offNamedUntil('/inicio/cliente/caja/create', (route) => false);
                  },
                );
              },
            ),
    );
  }
}