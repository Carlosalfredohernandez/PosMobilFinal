import 'package:flutter/material.dart';

import '../../providers/boleta_provider.dart';
import 'boleta_pdf_pos_page.dart';
import 'package:get/get.dart';
import 'package:xml/xml.dart' as xml;
import '../../../utils/boleta_xml_parser.dart';

class BoletaApiDemoPage extends StatefulWidget {
  const BoletaApiDemoPage({super.key});

  @override
  State<BoletaApiDemoPage> createState() => _BoletaApiDemoPageState();
}

class _BoletaApiDemoPageState extends State<BoletaApiDemoPage> {
  void _mostrarPdfPosDesdeMapa(Map<String, dynamic> boleta) {
    // Navega a la nueva página de PDF POS, pasándole el mapa como argumento
    Get.toNamed('/boleta_pdf_pos', arguments: boleta);
  }
        final TextEditingController _folioEnvioController = TextEditingController();
        final TextEditingController _folioEstadoController = TextEditingController();
      final TextEditingController _folioConsultaController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _folioController = TextEditingController();
    final TextEditingController _rutController = TextEditingController(text: '11111111-1');
    final TextEditingController _nombreController = TextEditingController(text: 'Cliente Demo');
    final TextEditingController _totalController = TextEditingController(text: '1000');
    final TextEditingController _detalleNombreController = TextEditingController(text: 'Producto Demo');
    final TextEditingController _detalleCantidadController = TextEditingController(text: '1');
    final TextEditingController _detallePrecioController = TextEditingController(text: '1000');
  final BoletaProvider _provider = BoletaProvider();
  String? _boletaId;
  String? _xml;
  String? _estado;
  String? _mensaje;
  bool _loading = false;

  // Ejemplo de datos mínimos para generar boleta
  final Map<String, dynamic> _boletaDemo = {
    // Completa con la estructura real según la API
    'emisor': '99999999-9',
    'receptor': {
      'rut': '11111111-1',
      'razon': 'Cliente Demo',
    },
    'detalle': [
      {
        'nombre': 'Producto Demo',
        'cantidad': 1,
        'precio': 1000,
        'monto': 1000,
      }
    ],
    'total': 1000,
    // ...otros campos requeridos por la API...
    'api_key': 'Vikingo80',
  };

