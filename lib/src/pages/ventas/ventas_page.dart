import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'ventas_controller.dart';
import 'package:posmobilfinal/src/models/boleta.dart';
import 'package:posmobilfinal/src/models/inventario.dart';
import 'package:posmobilfinal/src/providers/boletas_provider.dart';
import 'package:posmobilfinal/src/providers/boleta_provider.dart';
import 'package:posmobilfinal/src/models/producto.dart';

// --- Controlador del carrito ---
class CarritoController extends GetxController {
  var carrito = <Producto, int>{}.obs;

  int get totalProductos => carrito.values.fold(0, (a, b) => a + b);
  int get totalMonto {
    int total = 0;
    carrito.forEach((producto, cantidad) {
      final precio = int.tryParse(producto.precioVenta ?? '0') ?? 0;
      total += precio * cantidad;
    });
    return total;
  }

  void agregarProducto(Producto producto) {
    if (carrito.containsKey(producto)) {
      carrito[producto] = carrito[producto]! + 1;
    } else {
      carrito[producto] = 1;
    }
    update();
  }

  void quitarProducto(Producto producto) {
    if (carrito.containsKey(producto) && carrito[producto]! > 1) {
      carrito[producto] = carrito[producto]! - 1;
    } else {
      carrito.remove(producto);
    }
    update();
  }

  void limpiarCarrito() {
    carrito.clear();
    update();
  }
}

