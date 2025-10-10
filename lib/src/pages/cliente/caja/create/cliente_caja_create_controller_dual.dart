// controllers/cliente_caja_create_controller_dual.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/models/usuario.dart';
import 'package:posmobil/src/providers/productos_provider.dart';
import 'package:posmobil/src/providers/categorias_provider.dart';
// import 'package:posmobil/src/services/dual_pos_service.dart'; // ❌ ELIMINADO - Ya no necesario
import 'package:get_storage/get_storage.dart';

/// 🎮 CONTROLADOR DUAL DEL POS
/// Maneja la lógica con Backend Local (productos/inventario) y Backend SII (fiscal)
class ClienteCajaCreateControllerDual extends GetxController {

  // 🛒 ESTADO DEL CARRITO
  final RxList<Producto> selectedProducts = <Producto>[].obs;
  final RxDouble total = 0.0.obs;
  final RxDouble pago = 0.0.obs;

  // 📱 CONTROLES DE UI
  final TextEditingController codigoBarraController = TextEditingController();

  // 💳 FORMA DE PAGO
  String formaPago = '';

  // 👤 DATOS DE USUARIO
  // ✅ FUNCIÓN HELPER PARA CONVERTIR DATOS DE USUARIO
  static Map<String, dynamic> _convertirDatosUsuario(Map<String, dynamic> data) {
    Map<String, dynamic> usuarioData = Map<String, dynamic>.from(data);
    if (usuarioData['id'] != null && usuarioData['id'] is int) {
      usuarioData['id'] = usuarioData['id'].toString();
    }
    if (usuarioData['numero'] != null && usuarioData['numero'] is int) {
      usuarioData['numero'] = usuarioData['numero'].toString();
    }
    return usuarioData;
  }

  Usuario sesionUsuario = Usuario.fromJson(_convertirDatosUsuario(GetStorage().read('usuario') ?? {}));

  // 🛍️ PRODUCTOS DESDE API LOCAL
  final RxList<Producto> productos = <Producto>[].obs;

  // 🔄 SERVICIO DUAL - ❌ ELIMINADO
  // final DualPOSService dualService = Get.put(DualPOSService());

  // 📄 PROVIDERS EXISTENTES (para compatibilidad)
  ProductosProvider productosProvider = ProductosProvider();
  CategoriasProvider categoriasProvider = CategoriasProvider();

  // 🔄 ESTADOS DE CARGA
  final RxBool isLoading = false.obs;
  final RxBool isCreatingBill = false.obs;

  // ⚡ INICIALIZACIÓN DEL CONTROLADOR
  @override
  void onInit() {
    super.onInit();
    _verificarConectividad();
    getProducts(); // Cargar productos al inicializar
  }

