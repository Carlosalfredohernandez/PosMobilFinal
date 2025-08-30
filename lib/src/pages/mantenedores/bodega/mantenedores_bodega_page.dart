import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/pages/cliente/caja/search/cliente_caja_search_page.dart';
import 'package:posmobil/src/pages/mantenedores/bodega/mantenedores_bodega_controlador.dart';

class MantenedoresBodegaPage extends StatefulWidget {
  const MantenedoresBodegaPage({super.key});


  @override
  State<MantenedoresBodegaPage> createState() => _MantenedoresBodegaPageState();
}

class _MantenedoresBodegaPageState extends State<MantenedoresBodegaPage> {
  MantenedoresBodegaControlador controlador = Get.put(MantenedoresBodegaControlador());

  var precio = 0;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        bottomNavigationBar: Container(
          color: Color.fromRGBO(245, 245, 245, 1),
          height: 100,
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
        body: controlador.selectedProducts.isNotEmpty
            ? ListView(
          children: controlador.selectedProducts.map((Producto product) {
            return _cardProduct(product);
          }).toList(),
        )
            : Center(child: Text('No hay ningun producto agregado aun'))
    ));
  }

  Widget _totalToPay(BuildContext context) {
    return Column(
      children: [
        Divider(height: 1, color: Colors.grey[300]),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: 20, top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'TOTAL: \$${controlador.total.value}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                //width: MediaQuery.of(context).size.width * 0.55,
                child: ElevatedButton(
                    onPressed: (){
                      dialogPagar(context);
                    },
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(15)
                    ),
                    child: Text(
                      'PAGAR',
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

  void dialogPagar(BuildContext context){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Metodos de Pago'),
          content: Text(
              'Elija el metodo con el que desea continuar la compra'
          ),
          actions: [
            ListTile(
              leading: Icon(Icons.credit_card),
              title: Text('Debito'),
              onTap: (){
                controlador.formaPago = 'DEBITO';
              },
            ),
            ListTile(
              leading: Icon(Icons.credit_card_rounded),
              title: Text('Credito'),
              onTap: (){
                controlador.formaPago = 'CREDITO';
              },
            ),
            ListTile(
              leading: Icon(Icons.money_off_rounded),
              title: Text('Efectivo'),
              onTap: (){
                setState(() {
                  controlador.formaPago = 'EFECTIVO';
                  _cashBack(context);
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Cerrar')),
              ],
            )
          ],
        )
    );
  }

  void _cashBack(BuildContext context){
    showDialog(
        context: context,
        builder: (context) => Obx(() => AlertDialog(
          title: Text('Terminar venta al contado'),
          actions: [
            ListTile(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Cantidad recibida', style: TextStyle(color: Colors.blue, fontSize: 14)),
                    TextField(onChanged: controlador.onChangeText),
                  ],
                ),
                leading: Text('\$', style: TextStyle(fontSize: 25),),
                subtitle: Text('¿Con cuanto paga el cliente?', style: TextStyle(color: Colors.grey, fontSize: 14))
            ),
            SizedBox(height: 100),
            Container(
              child: Column(
                children: [
                  Text(
                    'TOTAL: \$${controlador.total.value}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                    ),
                  ),
                  Text(
                    (controlador.pago.value >= controlador.total.value)
                        ? 'PAGO: \$${controlador.pago.value}' : 'PAGO: \$ ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                    ),
                  ),
                  Text(
                    (controlador.pago.value >= controlador.total.value)
                        ? 'CAMBIO: \$${controlador.pago.value - controlador.total.value}'
                        : 'CAMBIO: \$ ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: ()=> controlador.createBill(context), child: Text('Terminar Venta')),
                SizedBox(width: 5),
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Cerrar')),
              ],
            )
          ],
        ))
    );
  }

  // Widget cashBack(){
  Widget _cardProduct(Producto product) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          SizedBox(width: 5),
          SizedBox(
            width: MediaQuery.of(context).size.height * 0.14,
            child: Text(product.nombreProducto!.length > 30
                ? product.nombreProducto!.substring(0,30)
                : product.nombreProducto ?? '' ,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Spacer(),

          SizedBox(width: MediaQuery.of(context).size.height * 0.12, child: _buttonsAddOrRemove(product)),
          Spacer(),

          SizedBox(width: MediaQuery.of(context).size.height * 0.05, child: Text(product.precioVenta ?? '', style: TextStyle(fontWeight: FontWeight.bold))),
          Spacer(),

          SizedBox(width: MediaQuery.of(context).size.height * 0.05, child: _textPrice(product)),
          Spacer(),

          SizedBox(width: MediaQuery.of(context).size.height * 0.04, child: _iconDelete(product))
        ],
      ),
    );
  }

  Widget _iconDelete(Producto product) {
    return IconButton(
        onPressed: () => controlador.deleteItem(product),
        icon: Icon(
          Icons.delete,
          color: Colors.red,
        )
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
          // controlador.getProductos();
          showSearch(context: context, delegate:ClienteCajaSearchPage(controlador.productos));
        },
        icon: Icon(
          Icons.search,
          color: Colors.black,
          size: 20,
        ),
      ),
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

  Widget _buttonsAddOrRemove(Producto product) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => controlador.removeItem(product),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Text('-'),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          color: Colors.grey[200],
          child: Text('${product.cantidad ?? 0}'),
        ),
        GestureDetector(
          onTap: () => controlador.addItem(product),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Text('+'),
          ),
        ),
      ],
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
}
