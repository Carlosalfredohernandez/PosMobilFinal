import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/models/boleta.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/pages/informes/detalle_venta/informes_detalle_venta_page.dart';
import 'package:posmobil/src/pages/inventarios/informes/inventarios_informes_controller.dart';
import 'package:posmobil/src/pages/inventarios/pdf/pdf_page.dart';
import 'package:posmobil/src/pages/inventarios/vista/inventarios_vista_page.dart';

//import '../../pdf/pdf_page.dart';

class InventariosInformesPage extends StatefulWidget {
  const InventariosInformesPage({super.key});

  @override
  State<InventariosInformesPage> createState() => _InventariosInformesPage();
}

class _InventariosInformesPage extends State<InventariosInformesPage> {

  InventariosInformesController controlador = Get.put(InventariosInformesController());

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
    // setState(() async {
    //   controlador.fechaFinal = (await getDatePickerWidget())!;
    // });
    controlador.fechaFinal = (await getDatePickerWidget())!;
    controlador.fechaInicial.isAfter(controlador.fechaFinal)
        ? Get.snackbar('Datos invalidos', 'Ingresa un rango de fecha valido')
        : controlador.updateBoletas('${controlador.fechaInicial}'.substring(0,10), '${controlador.fechaFinal.add(Duration(days: 1))}'.substring(0,10));
  }

  void searchDateBegin() async {
    // setState(() async {
    //   controlador.fechaInicial = (await getDatePickerWidget())!;
    // });
    controlador.fechaInicial = (await getDatePickerWidget())!;
    controlador.fechaInicial.isAfter(controlador.fechaFinal)
        ? Get.snackbar('Datos invalidos', 'Ingresa un rango de fecha valido')
        : controlador.updateBoletas('${controlador.fechaInicial}'.substring(0,10), '${controlador.fechaFinal.add(Duration(days: 1))}'.substring(0,10));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _textFieldSearch(context),
                    iconScan()
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: controlador.filter.isNotEmpty
                    ? ListView(
                  children: controlador.filter.map((Producto producto) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: ListTile(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => InventariosVistaPage(id: producto.id))
                          );
                        },
                        leading: Icon(Icons.account_balance_wallet_outlined),
                        title: Text('${producto.nombreProducto}'),
                        subtitle: Text('Codigo: ${producto.codigoBarra}\nCantidad ${producto.cantidad}'),
                      ),
                    );
                  }).toList(),
                )
                    : Center(child: Text('No se han encontrado boletas')),
              ),
            ],
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
              MaterialPageRoute(builder: (_) => PdfInventarioPage(productos: controlador.informe,total: controlador.total.value))
          );
        },
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.15),
        child: AppBar(
          elevation: 5,
          // backgroundColor: Colors.transparent,
          // shadowColor: Colors.black,
          automaticallyImplyLeading: false,

          leading: Builder(
            builder: (BuildContext context){
              return IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => controlador.regresar(),
              );
            },
          ),
          title: Text('Informe de Inventario'),
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
    ));
  }

  Widget iconScan(){
    return Container(
      // margin: EdgeInsets.only(left: 10,top: 30),
      child: IconButton(
        onPressed: () {
          controlador.scanBarcodeNormal(context);
        },
        icon: const Icon(Icons.camera_enhance_outlined),
      ),
    );
  }

  Widget _textFieldSearch(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: TextField(
          onChanged: (texto) {
            setState(() {
              controlador.onChangeText(texto);
            });
          },
          decoration: InputDecoration(
              hintText: 'Buscar',
              suffixIcon: Icon(Icons.search, color: Colors.white),
              hintStyle: TextStyle(
                  fontSize: 17,
                  color: Colors.black
              ),
              fillColor: Colors.white,
              filled: true,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color: Colors.grey
                  )
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color: Colors.grey
                  )
              ),
              contentPadding: EdgeInsets.all(15)
          ),
        ),
      ),
    );
  }


}
