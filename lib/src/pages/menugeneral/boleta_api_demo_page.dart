import 'package:flutter/material.dart';

import '../../providers/boleta_provider.dart';
import 'boleta_pdf_pos_page.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:xml/xml.dart' as xml;
import '../../../utils/boleta_xml_parser.dart';

class BoletaApiDemoPage extends StatefulWidget {
  const BoletaApiDemoPage({super.key});

  @override
  State<BoletaApiDemoPage> createState() => _BoletaApiDemoPageState();
}


class _BoletaApiDemoPageState extends State<BoletaApiDemoPage> {
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
    'api_key': 'Vikingo80',
  };

  @override
  void initState() {
    super.initState();
    _syncApiKeyFromStorage(ctx: 'initState');
  }

  Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  String _pickApiKeyFromMap(Map<String, dynamic> map, {String prefix = ''}) {
    final k1 = map['api_key']?.toString().trim() ?? '';
    if (k1.isNotEmpty) {
      print('[DTE] api_key encontrada en campo ${prefix}api_key');
      return k1;
    }

    final k2 = map['apiKey']?.toString().trim() ?? '';
    if (k2.isNotEmpty) {
      print('[DTE] api_key encontrada en campo ${prefix}apiKey');
      return k2;
    }

    final k3 = map['x_api_key']?.toString().trim() ?? '';
    if (k3.isNotEmpty) {
      print('[DTE] api_key encontrada en campo ${prefix}x_api_key');
      return k3;
    }

    return '';
  }

  String _pickRutEmpresaFromMap(Map<String, dynamic> map, {String prefix = ''}) {
    final r1 = map['rut_empresa']?.toString().trim() ?? '';
    if (r1.isNotEmpty) {
      print('[DTE] rut empresa encontrado en campo ${prefix}rut_empresa');
      return r1;
    }

    final r2 = map['rut_emisor']?.toString().trim() ?? '';
    if (r2.isNotEmpty) {
      print('[DTE] rut empresa encontrado en campo ${prefix}rut_emisor');
      return r2;
    }

    final r3 = map['rut']?.toString().trim() ?? '';
    if (r3.isNotEmpty) {
      print('[DTE] rut empresa encontrado en campo ${prefix}rut');
      return r3;
    }

    return '';
  }

  String _syncApiKeyFromStorage({required String ctx}) {
    final storage = GetStorage();

    final Map<String, dynamic>? empresaData = _asMap(storage.read('empresa_data'));
    final Map<String, dynamic>? usuarioEmpresaAlt = _asMap(storage.read('usuario_empresa'));
    final Map<String, dynamic>? usuarioempresa = _asMap(storage.read('usuarioempresa'));

    print('=== DEBUG STORAGE [$ctx] ===');
    print('[DTE][$ctx] empresa_data raw: $empresaData');
    print('[DTE][$ctx] usuario_empresa raw: $usuarioEmpresaAlt');
    print('[DTE][$ctx] usuarioempresa raw: $usuarioempresa');

    String apiKey = '';
    String apiKeySource = '';
    String rutEmpresa = '';
    String rutEmpresaSource = '';

    // 1) Priorizar la información de la empresa autenticada
    if (empresaData != null) {
      final candidate = _pickApiKeyFromMap(empresaData);
      if (candidate.isNotEmpty) {
        apiKey = candidate;
        apiKeySource = 'empresa_data';
      }

      if (apiKey.isEmpty && empresaData['empresa'] is Map) {
        final candidate2 = _pickApiKeyFromMap(Map<String, dynamic>.from(empresaData['empresa']), prefix: 'empresa.');
        if (candidate2.isNotEmpty) {
          apiKey = candidate2;
          apiKeySource = 'empresa_data.empresa';
        }
      }

      // rut de la empresa
      rutEmpresa = _pickRutEmpresaFromMap(empresaData);
      if (rutEmpresa.isNotEmpty) rutEmpresaSource = 'empresa_data';
      if (rutEmpresa.isEmpty && empresaData['empresa'] is Map) {
        final r2 = _pickRutEmpresaFromMap(Map<String, dynamic>.from(empresaData['empresa']), prefix: 'empresa.');
        if (r2.isNotEmpty) {
          rutEmpresa = r2;
          rutEmpresaSource = 'empresa_data.empresa';
        }
      }
    }

    // 2) Fallback: usuario_empresa (usuario asociado a la empresa)
    if (apiKey.isEmpty && usuarioEmpresaAlt != null) {
      final candidate = _pickApiKeyFromMap(usuarioEmpresaAlt);
      if (candidate.isNotEmpty) {
        apiKey = candidate;
        apiKeySource = 'usuario_empresa';
      }

      if (apiKey.isEmpty && usuarioEmpresaAlt['empresa'] is Map) {
        final candidate2 = _pickApiKeyFromMap(Map<String, dynamic>.from(usuarioEmpresaAlt['empresa']), prefix: 'usuario_empresa.empresa');
        if (candidate2.isNotEmpty) {
          apiKey = candidate2;
          apiKeySource = 'usuario_empresa.empresa';
        }
      }
    }

    // 3) RECHAZAR fallback a 'usuarioempresa': contiene datos del USUARIO, no de la empresa
    // Este fallback causaría que se use RUT del cajero en lugar de RUT de empresa
    // if (apiKey.isEmpty && usuarioempresa != null) { ... }
    // → BLOQUEADO POR DISEÑO (10-06-2026): Fase 2 de separación autenticación
    
    if (apiKey.isEmpty) {
      print('[DTE][$ctx] ❌ NO se encontró api_key en empresa_data ni usuario_empresa.');
      print('[DTE][$ctx] ⚠️ BLOQUEADO fallback a usuarioempresa (contiene datos de usuario, no empresa)');
    }

    if (apiKey.isNotEmpty) {
      _provider.setApiKey(apiKey);
      print('[DTE][$ctx] api_key aplicada desde "${apiKeySource}": "${apiKey}"');
    } else {
      print('[DTE][$ctx] WARNING: no se encontró api_key en storage; se mantiene: "${_provider.apiKey}"');
    }

    print('[DTE][$ctx] rut empresa usado: "${rutEmpresa}"');
    print('[DTE][$ctx] rut empresa fuente: "${rutEmpresaSource}"');
    print('[DTE][$ctx] api_key activa provider: "${_provider.apiKey}"');
    print('===========================');

    return apiKey;
  }

  String _getRutEmpresaFromStorage() {
    final storage = GetStorage();
    final Map<String, dynamic>? empresaData = _asMap(storage.read('empresa_data'));

    if (empresaData != null) {
      final r = _pickRutEmpresaFromMap(empresaData);
      if (r.isNotEmpty) return r;
      if (empresaData['empresa'] is Map) {
        final r2 = _pickRutEmpresaFromMap(Map<String, dynamic>.from(empresaData['empresa']), prefix: 'empresa.');
        if (r2.isNotEmpty) return r2;
      }
    }

    final Map<String, dynamic>? usuarioempresa = _asMap(storage.read('usuarioempresa'));
    if (usuarioempresa != null) {
      final r = _pickRutEmpresaFromMap(usuarioempresa);
      if (r.isNotEmpty) return r;
      if (usuarioempresa['empresa'] is Map) {
        final r2 = _pickRutEmpresaFromMap(Map<String, dynamic>.from(usuarioempresa['empresa']), prefix: 'empresa.');
        if (r2.isNotEmpty) return r2;
      }
    }

    final Map<String, dynamic>? usuarioEmpresaAlt = _asMap(storage.read('usuario_empresa'));
    if (usuarioEmpresaAlt != null) {
      final r = _pickRutEmpresaFromMap(usuarioEmpresaAlt);
      if (r.isNotEmpty) return r;
      if (usuarioEmpresaAlt['empresa'] is Map) {
        final r2 = _pickRutEmpresaFromMap(Map<String, dynamic>.from(usuarioEmpresaAlt['empresa']), prefix: 'empresa.');
        if (r2.isNotEmpty) return r2;
      }
    }

    return '';
  }

  void _mostrarPdfPosDesdeMapa(Map<String, dynamic> boleta) {
    // Navega a la nueva página de PDF POS, pasándole el mapa como argumento
    Get.toNamed('/boleta_pdf_pos', arguments: boleta);
  }

  Future<void> _generarBoleta() async {
    if (!_formKey.currentState!.validate()) return;

    _syncApiKeyFromStorage(ctx: 'generar');

    setState(() {
      _loading = true;
      _mensaje = null;
    });

    final folio = _folioController.text.trim();
    final rut = _rutController.text.trim();
    final nombre = _nombreController.text.trim();
    final total = int.tryParse(_totalController.text.trim()) ?? 0;
    final detalleNombre = _detalleNombreController.text.trim();
    final detalleCantidad = int.tryParse(_detalleCantidadController.text.trim()) ?? 1;
    final detallePrecio = int.tryParse(_detallePrecioController.text.trim()) ?? 0;

    final resolvedRutEmpresa = _getRutEmpresaFromStorage();
    final emisorRut = resolvedRutEmpresa.isNotEmpty ? resolvedRutEmpresa : '99999999-9';

    final Map<String, dynamic> boleta = {
      'folio': folio,
      'emisor': emisorRut,
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
      'api_key': _provider.apiKey,
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

    _syncApiKeyFromStorage(ctx: 'obtener_xml');

    setState(() {
      _loading = true;
      _mensaje = null;
    });

    // 1. Intentar obtener el XML por ID; si falla, intentar por folio (para compatibilidad)
    String? xmlString = await _provider.obtenerXmlBoleta(folioConsulta);
    if (xmlString == null || xmlString.isEmpty) {
      // intentar por folio (ruta o query que soporte el backend)
      xmlString = await _provider.obtenerXmlPorFolio(folioConsulta);
    }

    if (xmlString == null || xmlString.isEmpty) {
      setState(() {
        _loading = false;
        _mensaje = 'No se pudo obtener el XML: ${_provider.lastXmlError ?? 'Desconocido'}';
      });
      return;
    }

    // 2. Usar el parser centralizado para extraer todos los datos relevantes del XML
    final boleta = parseBoletaXml(xmlString);
    print('DEBUG boleta para PDF:');
    print(boleta);

    setState(() {
      _loading = false;
    });

    _mostrarPdfPosDesdeMapa(boleta);
  }

  Future<void> _enviarBoleta() async {
    final folioEnvio = _folioEnvioController.text.trim();
    if (folioEnvio.isEmpty) return;

    _syncApiKeyFromStorage(ctx: 'enviar');

    setState(() {
      _loading = true;
      _mensaje = null;
    });

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

    _syncApiKeyFromStorage(ctx: 'estado');

    setState(() {
      _loading = true;
      _mensaje = null;
    });

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

/*import 'package:flutter/material.dart';

import '../../providers/boleta_provider.dart';
import 'boleta_pdf_pos_page.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:xml/xml.dart' as xml;
import '../../../utils/boleta_xml_parser.dart';

class BoletaApiDemoPage extends StatefulWidget {
  const BoletaApiDemoPage({super.key});

  @override
  State<BoletaApiDemoPage> createState() => _BoletaApiDemoPageState();
}

class _BoletaApiDemoPageState extends State<BoletaApiDemoPage> {
  @override
  void initState() {
    super.initState();
    final usuarioEmpresa = GetStorage().read('usuarioempresa');
    String apiKeyUsed = '';
    String rutCandidate = '';
    if (usuarioEmpresa is Map) {
      apiKeyUsed = usuarioEmpresa['api_key']?.toString() ?? '';
      rutCandidate = usuarioEmpresa['rut']?.toString() ?? usuarioEmpresa['rut_emisor']?.toString() ?? usuarioEmpresa['empresa']?.toString() ?? usuarioEmpresa['rut_empresa']?.toString() ?? '';
    }
    if (apiKeyUsed.isNotEmpty) {
      _provider.setApiKey(apiKeyUsed);
    }
    print('DEBUG Demo: usuarioempresa api_key="$apiKeyUsed", rut_candidate="$rutCandidate", raw=$usuarioEmpresa');
  }
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

    // ——— LOG: volcar contenido de GetStorage('usuarioempresa') ———
    final ueRaw = GetStorage().read('usuarioempresa');
    print('=== DEBUG GetStorage(usuarioempresa) ===');
    print('tipo: ${ueRaw?.runtimeType}');
    print('valor raw: $ueRaw');
    if (ueRaw is Map) {
      print('campos disponibles: ${ueRaw.keys.toList()}');
      print('  api_key        = ${ueRaw['api_key']}');
      print('  rut            = ${ueRaw['rut']}');
      print('  rut_emisor     = ${ueRaw['rut_emisor']}');
      print('  empresa        = ${ueRaw['empresa']}');
      print('  rut_empresa    = ${ueRaw['rut_empresa']}');
      print('  local_asignado = ${ueRaw['local_asignado']}');
      // Actualizar api_key en el provider con el valor real de la empresa activa
      final apiKeyActual = ueRaw['api_key']?.toString() ?? '';
      if (apiKeyActual.isNotEmpty) _provider.setApiKey(apiKeyActual);
      print('api_key seteado en provider: "$apiKeyActual"');
    } else {
      print('ADVERTENCIA: usuarioempresa NO es Map (es null o tipo inesperado)');
    }
    print('api_key activo en provider: "${_provider.apiKey}"');
    print('========================================');
    // ——————————————————————————————————————————————————————————————

    // 1. Intentar obtener el XML por ID; si falla, intentar por folio (para compatibilidad)
    String? xmlString = await _provider.obtenerXmlBoleta(folioConsulta);
    if (xmlString == null || xmlString.isEmpty) {
      // intentar por folio (ruta o query que soporte el backend)
      xmlString = await _provider.obtenerXmlPorFolio(folioConsulta);
    }

    if (xmlString == null || xmlString.isEmpty) {
      setState(() { _loading = false; _mensaje = 'No se pudo obtener el XML: ${_provider.lastXmlError ?? 'Desconocido'}'; });
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
*/