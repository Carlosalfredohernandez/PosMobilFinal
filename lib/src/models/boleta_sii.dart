// models/boleta_sii.dart
// 📄 MODELOS DE DATOS PARA INTEGRACIÓN SII
// 
// Este archivo contiene los modelos de datos que representan las respuestas
// del backend SII cuando se genera una boleta electrónica oficial.
//
// 🔄 FLUJO DE DATOS:
// 1. POS envía datos de venta → Backend SII
// 2. Backend genera boleta oficial → Respuesta JSON
// 3. Estos modelos convierten JSON → Objetos Dart
//
// 📋 ESTRUCTURA DE RESPUESTA DEL BACKEND:
// {
//   "success": true,
//   "data": {
//     "boletaElectronica": { ... },
//     "urls": { ... },
//     "datosFacturacion": { ... },
//     "metadata": { ... }
//   }
// }

/// 🧾 CLASE PRINCIPAL: Boleta SII
/// 
/// Representa una boleta electrónica oficial generada por el backend SII
/// Contiene toda la información necesaria para:
/// - Mostrar al usuario los detalles de la boleta
/// - Descargar el XML oficial firmado
/// - Enviar la boleta al SII para validación
/// - Consultar el estado de la boleta
class BoletaSII {
  final String id;              // 🔑 ID único de la boleta en el backend
  final int folio;              // 📋 Folio oficial asignado por el SII (ej: 58, 59, 60...)
  final String trackId;         // 🔍 ID de seguimiento para consultas al SII
  final String estado;          // 📊 Estado: 'PENDIENTE', 'ENVIADO', 'ACEPTADO', 'RECHAZADO'
  final DateTime fechaGeneracion; // 📅 Fecha y hora de generación de la boleta
  final DateTime fechaEmision;  // 📅 Fecha de emisión para el PDF
  final String xmlUrl;          // 🔗 URL para descargar XML firmado oficial
  final String verBoletaUrl;    // 👁️ URL para ver la boleta en el navegador
  final String enviarSIIUrl;    // 📤 URL para enviar la boleta al SII
  final DatosFacturacion datosFacturacion; // 💰 Datos oficiales de facturación
  final MetadataPOS metadata;   // 📱 Metadatos del POS (vendedor, sucursal, etc.)
  final List<ProductoBoleta> productos; // 🛍️ Lista de productos de la boleta
  final double total;           // 💰 Total calculado de la boleta

  BoletaSII({
    required this.id,
    required this.folio,
    required this.trackId,
    required this.estado,
    required this.fechaGeneracion,
    required this.fechaEmision,
    required this.xmlUrl,
    required this.verBoletaUrl,
    required this.enviarSIIUrl,
    required this.datosFacturacion,
    required this.metadata,
    required this.productos,
    required this.total,
  });

  /// 🔄 FACTORY CONSTRUCTOR
  /// 
  /// Convierte la respuesta JSON del backend en un objeto BoletaSII
  /// 
  /// EJEMPLO DE USO:
  /// ```dart
  /// final response = await http.post('http://localhost:3000/api/pos/procesar-venta');
  /// final boleta = BoletaSII.fromJson(jsonDecode(response.body));
  /// print('Folio generado: ${boleta.folio}');
  /// ```
  factory BoletaSII.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final boletaElectronica = data['boletaElectronica'] ?? data;
    final urls = data['urls'] ?? {};
    final datosFacturacion = data['datosFacturacion'] ?? {};
    final metadata = data['metadata'] ?? {};
    final productos = data['productos'] ?? [];

    return BoletaSII(
      id: boletaElectronica['id'] ?? '',
      folio: boletaElectronica['folio'] ?? 0,
      trackId: boletaElectronica['trackId'] ?? '',
      estado: boletaElectronica['estado'] ?? 'PENDIENTE',
      fechaGeneracion: DateTime.tryParse(boletaElectronica['fechaGeneracion'] ?? '') ?? DateTime.now(),
      fechaEmision: DateTime.tryParse(boletaElectronica['fechaEmision'] ?? '') ?? DateTime.now(),
      xmlUrl: urls['descargarXML'] ?? '',
      verBoletaUrl: urls['verBoleta'] ?? '',
      enviarSIIUrl: urls['enviarSII'] ?? '',
      datosFacturacion: DatosFacturacion.fromJson(datosFacturacion),
      metadata: MetadataPOS.fromJson(metadata),
      productos: (productos as List).map((item) => ProductoBoleta.fromJson(item)).toList(),
      total: (datosFacturacion['montoTotal'] ?? 0).toDouble(),
    );
  }
}

