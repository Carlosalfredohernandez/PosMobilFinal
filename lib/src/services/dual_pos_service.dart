// services/dual_pos_service.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../environment/environment.dart';
import '../models/producto.dart';

/// 🔄 SERVICIO DUAL PARA MANEJO DE POS - DESHABILITADO
/// 
/// ⚠️ ESTE SERVICIO YA NO SE USA - Se mantiene por compatibilidad
/// La aplicación ahora usa la arquitectura simplificada con un solo backend
class DualPOSService extends GetConnect {
  
  // 🏪 Cliente HTTP para Backend Local (Puerto 4400)
  GetConnect get localAPI => GetConnect(
    timeout: const Duration(seconds: 30),
  );
  
  // 🏛️ Cliente HTTP para Backend SII (Puerto 3000) - DESHABILITADO
  GetConnect get siiAPI => GetConnect(
    timeout: const Duration(seconds: 30),
  );

  @override
  void onInit() {
    super.onInit();
    
    // Configurar headers por defecto para Backend Local
    localAPI.httpClient.addRequestModifier<Object?>((request) {
      request.headers['Content-Type'] = 'application/json';
      return request;
    });
    
    // Configurar headers por defecto para Backend SII
    siiAPI.httpClient.addRequestModifier<Object?>((request) {
      request.headers['Content-Type'] = 'application/json';
      return request;
    });
    
    print('🔄 DualPOSService inicializado - MODO DESHABILITADO');
    print('� Backend: ${Environment.API_URL}');
  }

  /// 📦 OBTENER PRODUCTOS (Backend Local) - SIMPLIFICADO
  Future<List<Producto>> getProductos() async {
    try {
      print('📦 Obteniendo productos desde Backend...');
      
      final response = await localAPI.get(
        '${Environment.API_URL}api/productos/getAllByUser/1'
      );
      
      if (response.statusCode == 200) {
        final List<Producto> productos = Producto.fromJsonList(response.body);
        print('✅ ${productos.length} productos obtenidos');
        return productos;
      } else {
        print('❌ Error obteniendo productos: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error de conexión productos: $e');
      return [];
    }
  }

  /// 🔍 BUSCAR PRODUCTO POR CÓDIGO (Backend Local) - SIMPLIFICADO
  Future<Producto?> buscarProducto(String codigo) async {
    try {
      print('🔍 Buscando producto: $codigo');
      
      final response = await localAPI.get(
        '${Environment.API_URL}api/productos/findByCode/$codigo'
      );
      
      if (response.statusCode == 200 && response.body != null) {
        final producto = Producto.fromJson(response.body);
        print('✅ Producto encontrado: ${producto.nombreProducto}');
        return producto;
      } else {
        print('❌ Producto no encontrado: $codigo');
        return null;
      }
    } catch (e) {
      print('❌ Error buscando producto: $e');
      return null;
    }
  }

  /// 💾 CREAR BOLETA - SIMPLIFICADO (Solo Backend Local)
  Future<Map<String, dynamic>> crearBoletaDual({
    required List<Producto> productos,
    required double total,
    required String formaPago,
    String? rutCliente,
  }) async {
    
    try {
      print('💾 Creando boleta simplificada...');
      
      // Solo crear boleta en Backend Local
      final boletaLocal = await _crearBoletaLocal(
        productos: productos,
        total: total,
        formaPago: formaPago,
        rutCliente: rutCliente,
      );
      
      if (!boletaLocal['success']) {
        return {
          'success': false,
          'error': 'Error en Backend: ${boletaLocal['error']}',
        };
      }
      
      print('✅ Boleta creada: ${boletaLocal['boletaId']}');
      
      return {
        'success': true,
        'boletaLocalId': boletaLocal['boletaId'],
        'message': 'Boleta creada exitosamente'
      };
      
    } catch (e) {
      print('❌ Error general en boleta: $e');
      return {
        'success': false,
        'error': 'Error interno: $e',
      };
    }
  }

  /// 🏪 CREAR BOLETA EN BACKEND - SIMPLIFICADO
  Future<Map<String, dynamic>> _crearBoletaLocal({
    required List<Producto> productos,
    required double total,
    required String formaPago,
    String? rutCliente,
  }) async {
    
    try {
      final boletaData = {
        'total': total,
        'formaPago': formaPago,
        'rutCliente': rutCliente,
        'productos': productos.map((p) => {
          'codigo': p.codigoBarra,
          'nombre': p.nombreProducto,
          'cantidad': p.cantidad,
          'precio': double.tryParse(p.precioVenta ?? '0') ?? 0.0,
          'subtotal': (double.tryParse(p.precioVenta ?? '0') ?? 0.0) * (p.cantidad ?? 1),
        }).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      final response = await localAPI.post(
        '${Environment.API_URL}api/boletas/create',
        boletaData,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'boletaId': response.body['id'] ?? response.body['boletaId'],
          'data': response.body,
        };
      } else {
        return {
          'success': false,
          'error': 'Status ${response.statusCode}: ${response.body}',
        };
      }
      
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión Backend: $e',
      };
    }
  }

  /// 🏛️ CREAR BOLETA EN BACKEND SII - DESHABILITADO
  /*
  Future<Map<String, dynamic>> _crearBoletaSII({
    required List<Producto> productos,
    required double total,
    required String empresaRut,
    required dynamic boletaLocalId,
  }) async {
    
    try {
      final siiData = {
        'empresaRut': empresaRut,
        'boletaLocalId': boletaLocalId,
        'productos': productos.map((p) => {
          'codigo': p.codigoBarra,
          'nombre': p.nombreProducto,
          'cantidad': p.cantidad,
          'precio': double.tryParse(p.precioVenta ?? '0') ?? 0.0,
        }).toList(),
        'total': total,
        'fecha': DateTime.now().toIso8601String(),
      };
      
      final response = await siiAPI.post(
        '${Environment.SII_BOLETAS_API}/boleta/create',
        siiData,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'xmlId': response.body['xmlId'] ?? response.body['id'],
          'xmlUrl': response.body['xmlUrl'],
          'data': response.body,
        };
      } else {
        return {
          'success': false,
          'error': 'SII Status ${response.statusCode}: ${response.body}',
        };
      }
      
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión Backend SII: $e',
      };
    }
  }
  */

  /// 📊 VERIFICAR CONECTIVIDAD - SIMPLIFICADO
  Future<Map<String, bool>> verificarConectividad() async {
    final resultado = <String, bool>{};
    
    try {
      // Test Backend
      final response = await localAPI.get('${Environment.API_URL}api/health');
      resultado['backend'] = response.statusCode == 200;
    } catch (e) {
      resultado['backend'] = false;
    }
    
    print('📊 Conectividad - Backend: ${resultado['backend']}');
    return resultado;
  }
}