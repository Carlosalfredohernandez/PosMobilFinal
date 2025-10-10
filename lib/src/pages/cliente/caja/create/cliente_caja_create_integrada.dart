// pages/cliente/caja/create/cliente_caja_create_page_integrada.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:posmobil/src/models/boleta_sii.dart';
import 'package:posmobil/src/pages/cliente/caja/create/cliente_caja_create_controller.dart';
import 'package:posmobil/src/pages/cliente/caja/search/cliente_caja_search_page.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/providers/categorias_provider.dart';
import 'package:posmobil/src/services/pos_sii_service.dart';
// Importar modelos y servicios locales

import 'cliente_caja_create_controller.dart' hide CategoriasProvider;


// ========== FUNCIONES AUXILIARES PARA TU MODELO PRODUCTO ==========

/// Convertir tu modelo Producto al formato SII
Map<String, dynamic> productoToSIIFormat(Producto producto) {
  return {
    'codigo': producto.codigoBarra ?? '',
    'nombre': producto.nombreProducto ?? '',
    'cantidad': producto.cantidad ?? 1,
    'precio': int.tryParse(producto.precioVenta ?? '0') ?? 0,
  };
}

/// Calcular subtotal de un producto
int calcularSubtotalProducto(Producto producto) {
  final precio = int.tryParse(producto.precioVenta ?? '0') ?? 0;
  final cantidad = producto.cantidad ?? 1;
  return precio * cantidad;
}

/// Validar si un producto es válido para SII
bool esProductoValidoParaSII(Producto producto) {
  return (producto.nombreProducto?.isNotEmpty ?? false) && 
         (producto.precioVenta?.isNotEmpty ?? false) &&
         (producto.cantidad != null && producto.cantidad! > 0);
}
// Nuevos imports para funcionalidades avanzadas - COMENTADOS HASTA AGREGAR AL PUBSPEC.YAML
/*
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// Import condicional para web
import 'dart:html' as html show Blob, Url, document, AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;
*/

class ClienteCajaCreatePageIntegrada extends StatefulWidget {
  @override
  State<ClienteCajaCreatePageIntegrada> createState() => _ClienteCajaCreatePageIntegradaState();
}

class _ClienteCajaCreatePageIntegradaState extends State<ClienteCajaCreatePageIntegrada> {
  final ClienteCajaCreateController controlador = Get.put(ClienteCajaCreateController());
  final TextEditingController efectivoController = TextEditingController();
  
  // Nuevos controladores para datos SII
  final TextEditingController rutClienteController = TextEditingController();
  final TextEditingController nombreClienteController = TextEditingController();
  final TextEditingController direccionClienteController = TextEditingController();
  final TextEditingController comunaClienteController = TextEditingController();
  
  bool mostrarEfectivo = false;
  bool mostrarDatosCliente = false;
  bool generandoBoletaSII = false;
  BoletaSII? ultimaBoletaSII;

  void _resetPage() {
    controlador.selectedProducts.clear();
    controlador.total.value = 0;
    controlador.pago.value = 0;
    controlador.formaPago = '';
    controlador.codigoBarraController.clear();
    efectivoController.clear();
    
    // Limpiar campos SII
    rutClienteController.clear();
    nombreClienteController.clear();
    direccionClienteController.clear();
    comunaClienteController.clear();
    
    mostrarEfectivo = false;
    mostrarDatosCliente = false;
    generandoBoletaSII = false;
    ultimaBoletaSII = null;
    
    controlador.update();
    setState(() {});
  }

