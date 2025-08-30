import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:posmobil/src/models/boleta.dart';
import 'package:posmobil/src/pages/informes/detalle_venta/informes_detalle_venta_page.dart';
import 'package:posmobil/src/pages/informes/ventas/informes_ventas_controller.dart';

import '../../pdf/pdf_page.dart';

class InformesVentasPage extends StatefulWidget {
  const InformesVentasPage({super.key});

  @override
  State<InformesVentasPage> createState() => _InformesVentasPageState();
}

class _InformesVentasPageState extends State<InformesVentasPage> {

  InformesVentasController controlador = Get.put(InformesVentasController());

  Future<DateTime?> getDatePickerWidget() {
    return showDatePicker(
        context: context,
        initialDate: controlador.currentSelectedDate,
        lastDate: DateTime.now(),
        firstDate: DateTime(2022),
        builder: (context, child){
          return Theme(data: ThemeData.dark(), child: child!);
        }
    );
  }

  void searchDateEnd() async {
    controlador.fechaFinal = (await getDatePickerWidget())!;
    controlador.fechaInicial.isAfter(controlador.fechaFinal)
        ? Get.snackbar('Datos invalidos', 'Ingresa un rango de fecha valido')
        : controlador.updateBoletas('${controlador.fechaInicial}'.substring(0,10), '${controlador.fechaFinal.add(Duration(days: 1))}'.substring(0,10));
  }

  void searchDateBegin() async {
    controlador.fechaInicial = (await getDatePickerWidget())!;
    controlador.fechaInicial.isAfter(controlador.fechaFinal)
        ? Get.snackbar('Datos invalidos', 'Ingresa un rango de fecha valido')
        : controlador.updateBoletas('${controlador.fechaInicial}'.substring(0,10), '${controlador.fechaFinal.add(Duration(days: 1))}'.substring(0,10));
  }

  // Future toPDFScreen() {
  //   return MaterialApp(
  //     title: 'PDF',
  //     initialRoute: PDFScreen.id,
  //     routes: {
  //       PDFScreen.id: (context) => PDFScreen(),
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        body: controlador.boletas.isNotEmpty
            ? ListView(
          children: controlador.boletas.map((Boleta boleta) {
            return ListTile(
              onTap: (){
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Boleta'),
                      actions: [
                        Column(
                          children: [
                            Row(children: [Text('Numero: ${boleta.id}'),],),
                            Row(children: [Text('FECHA:  ${boleta.fecha!.substring(0,10)}'),],),
                            Row(children: [Text('VALOR:   ${boleta.valor}'),],),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cerrar')),
                          ],
                        )
                      ],
                      content: InformesDetalleVentaPage(boleta: boleta),
                    )
                );
              },
              leading: Icon(Icons.account_balance_wallet_outlined),
              title: Text('${boleta.fecha}'),
              subtitle: Text('Boleta: ${boleta.id} - METODO ${boleta.formaPago} \n\$ ${boleta.valor}'),
            );
          }).toList(),
        )
            : Center(child: Text('No se han encontrado boletas')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey[800],
        splashColor: Colors.black,
        elevation: 0,
        child: Icon(Icons.picture_as_pdf),
        onPressed: (){
          Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PdfExportPage(boletas: controlador.boletas,total: controlador.total.value))
          );
        },
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          elevation: 5,
          // backgroundColor: Colors.transparent,
          // shadowColor: Colors.black,
          automaticallyImplyLeading: false,
          // actions: [
          //   TextButton(
          //     child: Text('Fecha\nInicial',style: TextStyle(color: Colors.black)),
          //   //icon: Icon(Icons.access_time),
          //     onPressed: searchDateBegin
          //   ),
          //   TextButton(
          //       child: Text('Fecha\nFinal',style: TextStyle(color: Colors.black),),
          //       //icon: Icon(Icons.access_time),
          //       onPressed: searchDateEnd
          //   ),
          // ],
          leading: Builder(
            builder: (BuildContext context){
              return IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => controlador.regresar(),
              );
            },
          ),
          title: Text('Informe de Ventas'),
          centerTitle: true,
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Fecha Inicial',style: TextStyle(color: Colors.black,)),
                  TextButton(
                      onPressed: searchDateBegin,
                      child: Text('${controlador.fechaInicial}'.substring(0,10),style: TextStyle(color: Colors.black))
                  ),
                  Text('Fecha Final',style: TextStyle(color: Colors.black,)),
                  TextButton(
                      onPressed: searchDateEnd,
                      child: Text('${controlador.fechaFinal}'.substring(0,10),style: TextStyle(color: Colors.black),)
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: MediaQuery.of(context).size.height * 0.08,
        child: BottomNavigationBar(
          elevation: 10,
          backgroundColor: Colors.grey[300],
          items: [
          BottomNavigationBarItem(
            label: 'Total: \$ ${controlador.numberFormat(controlador.total.value)}',
            icon: Icon(Icons.currency_exchange, color: Colors.grey[600],),
            tooltip: 'Total Ventas',
            //activeIcon: Text('\$'),
          ),
          BottomNavigationBarItem(
             label: 'Boletas: ${controlador.cant}',
             icon: Icon(Icons.import_contacts_sharp, color: Colors.grey[600],),
             tooltip: 'Cantidad total de boletas',
              //activeIcon: Text('\$'),
          ),
          BottomNavigationBarItem(
            label: 'Exportar',
            icon: Icon(Icons.picture_as_pdf),
            tooltip: 'Exportar la informacion recibida a un formato pdf ',
          )
        ],),
      ),

    ));
  }


}
