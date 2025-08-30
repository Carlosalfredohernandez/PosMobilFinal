import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:get/get.dart';

class ImpresorasPage extends StatelessWidget {

  final List<PrinterBluetooth> _devices = [];
  final String _devicesMsg = 'No se han encontrado impresoras';

  ImpresorasPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _devices.isEmpty
          ? Center(child:  Text(_devicesMsg))
          : ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (c,i) {
          return ListTile(
            leading: Icon(Icons.print),
            title: Text(_devices[i].name!),
            subtitle: Text(_devices[i].address!),
            onTap: () {
              savePrinter(_devices[i]);
            },
          );
        },
      ),
    );
  }
  void savePrinter(PrinterBluetooth device){
    GetStorage().write('impresora',device);
  }
}