  Future<bool> _onWillPop() async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salir'),
        content: const Text('¿Desea salir de la aplicación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí'),
          ),
        ],
      ),
    );
    if (salir == true) {
      exit(0);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Obx(() => Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(child: _campoCodigoBarra()),
              _iconSearch(context),
            ],
          ),
          actions: [
            _iconScanMobile(context),
            // Nuevo botón para ver última boleta SII
            if (ultimaBoletaSII != null)
              IconButton(
                icon: const Icon(Icons.receipt_long, color: Colors.green),
                tooltip: 'Ver última boleta SII',
                onPressed: () => _mostrarUltimaBoletaSII(),
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: controlador.selectedProducts.isNotEmpty
                  ? ListView(
                      children: controlador.selectedProducts
                          .where((product) => product != null)
                          .map((Producto product) => _cardProduct(product))
                          .toList(),
                    )
                  : const Center(child: Text('No hay ningun producto agregado aun')),
            ),
            _footerVenta(context),
          ],
        ),
      )),
    );
  }

  Widget _footerVenta(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'TOTAL: \$${controlador.total.value}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Mostrar loading de boleta SII
            if (generandoBoletaSII)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Generando boleta electrónica SII...',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Mostrar datos del cliente si están expandidos
            if (mostrarDatosCliente) _seccionDatosCliente(),
            
            if (!mostrarEfectivo && !generandoBoletaSII) Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _onEfectivoPressed(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Efectivo + Boleta SII', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _onTarjetaPressed(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Tarjeta + Boleta SII', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
            
            if (mostrarEfectivo && !generandoBoletaSII) Column(
              children: [
                const SizedBox(height: 8),
                TextField(
                  controller: efectivoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Monto recibido',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _onGenerarBoletaSII(context, 'EFECTIVO'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Generar Boleta SII', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Vuelto: \$${_calcularVuelto()}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          mostrarEfectivo = false;
                          mostrarDatosCliente = false;
                          efectivoController.clear();
                        });
                      },
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _seccionDatosCliente() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Datos del Cliente (SII)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    mostrarDatosCliente = false;
                  });
                },
                icon: const Icon(Icons.keyboard_arrow_up),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: rutClienteController,
                  decoration: const InputDecoration(
                    labelText: 'RUT Cliente',
                    hintText: '12345678-9',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: nombreClienteController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: direccionClienteController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: comunaClienteController,
                  decoration: const InputDecoration(
                    labelText: 'Comuna',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onEfectivoPressed() {
    setState(() {
      mostrarEfectivo = true;
      mostrarDatosCliente = true;
    });
  }

  void _onTarjetaPressed(BuildContext context) async {
    final respuesta = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Pago con Tarjeta'),
        content: const Text('¿El pago con tarjeta fue exitoso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí'),
          ),
        ],
      ),
    );
    
    if (respuesta == true) {
      setState(() {
        mostrarDatosCliente = true;
      });
      
      // Esperar un momento para que se muestre la UI de datos del cliente
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Proceder con la generación de boleta SII
      await _onGenerarBoletaSII(context, 'TARJETA');
    }
  }

  Future<void> _onGenerarBoletaSII(BuildContext context, String metodoPago) async {
    // Validaciones básicas
    if (controlador.selectedProducts.isEmpty) {
      _mostrarError('No hay productos en la venta');
      return;
    }

    if (metodoPago == 'EFECTIVO') {
      final montoRecibido = int.tryParse(efectivoController.text) ?? 0;
      if (montoRecibido < controlador.total.value) {
        _mostrarError('El monto recibido es insuficiente');
        return;
      }
    }

    setState(() {
      generandoBoletaSII = true;
    });

    try {
      // 1. Preparar datos de la venta
      final ventaId = POSSIIService.generarVentaId();
      
      // 2. Preparar datos del cliente (usar valores por defecto si están vacíos)
      final cliente = {
        'rut': rutClienteController.text.trim().isNotEmpty 
            ? rutClienteController.text.trim() 
            : '66666666-6', // RUT genérico
        'nombre': nombreClienteController.text.trim().isNotEmpty 
            ? nombreClienteController.text.trim() 
            : 'Cliente Sin Nombre',
        'direccion': direccionClienteController.text.trim().isNotEmpty 
            ? direccionClienteController.text.trim() 
            : 'Sin Dirección',
        'comuna': comunaClienteController.text.trim().isNotEmpty 
            ? comunaClienteController.text.trim() 
            : 'Sin Comuna',
      };

      // 3. Preparar items usando tu modelo Producto original con TU estructura
      final items = controlador.selectedProducts.map((producto) {
        return productoToSIIFormat(producto);
      }).toList();

      // 4. Calcular totales
      final totales = POSSIIService.calcularTotales(items);

      // 5. Llamar al servicio SII
      final resultado = await POSSIIService.procesarVentaPOS(
        ventaId: ventaId,
        cliente: cliente,
        items: items,
        totales: totales,
        vendedor: controlador.sesionUsuario.nombre ?? 'Vendedor',
        sucursal: 'Local Principal', // Puedes hacer esto configurable
        metodoPago: metodoPago,
      );

      setState(() {
        generandoBoletaSII = false;
      });

      if (resultado['success']) {
        // 6. Guardar boleta SII
        ultimaBoletaSII = BoletaSII.fromJson(resultado);
        
        // 7. Guardar venta local (tu lógica original)
        controlador.formaPago = metodoPago;
        if (metodoPago == 'EFECTIVO') {
          controlador.pago.value = (int.tryParse(efectivoController.text) ?? 0).toDouble();
        }
        
        // Agregar datos SII a la venta local
        await _guardarVentaLocalConSII(ventaId, ultimaBoletaSII!);
        
        // 8. Mostrar éxito
        await _mostrarExitoBoletaSII(ultimaBoletaSII!);
        
        // 9. Reset página
        _resetPage();
        
      } else {
        // Error generando boleta SII
        await _mostrarErrorSII(resultado['message'], resultado['error']);
        
        // Aún así guardar venta local sin SII
        controlador.formaPago = metodoPago;
        if (metodoPago == 'EFECTIVO') {
          controlador.pago.value = (int.tryParse(efectivoController.text) ?? 0).toDouble();
        }
        await controlador.createBill(context);
        _resetPage();
      }

    } catch (e) {
      setState(() {
        generandoBoletaSII = false;
      });
      
      print('Error inesperado: $e');
      await _mostrarErrorSII('Error inesperado', e.toString());
      
      // Guardar venta local sin SII
      controlador.formaPago = metodoPago;
      if (metodoPago == 'EFECTIVO') {
        controlador.pago.value = (int.tryParse(efectivoController.text) ?? 0).toDouble();
      }
      await controlador.createBill(context);
      _resetPage();
    }
  }

  Future<void> _guardarVentaLocalConSII(String ventaId, BoletaSII boletaSII) async {
    // Aquí puedes extender tu controlador para guardar datos SII
    // Por ejemplo, agregar campos a tu modelo de venta local:
    /*
    final ventaConSII = {
      ...ventaLocal,
      'ventaIdSII': ventaId,
      'boletaElectronicaId': boletaSII.id,
      'folioSII': boletaSII.folio,
      'trackId': boletaSII.trackId,
      'estadoSII': boletaSII.estado,
      'fechaGeneracionSII': boletaSII.fechaGeneracion.toIso8601String(),
    };
    */
    
    // Por ahora, usar tu método original
    await controlador.createBill(context);
  }

  Future<void> _mostrarExitoBoletaSII(BoletaSII boleta) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 30),
            const SizedBox(width: 12),
            const Text('Boleta SII Generada'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ Boleta electrónica oficial del SII generada exitosamente'),
            const SizedBox(height: 12),
            Text('🏷️ Folio SII: ${boleta.folio}', 
                 style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('📄 ID: ${boleta.id}'),
            Text('📊 Estado: ${boleta.estado}'),
            Text('💰 Total: \$${boleta.datosFacturacion.montoTotal}'),
            Text('👤 Cliente: ${boleta.datosFacturacion.razonSocialReceptor}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _mostrarOpcionesBoletaSII(boleta);
            },
            child: const Text('Ver Opciones'),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarErrorSII(String mensaje, String? error) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange, size: 30),
            const SizedBox(width: 12),
            const Text('Aviso Boleta SII'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⚠️ La venta se guardó localmente, pero hubo un problema con la boleta electrónica SII:'),
            const SizedBox(height: 12),
            Text('Mensaje: $mensaje'),
            if (error != null) Text('Error: $error'),
            const SizedBox(height: 12),
            const Text('✅ Puedes continuar vendiendo normalmente. '
                      'Las boletas SII se pueden generar más tarde.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _mostrarUltimaBoletaSII() {
    if (ultimaBoletaSII != null) {
      _mostrarOpcionesBoletaSII(ultimaBoletaSII!);
    }
  }

  void _mostrarOpcionesBoletaSII(BoletaSII boleta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.receipt_long, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(child: Text('Boleta SII ${boleta.folio}')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Estado actual
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getEstadoColor(boleta.estado),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(_getEstadoIcon(boleta.estado), color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Estado: ${boleta.estado}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Opciones principales
              _opcionBoletaItem(
                icon: Icons.download,
                title: 'Descargar XML',
                subtitle: 'XML firmado oficial del SII',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  _descargarXML(boleta);
                },
              ),
              
              _opcionBoletaItem(
                icon: Icons.picture_as_pdf,
                title: 'Generar PDF 58mm',
                subtitle: 'PDF optimizado para impresora térmica',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  _generarPDF58mm(boleta);
                },
              ),
              
              _opcionBoletaItem(
                icon: Icons.print,
                title: 'Imprimir Boleta',
                subtitle: 'Enviar a impresora conectada',
                color: Colors.purple,
                onTap: () {
                  Navigator.pop(context);
                  _imprimirBoleta(boleta);
                },
              ),
              
              _opcionBoletaItem(
                icon: Icons.send,
                title: 'Enviar al SII',
                subtitle: 'Enviar boleta al SII para validación oficial',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  _enviarBoletaAlSII(boleta);
                },
              ),
              
              _opcionBoletaItem(
                icon: Icons.visibility,
                title: 'Ver Detalles Completos',
                subtitle: 'Información completa de la boleta',
                color: Colors.teal,
                onTap: () {
                  Navigator.pop(context);
                  _mostrarDetallesCompletos(boleta);
                },
              ),
              
              _opcionBoletaItem(
                icon: Icons.share,
                title: 'Compartir',
                subtitle: 'Compartir información de la boleta',
                color: Colors.indigo,
                onTap: () {
                  Navigator.pop(context);
                  _compartirBoleta(boleta);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _opcionBoletaItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE': return Colors.orange;
      case 'ENVIADO': return Colors.blue;
      case 'ACEPTADO': return Colors.green;
      case 'RECHAZADO': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE': return Icons.pending;
      case 'ENVIADO': return Icons.send;
      case 'ACEPTADO': return Icons.check_circle;
      case 'RECHAZADO': return Icons.error;
      default: return Icons.info;
    }
  }

  Future<void> _enviarBoletaAlSII(BoletaSII boleta) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Enviando al SII...'),
          ],
        ),
      ),
    );

    try {
      final resultado = await POSSIIService.enviarBoletaAlSII(boleta.id);
      Navigator.pop(context); // Cerrar loading

      if (resultado['success']) {
        _mostrarInfo('✅ Boleta enviada al SII exitosamente');
      } else {
        _mostrarError('❌ Error enviando al SII: ${resultado['message']}');
      }
    } catch (e) {
      Navigator.pop(context); // Cerrar loading
      _mostrarError('❌ Error enviando al SII: $e');
    }
  }

  void _mostrarDetallesBoleta(BoletaSII boleta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Boleta SII ${boleta.folio}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detalleItem('ID Boleta', boleta.id),
              _detalleItem('Folio SII', boleta.folio.toString()),
              _detalleItem('Estado', boleta.estado),
              _detalleItem('Track ID', boleta.trackId),
              _detalleItem('Fecha', boleta.fechaGeneracion.toString()),
              const Divider(),
              const Text('Datos de Facturación:', style: TextStyle(fontWeight: FontWeight.bold)),
              _detalleItem('Emisor', '${boleta.datosFacturacion.razonSocialEmisor} (${boleta.datosFacturacion.rutEmisor})'),
              _detalleItem('Receptor', '${boleta.datosFacturacion.razonSocialReceptor} (${boleta.datosFacturacion.rutReceptor})'),
              _detalleItem('Total', '\$${boleta.datosFacturacion.montoTotal}'),
              _detalleItem('Neto', '\$${boleta.datosFacturacion.montoNeto}'),
              _detalleItem('IVA', '\$${boleta.datosFacturacion.iva}'),
              const Divider(),
              const Text('Metadata POS:', style: TextStyle(fontWeight: FontWeight.bold)),
              _detalleItem('Vendedor', boleta.metadata.vendedor),
              _detalleItem('Sucursal', boleta.metadata.sucursal),
              _detalleItem('Método Pago', boleta.metadata.metodoPago),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _detalleItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _mostrarInfo(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.blue,
      ),
    );
  }

