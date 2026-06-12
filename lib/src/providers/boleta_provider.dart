import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class BoletaProvider {
  static const String _baseUrl = 'https://divine-commitment-production-a0ed.up.railway.app/api/v1/boleta';
  static const String _trackingUrl = 'https://divine-commitment-production-a0ed.up.railway.app/api/v1/tracking';
  static const String _cafStatusUrl = 'https://divine-commitment-production-a0ed.up.railway.app/api/v1/caf/status';

  String _apiKey;
  String? lastError;
  String? lastXmlError;
  String? lastFoliosError;

  BoletaProvider({String apiKey = ''}) : _apiKey = apiKey {
    if (apiKey.isEmpty) {
      print('⚠️ WARNING: BoletaProvider inicializado sin api_key. Debe llamarse setApiKey() antes de emitir boleta.');
    }
  }

  String get apiKey => _apiKey;

  void setApiKey(String value) {
    _apiKey = value.trim();
  }

  Map<String, String> _headersJson() {
    return {
      'Content-Type': 'application/json',
      'X-API-Key': _apiKey,
    };
  }

  Map<String, String> _headersAuth() {
    return {
      'X-API-Key': _apiKey,
    };
  }

  int? _tryParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final soloNumeros = value.replaceAll(RegExp(r'[^0-9\-]'), '');
      return int.tryParse(soloNumeros);
    }
    return null;
  }

  int? _extraerFoliosDisponibles(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final keysPrioritarias = <String>[
        'total_folios_disponibles',
        'folios_disponibles',
        'foliosDisponibles',
        'disponibles',
        'disponible',
        'saldo_folios',
        'restantes',
        'cantidad_disponible',
        'cantidadDisponible',
      ];

      for (final key in keysPrioritarias) {
        if (data.containsKey(key)) {
          final parsed = _tryParseInt(data[key]);
          if (parsed != null) return parsed;
        }
      }

      for (final value in data.values) {
        final parsed = _extraerFoliosDisponibles(value);
        if (parsed != null) return parsed;
      }
      return null;
    }

    if (data is List) {
      for (final item in data) {
        final parsed = _extraerFoliosDisponibles(item);
        if (parsed != null) return parsed;
      }
      return null;
    }

    return _tryParseInt(data);
  }

  int? _sumarRestantesDesdeDetalles(dynamic data) {
    if (data is! Map) return null;
    final detalles = data['detalles'];
    if (detalles is! List) return null;

    int suma = 0;
    bool encontro = false;
    for (final item in detalles) {
      if (item is Map) {
        final restantes = _tryParseInt(item['restantes']);
        if (restantes != null) {
          suma += restantes;
          encontro = true;
        }
      }
    }
    return encontro ? suma : null;
  }

  Future<Map<String, dynamic>?> generarBoleta(Map<String, dynamic> boletaData) async {
    lastError = null;
    try {
      final url = Uri.parse('$_baseUrl/generar');
      final response = await http
          .post(
            url,
            headers: _headersJson(),
            body: jsonEncode(boletaData),
          )
          .timeout(const Duration(seconds: 20));

      print('SII API status: ${response.statusCode}');
      print('SII API body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      }

      lastError = 'SII respondió ${response.statusCode}: ${response.body}';
      print('Error al generar boleta SII: $lastError');
      return null;
    } on TimeoutException {
      lastError = 'Timeout al generar boleta en SII';
      print(lastError);
      return null;
    } catch (e) {
      lastError = 'Excepción al generar boleta: $e';
      print(lastError);
      return null;
    }
  }

  Future<String?> obtenerXmlBoleta(String boletaId) async {
    lastXmlError = null;
    final url = Uri.parse('$_baseUrl/$boletaId/xml');

    const int maxAttempts = 5;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await http
            .get(
              url,
              headers: _headersAuth(),
            )
            .timeout(const Duration(seconds: 12));

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          return response.body;
        }

        lastXmlError = 'XML no disponible (status ${response.statusCode}) intento $attempt/$maxAttempts';
        print(lastXmlError);
      } on TimeoutException {
        lastXmlError = 'Timeout obteniendo XML (intento $attempt/$maxAttempts)';
        print(lastXmlError);
      } catch (e) {
        lastXmlError = 'Excepción obteniendo XML: $e';
        print(lastXmlError);
      }

      if (attempt < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }

    return null;
  }

  /// Intenta obtener el XML buscando por folio cuando no se dispone del ID interno.
  /// Prueba varias rutas comunes que el backend podría soportar (folio como ruta o query).
  Future<String?> obtenerXmlPorFolio(String folio) async {
    lastXmlError = null;

    final candidates = <Uri>[
      Uri.parse('$_baseUrl/folio/$folio/xml'),
      Uri.parse('$_baseUrl/folio/$folio'),
      Uri.parse('$_baseUrl/$folio/xml'),
      Uri.parse(_baseUrl).replace(queryParameters: {'folio': folio}),
    ];

    for (final uri in candidates) {
      try {
        final response = await http.get(uri, headers: _headersAuth()).timeout(const Duration(seconds: 12));
        if (response.statusCode == 200 && response.body.isNotEmpty) {
          return response.body;
        }
        lastXmlError = 'Intento ${uri.toString()} respondió ${response.statusCode}';
        print(lastXmlError);
      } on TimeoutException {
        lastXmlError = 'Timeout obteniendo XML por folio desde ${uri.toString()}';
        print(lastXmlError);
      } catch (e) {
        lastXmlError = 'Excepción obteniendo XML por folio desde ${uri.toString()}: $e';
        print(lastXmlError);
      }
    }

    return null;
  }

  Future<bool?> enviarBoleta(String boletaId) async {
    final url = Uri.parse('$_baseUrl/enviar');
    final response = await http.post(
      url,
      headers: _headersJson(),
      body: jsonEncode({'id': boletaId}),
    );

    if (response.statusCode == 200) return true;
    if (response.statusCode == 404) return null;
    return false;
  }

  Future<String?> consultarEstadoEnvio(String dteId) async {
    final url = Uri.parse('$_trackingUrl/$dteId/estado');
    final response = await http.get(
      url,
      headers: _headersAuth(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['estado']?.toString();
    } else if (response.statusCode == 404) {
      return '';
    }
    return null;
  }

  Future<int?> consultarFoliosDisponibles({String? emisor, int tipoDte = 39}) async {
    lastFoliosError = null;

    try {
      final query = <String, String>{'tipo_dte': tipoDte.toString()};

      if (emisor != null && emisor.trim().isNotEmpty) {
        query['emisor'] = emisor.trim();
      }

      final uri = Uri.parse(_cafStatusUrl).replace(queryParameters: query);
      final response = await http
          .get(
            uri,
            headers: _headersAuth(),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        lastFoliosError = 'CAF status respondió ${response.statusCode}: ${response.body}';
        return null;
      }

      if (response.body.isEmpty) {
        lastFoliosError = 'CAF status respondió vacío';
        return null;
      }

      final dynamic data = jsonDecode(response.body);
      final int? totalDirecto = _extraerFoliosDisponibles(data);
      if (totalDirecto != null) return totalDirecto;

      final int? totalPorDetalles = _sumarRestantesDesdeDetalles(data);
      if (totalPorDetalles != null) return totalPorDetalles;

      lastFoliosError = 'CAF status sin campo de folios disponibles reconocido';
      return null;
    } on TimeoutException {
      lastFoliosError = 'Timeout consultando folios disponibles';
      return null;
    } catch (e) {
      lastFoliosError = 'No se pudo consultar folios: $e';
      return null;
    }
  }
}


