import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/models/producto.dart';
import 'package:posmobilfinal/src/pages/cliente/caja/create/cliente_caja_create_controller.dart';
import 'package:posmobilfinal/src/pages/cliente/caja/search/cliente_caja_search_page.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class ClienteCajaCreatePage extends StatefulWidget {

  @override
  State<ClienteCajaCreatePage> createState() => _ClienteCajaCreatePageState();
}

class _ClienteCajaCreatePageState extends State<ClienteCajaCreatePage> {
  // Asegura que el controlador esté inicializado
  late final ClienteCajaCreateController controlador;
  // Función para generar el PDF de la boleta con firma SII simulada
  Future<void> _generarYMostrarBoletaPDF(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('BOLETA ELECTRÓNICA', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Emisor: Empresa de Ejemplo SpA'),
              pw.Text('RUT: 76.123.456-7'),
              pw.Text('Fecha: ${DateTime.now().toString().substring(0, 16)}'),
              pw.SizedBox(height: 10),
              pw.Text('Detalle de productos/servicios:'),
              pw.Bullet(text: 'Producto 1 - \$1.000'),
              pw.Bullet(text: 'Producto 2 - \$2.000'),
              pw.SizedBox(height: 10),
              pw.Text('Total: \$3.000', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Text('FIRMA ELECTRÓNICA SII (simulada):', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('SII: 2026-05-01T12:00:00Z'),
              pw.BarcodeWidget(
                data: 'BOLETA123456|2026-05-01',
                barcode: pw.Barcode.qrCode(),
                width: 80,
                height: 80,
              ),
              pw.SizedBox(height: 10),
              pw.Text('Timbre electrónico simulado para pruebas internas.'),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
    final GetStorage storage = GetStorage();

    @override
    void initState() {
    super.initState();
    // Inicializa el controlador solo si no existe
    if (!Get.isRegistered<ClienteCajaCreateController>()) {
      controlador = Get.put(ClienteCajaCreateController());
    } else {
      controlador = Get.find<ClienteCajaCreateController>();
    }
    // Mostrar en consola los datos guardados en el storage
    print('📦 Storage - usuario: ' + (storage.read('usuario')?.toString() ?? 'null'));
    print('📦 Storage - usuarioempresa: ' + (storage.read('usuarioempresa')?.toString() ?? 'null'));
    print('📦 Storage - usuario_rol: ' + (storage.read('usuario_rol')?.toString() ?? 'null'));
    }
  @override
  void dispose() {
    super.dispose();
  }

  var precio = 0;

  @override
  Widget build(BuildContext context) {
    print('🟦 ClienteCajaCreatePage: build ejecutado');
      return WillPopScope(
        onWillPop: () async {
          controlador.limpiarCarrito();
          controlador.codigoBarraController.clear();
          return true;
        },
        child: Obx(() {
          if (controlador.isLoading.value) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return Scaffold(
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(245, 245, 245, 1),
              ),
              height: 100,
              child: _totalToPay(context),
            ),
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(60),
                  child: AppBar(
                    automaticallyImplyLeading: false, // No mostrar la flecha automática
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      tooltip: 'Volver al menú general',
                      onPressed: () {
                        controlador.limpiarCarrito();
                        controlador.codigoBarraController.clear();
                        Get.toNamed('/menugeneral');
                      },
                    ),
                    title: Row(
                      children: [
                        Expanded(child: _campoCodigoBarra(context)),
                      ],
                    ),
                    actions: [
                      _iconSearch(context),
                      _iconScan(),
                    ],
                  ),
                ),
            resizeToAvoidBottomInset: true,
            body: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: controlador.selectedProducts.length > 0
                  ? ListView.builder(
                      padding: EdgeInsets.only(top: 8),
                      itemCount: controlador.selectedProducts.length,
                      itemBuilder: (context, index) {
                        final product = controlador.selectedProducts[index];
                        return _cardProduct(product);
                      },
                    )
                  : Center(child: Text('No hay ningun producto agregado aun')),
            ),
          );
        }),
      );
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
                "TOTAL: \$${controlador.total.value.toStringAsFixed(0)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                  onPressed: () {
                    print('Cobrar presionado');
                    setState(() {
                      controlador.formaPago = 'EFECTIVO';
                      _cashBack(context);
                    });
                  },
                  child: Text('Cobrar'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  void _cashBack(BuildContext context) {
    print('_cashBack llamado');
    showDialog(
      context: context,
      builder: (context) {
        double pagoLocal = controlador.pago.value;
        return StatefulBuilder(
          builder: (context, setState) {
            double total = controlador.total.value;
            double cambio = pagoLocal - total;
            return AlertDialog(
              title: Text('Terminar venta al contado'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Cantidad recibida', style: TextStyle(color: Colors.blue, fontSize: 14)),
                          TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                pagoLocal = double.tryParse(value) ?? 0.0;
                              });
                            },
                          ),
                        ],
                      ),
                      leading: Text('\u0000', style: TextStyle(fontSize: 25)),
                      subtitle: Text('¿Con cuanto paga el cliente?', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "TOTAL: \$${total.toStringAsFixed(0)}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      "PAGO: \$${pagoLocal.toStringAsFixed(0)}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      "CAMBIO: \$${cambio.toStringAsFixed(0)}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await controlador.emitirBoletaSii(context: context);
                            // Si se generó el XML, mostrar el PDF automáticamente y cerrar el diálogo
                            if ((controlador.dteXmlString ?? '').isNotEmpty) {
                              // Debug: mostrar el XML y el folio antes de navegar al PDF
                              print('DEBUG flujo principal: folio = \\${controlador.dteBoletaId}');
                              print('DEBUG flujo principal: xml_string =');
                              print(controlador.dteXmlString);
                              Navigator.of(context).pop(); // Cierra el diálogo primero
                              await Get.toNamed('/boleta_pdf_pos', arguments: {
                                'folio': controlador.dteBoletaId ?? 'SIN_FOLIO',
                                'xml_string': controlador.dteXmlString ?? '',
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          child: Text('Emitir Boleta SII'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final exito = await controlador.createBill(context);
                    if (exito == true) {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('¿Imprimir boleta?'),
                          content: Text('¿Desea imprimir la boleta?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Sí'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('No'),
                            ),
                          ],
                        ),
                      );
                      // Aquí puedes manejar el resultado de imprimir o no
                    }
                  },
                  child: Text('Finalizar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Widget cashBack(){
  Widget _cardProduct(Producto product) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          SizedBox(width: 5),
          Container(
            width: MediaQuery.of(context).size.height * 0.14,
            child: Text(product.nombreProducto!.length > 30
                ? product.nombreProducto!.substring(0,30)
                : product.nombreProducto ?? '' ,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Spacer(),

          Container(width: MediaQuery.of(context).size.height * 0.12, child: _buttonsAddOrRemove(product)),
          Spacer(),

          Container(width: MediaQuery.of(context).size.height * 0.05, child: Text(product.precioVenta ?? '', style: TextStyle(fontWeight: FontWeight.bold))),
          Spacer(),

          Container(width: MediaQuery.of(context).size.height * 0.05, child: _textPrice(product)),
          Spacer(),

          Container(width: MediaQuery.of(context).size.height * 0.04, child: _iconDelete(product))
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
        onPressed: () async {
          String? barcode = await _scanBarcodeMobileScanner(context);
          if (barcode != null && barcode.isNotEmpty) {
            await controlador.scanBarcodeMobileScanner(
              barcode,
              context,
              (codigo) async {
                await controlador.showProductoNoExisteDialog(context, codigo);
              },
            );
          }
        },
        icon: Container(
          child: Icon(
            Icons.qr_code_scanner,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  /// Escaneo real usando MobileScanner
  Future<String?> _scanBarcodeMobileScanner(BuildContext context) async {
    String? scannedCode;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text('Escanear código de barras'),
            actions: [
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
          body: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                scannedCode = barcodes.first.rawValue;
                Navigator.of(context).pop();
              }
            },
          ),
        );
      },
    );
    return scannedCode;
  }



  Widget _iconSearch(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 5, right: 5),
      child: IconButton(
        onPressed: () async {
          final Producto? result = await showSearch<Producto>(
            context: context,
            delegate: ClienteCajaSearchPage(controlador.productos),
          );
          if (result != null && result.nombreProducto != null && result.nombreProducto!.isNotEmpty) {
            // Agregar el producto seleccionado a la lista
            controlador.addItem(result);
            FocusScope.of(context).unfocus(); // Cierra el teclado automáticamente
          }
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
            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Text('-', style: TextStyle(fontSize: 15)),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          color: Colors.grey[200],
          child: Text('${product.cantidad ?? 0}', style: TextStyle(fontSize: 15)),
        ),
        GestureDetector(
          onTap: () => controlador.addItem(product),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Text('+', style: TextStyle(fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _campoCodigoBarra(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8, top: 5, right: 8),
      child: SizedBox(
        width: 340.0,
        height: 44.0,
        child: TextField(
          controller: controlador.codigoBarraController,
          keyboardType: TextInputType.text,
          style: TextStyle(fontSize: 18),
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Código de barra',
              suffixIcon: IconButton(
                onPressed: () {
                  controlador.code(context);
                  controlador.codigoBarraController.clear();
                  FocusScope.of(context).unfocus(); // Oculta el teclado
                },
                icon: Icon(Icons.search),
              ),
              hintStyle: TextStyle(
                  fontSize: 16,
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
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)
          ),
        ),
      ),
    );
  }
}