int _calcularVuelto() {
  final recibido = int.tryParse(efectivoController.text) ?? 0;
  final total = (controlador.total.value is int)
      ? controlador.total.value
      : (controlador.total.value is double)
          ? (controlador.total.value as double).toInt()
          : 0;
   return (recibido - total).toInt();
}

  // Resto de métodos sin cambios...
  Widget _iconScanMobile(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
      tooltip: 'Escanear código',
      onPressed: () async {
        final barcode = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (_) => _BarcodeScannerView()),
        );
        if (barcode != null && barcode.isNotEmpty) {
          controlador.codigoBarraController.text = barcode;
          await controlador.code(context);
          controlador.codigoBarraController.clear();
          controlador.update();
          setState(() {});
        }
      },
    );
  }

  Widget _iconSearch(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final Producto? productoSeleccionado = await showSearch(
          context: context, 
          delegate: ClienteCajaSearchPage(controlador.productos)
        );
        
        if (productoSeleccionado != null && productoSeleccionado.id != null) {
          // Agregar el producto seleccionado al carrito
          controlador.addItem(productoSeleccionado);
          controlador.update();
          setState(() {});
          print('✅ Producto agregado desde search: ${productoSeleccionado.nombreProducto}');
        }
      },
      icon: const Icon(
        Icons.search,
        color: Colors.black,
        size: 20,
      ),
      tooltip: 'Buscar producto',
    );
  }

  Widget _campoCodigoBarra() {
    return Container(
      margin: const EdgeInsets.only(left: 10, top: 5, right: 10),
      child: SizedBox(
        width: 180.0,
        height: 40.0,
        child: TextField(
          controller: controlador.codigoBarraController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Codigo de barra',
              suffixIcon: IconButton(
                onPressed: () async {
                  controlador.codigoBarraController.text = controlador.codigoBarraController.text.trim();
                  await controlador.code(context);
                  controlador.codigoBarraController.clear();
                  controlador.update();
                  setState(() {});
                },
                icon: const Icon(Icons.search),
              ),
              hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.black
              ),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                      color: Colors.grey
                  )
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                      color: Colors.grey
                  )
              ),
              contentPadding: const EdgeInsets.all(7)
          ),
        ),
      ),
    );
  }

  Widget _cardProduct(Producto product) {
    final nombre = product.nombreProducto ?? '';
    final precioVenta = int.tryParse(product.precioVenta ?? '0') ?? 0;
    final cantidad = product.cantidad ?? 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          const SizedBox(width: 5),
          Container(
            width: MediaQuery.of(context).size.height * 0.13,
            child: Text(
              nombre.isNotEmpty
                ? (nombre.length > 30 ? nombre.substring(0, 30) : nombre)
                : '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const Spacer(),
          Container(
            width: MediaQuery.of(context).size.height * 0.11,
            child: _buttonsAddOrRemove(product),
          ),
          const Spacer(),
          Container(
            width: MediaQuery.of(context).size.height * 0.05,
            child: Text(
              product.precioVenta ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const Spacer(),
          Container(
            width: MediaQuery.of(context).size.height * 0.05,
            child: Text(
              '${precioVenta * cantidad}',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ),
          const Spacer(),
          Container(
            width: MediaQuery.of(context).size.height * 0.04,
            child: _iconDelete(product),
          ),
        ],
      ),
    );
  }

  Widget _iconDelete(Producto product) {
    return IconButton(
        onPressed: () => controlador.deleteItem(product),
        icon: const Icon(
          Icons.delete,
          color: Colors.red,
        )
    );
  }

  Widget _buttonsAddOrRemove(Producto product) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => controlador.removeItem(product),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: const Text('-'),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          color: Colors.grey[200],
          child: Text('${product.cantidad ?? 0}'),
        ),
        GestureDetector(
          onTap: () => controlador.addItem(product),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: const Text('+'),
          ),
        ),
      ],
    );
  }
  
  // =================== PLACEHOLDERS PARA FUNCIONALIDADES AVANZADAS ===================
  // Estos métodos muestran mensaje informativo hasta instalar dependencias
  
  Future<void> _descargarXML(BoletaSII boleta) async {
    _mostrarInfo('⚠️ Descarga XML disponible después de instalar dependencias. Ver DEPENDENCIAS_REQUERIDAS.md');
  }
  
  Future<void> _generarPDF58mm(BoletaSII boleta) async {
    _mostrarInfo('⚠️ Generación PDF disponible después de instalar dependencias. Ver DEPENDENCIAS_REQUERIDAS.md');
  }
  
  Future<void> _imprimirBoleta(BoletaSII boleta) async {
    _mostrarInfo('⚠️ Impresión disponible después de instalar dependencias. Ver DEPENDENCIAS_REQUERIDAS.md');
  }
  
  Future<void> _compartirBoleta(BoletaSII boleta) async {
    _mostrarInfo('⚠️ Compartir disponible después de instalar dependencias. Ver DEPENDENCIAS_REQUERIDAS.md');
  }
  
  Future<void> _mostrarDetallesCompletos(BoletaSII boleta) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles Completos - Boleta ${boleta.folio}'),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detalleItemCompleto('ID', boleta.id),
                _detalleItemCompleto('Folio', boleta.folio.toString()),
                _detalleItemCompleto('Estado', boleta.estado),
                _detalleItemCompleto('Track ID', boleta.trackId),
                _detalleItemCompleto('Fecha Generación', _formatearFechaCompleta(boleta.fechaGeneracion)),
                _detalleItemCompleto('Total', '\$${boleta.total.toStringAsFixed(0)}'),
                
                const SizedBox(height: 16),
                const Text('Datos de Facturación:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _detalleItemCompleto('Emisor', '${boleta.datosFacturacion.razonSocialEmisor} (${boleta.datosFacturacion.rutEmisor})'),
                _detalleItemCompleto('Receptor', '${boleta.datosFacturacion.razonSocialReceptor} (${boleta.datosFacturacion.rutReceptor})'),
                _detalleItemCompleto('Monto Total', '\$${boleta.datosFacturacion.montoTotal}'),
                _detalleItemCompleto('Monto Neto', '\$${boleta.datosFacturacion.montoNeto}'),
                _detalleItemCompleto('IVA', '\$${boleta.datosFacturacion.iva}'),
                
                const SizedBox(height: 16),
                const Text('Metadata POS:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _detalleItemCompleto('Vendedor', boleta.metadata.vendedor),
                _detalleItemCompleto('Sucursal', boleta.metadata.sucursal),
                _detalleItemCompleto('Método Pago', boleta.metadata.metodoPago),
                
                const SizedBox(height: 16),
                const Text('Productos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                
                ...boleta.productos.map((producto) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Código: ${producto.codigo}'),
                      Text('Cantidad: ${producto.cantidad}'),
                      Text('Precio Unitario: \$${producto.precio.toStringAsFixed(0)}'),
                      Text('Subtotal: \$${(producto.cantidad * producto.precio).toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
  
  Widget _detalleItemCompleto(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  String _formatearFechaCompleta(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }
  
  void _mostrarCargando(String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(mensaje)),
          ],
        ),
      ),
    );
  }
}

