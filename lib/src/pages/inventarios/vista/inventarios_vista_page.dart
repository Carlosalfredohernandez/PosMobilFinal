import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/models/inventario.dart';
import 'package:posmobil/src/pages/inventarios/vista/inventarios_vista_controller.dart';
import 'package:posmobil/src/pages/inventarios/vista/pdf_vista_page.dart';

class InventariosVistaPage extends StatefulWidget {

  var id;
  InventariosVistaPage({super.key, required this.id});

  @override
  State<InventariosVistaPage> createState() => _InventariosVistaPageState(id: id);
}

class _InventariosVistaPageState extends State<InventariosVistaPage> {

  var id;

  late InventariosVistaController controlador;

  _InventariosVistaPageState({@required this.id}){
    Get.delete<InventariosVistaController>();
    controlador = Get.put(InventariosVistaController(id!));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          title: Text('Historial de Inventario'),
          centerTitle: true,
          // backgroundColor: Colors.transparent,
          // flexibleSpace: Column(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     Row(
          //       children: [
          //         _campoCodigoBarra(context),
          //       ],
          //     ),
          //   ],
          // ),
        ),
      ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.grey[800],
          splashColor: Colors.black,
          elevation: 0,
          child: Icon(Icons.picture_as_pdf),
          onPressed: (){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PdfVistaPage(productos: controlador.stock))
            );
          },
        ),
        bottomNavigationBar: SizedBox(
          height: MediaQuery.of(context).size.height * 0.08,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Cantidad Total ${controlador.total.value}')
            ],
          )
        ),
      // floatingActionButton: IconButton(onPressed: () => controlador.getBack() , icon: Icon(Icons.backspace_outlined)),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: DataTable(
            columns: const <DataColumn>[
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Productos',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
              DataColumn(
                  label: Expanded(
                    child: Text(
                      'Stock',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Movimientos',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Documento',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
                  tooltip: 'Nro Documento'
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Fecha',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ],
            rows: controlador.stock.map<DataRow>((Inventario inventario) {
              return DataRow(
                  cells: <DataCell>[
                    DataCell(
                      Text(inventario.idCliente!,style: TextStyle(fontSize: 10)),
                    ),
                    DataCell(
                      Text('${inventario.cantidad!}',style: TextStyle(fontSize: 10)),
                    ),
                    DataCell(
                      Text(inventario.tipoMovimiento ?? '',style: TextStyle(fontSize: 10)),
                    ),
                    DataCell(
                      Text('${inventario.nroDocumento!}',style: TextStyle(fontSize: 10)),
                    ),
                    DataCell(
                      Text(inventario.fecha ?? '',style: TextStyle(fontSize: 10)),
                    ),
                  ]
              );
            }).toList(),
            dividerThickness: 0,
            headingRowColor:
            WidgetStateColor.resolveWith(
                    (states) => Colors.grey),
            headingRowHeight: 30,
            columnSpacing: 20,
            dataRowHeight: 30,
          ),
        ),
      )
    ));
  }

  // Widget _campoCodigoBarra(BuildContext context) {
  //   return Container(
  //     margin: EdgeInsets.all(10),
  //     child: SizedBox(
  //       width: MediaQuery.of(context).size.height * 0.25,
  //       height: MediaQuery.of(context).size.height * 0.035,
  //       child: TextField(
  //         onChanged: (texto){
  //           setState(() {
  //             controlador.onChangeText(texto);
  //           });
  //         },
  //         keyboardType: TextInputType.text,
  //         decoration: InputDecoration(
  //             fillColor: Colors.white,
  //             filled: true,
  //             // hintText: '',
  //             suffixIcon: IconButton(
  //               onPressed: () {},
  //               icon: Icon(Icons.search),
  //             ),
  //             hintStyle: TextStyle(
  //                 fontSize: 14,
  //                 color: Colors.black
  //             ),
  //             enabledBorder: OutlineInputBorder(
  //               // borderRadius: BorderRadius.circular(15),
  //                 borderSide: BorderSide(
  //                     color: Colors.grey
  //                 )
  //             ),
  //             focusedBorder: OutlineInputBorder(
  //               // borderRadius: BorderRadius.circular(15),
  //                 borderSide: BorderSide(
  //                     color: Colors.grey
  //                 )
  //             ),
  //             contentPadding: EdgeInsets.all(7)
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