// --- Widget mínimo del carrito ---
class CarritoWidget extends StatelessWidget {
  final ScrollController? scrollController;
  const CarritoWidget({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    final carritoController = Get.find<CarritoController>();
    return Obx(() {
      final productos = carritoController.carrito;
      return ListView(
        controller: scrollController,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Carrito',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (productos.isEmpty) const Text('No hay productos en el carrito.'),
          ...productos.entries.map(
            (entry) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(entry.key.nombreProducto ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Precio: ${entry.key.precioVenta ?? '0'}'),
                    Text(
                      'Subtotal: \$${(int.tryParse(entry.key.precioVenta ?? '0') ?? 0) * entry.value}',
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (entry.value > 1) {
                              carritoController.quitarProducto(entry.key);
                            }
                          },
                        ),
                        Text(
                          '${entry.value}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            carritoController.agregarProducto(entry.key);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Eliminar producto',
                  onPressed: () {
                    carritoController.carrito.remove(entry.key);
                    carritoController.update();
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Total: ${carritoController.totalMonto}'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              await _finalizarVenta(carritoController);
            },
            child: const Text('Cobrar y finalizar venta'),
          ),
        ],
      );
    });
  }

}

// Esta función debe estar fuera de cualquier clase o método build
Future<void> _finalizarVenta(CarritoController carritoController) async {
  if (carritoController.carrito.isEmpty) {
    Get.snackbar('Carrito vacío', 'Agrega productos antes de cobrar');
    return;
  }
  try {
    // 1. Construir boleta local y grabar en backendposmobil
    final productos = carritoController.carrito;
    final total = productos.entries.fold(0, (sum, entry) {
      final precioVenta = entry.key.precioVenta ?? '0';
      final precio = int.tryParse(precioVenta) ?? 0;
      return sum + (precio * entry.value);
    });
    final boletasProvider = Get.put(BoletasProvider());
    // Datos mínimos para inventario
    final usuario = boletasProvider.userSession;
    final numeroBoleta = '201'; // String
    final localUsuario = (usuario.localOficina != null && usuario.localOficina!.isNotEmpty)
        ? usuario.localOficina!
        : '1';
    final idUsuario = usuario.id?.toString() ?? "";
    final idUsuarioE = usuario.id?.toString() ?? "1";
    final idCliente = '23'; // String
    final fechaHoy = DateTime.now();
    final fechaStr = "${fechaHoy.year.toString().padLeft(4, '0')}-${fechaHoy.month.toString().padLeft(2, '0')}-${fechaHoy.day.toString().padLeft(2, '0')}";

    final productosPayload = productos.entries.map((entry) {
      return {
        "id": entry.key.id?.toString() ?? '',
        "cantidad": entry.value,
        "precio_venta": int.tryParse(entry.key.precioVenta ?? "0") ?? 0,
      };
    }).toList();

    final inventarioObj = Inventario(
      idCliente: idCliente,
      local: int.tryParse(localUsuario) ?? 1,
      idUsuarioE: idUsuarioE,
      fecha: fechaStr,
      nroDocumento: int.tryParse(numeroBoleta) ?? 201,
    );

    final boletaLocal = Boleta(
      numero: numeroBoleta,
      usuario: idUsuario,
      localUsuario: localUsuario,
      valor: total.toString(),
      formaPago: 'EFECTIVO',
      inventario: inventarioObj,
      productos: productosPayload,
    );

    bool boletaLocalGuardada = false;
    final responseApi = await boletasProvider.create(boletaLocal);
    if (responseApi.success == true) {
      boletaLocalGuardada = true;
    } else {
      final backendMessage = responseApi.message ?? '';
      if (_esFalloTemporalBackend(backendMessage)) {
        final continuarContingencia = await Get.dialog<bool>(
              AlertDialog(
                title: const Text('Servidor no disponible'),
                content: const Text(
                  'No se pudo grabar en backendposmobil por una falla temporal del servidor. ¿Desea continuar la venta y dejar esta boleta como pendiente de sincronizacion?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text('Continuar'),
                  ),
                ],
              ),
            ) ??
            false;

        if (!continuarContingencia) {
          Get.snackbar(
            'Error',
            'No se pudo grabar la boleta: ${responseApi.message ?? 'error de servidor'}',
          );
          return;
        }

        await _guardarBoletaPendiente(boletaLocal.toJson());
        Get.snackbar(
          'Modo contingencia',
          'Boleta marcada como pendiente para sincronizar cuando vuelva el backend.',
        );
      } else {
        Get.snackbar(
          'Error',
          responseApi.message?.isNotEmpty == true
              ? 'No se pudo grabar la boleta: ${responseApi.message}'
              : 'No se pudo grabar la boleta en backendposmobil',
        );
        return;
      }
    }

    final detallesSii = productos.entries.map((entry) {
      final precioVenta = entry.key.precioVenta ?? '0';
      final precio = int.tryParse(precioVenta) ?? 0;
      return {
        'nombre': entry.key.nombreProducto ?? '',
        'cantidad': entry.value,
        'precio': precio,
        'monto_item': precio * entry.value,
      };
    }).toList();

    // 2. Grabar boleta en API SII
    final boletaSii = {
      'emisor': '99999999-9',
      'receptor': {'rut': '11111111-1', 'razon': 'Cliente POS'},
      'detalles': detallesSii,
      'total': total,
      'api_key': 'Vikingo80',
    };
    final boletaProvider = Get.put(BoletaProvider());
    final boletaId = await boletaProvider.generarBoleta(boletaSii);
    if (boletaId == null) {
      Get.snackbar('Error', 'No se pudo grabar la boleta en SII');
      return;
    }
    // 3. Preguntar al usuario si quiere PDF o impresión
    final opcion = await Get.dialog<String>(
      AlertDialog(
        title: const Text('¿Qué desea hacer?'),
        content: const Text(
          'La venta fue registrada en ambos sistemas. ¿Desea ver el PDF o imprimir la boleta?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: 'pdf'),
            child: const Text('Ver PDF'),
          ),
          TextButton(
            onPressed: () => Get.back(result: 'imprimir'),
            child: const Text('Imprimir'),
          ),
        ],
      ),
    );
    if (opcion == 'pdf') {
      // Navegar a pantalla de PDF (ajusta según tu flujo)
      Get.toNamed('/boleta_pdf_pos', arguments: {'boletaId': boletaId});
    } else if (opcion == 'imprimir') {
      // Navegar a pantalla de impresión directa (ajusta según tu flujo)
      Get.toNamed('/boleta_pdf_pos', arguments: {'boletaId': boletaId, 'imprimir': true});
    }
    carritoController.limpiarCarrito();
    if (boletaLocalGuardada) {
      Get.snackbar(
        'Venta finalizada',
        'La venta fue registrada y el carrito limpiado',
      );
    } else {
      Get.snackbar(
        'Venta finalizada en contingencia',
        'Emitida en SII y guardada como pendiente en backendposmobil.',
      );
    }
  } catch (e) {
    Get.snackbar('Error', 'Ocurrió un error: $e');
  }
}

bool _esFalloTemporalBackend(String message) {
  final msg = message.toLowerCase();
  return msg.contains('failed to respond') ||
      msg.contains('temporalmente no disponible') ||
      msg.contains('timeout') ||
      msg.contains('502') ||
      msg.contains('503') ||
      msg.contains('504');
}

Future<void> _guardarBoletaPendiente(Map<String, dynamic> boletaJson) async {
  final storage = GetStorage();
  final raw = storage.read('boletas_pendientes');
  final pendientes = <Map<String, dynamic>>[];

  if (raw is List) {
    for (final item in raw) {
      if (item is Map) {
        pendientes.add(Map<String, dynamic>.from(item));
      }
    }
  }

  pendientes.add({...boletaJson, 'pendiente_sync': true});
  await storage.write('boletas_pendientes', pendientes);
}

