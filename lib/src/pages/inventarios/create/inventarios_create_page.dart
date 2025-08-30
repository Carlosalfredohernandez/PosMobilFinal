
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/models/local.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/models/proveedores.dart';
import 'package:posmobil/src/pages/inventarios/create/inventarios_create_controller.dart';
import 'package:posmobil/src/pages/inventarios/search/inventario_search_page.dart';

class InventarioCreatePage extends StatefulWidget {
  const InventarioCreatePage({super.key});

  @override
  State<InventarioCreatePage> createState() => _InventarioCreatePageState();
}

class _InventarioCreatePageState extends State<InventarioCreatePage> {
  InventariosCreateController controlador = Get.put(InventariosCreateController());

  var precio = 0;

  @override
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

  void searchDateBegin() async {
    controlador.fecha = (await getDatePickerWidget())!;
    setState(() {
      controlador.currentSelectedDate = controlador.fecha;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        color: Color.fromRGBO(245, 245, 245, 1),
        height: MediaQuery.of(context).size.height * 0.1,
        child:_totalToPay(context),
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.2,
            child: SafeArea(
              child: Wrap(
                direction: Axis.horizontal,
                children: [
                  _campoCodigoBarra(),
                  _iconSearch(context),
                  _iconScan()
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(

              height: MediaQuery.of(context).size.height * 0.2,
              // width: MediaQuery.of(context).size.width * 0.55,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Fecha:',style: TextStyle(color: Colors.black,)),
                      TextButton(
                        onPressed: searchDateBegin,
                        child: Text('${controlador.fecha}'.substring(0,10),style: TextStyle(color: Colors.black)),
                      )
                    ],
                  ),
                  _dropDownLocales(controlador.locales),
                  _dropDownProveedores(controlador.proveedores),
                  _campoDocumento()
                ],
              ),
            ),
            Divider(height: 1,thickness: 1),
            Container(
              margin: EdgeInsets.only(top: 1),
              height: MediaQuery.of(context).size.height * 0.55,
              child: controlador.selectedProducts.isNotEmpty
                  ? ListView(
                children: controlador.selectedProducts.map((Producto product) {
                  return _cardProduct(product);
                }).toList(),
              )
                  : Center(child: Text('No hay ningun producto agregado aun')),
            )
          ],
        ),
      ),
      // persistentFooterButtons: <Widget>[
      //   IconButton(onPressed: () => controlador.goToView(), icon: Icon(Icons.list)),
      // ],
    );
  }

  Widget _totalToPay(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Divider(height: 1, color: Colors.grey[300]),
        Container(
          alignment: Alignment.center,
          // margin: EdgeInsets.only(left: 20, top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                //width: MediaQuery.of(context).size.width * 0.55,
                child: ElevatedButton(
                    onPressed: () => controlador.createInventario(),
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(15)
                    ),
                    child: Text(
                      'GRABAR TRANSACCION',
                      style: TextStyle(
                          color: Colors.black
                      ),
                    )
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconScan() {
    return Container(
      margin: EdgeInsets.only(left: 5, right: 5),
      child: IconButton(
          onPressed: () => controlador.scanBarcodeNormal(),
          icon: Container(
            //height: MediaQuery.of(context).size.height * 0.1,
            child: Icon(
              Icons.qr_code_scanner,
              color: Colors.black,
            ),
          )
      ),
    );
  }

  Widget _iconSearch(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 5, right: 5),
      child: IconButton(
        onPressed: (){
          showSearch(context: context, delegate:InventarioSearchPage(controlador.productos));
        },
        icon: Icon(
          Icons.search,
          color: Colors.black,
          size: 20,
        ),
      ),
    );
  }


  Widget _productoCantidad(Producto producto, BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.05,
      child: TextField(
        onChanged: (texto) {
          setState(() {
            // producto.cantidad = int.parse(texto);
            controlador.getCantidad(producto, texto);
          });
        },
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Cantidad',
        ),
      ),
    );
  }

  Widget _cardProduct(Producto product) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          SizedBox(width: 5),
          SizedBox(
            width: MediaQuery.of(context).size.height * 0.1,
            child: Text(product.nombreProducto!.length > 24
                ? product.nombreProducto!.substring(0,24)
                : product.nombreProducto ?? '' ,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Spacer(),

          SizedBox(width: MediaQuery.of(context).size.height * 0.12, child: _productoCantidad(product,context)),
          Spacer(),

          SizedBox(width: MediaQuery.of(context).size.height * 0.05, child: Text(product.precioVenta ?? '', style: TextStyle(fontWeight: FontWeight.bold))),
          Spacer(),

          SizedBox(width: MediaQuery.of(context).size.height * 0.07, child: _textPrice(product)),
          Spacer(),

          SizedBox(width: MediaQuery.of(context).size.height * 0.035, child: _iconDelete(product)),
          Spacer(),
        ],
      ),
    );
  }
  Widget _iconDelete(Producto product) {
    return IconButton(
        onPressed: () {
          setState(() {
            controlador.deleteItem(product);
          });
        },
        icon: Icon(
          Icons.delete,
          color: Colors.grey,
        )
    );
  }

  Widget _textPrice(Producto product) {
    return Text(
      '${int.parse(product.precioVenta!) * product.cantidad!}',
      style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold
      ),
    );
  }

  Widget _campoCodigoBarra() {
    return Container(
      margin: EdgeInsets.only(left: 40, top: 5),
      child: Column(
        children: [
          SizedBox(
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
                    onPressed: () {
                      controlador.code();
                      controlador.codigoBarraController.clear();
                    },
                    icon: Icon(Icons.search),
                  ),
                  hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.black
                  ),
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
                  contentPadding: EdgeInsets.all(7)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoDocumento() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      height: MediaQuery.of(context).size.width * 0.1,
      margin: EdgeInsets.symmetric(horizontal: 50),
      child: TextField(
        controller: controlador.guiaController,
        keyboardType: TextInputType.number,
        obscureText: false,
        decoration: const InputDecoration(
          hintText: 'Nº Documento',
        ),
      ),
    );
  }

  Widget _dropDownLocales(List<Local> locales) {
    return Obx(() => SizedBox(
      // padding: EdgeInsets.symmetric(horizontal: 50),
      // margin: EdgeInsets.only(top: 15),
      width: MediaQuery.of(context).size.width * 0.6,
      height: MediaQuery.of(context).size.width * 0.1,
      child: DropdownButton(
        underline: Container(
          alignment: Alignment.centerRight,
        ),
        elevation: 3,
        isExpanded: true,
        hint: Text(
          'Locales',
          style: TextStyle(
              fontSize: 15
          ),
        ),
        items: _dropDownItems(locales),
        value: controlador.localAsignado.value == '' ? null : controlador.localAsignado.value,
        onChanged: (option) {
          print('Mostrar categorias $option');
          controlador.localAsignado.value = option.toString();
        },
      ),
    ));
  }

  List<DropdownMenuItem<String>> _dropDownItems(List<Local> locales) {
    List<DropdownMenuItem<String>> list = [];
    for (var local in locales) {
      list.add(DropdownMenuItem(
        value: local.id!,
        child: Text('${local.nombreLocal}'),
      ));
    }

    return list;
  }

  Widget _dropDownProveedores(List<Proveedor> proveedores) {
    return Obx(() => SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      height: MediaQuery.of(context).size.width * 0.05,
      child: DropdownButton(
        underline: Container(
          alignment: Alignment.centerRight,

        ),
        elevation: 3,
        isExpanded: true,
        hint: Text(
          'Proveedores',
          style: TextStyle(
              fontSize: 15
          ),
        ),
        items: dropDownItems(proveedores),
        value: controlador.prove.value == '' ? null : controlador.prove.value,
        onChanged: (option) {
          controlador.prove.value = option.toString();
        },
      ),
    ));
  }

  List<DropdownMenuItem<String>> dropDownItems(List<Proveedor> proveedores) {
    List<DropdownMenuItem<String>> list = [];
    for (var proveedor in proveedores) {
      list.add(DropdownMenuItem(
        value: proveedor.id!,
        child: Text(proveedor.nombre!),
      ));
    }

    return list;
  }
}
