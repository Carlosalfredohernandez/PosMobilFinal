import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class BoletaProvider {
  static const String _baseUrl = 'https://divine-commitment-production-a0ed.up.railway.app/api/v1/boleta';
  static const String _trackingUrl = 'https://divine-commitment-production-a0ed.up.railway.app/api/v1/tracking';
  String? lastError;
  String? lastXmlError;

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
}