// Si CarritoController y CarritoWidget están en archivos separados, descomentar y ajustar:
// import 'carrito_controller.dart';
// import 'carrito_widget.dart';

class VentasPage extends StatelessWidget {
  const VentasPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Asegura que los controladores estén registrados solo una vez
    final controller = Get.isRegistered<VentasController>()
        ? Get.find<VentasController>()
        : Get.put(VentasController());
    if (!Get.isRegistered<CarritoController>()) {
      Get.put(CarritoController());
    }

    return Obx(() {
      debugPrint(
        '[VENTAS][BUILD] isLoading: [36m${controller.isLoading.value}[0m, error: [31m${controller.error.value}[0m, productos: [32m${controller.productos.length}[0m',
      );

      if (controller.isLoading.value) {
        return Scaffold(
          appBar: AppBar(title: const Text('Ventas')),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      if (controller.error.value.isNotEmpty) {
        return Scaffold(
          appBar: AppBar(title: const Text('Ventas')),
          body: Center(
            child: Text(
              controller.error.value,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      }

      if (controller.productos.isEmpty ||
          controller.categoriaNombreMap.isEmpty) {
        return Scaffold(
          appBar: AppBar(title: const Text('Ventas')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Diagnóstico de datos',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Productos cargados: ${controller.productos.length}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Categorías cargadas: ${controller.categoriaNombreMap.length}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                if (controller.productos.isNotEmpty)
                  ...controller.productos.map(
                    (p) => Text(
                      'Producto: ${p.nombreProducto ?? ''} | Cat: ${p.categoria ?? ''}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                if (controller.productos.isEmpty)
                  const Text(
                    'No hay productos disponibles.',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                if (controller.categoriaNombreMap.isEmpty)
                  const Text(
                    'No hay categorías cargadas.',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
              ],
            ),
          ),
        );
      }

      final categoriaIds = controller.productos
          .map((p) => p.categoria ?? 'Sin categoría')
          .toSet()
          .toList();
      final categorias = categoriaIds
          .map(
            (id) => controller.categoriaNombreMap[id] ?? id,
          )
          .toList();
      final tabs = categorias.isNotEmpty ? categorias : ['Sin categoría'];
      final tabIds = categoriaIds.isNotEmpty ? categoriaIds : ['Sin categoría'];

      return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.exit_to_app),
              tooltip: 'Salir',
              onPressed: () {
                // Ir al menú inicial de logeo
                Get.offAllNamed('/login');
              },
            ),
            title: const Text('Ventas'),
            actions: [
              GetBuilder<CarritoController>(
                builder: (carritoController) {
                  final cantidad = carritoController.carrito.values.fold<int>(
                    0,
                    (a, b) => a + b,
                  );
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        onPressed: () {
                          showModalBottomSheet(
                            context: Get.context!,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            builder: (_) => DraggableScrollableSheet(
                              expand: false,
                              initialChildSize: 0.7,
                              minChildSize: 0.4,
                              maxChildSize: 0.95,
                              builder: (context, scrollController) =>
                                  CarritoWidget(
                                    scrollController: scrollController,
                                  ),
                            ),
                          );
                        },
                      ),
                      if (cantidad > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Text(
                              cantidad.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
            bottom: TabBar(
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              tabs: tabs.map((cat) => Tab(text: cat)).toList(),
            ),
          ),
          body: TabBarView(
            children: tabIds.map((catId) {
              final productosCategoria = controller.productos
                  .where((p) => (p.categoria ?? 'Sin categoría') == catId)
                  .toList();
              if (productosCategoria.isEmpty) {
                return const Center(
                  child: Text('No hay productos en esta categoría.'),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: productosCategoria.length,
                itemBuilder: (context, index) {
                  final producto = productosCategoria[index];
                  final url = producto.imagenUrl;
                  return Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 60,
                            child: (url != null && url.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      url,
                                      width: double.infinity,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                    ),
                                  )
                                : Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            producto.nombreProducto ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Precio: \u0024${producto.precioVenta != null ? producto.precioVenta.toString() : ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(),
                          SizedBox(
                            height: 32,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.shopping_cart, size: 16),
                              label: const Text('Comprar', style: TextStyle(fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                minimumSize: const Size(0, 32),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                final carritoController = Get.find<CarritoController>();
                                carritoController.agregarProducto(producto);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      );
    });
  }
}
