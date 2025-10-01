import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:posmobil/src/models/boleta.dart';
import 'package:posmobil/src/models/detalle.dart';
import 'package:posmobil/src/models/producto.dart';

class PdfInventarioPage extends StatefulWidget {

  List<Producto> productos = <Producto>[];
  var total;
  PdfInventarioPage({super.key, required this.productos, this.total});

  @override
  State<PdfInventarioPage> createState() => _PdfInventarioPage(productos: productos, total: total);
}

class _PdfInventarioPage extends State<PdfInventarioPage> {
  List<DetalleBoleta> detalles = <DetalleBoleta>[];
  List<Producto> productos = <Producto>[];
  var total;
  _PdfInventarioPage({required this.productos, this.total});
  Uint8List? archivoPdf;
  pw.Document? pdf;

  double sizeIcon1 = 45;
  double sizeIcon2 = 30;
  double sizeIcon3 = 30;


  @override
  void initState() {
    total = numberFormat(total);
    initPDF();
  }

  Future<void> initPDF() async {
    archivoPdf = await generarPdf();
  }


  String numberFormat(int x) {
    List<String> parts = x.toString().split('.');
    RegExp re = RegExp(r'\B(?=(\d{3})+(?!\d))');

    parts[0] = parts[0].replaceAll(re, '.');
    if (parts.length == 1) {
      // parts.add('00');
    } else {
      parts[1] = parts[1].padRight(2, '0').substring(0, 2);
    }
    return parts.join(',');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.black,
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 600,
                width: double.maxFinite,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 25,
                  ),
                  child: PdfPreview(
                    build: (format) => archivoPdf!,
                    useActions: false,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        archivoPdf = await generarPdf();
                        setState(
                              () {
                            archivoPdf = archivoPdf;
                          },
                        );
                      },
                      child: Icon(
                        Icons.picture_as_pdf,
                        size: sizeIcon1,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 20,
                    ),
              GestureDetector(
                onTap: () async {
                  await Printing.sharePdf(
                      bytes: archivoPdf!, filename: 'Informe_de_ventas.pdf');
                },
                child: Icon(
                  Icons.share,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
            ],
          ),
        ),
        ]
      ),
    )));
  }

  Future<Uint8List> generarPdf() async {
    var pdf = pw.Document();
    final headers = ['Producto','Codigo','Cantidad'];
    final data = productos.map((Producto producto) =>[
      producto.nombreProducto ?? '',producto.codigoBarra ?? '',producto.cantidad ?? ''
    ]).toList();
    // final _headers = ['Boleta','Producto','Precio','Cantidad','Total'];
    // final detalle = detalles.map((DetalleBoleta detail) =>[
    //   detail.id ?? '',detail.nombreProducto ?? '',detail.valorLinea ?? '',detail.cantidad ?? '',detail.totalLinea ?? ''
    // ]).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a5,
        margin: pw.EdgeInsets.zero,
        build: (context) => [
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(vertical: 20),
            child: pw.Center(
              child: pw.Text(
                'Informe de Inventario',
                style: pw.TextStyle(
                  fontSize: 25,
                  color: PdfColors.black,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ),

          pw.SizedBox(
            height: 20,
          ),
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 20,
            ),
            child: pw.Table.fromTextArray(
                headers: headers,
                data: data
            ),
          ),
          pw.SizedBox(
            height: 20,
          ),

        ],
      ),
    );
    return pdf.save();
  }



}


