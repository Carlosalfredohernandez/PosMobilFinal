import 'dart:convert';
import 'package:http/http.dart' as http;

class BoletaProvider {
  static const String _baseUrl = 'https://dtecoreengine-production.up.railway.app/api/v1/boleta';
  static const String _trackingUrl = 'https://dtecoreengine-production.up.railway.app/api/v1/tracking';

  /// Genera una boleta electrónica en el sistema DTE
  Future<String?> generarBoleta(Map<String, dynamic> boletaData) async {
    final url = Uri.parse('$_baseUrl/generar');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': 'Vikingo80',
      },
      body: jsonEncode(boletaData),
    );
    print('SII API status: \\${response.statusCode}');
    print('SII API body: \\${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id']?.toString(); // ID de la boleta generada
    } else {
      // Mostrar error detallado en consola
      print('Error al generar boleta SII: status=\\${response.statusCode}, body=\\${response.body}');
    }
    return null;
  }

  /// Obtiene el XML oficial de la boleta por su ID
  Future<String?> obtenerXmlBoleta(String boletaId) async {
    final url = Uri.parse('$_baseUrl/$boletaId/xml');
    final response = await http.get(
      url,
      headers: {'X-API-Key': 'Vikingo80'},
    );
    if (response.statusCode == 200) {
      return response.body; // XML como string
    } else if (response.statusCode == 404) {
      return '';
    } else if (response.statusCode == 401) {
      return '';
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
