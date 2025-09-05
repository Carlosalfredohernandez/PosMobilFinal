import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/models/boleta.dart';
import 'package:posmobil/src/models/detalle.dart';
// import 'package:posmobil/src/providers/boletas_provider.dart';

class InformesDetalleVentaPage extends StatelessWidget {
  Boleta? boleta;
  // BoletasProvider boletasProvider = BoletasProvider();
  InformesDetalleVentaPage({super.key, @required this.boleta}){
    getDetalleBoletas(boleta!);
  }
  List<DetalleBoleta> detalleboletas = <DetalleBoleta>[].obs;

  void getDetalleBoletas(Boleta boleta) async {
    detalleboletas.clear();
    detalleboletas.addAll(boleta.detalle!);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: double.maxFinite,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(
              label: Expanded(
                child: Text(
                  'Producto',
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Cantidad',
                  style: TextStyle(fontSize: 10),
                ),
              ),
              tooltip: 'Cantidad de productos'
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Valor',
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Total',
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
          ],
          rows: detalleboletas.map<DataRow>((DetalleBoleta boleta) {
            return DataRow(
              cells: <DataCell>[
                DataCell(
                    Text(boleta.nombreProducto!,style: TextStyle(fontSize: 10)),
                ),
                DataCell(
                  Text(boleta.cantidad!,style: TextStyle(fontSize: 10)),
                ),
                DataCell(
                  Text(boleta.valorLinea!,style: TextStyle(fontSize: 10)),
                ),
                DataCell(
                  Text('${boleta.totalLinea ?? ''}',style: TextStyle(fontSize: 10)),
                ),
              ]
            );
          }).toList(),
          dividerThickness: 0,
          headingRowColor:
          WidgetStateColor.resolveWith(
                  (states) => Colors.grey),
          headingRowHeight: 30,
          columnSpacing: 10,
          dataRowHeight: 25,
          ),
      ),
    );
  }
}
// Row(
//   children: [
//     Container(width: 50,child: Text('Producto')),
//     Container(width: 50, child: Text('Valor')),
//     Container(width: 50, child: Text('Cantidad')),
//     Container(width: 50, child: Text('Total')),
//   ],
// ),