/// 💰 DATOS DE FACTURACIÓN OFICIAL SII
/// 
/// Contiene todos los datos oficiales que aparecen en la boleta electrónica
/// según los estándares del SII chileno.
/// 
/// 📋 CAMPOS REQUERIDOS POR EL SII:
/// - RUT y razón social del emisor (tu empresa)
/// - RUT y razón social del receptor (el cliente)
/// - Montos: total, neto e IVA
/// - Folio oficial asignado
class DatosFacturacion {
  final String rutEmisor;           // 🏢 RUT de tu empresa (ej: "77710916-2")
  final String razonSocialEmisor;   // 🏢 Nombre de tu empresa (ej: "TECNOALSA CHILE SPA")
  final int folio;                  // 📋 Folio SII (ej: 58, 59, 60...)
  final String rutReceptor;         // 👤 RUT del cliente (ej: "12345678-9")
  final String razonSocialReceptor; // 👤 Nombre del cliente
  final int montoTotal;             // 💰 Monto total con IVA (ej: 11900)
  final int montoNeto;              // 💰 Monto neto sin IVA (ej: 10000)
  final int iva;                    // 💰 Monto del IVA (ej: 1900)

  DatosFacturacion({
    required this.rutEmisor,
    required this.razonSocialEmisor,
    required this.folio,
    required this.rutReceptor,
    required this.razonSocialReceptor,
    required this.montoTotal,
    required this.montoNeto,
    required this.iva,
  });

  /// 🔄 CONVERSIÓN DESDE JSON
  /// 
  /// Convierte los datos de facturación desde la respuesta del backend
  /// 
  /// EJEMPLO DE JSON:
  /// ```json
  /// {
  ///   "rutEmisor": "77710916-2",
  ///   "razonSocialEmisor": "TECNOALSA CHILE SPA",
  ///   "folio": 58,
  ///   "rutReceptor": "12345678-9",
  ///   "razonSocialReceptor": "Cliente de Prueba",
  ///   "montoTotal": 11900,
  ///   "montoNeto": 10000,
  ///   "iva": 1900
  /// }
  /// ```
  factory DatosFacturacion.fromJson(Map<String, dynamic> json) {
    return DatosFacturacion(
      rutEmisor: json['rutEmisor'],
      razonSocialEmisor: json['razonSocialEmisor'],
      folio: json['folio'],
      rutReceptor: json['rutReceptor'],
      razonSocialReceptor: json['razonSocialReceptor'],
      montoTotal: json['montoTotal'],
      montoNeto: json['montoNeto'],
      iva: json['iva'],
    );
  }
}

/// 📱 METADATOS DEL PUNTO DE VENTA (POS)
/// 
/// Información adicional del contexto donde se generó la venta.
/// Estos datos no son parte oficial de la boleta SII, pero son útiles
/// para la trazabilidad y gestión interna.
/// 
/// 🎯 PROPÓSITO:
/// - Identificar qué vendedor realizó la venta
/// - Saber en qué sucursal se hizo la venta  
/// - Registrar el método de pago utilizado
/// - Identificar el sistema origen (POS móvil)
class MetadataPOS {
  final String sistemaOrigen;  // 📱 Sistema que originó la venta (ej: "POS_MOVIL")
  final String vendedor;       // 👤 Nombre del vendedor (ej: "Juan Pérez")
  final String sucursal;       // 🏪 Sucursal donde se realizó (ej: "Local Principal")
  final String metodoPago;     // 💳 Método de pago (ej: "EFECTIVO", "TARJETA")

