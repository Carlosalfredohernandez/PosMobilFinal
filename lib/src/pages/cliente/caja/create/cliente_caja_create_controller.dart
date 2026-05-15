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
  /// Emite boleta SII usando la API y guarda el XML real y el ID para el PDF
  Future<void> emitirBoletaSii({required BuildContext context}) async {
    isLoading.value = true;
    try {
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
      final boletaProvider = BoletaProvider();
      final boletaResponse = await boletaProvider.generarBoleta(boletaData);
      if (boletaResponse == null) {
        Get.snackbar('❌ Error', 'No se pudo generar la boleta SII');
        return;
      }
      final boletaId = boletaResponse['id']?.toString() ?? '';
      print('✅ Boleta generada con ID: $boletaId');
      // Obtener XML del DTE autorizado
      final xml = await boletaProvider.obtenerXmlBoleta(boletaId);
      if (xml == null || xml.isEmpty) {
        Get.snackbar('❌ Error', 'No se pudo obtener el XML de la boleta');
        return;
      }
      print('✅ XML recibido del SII');
      dteXmlString = xml;
      dteXmlDocument = XmlDocument.parse(xml);
      dteBoletaId = boletaId;
      Get.snackbar('✅ Éxito', 'Boleta SII emitida y autorizada');
      update();
    } catch (e) {
      print('❌ Error emitiendo boleta SII: $e');
      Get.snackbar('❌ Error', 'Error emitiendo boleta SII: $e');
    } finally {
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
        localUsuario: sesionUsuario.localOficina ?? '',
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

  const _CrearProductoDialog({required this.barcode});

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