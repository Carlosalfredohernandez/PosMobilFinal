import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ventas_controller.dart';
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
  const CarritoWidget({Key? key, this.scrollController}) : super(key: key);

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
            onPressed: () => carritoController.limpiarCarrito(),
            child: const Text('Limpiar carrito'),
          ),
        ],
      );
    });
  }
}

// Si CarritoController y CarritoWidget están en archivos separados, descomentar y ajustar:
// import 'carrito_controller.dart';
// import 'carrito_widget.dart';

class VentasPage extends StatelessWidget {
  VentasPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Asegura que los controladores estén registrados solo una vez
    final controller = Get.isRegistered<VentasController>()
        ? Get.find<VentasController>()
        : Get.put(VentasController());
    final carritoController = Get.isRegistered<CarritoController>()
        ? Get.find<CarritoController>()
        : Get.put(CarritoController());

    return Obx(() {
      print(
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
            (id) => controller.categoriaNombreMap[id] ?? id ?? 'Sin categoría',
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