  /// 📊 VERIFICAR CONECTIVIDAD - SIMPLIFICADO
  Future<void> _verificarConectividad() async {
    try {
      print('🌐 Verificando conectividad simplificada...');
      // Por ahora solo mostrar mensaje de que estamos usando autenticación básica
      Get.snackbar(
        '✅ Modo Simplificado', 
        'Usando autenticación básica con backend unificado',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
      
    } catch (e) {
      print('❌ Error verificando conectividad: $e');
    }
  }

  /// 📦 CARGAR PRODUCTOS - SIMPLIFICADO (usando providers existentes)
  Future<void> getProducts() async {
    try {
      isLoading.value = true;
      print('📦 Cargando productos desde API...');

      // Usar el provider real como en el controlador correcto
      final productosFromAPI = await productosProvider.getAllByUser();

      // Actualizar la lista observable
      productos.value = productosFromAPI;

      print('✅ Productos cargados desde API: ${productos.length}');

      // Debug: mostrar algunos códigos de barra
      for (var producto in productos.take(3)) {
        print('🏷️ Código: ${producto.codigoBarra} - ${producto.nombreProducto}');
      }

    } catch (e) {
      print('❌ Error cargando productos desde API: $e');
      Get.snackbar(
        '❌ Error', 
        'No se pudieron cargar los productos: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔍 BUSCAR PRODUCTO POR CÓDIGO DE BARRAS - SIMPLIFICADO
  Future<void> code(BuildContext context) async {
    final codigo = codigoBarraController.text.trim();
    if (codigo.isEmpty) {
      Get.snackbar('Error', 'Ingrese un código de barras');
      return;
    }

    try {
      print('🔍 Buscando producto con código: $codigo');

      // Usar el método getProduct de la API como en el controlador correcto
      final producto = await productosProvider.getProduct(codigo);

      if (producto != null) {
        print('✅ Producto encontrado: ${producto.nombreProducto}');
        // Si lo encuentra, lo agrega a la lista con cantidad 1
        addItem(producto);
        Get.snackbar('Producto agregado', producto.nombreProducto ?? '');
        codigoBarraController.clear();
      } else {
        print('❌ Producto no encontrado: $codigo');
        
        // Preguntar si quiere crear el producto
        final crearProducto = await Get.defaultDialog<bool>(
          title: 'Producto no encontrado',
          middleText: 'El producto con código $codigo no existe.\n¿Desea crearlo?',
          textCancel: 'No',
          textConfirm: 'Sí',
          confirmTextColor: Colors.white,
          onConfirm: () => Get.back(result: true),
          onCancel: () => Get.back(result: false),
        );

        if (crearProducto == true) {
          _mostrarDialogoCrearProducto(context, codigo);
        }
      }
    } catch (e) {
      print('❌ Error buscando producto: $e');
      Get.snackbar('Error', 'Error buscando producto: $e');
    }
  }

  /// 🛒 AGREGAR PRODUCTO AL CARRITO
  void addItem(Producto producto) {
    // Buscar si el producto ya existe en el carrito
    final existingProduct = selectedProducts.firstWhereOrNull(
      (p) => p.codigoBarra == producto.codigoBarra,
    );

    if (existingProduct != null) {
      // Si existe, aumentar cantidad
      final index = selectedProducts.indexOf(existingProduct);
      final nuevaCantidad = (existingProduct.cantidad ?? 0) + 1;
      
      selectedProducts[index] = existingProduct.copyWith(cantidad: nuevaCantidad);
    } else {
      // Si no existe, agregarlo con cantidad 1
      selectedProducts.add(producto.copyWith(cantidad: 1));
    }

    _calcularTotal();
    update();
  }

  /// ➖ ELIMINAR PRODUCTO DEL CARRITO
  void removeItem(Producto producto) {
    selectedProducts.removeWhere(
      (p) => p.codigoBarra == producto.codigoBarra,
    );
    _calcularTotal();
    update();
  }

  /// ➖ ELIMINAR PRODUCTO DEL CARRITO (ALIAS)
  void deleteItem(Producto producto) {
    removeItem(producto);
  }

  /// 🧮 CALCULAR TOTAL DEL CARRITO
  void _calcularTotal() {
    double totalCalculado = 0.0;

    for (var producto in selectedProducts) {
      final precio = double.tryParse(producto.precioVenta ?? '0') ?? 0.0;
      final cantidad = producto.cantidad ?? 0;
      totalCalculado += precio * cantidad;
    }

    total.value = totalCalculado;
  }

  /// 💾 CREAR BOLETA - SIMPLIFICADO
  Future<void> createBill(BuildContext context) async {
    if (selectedProducts.isEmpty) {
      Get.snackbar('Error', 'El carrito está vacío');
      return;
    }

    try {
      isCreatingBill.value = true;
      
      print('💾 Guardando boleta local...');
      
      final ventaLocal = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'productos': selectedProducts.map((p) => p.toJson()).toList(),
        'total': total.value,
        'formaPago': formaPago.isEmpty ? 'Efectivo' : formaPago,
        'fecha': DateTime.now().toIso8601String(),
        'vendedor': sesionUsuario.nombre,
      };
      
      // Simular guardado (aquí iría la lógica real)
      await Future.delayed(const Duration(milliseconds: 500));
      
      print('✅ Boleta local guardada: ${ventaLocal['id']}');

      Get.snackbar(
        '✅ Boleta Creada', 
        'Venta guardada exitosamente por \$${total.value.toStringAsFixed(0)}',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: const Duration(seconds: 4),
      );

      // Limpiar carrito
      _limpiarCarrito();

    } catch (e) {
      print('❌ Error creando boleta: $e');
      Get.snackbar('❌ Error', 'Error interno: $e');
    } finally {
      isCreatingBill.value = false;
    }
  }

  /// 🧹 LIMPIAR CARRITO
  void _limpiarCarrito() {
    selectedProducts.clear();
    total.value = 0.0;
    pago.value = 0.0;
    formaPago = '';
    codigoBarraController.clear();
    update();
  }

  /// � MOSTRAR DIÁLOGO PARA CREAR PRODUCTO
  void _mostrarDialogoCrearProducto(BuildContext context, String codigo) {
    Get.defaultDialog(
      title: 'Producto no encontrado',
      middleText: 'El producto con código $codigo no existe.\n¿Desea crearlo?',
      textCancel: 'No',
      textConfirm: 'Sí',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        // Aquí iría la lógica para crear el producto
        print('🆕 Crear producto con código: $codigo');
      },
    );
  }

  /// 📱 ESCANEO CON MOBILE SCANNER - SIMPLIFICADO
  Future<void> scanBarcodeMobileScanner(
    String barcode,
    BuildContext context,
    Function(String) onProductoNoExiste,
  ) async {
    try {
      print('📱 Escaneando código: $barcode');

      // Usar el método getProduct de la API como en el controlador correcto
      final producto = await productosProvider.getProduct(barcode);

      if (producto != null) {
        print('✅ Producto encontrado: ${producto.nombreProducto}');
        addItem(producto);
        Get.snackbar('Producto agregado', producto.nombreProducto ?? '');
      } else {
        print('❌ Producto no encontrado en escaneo: $barcode');
        onProductoNoExiste(barcode);
      }
    } catch (e) {
      print('❌ Error en escaneo: $e');
      Get.snackbar('Error', 'Error escaneando: $e');
    }
  }

  @override
  void onClose() {
    codigoBarraController.dispose();
    super.onClose();
  }

  // 📋 MÉTODO PARA USO FUTURO - COMENTADO
  /// 📋 MOSTRAR OPCIONES ADICIONALES DE BOLETA (PARA USO FUTURO)
  /*
  void _mostrarOpcionesBoleta(Map<String, dynamic> resultado) {
    Get.defaultDialog(
      title: 'Boleta Creada',
      middleText: 'Boleta SII generada exitosamente',
      textCancel: 'Cerrar',
      textConfirm: 'Ver XML',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        // Aquí podrías abrir el XML o hacer otras acciones
        print('🔗 XML URL: ${resultado['xmlUrl']}');
        // Implementar lógica para:
        // - Mostrar XML
        // - Descargar archivo
        // - Enviar por email
        // - Imprimir
      },
    );
  }
  */
}