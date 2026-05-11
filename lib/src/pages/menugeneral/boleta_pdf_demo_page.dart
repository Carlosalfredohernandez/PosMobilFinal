import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart';
import 'package:get/get.dart';

import '../../../utils/boleta_pdf_pos.dart';
import '../../../utils/boleta_xml_parser.dart';


class BoletaPdfDemoPage extends StatefulWidget {
  const BoletaPdfDemoPage({super.key});

  @override
  State<BoletaPdfDemoPage> createState() => _BoletaPdfDemoPageState();
}

class _BoletaPdfDemoPageState extends State<BoletaPdfDemoPage> {
  PdfController? _pdfController;
  String? _pdfPath;
  bool _loading = true;

  final String xmlEjemplo = '''<?xml version="1.0" encoding="ISO-8859-1"?>
  <EnvioBOLETA xmlns="http://www.sii.cl/SiiDte" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0" xsi:schemaLocation="http://www.sii.cl/SiiDte EnvioBOLETA_v11.xsd">
    <SetDTE ID="SetDoc">
      <Caratula version="1.0">
        <RutEmisor>77710916-2</RutEmisor>
        <RutEnvia>77710916-2</RutEnvia>
        <RutReceptor>60803000-K</RutReceptor>
        <FchResol>2024-04-02</FchResol>
        <NroResol>0</NroResol>
        <TmstFirmaEnv>2026-05-05T03:33:49</TmstFirmaEnv>
        <SubTotDTE>
          <TpoDTE>39</TpoDTE>
          <NroDTE>1</NroDTE>
        </SubTotDTE>
      </Caratula>
      <DTE version="1.0">
        <Documento ID="T39F197">
          <Encabezado>
            <IdDoc>
              <TipoDTE>39</TipoDTE>
              <Folio>197</Folio>
              <FchEmis>2026-05-04</FchEmis>
              <IndServicio>3</IndServicio>
            </IdDoc>
            <Emisor>
              <RUTEmisor>77710916-2</RUTEmisor>
              <RznSocEmisor>TECNOALSA CHILE SPA</RznSocEmisor>
              <GiroEmisor>Servicios Tecnologicos</GiroEmisor>
              <DirOrigen>Av. Principal 123</DirOrigen>
              <CmnaOrigen>Santiago</CmnaOrigen>
            </Emisor>
            <Receptor>
              <RUTRecep>10320053-9</RUTRecep>
              <RznSocRecep>Carlos Antonio</RznSocRecep>
            </Receptor>
            <Totales>
              <MntTotal>3000</MntTotal>
            </Totales>
          </Encabezado>
          <Detalle>
            <NroLinDet>1</NroLinDet>
            <NmbItem>Alto del carmen</NmbItem>
            <QtyItem>3.0</QtyItem>
            <PrcItem>1000.0</PrcItem>
            <MontoItem>3000</MontoItem>
          </Detalle>
        </Documento>
      </DTE>
    </SetDTE>
  </EnvioBOLETA>
  ''';

  @override
  void initState() {
    super.initState();
    _generarPdfYMostrar();
  }

  Future<void> _generarPdfYMostrar() async {
    final String? xmlArg = Get.arguments is String ? Get.arguments as String : null;
    print('XML recibido en PDF:');
    print(xmlArg);
    if (xmlArg != null) {
      print('--- XML COMPLETO ---');
      print(xmlArg);
      print('--------------------');
    }
    try {
      final dir = await getTemporaryDirectory();
      final outputPath = '${dir.path}/boleta_demo.pdf';
      // Parsear el XML real para extraer los productos y datos
      final boletaMapa = parseBoletaXml(xmlArg ?? xmlEjemplo);
      await BoletaPdfPosGenerator.generarPdfDesdeMapa(boletaMapa, outputPath);
      print('PDF generado en: $outputPath');
      setState(() {
        _pdfPath = outputPath;
        _pdfController = PdfController(document: PdfDocument.openFile(outputPath));
        _loading = false;
      });
    } catch (e, stack) {
      print('❌ Error generando PDF: $e');
      print(stack);
      setState(() {
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error al generar PDF'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cerrar'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Boleta SII (Demo XML)')),
      body: Center(
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: 350,
              height: 500,
              child: _loading || _pdfController == null
                  ? const Center(child: CircularProgressIndicator())
                  : PdfView(
                      controller: _pdfController!,
                      scrollDirection: Axis.vertical,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