  MetadataPOS({
    required this.sistemaOrigen,
    required this.vendedor,
    required this.sucursal,
    required this.metodoPago,
  });

  /// 🔄 CONVERSIÓN DESDE JSON CON VALORES POR DEFECTO
  /// 
  /// Si algún campo no viene en el JSON, se asigna un valor por defecto
  /// para evitar errores y mantener la funcionalidad.
  /// 
  /// EJEMPLO DE JSON:
  /// ```json
  /// {
  ///   "sistemaOrigen": "POS_MOVIL",
  ///   "vendedor": "Juan Pérez",
  ///   "sucursal": "Local Principal", 
  ///   "metodoPago": "EFECTIVO"
  /// }
  /// ```
  /// 
  /// 💡 NOTA: Si falta algún campo, se usan valores por defecto seguros
  factory MetadataPOS.fromJson(Map<String, dynamic> json) {
    return MetadataPOS(
      sistemaOrigen: json['sistemaOrigen'] ?? 'POS_MOVIL',  // Por defecto: POS móvil
      vendedor: json['vendedor'] ?? '',                     // Por defecto: vacío
      sucursal: json['sucursal'] ?? '',                     // Por defecto: vacío  
      metodoPago: json['metodoPago'] ?? '',                 // Por defecto: vacío
    );
  }
}

/// 🛍️ PRODUCTO EN BOLETA SII
/// 
/// Representa un producto individual dentro de una boleta electrónica.
/// Contiene la información básica necesaria para generar el detalle
/// de la boleta y los PDFs de impresión.
class ProductoBoleta {
  final String codigo;    // 🔢 Código de barras o SKU del producto
  final String nombre;    // 📝 Nombre del producto
  final int cantidad;     // 🔢 Cantidad vendida
  final double precio;    // 💰 Precio unitario

  ProductoBoleta({
    required this.codigo,
    required this.nombre,
    required this.cantidad,
    required this.precio,
  });

  /// 🔄 CONVERSIÓN DESDE JSON
  /// 
  /// Convierte los datos del producto desde la respuesta del backend
  /// 
  /// EJEMPLO DE JSON:
  /// ```json
  /// {
  ///   "codigo": "7804123456789",
  ///   "nombre": "Producto de Ejemplo",
  ///   "cantidad": 2,
  ///   "precio": 1500
  /// }
  /// ```
  factory ProductoBoleta.fromJson(Map<String, dynamic> json) {
    return ProductoBoleta(
      codigo: json['codigo'] ?? '',
      nombre: json['nombre'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      precio: (json['precio'] ?? 0).toDouble(),
    );
  }

  /// 🔄 CONVERSIÓN A JSON
  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'nombre': nombre,
      'cantidad': cantidad,
      'precio': precio,
    };
  }
}

// 📝 EJEMPLO COMPLETO DE USO:
//
// ```dart
// // 1. Recibir respuesta del backend
// final response = await http.post(
//   'http://localhost:3000/api/pos/procesar-venta',
//   body: jsonEncode(datosVenta),
// );
//
// // 2. Convertir a objeto Dart
// final boleta = BoletaSII.fromJson(jsonDecode(response.body));
//
// // 3. Usar los datos
// print('🧾 Boleta generada:');
// print('   📋 Folio: ${boleta.folio}');
// print('   💰 Total: \$${boleta.datosFacturacion.montoTotal}');
// print('   👤 Vendedor: ${boleta.metadata.vendedor}');
// print('   📊 Estado: ${boleta.estado}');
//
// // 4. Mostrar al usuario
// showDialog(
//   context: context,
//   builder: (context) => AlertDialog(
//     title: Text('Boleta ${boleta.folio} generada'),
//     content: Text('Total: \$${boleta.datosFacturacion.montoTotal}'),
//   ),
// );
// ```
//
// 🔗 INTEGRACIÓN CON EL BACKEND:
// Este archivo trabaja junto con:
// - pos_sii_service.dart: Maneja las llamadas HTTP al backend
// - POSIntegrationController.js: Endpoint del backend que procesa ventas
// - Base de datos MySQL: Donde se almacenan las boletas generadas