// Vista de escaneo con mobile_scanner (sin cambios)
class _BarcodeScannerView extends StatefulWidget {
  @override
  State<_BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<_BarcodeScannerView> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    final controlador = Get.find<ClienteCajaCreateController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear código')),
      body: MobileScanner(
        onDetect: (capture) async {
          if (_scanned) return;
          final barcode = capture.barcodes.first;
          final String? code = barcode.rawValue;
          if (code != null && code.isNotEmpty) {
            _scanned = true;
            await controlador.scanBarcodeMobileScanner(
              code,
              context,
              (barcode) async {
                await _showProductoNoExisteDialog(context, barcode);
              },
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) Navigator.pop(context, code);
            });
          }
        },
      ),
    );
  }

  Future<void> _showProductoNoExisteDialog(BuildContext context, String barcode) async {
    final respuesta = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Producto no existe'),
        content: const Text('¿Desea crear este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí'),
          ),
        ],
      ),
    );

    if (respuesta == true) {
      await showDialog(
        context: context,
        builder: (context) => _CrearProductoDialog(barcode: barcode),
      );
    }
  }
}

class _CrearProductoDialog extends StatefulWidget {
  final String barcode;
  const _CrearProductoDialog({required this.barcode});

  @override
  State<_CrearProductoDialog> createState() => _CrearProductoDialogState();
}

