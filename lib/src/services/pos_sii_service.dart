// services/pos_sii_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class POSSIIService {
  static const String _baseUrl = 'http://192.168.1.88:3000'; // IP real de tu PC
  static const String _rutEmpresa = '77710916-2';
  static const String _passwordCert = 'vikingo80';
  
  /// Procesar venta POS y generar boleta electrónica SII
  static Future<Map<String, dynamic>> procesarVentaPOS({
    required String ventaId,
    required Map<String, dynamic> cliente,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> totales,
    required String vendedor,
    required String sucursal,
    required String metodoPago,
  }) async {
    
    final data = {
      'ventaId': ventaId,
      'rutEmpresa': _rutEmpresa,
      'passwordCert': _passwordCert,
      'cliente': cliente,
      'items': items,
      'totales': totales,
      'vendedor': vendedor,
      'sucursal': sucursal,
      'metodoPago': metodoPago,
    };
    
    try {
      print('📱 Enviando venta al backend SII: $ventaId');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/pos/procesar-venta'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 90)); // Timeout aumentado para debugging
      
      final resultado = jsonDecode(response.body);
      
      if (response.statusCode == 200 && resultado['success'] == true) {
        print('✅ Boleta SII generada: ${resultado['data']['boletaElectronica']['id']}');
        return {
          'success': true,
          'data': resultado['data'],
          'message': resultado['message'],
        };
      } else {
        print('❌ Error del servidor: ${resultado['message']}');
        return {
          'success': false,
          'error': resultado['error'] ?? 'Error desconocido',
          'message': resultado['message'] ?? 'Error del servidor',
        };
      }
      
    } catch (e) {
      print('❌ Error de conexión: $e');
      return {
        'success': false,
        'error': 'CONNECTION_ERROR',
        'message': 'Error de conexión con el servidor SII: $e',
      };
    }
  }
  
  /// Consultar estado de boleta por venta ID
  static Future<Map<String, dynamic>> consultarEstadoBoleta(String ventaId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/pos/estado-boleta/$ventaId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));
      
      final resultado = jsonDecode(response.body);
      
      if (response.statusCode == 200 && resultado['success'] == true) {
        return {
          'success': true,
          'data': resultado['data'],
        };
      } else {
        return {
          'success': false,
          'message': resultado['message'] ?? 'Boleta no encontrada',
        };
      }
      
    } catch (e) {
      return {
        'success': false,
        'message': 'Error consultando estado: $e',
      };
    }
  }
  
  /// Enviar boleta al SII
  static Future<Map<String, dynamic>> enviarBoletaAlSII(String boletaElectronicaId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/pos/enviar-sii/$boletaElectronicaId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'rutEmpresa': _rutEmpresa,
          'passwordCert': _passwordCert,
        }),
      ).timeout(const Duration(seconds: 45));
      
      final resultado = jsonDecode(response.body);
      
      return {
        'success': response.statusCode == 200 && resultado['success'] == true,
        'data': resultado['data'],
        'message': resultado['message'],
      };
      
    } catch (e) {
      return {
        'success': false,
        'message': 'Error enviando al SII: $e',
      };
    }
  }
  
  /// Generar ID único para venta
  static String generarVentaId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'V-TECNOALSA-$timestamp';
  }
  
  /// Calcular totales de venta
  static Map<String, dynamic> calcularTotales(List<dynamic> items) {
    double total = 0.0;
    
    for (var item in items) {
      final precio = double.tryParse(item['precio'].toString()) ?? 0.0;
      final cantidad = int.tryParse(item['cantidad'].toString()) ?? 0;
      total += precio * cantidad;
    }
    
    final neto = total / 1.19; // Quitar IVA
    final iva = total - neto;
    
    return {
      'total': total.round(),
      'neto': neto.round(),
      'iva': iva.round(),
    };
  }

  /// Descargar XML de boleta
  static Future<List<int>?> descargarXMLBoleta(String boletaId) async {
    try {
      print('📥 Descargando XML de boleta: $boletaId');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/pos/boleta/$boletaId/xml'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 90));
      
      if (response.statusCode == 200) {
        print('✅ XML descargado exitosamente');
        return response.bodyBytes;
      } else {
        print('❌ Error descargando XML: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error de conexión descargando XML: $e');
      return null;
    }
  }
}