/*import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class BoletaProvider {
  static const String _baseUrl = 'https://divine-commitment-production-a0ed.up.railway.app/api/v1/boleta';
  static const String _trackingUrl = 'https://divine-commitment-production-a0ed.up.railway.app/api/v1/tracking';
  static const String _cafStatusUrl = 'https://divine-commitment-production-a0ed.up.railway.app/api/v1/caf/status';
  String? lastError;
  String? lastXmlError;
  String? lastFoliosError;

  int? _tryParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final soloNumeros = value.replaceAll(RegExp(r'[^0-9\-]'), '');
      return int.tryParse(soloNumeros);
    }
    return null;
  }

  int? _extraerFoliosDisponibles(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final keysPrioritarias = <String>[
        'total_folios_disponibles',
        'folios_disponibles',
        'foliosDisponibles',
        'disponibles',
        'disponible',
        'saldo_folios',
        'restantes',
        'cantidad_disponible',
        'cantidadDisponible',
      ];

      for (final key in keysPrioritarias) {
        if (data.containsKey(key)) {
          final parsed = _tryParseInt(data[key]);
          if (parsed != null) return parsed;
        }
      }

      for (final value in data.values) {
        final parsed = _extraerFoliosDisponibles(value);
        if (parsed != null) return parsed;
      }
      return null;
    }

    if (data is List) {
      for (final item in data) {
        final parsed = _extraerFoliosDisponibles(item);
        if (parsed != null) return parsed;
      }
      return null;
    }

    return _tryParseInt(data);
  }

  int? _sumarRestantesDesdeDetalles(dynamic data) {
    if (data is! Map) return null;
    final detalles = data['detalles'];
    if (detalles is! List) return null;

    int suma = 0;
    bool encontro = false;
    for (final item in detalles) {
      if (item is Map) {
        final restantes = _tryParseInt(item['restantes']);
        if (restantes != null) {
          suma += restantes;
          encontro = true;
        }
      }
    }
    return encontro ? suma : null;
  }

  /// Genera una boleta electrónica en el sistema DTE
  /// Ahora retorna el objeto completo (id, ted_dd, etc)
  Future<Map<String, dynamic>?> generarBoleta(Map<String, dynamic> boletaData) async {
    lastError = null;
    try {
      final url = Uri.parse('$_baseUrl/generar');
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'X-API-Key': 'Vikingo80',
            },
            body: jsonEncode(boletaData),
          )
          .timeout(const Duration(seconds: 20));

      print('SII API status: ${response.statusCode}');
      print('SII API body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      }

      lastError = 'SII respondió ${response.statusCode}: ${response.body}';
      print('Error al generar boleta SII: $lastError');
      return null;
    } on TimeoutException {
      lastError = 'Timeout al generar boleta en SII';
      print(lastError);
      return null;
    } catch (e) {
      lastError = 'Excepción al generar boleta: $e';
      print(lastError);
      return null;
    }
  }

  /// Obtiene el XML oficial de la boleta por su ID
  Future<String?> obtenerXmlBoleta(String boletaId) async {
    lastXmlError = null;
    final url = Uri.parse('$_baseUrl/$boletaId/xml');

    // El XML puede demorar unos segundos en estar disponible; reintentamos.
    const int maxAttempts = 5;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await http
            .get(
              url,
              headers: {'X-API-Key': 'Vikingo80'},
            )
            .timeout(const Duration(seconds: 12));

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          return response.body;
        }

        lastXmlError = 'XML no disponible (status ${response.statusCode}) intento $attempt/$maxAttempts';
        print(lastXmlError);
      } on TimeoutException {
        lastXmlError = 'Timeout obteniendo XML (intento $attempt/$maxAttempts)';
        print(lastXmlError);
      } catch (e) {
        lastXmlError = 'Excepción obteniendo XML: $e';
        print(lastXmlError);
      }

      if (attempt < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }

    return null;
  }

  /// Envía la boleta al SII para su validación
  Future<bool?> enviarBoleta(String boletaId) async {
    final url = Uri.parse('$_baseUrl/enviar');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': 'Vikingo80',
      },
      body: jsonEncode({'id': boletaId}),
    );
    if (response.statusCode == 200) return true;
    if (response.statusCode == 404) return null;
    return false;
  }

  /// Consulta el estado de envío de la boleta en el SII
  Future<String?> consultarEstadoEnvio(String dteId) async {
    final url = Uri.parse('$_trackingUrl/$dteId/estado');
    final response = await http.get(
      url,
      headers: {'X-API-Key': 'Vikingo80'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['estado']?.toString();
    } else if (response.statusCode == 404) {
      return '';
    }
    return null;
  }

  /// Consulta folios disponibles para emisión usando endpoint oficial de CAF.
  /// Por defecto consulta boletas afectas (tipo 39).
  Future<int?> consultarFoliosDisponibles({String? emisor, int tipoDte = 39}) async {
    lastFoliosError = null;

    try {
      final query = <String, String>{'tipo_dte': tipoDte.toString()};
      if (emisor != null && emisor.trim().isNotEmpty) {
        query['emisor'] = emisor.trim();
      }

      final uri = Uri.parse(_cafStatusUrl).replace(queryParameters: query);
      final response = await http
          .get(
            uri,
            headers: {'X-API-Key': 'Vikingo80'},
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        lastFoliosError = 'CAF status respondió ${response.statusCode}: ${response.body}';
        return null;
      }

      if (response.body.isEmpty) {
        lastFoliosError = 'CAF status respondió vacío';
        return null;
      }

      final dynamic data = jsonDecode(response.body);
      final int? totalDirecto = _extraerFoliosDisponibles(data);
      if (totalDirecto != null) return totalDirecto;

      final int? totalPorDetalles = _sumarRestantesDesdeDetalles(data);
      if (totalPorDetalles != null) return totalPorDetalles;

      lastFoliosError = 'CAF status sin campo de folios disponibles reconocido';
      return null;
    } on TimeoutException {
      lastFoliosError = 'Timeout consultando folios disponibles';
      return null;
    } catch (e) {
      lastFoliosError = 'No se pudo consultar folios: $e';
      return null;
    }
  }
}
*/