class _CrearProductoDialogState extends State<_CrearProductoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  String? _categoriaSeleccionada;
  List<dynamic> _categorias = [];

  @override
  void initState() {
    super.initState();
    _loadCategorias();
  }

  Future<void> _loadCategorias() async {
    final categoriasProvider = CategoriasProvider();
    final categorias = await categoriasProvider.getAllByUser();
    setState(() {
      _categorias = categorias;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear nuevo producto'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Código de barras: ${widget.barcode}'),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese un nombre' : null,
              ),
              TextFormField(
                enabled: false,
                controller: TextEditingController(text: _nombreController.text),
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Ingrese un precio' : null,
              ),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: _categorias.map<DropdownMenuItem<String>>((cat) {
                  return DropdownMenuItem<String>(
                    value: cat.id,
                    child: Text(cat.nombreCategoria ?? ''),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaSeleccionada = value;
                  });
                },
                validator: (value) => value == null ? 'Seleccione una categoría' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final controlador = Get.find<ClienteCajaCreateController>();
              final producto = Producto(
                codigoBarra: widget.barcode,
                nombreProducto: _nombreController.text.trim(),
                descripcionProducto: _nombreController.text.trim(),
                precioVenta: _precioController.text.trim(),
                precioCosto: "0",
                proveedor: "0",
                categoria: _categoriaSeleccionada,
                usuario: controlador.sesionUsuario.id.toString(),
              );
              await controlador.productosProvider.create(producto);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Producto creado exitosamente'))
              );
            }
          },
          child: const Text('Crear'),
        ),
      ],
    );
  }

  // =================== MÉTODOS AVANZADOS PARA BOLETAS SII ===================
  // NOTA: Estos métodos requieren las dependencias del pubspec.yaml
  // Descomenta cuando agregues: http, path_provider, share_plus, printing, pdf
  
  /*
  Future<void> _descargarXML(BoletaSII boleta) async {
    try {
      _mostrarCargando('Descargando XML...');
      
      final response = await http.get(
        Uri.parse('http://192.168.1.88:3000/api/pos/boleta/${boleta.id}/xml'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final fileName = 'boleta_${boleta.folio}_${DateTime.now().millisecondsSinceEpoch}.xml';
        
        if (kIsWeb) {
          // Para web, descargar directamente
          final bytes = response.bodyBytes;
          final blob = html.Blob([bytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.document.createElement('a') as html.AnchorElement
            ..href = url
            ..style.display = 'none'
            ..download = fileName;
          html.document.body!.children.add(anchor);
          anchor.click();
          html.document.body!.children.remove(anchor);
          html.Url.revokeObjectUrl(url);
        } else {
          // Para móvil, guardar en directorio de documentos
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/$fileName');
          await file.writeAsBytes(response.bodyBytes);
          
          await Share.shareXFiles(
            [XFile(file.path)],
            text: 'XML Boleta SII ${boleta.folio}',
          );
        }
        
        _mostrarExito('XML descargado exitosamente');
      } else {
        _mostrarError('Error al descargar XML: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarError('Error de conexión al descargar XML: ${e.toString()}');
    } finally {
      Navigator.pop(context); // Cerrar loading
    }
  }

  Future<void> _generarPDF58mm(BoletaSII boleta) async {
    try {
      _mostrarCargando('Generando PDF 58mm...');
      
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: const PdfPageFormat(58 * PdfPageFormat.mm, double.infinity),
          margin: const pw.EdgeInsets.all(2 * PdfPageFormat.mm),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header empresa
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text('TECNOALSA CHILE SPA', 
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text('RUT: 77.710.916-2', style: const pw.TextStyle(fontSize: 6)),
                      pw.Text('Dirección de Empresa', style: const pw.TextStyle(fontSize: 6)),
                      pw.SizedBox(height: 2),
                    ],
                  ),
                ),
                
                // Línea separadora
                pw.Divider(thickness: 1),
                
                // Información boleta
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text('BOLETA ELECTRÓNICA', 
                        style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                      pw.Text('N° ${boleta.folio}', 
                        style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                    ],
                  ),
                ),
                
                // Fecha y hora
                pw.Text('Fecha: ${_formatearFecha(boleta.fechaGeneracion)}', 
                  style: const pw.TextStyle(fontSize: 6)),
                pw.Text('Hora: ${_formatearHora(boleta.fechaGeneracion)}', 
                  style: const pw.TextStyle(fontSize: 6)),
                pw.SizedBox(height: 2),
                
                pw.Divider(thickness: 1),
                
                // Productos
                pw.Text('DETALLE:', style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 1),
                
                ...boleta.productos.map((producto) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text('${producto.nombre}', 
                        style: const pw.TextStyle(fontSize: 5)),
                    ),
                    pw.Text('${producto.cantidad}x', 
                      style: const pw.TextStyle(fontSize: 5)),
                    pw.Text('\$${producto.precio.toStringAsFixed(0)}', 
                      style: const pw.TextStyle(fontSize: 5)),
                  ],
                )),
                
                pw.SizedBox(height: 2),
                pw.Divider(thickness: 1),
                
                // Totales
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL:', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                    pw.Text('\$${boleta.total.toStringAsFixed(0)}', 
                      style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                
                pw.SizedBox(height: 2),
                pw.Divider(thickness: 1),
                
                // Footer
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text('Gracias por su compra', 
                        style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 1),
                      pw.Text('Estado SII: ${boleta.estado}', 
                        style: const pw.TextStyle(fontSize: 5)),
                      pw.Text('Generado: ${DateTime.now().toString().substring(0, 19)}', 
                        style: const pw.TextStyle(fontSize: 4)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
      
      final output = await pdf.save();
      final fileName = 'boleta_${boleta.folio}_58mm_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      if (kIsWeb) {
        // Para web
        final blob = html.Blob([output], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = fileName;
        html.document.body!.children.add(anchor);
        anchor.click();
        html.document.body!.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      } else {
        // Para móvil
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(output);
        
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Boleta SII ${boleta.folio} - PDF 58mm',
        );
      }
      
      _mostrarExito('PDF 58mm generado exitosamente');
    } catch (e) {
      _mostrarError('Error al generar PDF: ${e.toString()}');
    } finally {
      Navigator.pop(context);
    }
  }

  Future<void> _imprimirBoleta(BoletaSII boleta) async {
    try {
      _mostrarCargando('Preparando impresión...');
      
      // Generar PDF para impresión
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: const PdfPageFormat(58 * PdfPageFormat.mm, double.infinity),
          margin: const pw.EdgeInsets.all(2 * PdfPageFormat.mm),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header más simple para impresión térmica
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text('TECNOALSA CHILE SPA', 
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('RUT: 77.710.916-2', style: const pw.TextStyle(fontSize: 7)),
                      pw.Text('BOLETA N° ${boleta.folio}', 
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 3),
                    ],
                  ),
                ),
                
                pw.Text('${_formatearFecha(boleta.fechaGeneracion)} ${_formatearHora(boleta.fechaGeneracion)}', 
                  style: const pw.TextStyle(fontSize: 6)),
                pw.SizedBox(height: 2),
                
                // Productos simplificados
                ...boleta.productos.map((producto) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('${producto.nombre}', style: const pw.TextStyle(fontSize: 6)),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('${producto.cantidad} x \$${producto.precio.toStringAsFixed(0)}', 
                          style: const pw.TextStyle(fontSize: 6)),
                        pw.Text('\$${(producto.cantidad * producto.precio).toStringAsFixed(0)}', 
                          style: const pw.TextStyle(fontSize: 6)),
                      ],
                    ),
                    pw.SizedBox(height: 1),
                  ],
                )),
                
                pw.Divider(thickness: 1),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.Text('\$${boleta.total.toStringAsFixed(0)}', 
                      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 3),
                pw.Center(child: pw.Text('¡Gracias por su compra!', style: const pw.TextStyle(fontSize: 6))),
              ],
            );
          },
        ),
      );
      
      // Imprimir
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) => pdf.save(),
        name: 'Boleta_${boleta.folio}',
        format: const PdfPageFormat(58 * PdfPageFormat.mm, double.infinity),
      );
      
      _mostrarExito('Boleta enviada a impresora');
    } catch (e) {
      _mostrarError('Error al imprimir: ${e.toString()}');
    } finally {
      Navigator.pop(context);
    }
  }

  void _mostrarDetallesCompletos(BoletaSII boleta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles Completos - Boleta ${boleta.folio}'),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detalleItem('ID', boleta.id),
                _detalleItem('Folio', boleta.folio.toString()),
                _detalleItem('Estado', boleta.estado),
                _detalleItem('Track ID', boleta.trackId),
                _detalleItem('Fecha Generación', _formatearFechaCompleta(boleta.fechaGeneracion)),
                _detalleItem('Total', '\$${boleta.total.toStringAsFixed(0)}'),
                
                const SizedBox(height: 16),
                Text('Productos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                
                ...boleta.productos.map((producto) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Cantidad: ${producto.cantidad}'),
                      Text('Precio Unitario: \$${producto.precio.toStringAsFixed(0)}'),
                      Text('Subtotal: \$${(producto.cantidad * producto.precio).toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _compartirBoleta(BoletaSII boleta) async {
    try {
      final texto = '''
🧾 BOLETA ELECTRÓNICA SII

📋 Folio: ${boleta.folio}
📅 Fecha: ${_formatearFechaCompleta(boleta.fechaGeneracion)}
🏢 Empresa: TECNOALSA CHILE SPA
🆔 RUT: 77.710.916-2

💰 TOTAL: \$${boleta.total.toStringAsFixed(0)}
📊 Estado SII: ${boleta.estado}

🛍️ PRODUCTOS:
${boleta.productos.map((p) => '• ${p.nombre} (${p.cantidad}x) - \$${(p.cantidad * p.precio).toStringAsFixed(0)}').join('\n')}

Generado desde POS Móvil TECNOALSA
      ''';
      
      await Share.share(
        texto,
        subject: 'Boleta SII ${boleta.folio} - TECNOALSA',
      );
    } catch (e) {
      _mostrarError('Error al compartir: ${e.toString()}');
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  String _formatearHora(DateTime fecha) {
    return '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  String _formatearFechaCompleta(DateTime fecha) {
    return '${_formatearFecha(fecha)} ${_formatearHora(fecha)}';
  }

  void _mostrarCargando(String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(mensaje)),
          ],
        ),
      ),
    );
  }

  Widget _detalleItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  */
  
  // Placeholder para funcionalidades avanzadas
  Future<void> _descargarXML(BoletaSII boleta) async {
    print('⚠️ Funcionalidad disponible después de instalar dependencias. Ver DEPENDENCIAS_REQUERIDAS.md');
  }
  
  Future<void> _generarPDF58mm(BoletaSII boleta) async {
    print('⚠️ Funcionalidad disponible después de instalar dependencias. Ver DEPENDENCIAS_REQUERIDAS.md');
  }
  
  Future<void> _imprimirBoleta(BoletaSII boleta) async {
    print('⚠️ Funcionalidad disponible después de instalar dependencias. Ver DEPENDENCIAS_REQUERIDAS.md');
  }
  
  Future<void> _compartirBoleta(BoletaSII boleta) async {
    print('⚠️ Funcionalidad disponible después de instalar dependencias. Ver DEPENDENCIAS_REQUERIDAS.md');
  }
  
  void _mostrarCargando(String mensaje) {
    print('Cargando: $mensaje');
  }
}