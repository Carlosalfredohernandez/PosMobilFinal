
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:barcode/barcode.dart';

class BoletaPdfPosGenerator {
  static Future<void> generarPdfDesdeMapa(Map<String, dynamic> boleta, String outputPath) async {
    final pdf = pw.Document();

    // Campos ficticios para simular el formato de la boleta de ejemplo
    final sucursal = boleta['sucursal'] ?? '';
    final direccion = boleta['direccion'] ?? '';
    final giro = boleta['giro'] ?? '';
    final codVendedor = boleta['cod_vendedor'] ?? '3606';
    final vendedor = boleta['vendedor'] ?? 'NEFLI PALACIOS MARIO';
    final remision = boleta['remision'] ?? '528793';
    final caja = boleta['caja'] ?? '3';
    final fecha = boleta['fecha'] ?? DateTime.now().toString().substring(0,10);
    final now = DateTime.now();
    final hora = boleta['hora'] ?? "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    final nroBoleta = boleta['folio'] ?? '301534465';
    final rutEmisor = boleta['rut_emisor'] ?? '59.111.330-5';
    final tipoDoc = boleta['tipo_doc'] ?? 'BOLETA ELECTRONICA';
    final descuento = boleta['descuento'] ?? 0;
    final subtotal = boleta['subtotal'] ?? (boleta['total'] ?? 0) + descuento;
    final pago = boleta['pago'] ?? 'Tarjeta';
    final codAutorizacion = boleta['cod_autorizacion'] ?? '314730';
    final numeroUnico = boleta['numero_unico'] ?? '20260504175330045226151917';
    final iva = boleta['iva'] ?? 0;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, double.infinity),
        margin: pw.EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                padding: const pw.EdgeInsets.all(4),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    pw.Center(child: pw.Text('R.U.T.: ${boleta['rut_emisor'] ?? boleta['emisor'] ?? rutEmisor}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Center(child: pw.Text(tipoDoc, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Center(child: pw.Text('N° $nroBoleta', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              if (boleta['razon_social'] != null && (boleta['razon_social'] as String).isNotEmpty)
                pw.Center(child: pw.Text(boleta['razon_social'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              if (boleta['razon_social'] == null || (boleta['razon_social'] as String).isEmpty)
                pw.Center(child: pw.Text('RAZÓN SOCIAL NO DISPONIBLE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 8),
              pw.Text('SUCURSAL: $sucursal'),
              pw.Text('DIRECCIÓN: $direccion'),
              pw.Text('GIRO: $giro'),
              pw.Text('COD VENDEDOR: $codVendedor'),
              pw.Text('VENDEDOR: $vendedor'),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Nro. Caja: $caja'),
                  pw.Text('Nro. Boleta: $nroBoleta'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Fecha: $fecha'),
                  pw.Text('Hora: $hora'),
                ],
              ),
              pw.SizedBox(height: 8),
              // Detalle de productos
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                columnWidths: {
                  0: pw.FlexColumnWidth(2),
                  1: pw.FlexColumnWidth(5),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('Cant.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('Descripción', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('P.Unit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...((boleta['detalle'] as List).map<pw.TableRow>((item) => pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('${item['cantidad']}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('${item['nombre']}')),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text(
                          item['precio'] != null
                            ? (item['precio'] is num
                                ? item['precio'].toInt().toString()
                                : int.tryParse(item['precio'].toString())?.toString() ?? '')
                            : ''
                        ),
                      ),
                      pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('${item['monto']}')),
                    ],
                  ))),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('SUBTOTAL: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('$subtotal'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('${boleta['total']}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.SizedBox(height: 8),
              pw.Text('El IVA de esta boleta es: '),
              pw.Text('[ S/ $iva ]'),
              pw.SizedBox(height: 16),
              if (boleta['ted_dd'] != null && boleta['ted_dd'].toString().isNotEmpty)
                pw.Container(
                  height: 60,
                  child: pw.BarcodeWidget(
                    barcode: Barcode.pdf417(),
                    data: boleta['ted_dd'],
                    width: 200,
                    height: 60,
                    drawText: false,
                  ),
                ),
              if (boleta['ted_dd'] == null || boleta['ted_dd'].toString().isEmpty)
                pw.Container(
                  height: 40,
                  color: PdfColors.grey300,
                  child: pw.Center(child: pw.Text('CÓDIGO DE BARRAS (sin TED)', style: pw.TextStyle(fontSize: 10))),
                ),
              pw.SizedBox(height: 8),
              pw.SizedBox(height: 8),
              pw.Text('Timbre Electrónico SII'),
              pw.Text('Res. 71 del 31-07-2014'),
              pw.Text('Verifique documento: www.portaldte.cl'),
            ],
          );
        },
      ),
    );

    final file = File(outputPath);
    await file.writeAsBytes(await pdf.save());
  }
}