  Future<void> _generarBoleta() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _mensaje = null; });
    final folio = _folioController.text.trim();
    final rut = _rutController.text.trim();
    final nombre = _nombreController.text.trim();
    final total = int.tryParse(_totalController.text.trim()) ?? 0;
    final detalleNombre = _detalleNombreController.text.trim();
    final detalleCantidad = int.tryParse(_detalleCantidadController.text.trim()) ?? 1;
    final detallePrecio = int.tryParse(_detallePrecioController.text.trim()) ?? 0;
    final Map<String, dynamic> boleta = {
      'folio': folio,
      'emisor': '99999999-9',
      'receptor': {
        'rut': rut,
        'razon': nombre,
      },
      'detalle': [
        {
          'nombre': detalleNombre,
          'cantidad': detalleCantidad,
          'precio': detallePrecio,
          'monto': detalleCantidad * detallePrecio,
        }
      ],
      'total': total,
      'api_key': 'Vikingo80',
    };
    final boletaResponse = await _provider.generarBoleta(boleta);
    print('DEBUG boletaResponse:');
    print(boletaResponse);
    String? id;
    if (boletaResponse != null) {
      id = boletaResponse['id']?.toString();
    }
    setState(() {
      _boletaId = id;
      _mensaje = id != null ? 'Boleta generada: $id' : 'Error al generar boleta';
      _loading = false;
    });
  }

  Future<void> _obtenerXml() async {
    final folioConsulta = _folioConsultaController.text.trim();
    if (folioConsulta.isEmpty) return;
    setState(() { _loading = true; _mensaje = null; });

    // 1. Obtener el XML real desde la API (ajusta el método según tu provider)
    final String? xmlString = await _provider.obtenerXmlBoleta(folioConsulta);

    if (xmlString == null || xmlString.isEmpty) {
      setState(() { _loading = false; _mensaje = 'No se pudo obtener el XML.'; });
      return;
    }

    // 2. Usar el parser centralizado para extraer todos los datos relevantes del XML
    final boleta = parseBoletaXml(xmlString);
    // Debug: mostrar el mapa boleta en consola
    print('DEBUG boleta para PDF:');
    print(boleta);
    setState(() { _loading = false; });
    _mostrarPdfPosDesdeMapa(boleta);
  }

  Future<void> _enviarBoleta() async {
    final folioEnvio = _folioEnvioController.text.trim();
    if (folioEnvio.isEmpty) return;
    setState(() { _loading = true; _mensaje = null; });
    final ok = await _provider.enviarBoleta(folioEnvio);
    setState(() {
      if (ok == null) {
        _mensaje = 'Folio no encontrado para enviar.';
      } else if (ok == false) {
        _mensaje = 'Error al enviar boleta.';
      } else {
        _mensaje = 'Boleta enviada al SII';
      }
      _loading = false;
    });
  }

  Future<void> _consultarEstado() async {
    final folioEstado = _folioEstadoController.text.trim();
    if (folioEstado.isEmpty) return;
    setState(() { _loading = true; _mensaje = null; });
    final estado = await _provider.consultarEstadoEnvio(folioEstado);
    setState(() {
      _estado = estado;
      if (estado == null || estado.isEmpty) {
        _mensaje = 'Folio no encontrado o sin estado disponible.';
      } else {
        _mensaje = 'Estado: $estado';
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo API Boletas SII')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Datos para generar boleta', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _folioController,
                  decoration: const InputDecoration(labelText: 'Folio de la boleta'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese folio' : null,
                ),
                TextFormField(
                  controller: _rutController,
                  decoration: const InputDecoration(labelText: 'RUT del cliente'),
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese RUT' : null,
                ),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre del cliente'),
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese nombre' : null,
                ),
                TextFormField(
                  controller: _totalController,
                  decoration: const InputDecoration(labelText: 'Total'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese total' : null,
                ),
                const SizedBox(height: 10),
                const Text('Detalle de la venta', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _detalleNombreController,
                  decoration: const InputDecoration(labelText: 'Nombre producto'),
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese producto' : null,
                ),
                TextFormField(
                  controller: _detalleCantidadController,
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese cantidad' : null,
                ),
                TextFormField(
                  controller: _detallePrecioController,
                  decoration: const InputDecoration(labelText: 'Precio unitario'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese precio' : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _generarBoleta,
                  child: const Text('Generar Boleta'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _folioConsultaController,
                  decoration: const InputDecoration(labelText: 'Folio para consultar XML'),
                  keyboardType: TextInputType.text,
                  onChanged: (_) => setState(() {}),
                ),
                ElevatedButton(
                  onPressed: _loading || _folioConsultaController.text.trim().isEmpty ? null : _obtenerXml,
                  child: const Text('Obtener XML de Boleta'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _folioEnvioController,
                  decoration: const InputDecoration(labelText: 'Folio para enviar boleta'),
                  keyboardType: TextInputType.text,
                  onChanged: (_) => setState(() {}),
                ),
                ElevatedButton(
                  onPressed: _loading || _folioEnvioController.text.trim().isEmpty ? null : _enviarBoleta,
                  child: const Text('Enviar Boleta al SII'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _folioEstadoController,
                  decoration: const InputDecoration(labelText: 'Folio para consultar estado'),
                  keyboardType: TextInputType.text,
                  onChanged: (_) => setState(() {}),
                ),
                ElevatedButton(
                  onPressed: _loading || _folioEstadoController.text.trim().isEmpty ? null : _consultarEstado,
                  child: const Text('Consultar Estado de Envío'),
                ),
                const SizedBox(height: 20),
                if (_mensaje != null && _mensaje!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _mensaje!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _mensaje!.toLowerCase().contains('no encontrado') ? Colors.red : Colors.black,
                      ),
                    ),
                  ),
                // Ya no se muestra el XML aquí, se muestra el PDF generado
                if (_mensaje != null && _mensaje!.isNotEmpty && (_xml == null || _xml!.isEmpty))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _mensaje!,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
