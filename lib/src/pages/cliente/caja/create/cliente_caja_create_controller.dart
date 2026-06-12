import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:posmobilfinal/src/models/categoria.dart';
import 'package:posmobilfinal/src/models/producto.dart';
import 'package:posmobilfinal/src/models/usuario.dart';
import 'package:posmobilfinal/src/providers/productos_provider.dart';
import 'package:posmobilfinal/src/providers/categorias_provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/models/boleta.dart';
import 'package:posmobilfinal/src/models/detalle.dart';
import 'package:posmobilfinal/src/models/inventario.dart';
import 'package:posmobilfinal/src/providers/boletas_provider.dart';
import 'package:posmobilfinal/src/providers/boleta_provider.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class ClienteCajaCreateController extends GetxController {
  static const int _umbralAlertaFoliosDefault = 10;
  static const int _umbralAlertaFoliosMin = 1;
  static const int _umbralAlertaFoliosMax = 200;
  static const String _umbralAlertaFoliosStorageKey = 'umbral_alerta_folios';

  final RxnInt foliosDisponibles = RxnInt();
  final RxBool foliosConsultaEnCurso = false.obs;
  final RxInt umbralAlertaFolios = _umbralAlertaFoliosDefault.obs;

  final RxList<Producto> selectedProducts = <Producto>[].obs;
  final RxDouble total = 0.0.obs;
  final RxDouble pago = 0.0.obs;

  final TextEditingController codigoBarraController = TextEditingController();
  final RxBool isLoading = false.obs;

  String formaPago = '';
  Usuario sesionUsuario = Usuario.fromJson(GetStorage().read('usuario') ?? {});
  final RxList<Producto> productos = <Producto>[].obs;

  ProductosProvider productosProvider = ProductosProvider();
  CategoriasProvider categoriasProvider = CategoriasProvider();
  final BoletasProvider boletasProvider = BoletasProvider();

  // Provider DTE único para todo el ciclo del controller
  final BoletaProvider boletaProvider = BoletaProvider();

  String? dteXmlString;
  XmlDocument? dteXmlDocument;
  String? dteBoletaId;

  ClienteCajaCreateController() {
    print('CONSTRUCTOR: ClienteCajaCreateController creado');
  }

  Map<String, dynamic>? _leerUsuarioEmpresaStorage() {
    final storage = GetStorage();
    final raw = storage.read('usuarioempresa') ?? storage.read('usuario_empresa');
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  String _resolverApiKeyEmpresaActiva() {
    try {
      final raw = _leerUsuarioEmpresaStorage();
      final dynamic key = raw?['api_key'] ?? raw?['apiKey'] ?? raw?['x_api_key'];
      final value = key?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    } catch (_) {}
    // Fallback para compatibilidad
    return 'Vikingo80';
  }

  void _sincronizarApiKeyDte() {
    boletaProvider.setApiKey(_resolverApiKeyEmpresaActiva());
  }

  Future<void> onEmpresaActivaCambiada({bool mostrarMensajes = true}) async {
    try {
      _sincronizarApiKeyDte();
      await refrescarFoliosDisponibles(mostrarMensajes: false);

      if (!mostrarMensajes) return;

      final f = foliosDisponibles.value;
      if (f == null) {
        Get.snackbar(
          'Empresa activa',
          boletaProvider.lastFoliosError ?? 'Empresa cambiada, pero no se pudo consultar folios',
        );
        return;
      }

      if (f <= 0) {
        Get.snackbar(
          'Empresa activa',
          'Empresa cambiada. Sin folios disponibles para emitir.',
        );
        return;
      }

      if (f <= umbralAlertaFolios.value) {
        Get.snackbar(
          'Empresa activa',
          'Empresa cambiada. Folios disponibles: $f (nivel bajo).',
        );
        return;
      }

      Get.snackbar(
        'Empresa activa',
        'Empresa cambiada correctamente. Folios disponibles: $f',
      );
    } catch (e) {
      if (mostrarMensajes) {
        Get.snackbar('Empresa activa', 'Error al cambiar empresa: $e');
      }
    } finally {
      update();
    }
  }

  double _parsePrecio(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 0.0;
    final normalizado = raw.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9\.]'), '');
    return double.tryParse(normalizado) ?? 0.0;
  }

  String? validarVentaAntesDeEmitir({double? montoRecibido}) {
    // FASE 2 (10-06-2026): Validar que empresa_data esté configurada antes de permitir emisión
    final storage = GetStorage();
    final Map<String, dynamic>? empresaData = storage.read('empresa_data') as Map<String, dynamic>?;
    
    if (empresaData == null) {
      return '❌ Datos de empresa no disponibles. Vuelve a hacer login para configurar la empresa.';
    }
    
    final apiKeyValue = empresaData['api_key']?.toString().trim() ?? '';
    if (apiKeyValue.isEmpty) {
      return '❌ API key de empresa no configurada. Vuelve a hacer login.';
    }
    
    final rutValue = (empresaData['rut'] ?? empresaData['rut_emisor'] ?? '').toString().trim();
    if (rutValue.isEmpty) {
      return '❌ RUT de empresa no configurado. Vuelve a hacer login.';
    }
    // Fin validaciones Fase 2

    if (selectedProducts.isEmpty) {
      return 'Agrega al menos un producto antes de emitir la boleta.';
    }

    if (formaPago.trim().isEmpty) {
      return 'Selecciona una forma de pago antes de continuar.';
    }

    if (total.value <= 0) {
      return 'El total debe ser mayor a 0 para emitir la boleta.';
    }

    for (final p in selectedProducts) {
      final nombre = (p.nombreProducto ?? '').trim();
      final cantidad = p.cantidad ?? 0;
      final precio = _parsePrecio(p.precioVenta);

      if (nombre.isEmpty) {
        return 'Hay productos sin nombre en el carrito.';
      }
      if (cantidad <= 0) {
        return 'La cantidad de "$nombre" debe ser mayor a 0.';
      }
      if (precio <= 0) {
        return 'El precio de "$nombre" debe ser mayor a 0.';
      }
    }

    if (formaPago == 'EFECTIVO' && montoRecibido != null && montoRecibido < total.value) {
      return 'El monto recibido debe ser mayor o igual al total.';
    }

    return null;
  }

  bool _esErrorSinFolios(String? error) {
    if (error == null || error.trim().isEmpty) return false;
    final msg = error.toLowerCase();
    return (msg.contains('folio') || msg.contains('folios') || msg.contains('caf')) &&
        (msg.contains('no hay') ||
            msg.contains('agot') ||
            msg.contains('insuf') ||
            msg.contains('disponib') ||
            msg.contains('vencid'));
  }

  void cargarConfiguracionFolios() {
    final dynamic umbralGuardado = GetStorage().read(_umbralAlertaFoliosStorageKey);
    final int umbral = umbralGuardado is int
        ? umbralGuardado
        : int.tryParse(umbralGuardado?.toString() ?? '') ?? _umbralAlertaFoliosDefault;
    umbralAlertaFolios.value = umbral.clamp(_umbralAlertaFoliosMin, _umbralAlertaFoliosMax);
  }

  Future<void> actualizarUmbralAlertaFolios(int nuevoUmbral) async {
    final int normalizado = nuevoUmbral.clamp(_umbralAlertaFoliosMin, _umbralAlertaFoliosMax);
    umbralAlertaFolios.value = normalizado;
    await GetStorage().write(_umbralAlertaFoliosStorageKey, normalizado);
    update();
  }

  Future<void> refrescarFoliosDisponibles({bool mostrarMensajes = false}) async {
    if (foliosConsultaEnCurso.value) return;
    foliosConsultaEnCurso.value = true;
    try {
      _sincronizarApiKeyDte();

      final int? disponibles = await boletaProvider.consultarFoliosDisponibles(
        tipoDte: 39,
      );
      foliosDisponibles.value = disponibles;

      if (mostrarMensajes) {
        if (disponibles == null) {
          Get.snackbar('Folios', boletaProvider.lastFoliosError ?? 'No se pudo consultar folios disponibles');
        } else if (disponibles <= 0) {
          Get.snackbar('❌ Sin folios', 'No hay folios disponibles para emitir boletas');
        } else if (disponibles <= umbralAlertaFolios.value) {
          Get.snackbar('⚠️ Folios bajos', 'Quedan $disponibles folios disponibles');
        } else {
          Get.snackbar('Folios', 'Disponibles: $disponibles');
        }
      }
    } finally {
      foliosConsultaEnCurso.value = false;
      update();
    }
  }

  Future<void> emitirBoletaSii({required BuildContext context}) async {
    final errorValidacion = validarVentaAntesDeEmitir();
    if (errorValidacion != null) {
      Get.snackbar('Validación', errorValidacion);
      return;
    }

    isLoading.value = true;
    String etapa = 'inicio';
    String resultado = 'ERROR';
    String? logBoletaId;
    String? logFolio;
    String? logError;

    try {
      _sincronizarApiKeyDte();

      etapa = 'verificando_folios';
      final foliosActuales = await boletaProvider.consultarFoliosDisponibles(
        tipoDte: 39,
      );
      foliosDisponibles.value = foliosActuales;

      if (foliosActuales != null) {
        if (foliosActuales <= 0) {
          logError = 'No hay folios disponibles para emitir boletas. Carga nuevos folios autorizados antes de continuar.';
          Get.snackbar('❌ Sin folios', logError!);
          return;
        }

        if (foliosActuales <= umbralAlertaFolios.value) {
          Get.snackbar(
            '⚠️ Folios bajos',
            'Quedan solo $foliosActuales folios disponibles. Recomendado cargar nuevos folios pronto.',
          );
        }
      }

      etapa = 'construyendo_payload';
      final boletaData = {
        'emisor': sesionUsuario.rut ?? '99999999-9', // opcional, ya no define tenant
        'receptor': {
          'rut': '11111111-1',
          'razon': 'Cliente POS',
        },
        'detalles': selectedProducts.map((p) {
          final precio = double.tryParse(p.precioVenta ?? '0') ?? 0;
          final cantidad = p.cantidad ?? 1;
          return {
            'nombre': p.nombreProducto ?? '',
            'cantidad': cantidad,
            'precio': precio,
            'monto_item': (precio * cantidad).toInt(),
          };
        }).toList(),
        'total': total.value.toInt(),
      };

      etapa = 'generando_boleta';
      _sincronizarApiKeyDte();
      final boletaResponse = await boletaProvider.generarBoleta(boletaData);
      if (boletaResponse == null) {
        logError = boletaProvider.lastError ?? 'No se pudo generar la boleta SII';
        if (_esErrorSinFolios(logError)) {
          logError = 'No se pudo generar la boleta: no hay folios disponibles o vigentes. Carga folios autorizados e intenta nuevamente.';
        }
        Get.snackbar('❌ Error', logError!);
        return;
      }

      final String boletaId = (boletaResponse['id'] ?? boletaResponse['data']?['id'] ?? boletaResponse['data']?['boleta']?['id'])?.toString() ?? '';
      final String folioDte = (boletaResponse['folio'] ?? boletaResponse['data']?['folio'] ?? boletaResponse['data']?['boleta']?['folio'] ?? boletaId)?.toString() ?? '';
      if (boletaId.isEmpty) {
        logError = 'No se obtuvo boletaId desde SII: ${boletaResponse}';
        print(logError);
        Get.snackbar('❌ Error', logError!);
        return;
      }
      logBoletaId = boletaId;
      logFolio = folioDte;

      etapa = 'obteniendo_xml';
      final xml = await boletaProvider.obtenerXmlBoleta(boletaId);
      if (xml == null || xml.isEmpty) {
        logError = boletaProvider.lastXmlError ?? 'No se pudo obtener el XML de la boleta';
        Get.snackbar('❌ Error', logError!);
        return;
      }

      dteXmlString = xml;
      dteXmlDocument = XmlDocument.parse(xml);
      dteBoletaId = boletaId;

      try {
        etapa = 'grabando_backend';

        List<DetalleBoleta> detalles = selectedProducts.map((p) {
          final precio = double.tryParse(p.precioVenta ?? '0') ?? 0.0;
          final cantidad = p.cantidad ?? 0;
          return DetalleBoleta(
            idProducto: p.id,
            nombreProducto: p.nombreProducto,
            cantidad: cantidad.toString(),
            valorLinea: precio.toString(),
            totalLinea: (precio * cantidad).toInt(),
          );
        }).toList();

        final usuarioEmpresaRaw = _leerUsuarioEmpresaStorage();
        final String empresa = usuarioEmpresaRaw?['empresa']?.toString() ?? '0';

        final String codigoLocal =
          usuarioEmpresaRaw?['local_asignado']?.toString() ?? (sesionUsuario.localOficina ?? '');

        Inventario inventario = Inventario(
          productos: selectedProducts.toList(),
          fecha: DateTime.now().toIso8601String(),
          idCliente: empresa,
          local: int.tryParse(codigoLocal) ?? 0,
          idUsuarioE: sesionUsuario.id?.toString(),
        );

        List<Map<String, dynamic>> productosBackend = selectedProducts.map((p) {
          final map = p.toJson();
          if (p.precioVenta != null) {
            map['precio_venta'] = p.precioVenta;
          }
          return map;
        }).toList();

        Boleta boleta = Boleta(
          numero: folioDte,
          usuario: sesionUsuario.id?.toString(),
          localUsuario: (() {
            final usuarioEmpresaRaw = _leerUsuarioEmpresaStorage();
            final localAsignado = usuarioEmpresaRaw?['local_asignado']?.toString();
            if (localAsignado != null && localAsignado.isNotEmpty) {
              return localAsignado;
            } else if (sesionUsuario.localOficina != null && sesionUsuario.localOficina!.isNotEmpty) {
              return sesionUsuario.localOficina!;
            } else {
              return '1';
            }
          })(),
          fecha: DateTime.now().toIso8601String(),
          valor: total.value.toStringAsFixed(0),
          formaPago: formaPago,
          productos: productosBackend.cast(),
          detalle: detalles,
          inventario: inventario,
        );

        final response = await boletasProvider.create(boleta);
        if (response.success == true) {
          print('✅ Boleta registrada en backendposmobil');
        } else {
          print('❌ Error backendposmobil: ${response.message}');
        }
      } catch (e) {
        print('❌ Error grabando en backendposmobil: $e');
      }

      etapa = 'finalizado';
      resultado = 'OK';
      Get.snackbar('✅ Éxito', 'Boleta SII emitida y autorizada');
      update();
    } catch (e) {
      logError = e.toString();
      print('❌ Error emitiendo boleta SII: $e');
      Get.snackbar('❌ Error', 'Error emitiendo boleta SII: $e');
    } finally {
      print('[SII_FLOW] resultado=$resultado etapa=$etapa boletaId=${logBoletaId ?? ''} folio=${logFolio ?? ''} total=${total.value.toStringAsFixed(0)} items=${selectedProducts.length} error=${logError ?? ''}');
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    print('onInit: ClienteCajaCreateController');
    super.onInit();
    cargarConfiguracionFolios();
    _sincronizarApiKeyDte();
    refrescarFoliosDisponibles();
    getProducts();
  }

  @override
  void onReady() {
    print('onReady: ClienteCajaCreateController');
    super.onReady();
  }

  void onChangeText(String value) {
    pago.value = double.tryParse(value) ?? 0.0;
    update();
  }

  Future<void> recibirDteXmlDesdeApi() async {
    isLoading.value = true;
    final url = Uri.parse('https://tu-api.com/boleta/xml/12345');
    final token = 'TU_TOKEN_DE_AUTENTICACION';

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/xml',
        },
      );
      if (response.statusCode == 200) {
        dteXmlString = response.body;
        dteXmlDocument = XmlDocument.parse(dteXmlString!);
        Get.snackbar('DTE recibido', 'XML recibido y guardado correctamente');
      } else {
        Get.snackbar('Error', 'No se pudo obtener el XML: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Excepción al obtener el XML: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getProducts() async {
    try {
      isLoading.value = true;
      final productosFromAPI = await productosProvider.getAllByUser();
      productos.value = productosFromAPI;
    } catch (e) {
      print('❌ Error cargando productos desde API: $e');
      Get.snackbar('Error', 'No se pudieron cargar los productos');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> code(BuildContext context) async {
    String codigo = '';
    try {
      codigo = codigoBarraController.text.trim();
    } catch (e, st) {
      print('ERROR acceso tardío a codigoBarraController en code: $e\n$st');
      Get.snackbar('Error', 'Error interno en acceso a código de barras');
      return;
    }

    if (codigo.isEmpty) {
      Get.snackbar('Error', 'Ingrese un código de barras');
      return;
    }

    try {
      final producto = await productosProvider.getProduct(codigo);
      if (producto != null) {
        addItem(producto);
      } else {
        await showProductoNoExisteDialog(context, codigo);
      }
    } catch (e) {
      print('❌ Error buscando producto: $e');
      Get.snackbar('Error', 'Error al buscar el producto');
    }
  }

  Future<void> scanBarcodeMobileScanner(
    String barcode,
    BuildContext context,
    Function(String) onProductoNoExiste,
  ) async {
    try {
      final producto = await productosProvider.getProduct(barcode);
      if (producto != null) {
        addItem(producto);
      } else {
        await onProductoNoExiste(barcode);
      }
    } catch (e) {
      print('❌ Error en escaneo: $e');
      Get.snackbar('Error', 'Error al escanear el código');
    }
  }

  Future<void> showProductoNoExisteDialog(BuildContext context, String barcode) async {
    await showDialog(
      context: context,
      builder: (context) => _CrearProductoDialog(barcode: barcode),
    );
  }

  void addItem(Producto producto) {
    final indiceExistente = selectedProducts.indexWhere(
      (p) => p.codigoBarra == producto.codigoBarra,
    );

    if (indiceExistente != -1) {
      selectedProducts[indiceExistente].cantidad =
          (selectedProducts[indiceExistente].cantidad ?? 0) + 1;
    } else {
      final nuevoProducto = Producto.fromJson(producto.toJson());
      nuevoProducto.cantidad = 1;
      selectedProducts.add(nuevoProducto);
    }

    _calcularTotal();
    update();
  }

  void removeItem(Producto producto) {
    final indice = selectedProducts.indexWhere(
      (p) => p.codigoBarra == producto.codigoBarra,
    );

    if (indice != -1) {
      final cantidadActual = selectedProducts[indice].cantidad ?? 0;
      if (cantidadActual > 1) {
        selectedProducts[indice].cantidad = cantidadActual - 1;
      } else {
        selectedProducts.removeAt(indice);
      }
      _calcularTotal();
      update();
    }
  }

  void deleteItem(Producto producto) {
    selectedProducts.removeWhere(
      (p) => p.codigoBarra == producto.codigoBarra,
    );
    _calcularTotal();
    update();
  }

  void _calcularTotal() {
    double totalCalculado = 0.0;
    for (var producto in selectedProducts) {
      double precio = 0.0;
      if (producto.precioVenta != null && producto.precioVenta!.isNotEmpty) {
        final precioStr =
            producto.precioVenta!.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9\.]'), '');
        precio = double.tryParse(precioStr) ?? 0.0;
      }
      final cantidad = (producto.cantidad != null && producto.cantidad! > 0) ? producto.cantidad! : 1;
      totalCalculado += precio * cantidad;
    }
    total.value = totalCalculado;
  }

  Future<bool> createBill(BuildContext context) async {
    try {
      List<DetalleBoleta> detalles = selectedProducts.map((p) {
        final precio = double.tryParse(p.precioVenta ?? '0') ?? 0.0;
        final cantidad = p.cantidad ?? 0;
        return DetalleBoleta(
          idProducto: p.id,
          nombreProducto: p.nombreProducto,
          cantidad: cantidad.toString(),
          valorLinea: precio.toString(),
          totalLinea: (precio * cantidad).toInt(),
        );
      }).toList();

          final usuarioEmpresaRaw = _leerUsuarioEmpresaStorage();
          final String empresa = usuarioEmpresaRaw?['empresa']?.toString() ?? '0';

          final String codigoLocal =
            usuarioEmpresaRaw?['local_asignado']?.toString() ?? (sesionUsuario.localOficina ?? '');

      Inventario inventario = Inventario(
        productos: selectedProducts.toList(),
        fecha: DateTime.now().toIso8601String(),
        idCliente: empresa,
        local: int.tryParse(codigoLocal) ?? 0,
        idUsuarioE: sesionUsuario.id?.toString(),
      );

      List<Map<String, dynamic>> productosBackend = selectedProducts.map((p) {
        final map = p.toJson();
        if (p.precioVenta != null) {
          map['precio_venta'] = p.precioVenta;
        }
        return map;
      }).toList();

      Boleta boleta = Boleta(
        numero: '123',
        usuario: sesionUsuario.id?.toString(),
        localUsuario: (() {
          final usuarioEmpresaRaw = _leerUsuarioEmpresaStorage();
          final localAsignado = usuarioEmpresaRaw?['local_asignado']?.toString();
          if (localAsignado != null && localAsignado.isNotEmpty) {
            return localAsignado;
          } else if (sesionUsuario.localOficina != null && sesionUsuario.localOficina!.isNotEmpty) {
            return sesionUsuario.localOficina!;
          } else {
            return '1';
          }
        })(),
        fecha: DateTime.now().toIso8601String(),
        valor: total.value.toStringAsFixed(0),
        formaPago: formaPago,
        productos: productosBackend.cast(),
        detalle: detalles,
        inventario: inventario,
      );

      final response = await boletasProvider.create(boleta);
      if (response.success == true) {
        _mostrarMensaje('Venta guardada exitosamente');
        return true;
      } else {
        _mostrarMensaje('Error guardando venta: ${response.message}', esError: true);
        return false;
      }
    } catch (e) {
      _mostrarMensaje('Error guardando venta: $e', esError: true);
      return false;
    }
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    Get.snackbar(
      esError ? 'Error' : 'Éxito',
      mensaje,
      backgroundColor: esError ? Colors.red[100] : Colors.green[100],
      colorText: esError ? Colors.red[800] : Colors.green[800],
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void limpiarCarrito() {
    selectedProducts.clear();
    total.value = 0.0;
    pago.value = 0.0;
    formaPago = '';
    try {
      codigoBarraController.clear();
    } catch (e, st) {
      print('ERROR acceso tardío a codigoBarraController en limpiarCarrito: $e\n$st');
    }
    update();
  }

  @override
  void onClose() {
    codigoBarraController.dispose();
    super.onClose();
  }
}

class _CrearProductoDialog extends StatefulWidget {
  final String barcode;
  final VoidCallback? onImprimirPdfTspl;

  const _CrearProductoDialog({required this.barcode, this.onImprimirPdfTspl});

  @override
  State<_CrearProductoDialog> createState() => _CrearProductoDialogState();
}

class _CrearProductoDialogState extends State<_CrearProductoDialog> {
  final nombreController = TextEditingController();
  final precioController = TextEditingController();
  final descripcionController = TextEditingController();
  final categoriasProvider = CategoriasProvider();

  List<Categoria> categorias = [];
  String? categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  void _cargarCategorias() async {
    try {
      categorias = await categoriasProvider.getAllByUser();
      setState(() {});
    } catch (e) {
      print('Error cargando categorías: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear Producto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Código: ${widget.barcode}'),
            const SizedBox(height: 10),
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre del producto'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: precioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Precio'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: categoriaSeleccionada,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: categorias.map((categoria) {
                return DropdownMenuItem<String>(
                  value: categoria.id,
                  child: Text(categoria.nombreCategoria ?? ''),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  categoriaSeleccionada = newValue;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_validarFormulario()) {
              await _crearProducto();
            }
          },
          child: const Text('Crear y Agregar'),
        ),
        ElevatedButton(
          onPressed: widget.onImprimirPdfTspl != null ? () => widget.onImprimirPdfTspl!() : null,
          child: const Text('Imprimir PDF TSPL'),
        ),
      ],
    );
  }

  bool _validarFormulario() {
    if (nombreController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Ingrese el nombre del producto');
      return false;
    }
    if (precioController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Ingrese el precio del producto');
      return false;
    }
    if (categoriaSeleccionada == null) {
      Get.snackbar('Error', 'Seleccione una categoría');
      return false;
    }
    return true;
  }

  Future<void> _crearProducto() async {
    try {
      final controlador = Get.find<ClienteCajaCreateController>();
      final usuario = Usuario.fromJson(GetStorage().read('usuario') ?? {});

      final nuevoProducto = Producto(
        usuario: usuario.id.toString(),
        nombreProducto: nombreController.text.trim(),
        descripcionProducto: descripcionController.text.trim(),
        codigoBarra: widget.barcode,
        precioCosto: '0',
        precioVenta: precioController.text.trim(),
        proveedor: 'Sin Especificar',
        categoria: categoriaSeleccionada,
      );

      final response = await controlador.productosProvider.create(nuevoProducto);

      if (response.success == true) {
        await controlador.getProducts();
        controlador.addItem(nuevoProducto);
        Navigator.of(context).pop();
        Get.snackbar('Éxito', 'Producto creado y agregado');
      } else {
        Get.snackbar('Error', response.message ?? 'Error creando producto');
      }
    } catch (e) {
      print('Error creando producto: $e');
      Get.snackbar('Error', 'Error creando producto: $e');
    }
  }
}


/*
// controllers/cliente_caja_create_controller.dart
// controllers/cliente_caja_create_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:posmobilfinal/src/models/categoria.dart';
import 'package:posmobilfinal/src/models/producto.dart';
import 'package:posmobilfinal/src/models/usuario.dart';
import 'package:posmobilfinal/src/providers/productos_provider.dart';
import 'package:posmobilfinal/src/providers/categorias_provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/models/boleta.dart';
import 'package:posmobilfinal/src/models/detalle.dart';
import 'package:posmobilfinal/src/models/inventario.dart';
import 'package:posmobilfinal/src/providers/boletas_provider.dart';
import 'package:posmobilfinal/src/providers/boleta_provider.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

/// 🎮 CONTROLADOR PRINCIPAL DEL POS
class ClienteCajaCreateController extends GetxController {
  static const int _umbralAlertaFoliosDefault = 10;
  static const int _umbralAlertaFoliosMin = 1;
  static const int _umbralAlertaFoliosMax = 200;
  static const String _umbralAlertaFoliosStorageKey = 'umbral_alerta_folios';

  final RxnInt foliosDisponibles = RxnInt();
  final RxBool foliosConsultaEnCurso = false.obs;
  final RxInt umbralAlertaFolios = _umbralAlertaFoliosDefault.obs;

  double _parsePrecio(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 0.0;
    final normalizado = raw.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9\.]'), '');
    return double.tryParse(normalizado) ?? 0.0;
  }

  /// Valida reglas de negocio de una venta antes de emitir la boleta.
  /// Retorna null si está todo correcto, o un mensaje de error si falla.
  String? validarVentaAntesDeEmitir({double? montoRecibido}) {
    if (selectedProducts.isEmpty) {
      return 'Agrega al menos un producto antes de emitir la boleta.';
    }

    if (formaPago.trim().isEmpty) {
      return 'Selecciona una forma de pago antes de continuar.';
    }

    if (total.value <= 0) {
      return 'El total debe ser mayor a 0 para emitir la boleta.';
    }

    for (final p in selectedProducts) {
      final nombre = (p.nombreProducto ?? '').trim();
      final cantidad = p.cantidad ?? 0;
      final precio = _parsePrecio(p.precioVenta);

      if (nombre.isEmpty) {
        return 'Hay productos sin nombre en el carrito.';
      }
      if (cantidad <= 0) {
        return 'La cantidad de "$nombre" debe ser mayor a 0.';
      }
      if (precio <= 0) {
        return 'El precio de "$nombre" debe ser mayor a 0.';
      }
    }

    if (formaPago == 'EFECTIVO' && montoRecibido != null && montoRecibido < total.value) {
      return 'El monto recibido debe ser mayor o igual al total.';
    }

    return null;
  }

  bool _esErrorSinFolios(String? error) {
    if (error == null || error.trim().isEmpty) return false;
    final msg = error.toLowerCase();
    return (msg.contains('folio') || msg.contains('folios') || msg.contains('caf')) &&
        (msg.contains('no hay') ||
            msg.contains('agot') ||
            msg.contains('insuf') ||
            msg.contains('disponib') ||
            msg.contains('vencid'));
  }

  void cargarConfiguracionFolios() {
    final dynamic umbralGuardado = GetStorage().read(_umbralAlertaFoliosStorageKey);
    final int umbral = umbralGuardado is int
        ? umbralGuardado
        : int.tryParse(umbralGuardado?.toString() ?? '') ?? _umbralAlertaFoliosDefault;
    umbralAlertaFolios.value = umbral.clamp(_umbralAlertaFoliosMin, _umbralAlertaFoliosMax);
  }

  Future<void> actualizarUmbralAlertaFolios(int nuevoUmbral) async {
    final int normalizado = nuevoUmbral.clamp(_umbralAlertaFoliosMin, _umbralAlertaFoliosMax);
    umbralAlertaFolios.value = normalizado;
    await GetStorage().write(_umbralAlertaFoliosStorageKey, normalizado);
    update();
  }

  Future<void> refrescarFoliosDisponibles({bool mostrarMensajes = false}) async {
    if (foliosConsultaEnCurso.value) return;
    foliosConsultaEnCurso.value = true;
    try {
      _sincronizarApiKeyDte();
      final int? disponibles = await boletaProvider.consultarFoliosDisponibles(
        emisor: sesionUsuario.rut,
      );
      foliosDisponibles.value = disponibles;

      if (mostrarMensajes) {
        if (disponibles == null) {
          Get.snackbar('Folios', boletaProvider.lastFoliosError ?? 'No se pudo consultar folios disponibles');
        } else if (disponibles <= 0) {
          Get.snackbar('❌ Sin folios', 'No hay folios disponibles para emitir boletas');
        } else if (disponibles <= umbralAlertaFolios.value) {
          Get.snackbar('⚠️ Folios bajos', 'Quedan $disponibles folios disponibles');
        } else {
          Get.snackbar('Folios', 'Disponibles: $disponibles');
        }
      }
    } finally {
      foliosConsultaEnCurso.value = false;
      update();
    }
  }

  /// Emite boleta SII usando la API y guarda el XML real y el ID para el PDF
  Future<void> emitirBoletaSii({required BuildContext context}) async {
    final errorValidacion = validarVentaAntesDeEmitir();
    if (errorValidacion != null) {
      Get.snackbar('Validación', errorValidacion);
      return;
    }

    isLoading.value = true;
    String etapa = 'inicio';
    String resultado = 'ERROR';
    String? logBoletaId;
    String? logFolio;
    String? logError;
    try {
      _sincronizarApiKeyDte();

      etapa = 'verificando_folios';
      final foliosActuales = await boletaProvider.consultarFoliosDisponibles(
        emisor: sesionUsuario.rut,
      );
      foliosDisponibles.value = foliosActuales;
      if (foliosActuales != null) {
        if (foliosActuales <= 0) {
          logError = 'No hay folios disponibles para emitir boletas. Carga nuevos folios autorizados antes de continuar.';
          Get.snackbar('❌ Sin folios', logError!);
          return;
        }

        if (foliosActuales <= umbralAlertaFolios.value) {
          Get.snackbar(
            '⚠️ Folios bajos',
            'Quedan solo $foliosActuales folios disponibles. Recomendado cargar nuevos folios pronto.',
          );
        }
      }

      etapa = 'construyendo_payload';
      // Construir datos para la API del SII
      final boletaData = {
        'emisor': sesionUsuario.rut ?? '99999999-9',
        'receptor': {
          'rut': '11111111-1',
          'razon': 'Cliente POS',
        },
        'detalles': selectedProducts.map((p) {
          final precio = double.tryParse(p.precioVenta ?? '0') ?? 0;
          final cantidad = p.cantidad ?? 1;
          return {
            'nombre': p.nombreProducto ?? '',
            'cantidad': cantidad,
            'precio': precio,
            'monto_item': (precio * cantidad).toInt(),
          };
        }).toList(),
        'total': total.value.toInt(),
        'api_key': 'Vikingo80',
      };

      print('📤 Enviando boleta al SII...');
      etapa = 'generando_boleta';
      final boletaResponse = await boletaProvider.generarBoleta(boletaData);
      if (boletaResponse == null) {
        logError = boletaProvider.lastError ?? 'No se pudo generar la boleta SII';
        if (_esErrorSinFolios(logError)) {
          logError = 'No se pudo generar la boleta: no hay folios disponibles o vigentes. Carga folios autorizados e intenta nuevamente.';
        }
        Get.snackbar(
          '❌ Error',
          logError!,
        );
        return;
      }
      final String boletaId = (boletaResponse['id'] ?? boletaResponse['data']?['id'] ?? boletaResponse['data']?['boleta']?['id'])?.toString() ?? '';
      final String folioDte = (boletaResponse['folio'] ?? boletaResponse['data']?['folio'] ?? boletaResponse['data']?['boleta']?['folio'] ?? boletaId)?.toString() ?? '';
      if (boletaId.isEmpty) {
        logError = 'No se obtuvo boletaId desde SII: ${boletaResponse}';
        print(logError);
        Get.snackbar('❌ Error', logError!);
        return;
      }
      logBoletaId = boletaId;
      logFolio = folioDte;
      print('✅ Boleta generada con ID: $boletaId, folio: $folioDte');
      // Obtener XML del DTE autorizado
      etapa = 'obteniendo_xml';
      final xml = await boletaProvider.obtenerXmlBoleta(boletaId);
      if (xml == null || xml.isEmpty) {
        logError = boletaProvider.lastXmlError ?? 'No se pudo obtener el XML de la boleta';
        Get.snackbar(
          '❌ Error',
          logError!,
        );
        return;
      }
      print('✅ XML recibido del SII');
      dteXmlString = xml;
      dteXmlDocument = XmlDocument.parse(xml);
      dteBoletaId = boletaId;
      // --- GRABAR EN BACKENDPOSMOBIL ---
      try {
        etapa = 'grabando_backend';
        // Construir detalles
        List<DetalleBoleta> detalles = selectedProducts.map((p) {
          final precio = double.tryParse(p.precioVenta ?? '0') ?? 0.0;
          final cantidad = p.cantidad ?? 0;
          return DetalleBoleta(
            idProducto: p.id,
            nombreProducto: p.nombreProducto,
            cantidad: cantidad.toString(),
            valorLinea: precio.toString(),
            totalLinea: (precio * cantidad).toInt(),
          );
        }).toList();

        // Obtener empresa desde usuarioempresa en GetStorage
        final usuarioEmpresaRaw = GetStorage().read('usuarioempresa');
        String? empresa = (usuarioEmpresaRaw is Map && usuarioEmpresaRaw['empresa'] != null)
            ? usuarioEmpresaRaw['empresa'].toString()
            : '0';
        String? codigoLocal = (usuarioEmpresaRaw is Map && usuarioEmpresaRaw['local_asignado'] != null)
            ? usuarioEmpresaRaw['local_asignado'].toString()
            : (sesionUsuario.localOficina ?? '');
        Inventario inventario = Inventario(
          productos: selectedProducts.toList(),
          fecha: DateTime.now().toIso8601String(),
          idCliente: empresa,
          local: int.tryParse(codigoLocal) ?? 0,
          idUsuarioE: sesionUsuario.id?.toString(),
        );

        List<Map<String, dynamic>> productosBackend = selectedProducts.map((p) {
          final map = p.toJson();
          if (p.precioVenta != null) {
            map['precio_venta'] = p.precioVenta;
          }
          return map;
        }).toList();

        Boleta boleta = Boleta(
          numero: folioDte, // Usar folio del DTE
          usuario: sesionUsuario.id?.toString(),
          localUsuario: (() {
            final usuarioEmpresaRaw = GetStorage().read('usuarioempresa');
            if (usuarioEmpresaRaw is Map && usuarioEmpresaRaw['local_asignado'] != null && usuarioEmpresaRaw['local_asignado'].toString().isNotEmpty) {
              return usuarioEmpresaRaw['local_asignado'].toString();
            } else if (sesionUsuario.localOficina != null && sesionUsuario.localOficina!.isNotEmpty) {
              return sesionUsuario.localOficina!;
            } else {
              return '1'; // Valor por defecto seguro
            }
          })(),
          fecha: DateTime.now().toIso8601String(),
          valor: total.value.toStringAsFixed(0),
          formaPago: formaPago,
          productos: productosBackend.cast(),
          detalle: detalles,
          inventario: inventario,
        );

        final response = await boletasProvider.create(boleta);
        if (response.success == true) {
          print('✅ Boleta registrada en backendposmobil');
        } else {
          print('❌ Error backendposmobil: \\${response.message}');
        }
      } catch (e) {
        print('❌ Error grabando en backendposmobil: $e');
      }
      // --- FIN GRABADO BACKEND ---
      etapa = 'finalizado';
      resultado = 'OK';
      Get.snackbar('✅ Éxito', 'Boleta SII emitida y autorizada');
      update();
    } catch (e) {
      logError = e.toString();
      print('❌ Error emitiendo boleta SII: $e');
      Get.snackbar('❌ Error', 'Error emitiendo boleta SII: $e');
    } finally {
      print('[SII_FLOW] resultado=$resultado etapa=$etapa boletaId=${logBoletaId ?? ''} folio=${logFolio ?? ''} total=${total.value.toStringAsFixed(0)} items=${selectedProducts.length} error=${logError ?? ''}');
      isLoading.value = false;
    }
  }

  /// Variable para guardar el ID de la boleta emitida
  String? dteBoletaId;




        @override
        void onReady() {
          print('onReady: ClienteCajaCreateController');
          super.onReady();
        }
      /// Actualiza el valor de pago al ingresar la cantidad recibida
      void onChangeText(String value) {
        pago.value = double.tryParse(value) ?? 0.0;
        update();
      }
    // Provider para boletas
    final BoletasProvider boletasProvider = BoletasProvider();
  
  // 🛒 ESTADO DEL CARRITO
  final RxList<Producto> selectedProducts = <Producto>[].obs;
  final RxDouble total = 0.0.obs;
  final RxDouble pago = 0.0.obs;
  
  // 📱 CONTROLES DE UI
  final TextEditingController codigoBarraController = TextEditingController();

  // Indicador de carga
  final RxBool isLoading = false.obs;

  ClienteCajaCreateController() {
    print('CONSTRUCTOR: ClienteCajaCreateController creado');
  }

  @override
  void onInit() {
    print('onInit: ClienteCajaCreateController');
    super.onInit();
    cargarConfiguracionFolios();
    refrescarFoliosDisponibles();
    getProducts(); // Cargar productos al inicializar
  }
  
  // 💳 FORMA DE PAGO
  String formaPago = '';
  
  // 👤 DATOS DE USUARIO
  Usuario sesionUsuario = Usuario.fromJson(GetStorage().read('usuario') ?? {});
  
  // 🛍️ PRODUCTOS DESDE API
  final RxList<Producto> productos = <Producto>[].obs;
  
  // 🔄 PROVIDERS REALES
  ProductosProvider productosProvider = ProductosProvider();
  CategoriasProvider categoriasProvider = CategoriasProvider();

  // Variable para guardar el XML recibido del SII
  String? dteXmlString;
  XmlDocument? dteXmlDocument;

  /// Función para recibir el XML del DTE desde una API y guardarlo para uso posterior
  Future<void> recibirDteXmlDesdeApi() async {
    isLoading.value = true;
    final url = Uri.parse('https://tu-api.com/boleta/xml/12345'); // <-- Cambia por tu endpoint real
    final token = 'TU_TOKEN_DE_AUTENTICACION'; // <-- Cambia por tu método de obtención de token

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/xml',
        },
      );
      if (response.statusCode == 200) {
        dteXmlString = response.body;
        dteXmlDocument = XmlDocument.parse(dteXmlString!);
        Get.snackbar('DTE recibido', 'XML recibido y guardado correctamente');
      } else {
        Get.snackbar('Error', 'No se pudo obtener el XML: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Excepción al obtener el XML: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// 📦 CARGAR PRODUCTOS DESDE LA API
  Future<void> getProducts() async {
    try {
      isLoading.value = true;
      print('📦 Cargando productos desde API...');
      
      // Cargar productos reales desde tu API
      final productosFromAPI = await productosProvider.getAllByUser();
      
      // Actualizar la lista observable
      productos.value = productosFromAPI;
      print('✅ Productos cargados desde API: ${productos.length}');
      
      // Debug: mostrar algunos códigos de barra
      for (var producto in productos.take(5)) {
        print('🏷️ Código: ${producto.codigoBarra} - ${producto.nombreProducto}');
      }
      
    } catch (e) {
      print('❌ Error cargando productos desde API: $e');
      Get.snackbar('Error', 'No se pudieron cargar los productos');
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔍 BUSCAR PRODUCTO POR CÓDIGO DE BARRAS USANDO API
  Future<void> code(BuildContext context) async {
    String codigo = '';
    try {
      print('ACCESO codigoBarraController.text en code: ${StackTrace.current}');
      codigo = codigoBarraController.text.trim();
    } catch (e, st) {
      print('ERROR acceso tardío a codigoBarraController en code: $e\n$st');
      Get.snackbar('Error', 'Error interno en acceso a código de barras');
      return;
    }
    if (codigo.isEmpty) {
      Get.snackbar('Error', 'Ingrese un código de barras');
      return;
    }
    if (codigo.isEmpty) {
      Get.snackbar('Error', 'Ingrese un código de barras');
      return;
    }

    try {
      print('🔍 Buscando producto con código: $codigo');
      
      // Usar el método getProduct de tu API
      final producto = await productosProvider.getProduct(codigo);
      
      if (producto != null) {
        print('✅ Producto encontrado: ${producto.nombreProducto}');
        // Si lo encuentra, lo agrega a la lista con cantidad 1
        addItem(producto);
        // Get.snackbar('Producto agregado', producto.nombreProducto ?? ''); // ← Mensaje deshabilitado
      } else {
        print('❌ Producto no encontrado para código: $codigo');
        // Si no lo encuentra, abre el modal de creación
        await showProductoNoExisteDialog(context, codigo);
      }
      
    } catch (e) {
      print('❌ Error buscando producto: $e');
      Get.snackbar('Error', 'Error al buscar el producto');
    }
  }

  /// 🔍 ESCANEO CON MOBILE SCANNER
  Future<void> scanBarcodeMobileScanner(
    String barcode,
    BuildContext context,
    Function(String) onProductoNoExiste,
  ) async {
    try {
      print('🔍 Escaneando código: $barcode');
      
      // Usar el método getProduct de tu API
      final producto = await productosProvider.getProduct(barcode);
      
      if (producto != null) {
        print('✅ Producto encontrado: ${producto.nombreProducto}');
        // Si encuentra el producto, agregarlo con cantidad 1
        addItem(producto);
        // Get.snackbar('Producto agregado', producto.nombreProducto ?? ''); // ← Mensaje deshabilitado
      } else {
        print('❌ Producto no encontrado para código: $barcode');
        // Si no lo encuentra, llamar callback para mostrar diálogo de creación
        await onProductoNoExiste(barcode);
      }
      
    } catch (e) {
      print('❌ Error en escaneo: $e');
      Get.snackbar('Error', 'Error al escanear el código');
    }
  }

  /// 📱 MODAL PARA CREAR PRODUCTO CUANDO NO EXISTE
  Future<void> showProductoNoExisteDialog(BuildContext context, String barcode) async {
    await showDialog(
      context: context,
      builder: (context) => _CrearProductoDialog(barcode: barcode),
    );
  }

  /// ➕ AGREGAR PRODUCTO AL CARRITO
  void addItem(Producto producto) {
    // Verificar si ya existe en el carrito
    final indiceExistente = selectedProducts.indexWhere(
      (p) => p.codigoBarra == producto.codigoBarra,
    );
    
    if (indiceExistente != -1) {
      // Si existe, aumentar cantidad
      selectedProducts[indiceExistente].cantidad = 
          (selectedProducts[indiceExistente].cantidad ?? 0) + 1;
    } else {
      // Si no existe, agregar nuevo con cantidad 1
      final nuevoProducto = Producto.fromJson(producto.toJson());
      nuevoProducto.cantidad = 1;
      selectedProducts.add(nuevoProducto);
    }
    
    _calcularTotal();
    update();
  }

  /// ➖ REDUCIR CANTIDAD DE PRODUCTO
  void removeItem(Producto producto) {
    final indice = selectedProducts.indexWhere(
      (p) => p.codigoBarra == producto.codigoBarra,
    );
    
    if (indice != -1) {
      final cantidadActual = selectedProducts[indice].cantidad ?? 0;
      if (cantidadActual > 1) {
        selectedProducts[indice].cantidad = cantidadActual - 1;
      } else {
        selectedProducts.removeAt(indice);
      }
      _calcularTotal();
      update();
    }
  }

  /// 🗑️ ELIMINAR PRODUCTO DEL CARRITO
  void deleteItem(Producto producto) {
    selectedProducts.removeWhere(
      (p) => p.codigoBarra == producto.codigoBarra,
    );
    _calcularTotal();
    update();
  }

  /// 🧮 CALCULAR TOTAL DEL CARRITO
  void _calcularTotal() {
    double totalCalculado = 0.0;
    for (var producto in selectedProducts) {
      // Validar precioVenta
      double precio = 0.0;
      if (producto.precioVenta != null && producto.precioVenta!.isNotEmpty) {
        // Reemplazar posibles comas por puntos y eliminar símbolos
        final precioStr = producto.precioVenta!.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9\.]'), '');
        precio = double.tryParse(precioStr) ?? 0.0;
      }
      // Validar cantidad
      final cantidad = (producto.cantidad != null && producto.cantidad! > 0) ? producto.cantidad! : 1;
      totalCalculado += precio * cantidad;
    }
    total.value = totalCalculado;
  }

  /// 💾 CREAR BOLETA Y ENVIAR AL BACKEND
  Future<bool> createBill(BuildContext context) async {
    try {
      print('💾 Enviando boleta al backend...');
      // Construir detalles
      List<DetalleBoleta> detalles = selectedProducts.map((p) {
        final precio = double.tryParse(p.precioVenta ?? '0') ?? 0.0;
        final cantidad = p.cantidad ?? 0;
        return DetalleBoleta(
          idProducto: p.id,
          nombreProducto: p.nombreProducto,
          cantidad: cantidad.toString(),
          valorLinea: precio.toString(),
          totalLinea: (precio * cantidad).toInt(),
        );
      }).toList();

      // Construir inventario con datos requeridos
      // Obtener empresa desde usuarioempresa en GetStorage
      final usuarioEmpresaRaw = GetStorage().read('usuarioempresa');
      String? empresa = (usuarioEmpresaRaw is Map && usuarioEmpresaRaw['empresa'] != null)
          ? usuarioEmpresaRaw['empresa'].toString()
          : '0';
      // Enviar el código del local como string
      String? codigoLocal = (usuarioEmpresaRaw is Map && usuarioEmpresaRaw['local_asignado'] != null)
          ? usuarioEmpresaRaw['local_asignado'].toString()
          : (sesionUsuario.localOficina ?? '');
      Inventario inventario = Inventario(
        productos: selectedProducts.toList(),
        fecha: DateTime.now().toIso8601String(),
        idCliente: empresa,
        local: int.tryParse(codigoLocal) ?? 0,
        idUsuarioE: sesionUsuario.id?.toString(),
      );

      // Mapear productos para backend (precioVenta -> precio_venta)
      List<Map<String, dynamic>> productosBackend = selectedProducts.map((p) {
        final map = p.toJson();
        if (p.precioVenta != null) {
          map['precio_venta'] = p.precioVenta;
        }
        return map;
      }).toList();

      // Crear boleta
      Boleta boleta = Boleta(
        numero: '123', // Valor fijo para pruebas
        usuario: sesionUsuario.id?.toString(),
        localUsuario: (() {
          final usuarioEmpresaRaw = GetStorage().read('usuarioempresa');
          if (usuarioEmpresaRaw is Map && usuarioEmpresaRaw['local_asignado'] != null && usuarioEmpresaRaw['local_asignado'].toString().isNotEmpty) {
            return usuarioEmpresaRaw['local_asignado'].toString();
          } else if (sesionUsuario.localOficina != null && sesionUsuario.localOficina!.isNotEmpty) {
            return sesionUsuario.localOficina!;
          } else {
            return '1'; // Valor por defecto seguro
          }
        })(),
        fecha: DateTime.now().toIso8601String(),
        valor: total.value.toStringAsFixed(0),
        formaPago: formaPago,
        productos: productosBackend.cast(),
        detalle: detalles,
        inventario: inventario,
      );

      final response = await boletasProvider.create(boleta);
      if (response.success == true) {
        print('✅ Boleta registrada en backend');
        _mostrarMensaje('Venta guardada exitosamente');
        return true;
      } else {
        print('❌ Error backend: ${response.message}');
        _mostrarMensaje('Error guardando venta: ${response.message}', esError: true);
        return false;
      }
    } catch (e) {
      print('❌ Error enviando boleta: $e');
      _mostrarMensaje('Error guardando venta: $e', esError: true);
      return false;
    }
  }

  /// 💬 MOSTRAR MENSAJE AL USUARIO
  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    Get.snackbar(
      esError ? 'Error' : 'Éxito',
      mensaje,
      backgroundColor: esError ? Colors.red[100] : Colors.green[100],
      colorText: esError ? Colors.red[800] : Colors.green[800],
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// 🧹 LIMPIAR CARRITO
  void limpiarCarrito() {
    selectedProducts.clear();
    total.value = 0.0;
    pago.value = 0.0;
    formaPago = '';
    try {
      print('ACCESO codigoBarraController.clear en limpiarCarrito: ${StackTrace.current}');
      codigoBarraController.clear();
    } catch (e, st) {
      print('ERROR acceso tardío a codigoBarraController en limpiarCarrito: $e\n$st');
    }
    update();
  }

  @override
  void onClose() {
    print('onClose: Disposing codigoBarraController');
    codigoBarraController.dispose();
    super.onClose();
  }
}

/// 🛠️ WIDGET PARA CREAR PRODUCTO

class _CrearProductoDialog extends StatefulWidget {
  final String barcode;
  final VoidCallback? onImprimirPdfTspl;

  const _CrearProductoDialog({required this.barcode, this.onImprimirPdfTspl});

  @override
  State<_CrearProductoDialog> createState() => _CrearProductoDialogState();
}

class _CrearProductoDialogState extends State<_CrearProductoDialog> {
  final nombreController = TextEditingController();
  final precioController = TextEditingController();
  final descripcionController = TextEditingController();
  final categoriasProvider = CategoriasProvider();
  List<Categoria> categorias = [];
  String? categoriaSeleccionada;
  
  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }
  
  void _cargarCategorias() async {
    try {
      categorias = await categoriasProvider.getAllByUser();
      setState(() {});
    } catch (e) {
      print('Error cargando categorías: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear Producto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Código: \\${widget.barcode}'),
            const SizedBox(height: 10),
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre del producto'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: precioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Precio'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: categoriaSeleccionada,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: categorias.map((categoria) {
                return DropdownMenuItem<String>(
                  value: categoria.id,
                  child: Text(categoria.nombreCategoria ?? ''),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  categoriaSeleccionada = newValue;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_validarFormulario()) {
              await _crearProducto();
            }
          },
          child: const Text('Crear y Agregar'),
        ),
        ElevatedButton(
          onPressed: widget.onImprimirPdfTspl != null
              ? () => widget.onImprimirPdfTspl!()
              : null,
          child: const Text('Imprimir PDF TSPL'),
        ),
      ],
    );
  }
  
  bool _validarFormulario() {
    if (nombreController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Ingrese el nombre del producto');
      return false;
    }
    if (precioController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Ingrese el precio del producto');
      return false;
    }
    if (categoriaSeleccionada == null) {
      Get.snackbar('Error', 'Seleccione una categoría');
      return false;
    }
    return true;
  }
  
  Future<void> _crearProducto() async {
    try {
      final controlador = Get.find<ClienteCajaCreateController>();
      final usuario = Usuario.fromJson(GetStorage().read('usuario') ?? {});
      
      final nuevoProducto = Producto(
        usuario: usuario.id.toString(),
        nombreProducto: nombreController.text.trim(),
        descripcionProducto: descripcionController.text.trim(),
        codigoBarra: widget.barcode,
        precioCosto: '0',
        precioVenta: precioController.text.trim(),
        proveedor: 'Sin Especificar',
        categoria: categoriaSeleccionada,
      );
      
      // Crear producto en la API
      final response = await controlador.productosProvider.create(nuevoProducto);
      
      if (response.success == true) {
        // Recargar productos
        await controlador.getProducts();
        
        // Agregar al carrito con cantidad 1
        controlador.addItem(nuevoProducto);
        
        Navigator.of(context).pop();
        Get.snackbar('Éxito', 'Producto creado y agregado');
      } else {
        Get.snackbar('Error', response.message ?? 'Error creando producto');
      }
      
    } catch (e) {
      print('Error creando producto: $e');
      Get.snackbar('Error', 'Error creando producto: $e');
    }
  }
}
*/