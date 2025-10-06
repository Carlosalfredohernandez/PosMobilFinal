// controllers/cliente_caja_create_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:posmobil/src/models/categoria.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/models/usuario.dart';
import 'package:posmobil/src/providers/productos_provider.dart';
import 'package:posmobil/src/providers/categorias_provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:collection/collection.dart';

/// 🎮 CONTROLADOR PRINCIPAL DEL POS
class ClienteCajaCreateController extends GetxController {
  
  // 🛒 ESTADO DEL CARRITO
  final RxList<Producto> selectedProducts = <Producto>[].obs;
  final RxDouble total = 0.0.obs;
  final RxDouble pago = 0.0.obs;
  
  // 📱 CONTROLES DE UI
  final TextEditingController codigoBarraController = TextEditingController();
  
  // 💳 FORMA DE PAGO
  String formaPago = '';
  
  // 👤 DATOS DE USUARIO
  Usuario sesionUsuario = Usuario.fromJson(GetStorage().read('usuario') ?? {});
  
  // 🛍️ PRODUCTOS DESDE API
  final RxList<Producto> productos = <Producto>[].obs;
  
  // 🔄 PROVIDERS REALES
  ProductosProvider productosProvider = ProductosProvider();
  CategoriasProvider categoriasProvider = CategoriasProvider();

  // ⚡ INICIALIZACIÓN DEL CONTROLADOR
  @override
  void onInit() {
    super.onInit();
    getProducts(); // Cargar productos al inicializar
  }

  /// 📦 CARGAR PRODUCTOS DESDE LA API
  Future<void> getProducts() async {
    try {
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
    }
  }

  /// 🔍 BUSCAR PRODUCTO POR CÓDIGO DE BARRAS USANDO API
  Future<void> code(BuildContext context) async {
    final codigo = codigoBarraController.text.trim();
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
        Get.snackbar('Producto agregado', producto.nombreProducto ?? '');
      } else {
        print('❌ Producto no encontrado para código: $codigo');
        // Si no lo encuentra, abre el modal de creación
        await _showProductoNoExisteDialog(context, codigo);
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
        Get.snackbar('Producto agregado', producto.nombreProducto ?? '');
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
  Future<void> _showProductoNoExisteDialog(BuildContext context, String barcode) async {
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
      final precio = double.tryParse(producto.precioVenta ?? '0') ?? 0.0;
      final cantidad = producto.cantidad ?? 0;
      totalCalculado += precio * cantidad;
    }
    
    total.value = totalCalculado;
  }

  /// 💾 CREAR BOLETA (MOCK)
  Future<void> createBill(BuildContext context) async {
    try {
      print('💾 Guardando boleta local...');
      
      final ventaLocal = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'productos': selectedProducts.map((p) => p.toJson()).toList(),
        'total': total.value,
        'formaPago': formaPago,
        'fecha': DateTime.now().toIso8601String(),
        'vendedor': sesionUsuario.nombre,
      };
      
      // Aquí iría la lógica para guardar en base de datos local
      await Future.delayed(const Duration(milliseconds: 500));
      
      print('✅ Boleta local guardada: ${ventaLocal['id']}');
      
      _mostrarMensaje('Venta guardada exitosamente');
      
    } catch (e) {
      print('❌ Error guardando boleta local: $e');
      _mostrarMensaje('Error guardando venta: $e', esError: true);
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
    codigoBarraController.clear();
    update();
  }

  @override
  void onClose() {
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