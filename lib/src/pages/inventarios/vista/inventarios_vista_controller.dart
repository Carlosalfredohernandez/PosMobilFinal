import 'package:get/get.dart';
import 'dart:async';
import 'package:posmobilfinal/src/models/inventario.dart';
import 'package:posmobilfinal/src/providers/inventario_provider.dart';
import 'package:posmobilfinal/src/providers/productos_provider.dart';
import 'package:posmobilfinal/src/models/producto.dart';
import 'package:posmobilfinal/src/providers/categorias_provider.dart';

class InventariosVistaController extends GetxController {
      /// Filtra el stock por las fechas seleccionadas y actualiza la lista mostrada
      void aplicarFiltroPorFecha() {
        final filtrados = stockFiltradoPorFecha;
        stock
          ..clear()
          ..addAll(filtrados);
        update();
      }
    RxBool cargandoDatos = true.obs;
  Rxn<DateTime> fechaDesde = Rxn<DateTime>(DateTime.now());
  Rxn<DateTime> fechaHasta = Rxn<DateTime>(DateTime.now());

  void setFechaDesde(DateTime? fecha) {
    fechaDesde.value = fecha;
    update();
  }

  void setFechaHasta(DateTime? fecha) {
    fechaHasta.value = fecha;
    update();
  }

  List<Inventario> get stockFiltradoPorFecha {
    final desde = fechaDesde.value;
    final hasta = fechaHasta.value;
    if (desde == null && hasta == null) return stock.value;
    return stock.value.where((inv) {
      if (inv.fecha == null) return false;
      final fechaInv = DateTime.tryParse(inv.fecha!);
      if (fechaInv == null) return false;
      if (desde != null && fechaInv.isBefore(desde)) return false;
      if (hasta != null && fechaInv.isAfter(hasta)) return false;
      return true;
    }).toList();
  }
  /// Devuelve un mapa agrupado por codigoProducto con el total de cantidad por producto,
  /// filtrando por categoría si corresponde
  Map<dynamic, int> get stockAgrupadoPorProducto {
    final inventariosFiltrados = categoriaSeleccionada.value.isEmpty
        ? stock.value
        : stock.value.where((inv) {
            final prod = productos.firstWhereOrNull(
              (p) => p.id?.toString().trim() == inv.codigoProducto?.toString().trim(),
            );
            return prod?.categoria == categoriaSeleccionada.value;
          }).toList();
    final agrupado = inventarioProvider.agruparPorCodigoProducto(inventariosFiltrados);
    return agrupado.map((codigo, lista) => MapEntry(
      codigo,
      lista.fold<int>(0, (prev, inv) => prev + (inv.cantidad ?? 0)),
    ));
  }
    final CategoriasProvider categoriasProvider = CategoriasProvider();
  final ProductosProvider productosProvider = ProductosProvider();
  Map<String, String> nombresProductos = {};
  List<Producto> productos = [];
  RxList<String> categorias = <String>[].obs;
  Map<String, String> nombreCategorias = {}; // id -> nombre legible
  RxString categoriaSeleccionada = ''.obs;
  RxList<Inventario> stock = <Inventario>[].obs;
  List<Inventario> filter = <Inventario>[].obs;
  InventarioProvider inventarioProvider = InventarioProvider();
  var texto = ''.obs;
  var total = 0.obs;
  Timer? searchOnStoppedTyping;

  List<Inventario> get stockFiltrado {
    if (categoriaSeleccionada.value.isEmpty) return stock.value;
    return stock.value.where((inv) {
      final codigo = inv.codigoProducto ?? '';
      final producto = productos.firstWhereOrNull((p) => p.codigoBarra == codigo);
      return producto != null && producto.categoria == categoriaSeleccionada.value;
    }).toList();
  }


  final dynamic _id;
  InventariosVistaController(this._id);

  @override
  void onInit() {
    super.onInit();
    print('InventariosVistaController onInit, id: \\$_id');
    if (_id == null || _id == '') {
      getAllStock();
    } else {
      getTheStock(_id);
    }
    getTotal();
  }

  Future<void> cargarNombresProductos() async {
      print('Entrando a cargarNombresProductos...');
      try {
          print('Llamando a productosProvider.getAllByUser()');
          var productosList = await productosProvider.getAllByUser();
          print('Productos recibidos: \\${productosList.length}');
          productos.clear();
          productos.addAll(productosList);
          print('productos.addAll completado');
        nombresProductos.clear();
        categorias.clear();
        nombreCategorias.clear();
        // 1. Obtener todas las categorías del usuario
          print('Llamando a categoriasProvider.getAllByUser()');
          var categoriasList = await categoriasProvider.getAllByUser();
          print('Categorias recibidas: \\${categoriasList.length}');
        final Map<String, String> mapaCategorias = { for (var c in categoriasList) c.id ?? '': c.nombreCategoria ?? '' };
        print('Categorias cargadas (id -> nombre): $mapaCategorias');
        // 2. Procesar productos
        for (final p in productos) {
          print('Producto: ${p.nombreProducto}, categoria: ${p.categoria}');
          if (p.codigoBarra != null && p.nombreProducto != null) {
            nombresProductos[p.codigoBarra!] = p.nombreProducto!;
          }
          if (p.categoria != null && p.categoria!.isNotEmpty) {
            if (!categorias.contains(p.categoria)) {
              categorias.add(p.categoria!);
            }
            // Usar el nombre legible si existe
            nombreCategorias[p.categoria!] = mapaCategorias[p.categoria!] ?? p.categoria!;
          }
        }
        categorias.sort();
        update();
      } catch (e, s) {
        print('Error en cargarNombresProductos: $e');
        print(s);
      }
  }

  void getAllStock() async {
    cargandoDatos.value = true;
    try {
      print('getAllStock: antes de llamar a inventarioProvider.getAllByUser');
      var result = await inventarioProvider.getAllByUser();
      print('getAllStock: resultado de inventarioProvider.getAllByUser ->');
      print(result);
      print('Tipo real de result: ' + result.runtimeType.toString());
      print('result.toString: ' + result.toString());
      print('Tipo de result: ' + result.runtimeType.toString());
      if (result is List && result.isNotEmpty) {
        print('Tipo de primer elemento: ' + result.first.runtimeType.toString());
      }
      print('getAllStock: después de inventarioProvider.getAllByUser');
      stock.clear();
      print('getAllStock: después de stock.clear()');
      try {
        if (result is List && result.isNotEmpty) {
          print('Tipos de los elementos de result:');
          for (var i = 0; i < result.length; i++) {
            print('Elemento $i: ' + result[i].runtimeType.toString());
          }
        } else {
          print('Result vacío o no es lista');
        }
      } catch (e, s) {
        print('Error en inspección de tipos de result: $e');
        print(s);
        cargandoDatos.value = false;
        return;
      }
      stock.addAll(result);
      print('Antes de cargarNombresProductos en getAllStock');
      await cargarNombresProductos();
      print('Después de cargarNombresProductos en getAllStock');
      getTotal();
      cargandoDatos.value = false;
    } catch (e, s) {
      print('Error en getAllStock: $e');
      print(s);
      cargandoDatos.value = false;
    }
  }

  void getTheStock(var producto) async {
    var result = await inventarioProvider.getByCodigo(producto);
    stock.clear();
    stock.addAll(result);
    print('Antes de cargarNombresProductos en getTheStock');
    await cargarNombresProductos();
    print('Después de cargarNombresProductos en getTheStock');
    getTotal();
  }

  void getTotal() {
    total.value = 0;
    for (var element in stock.value) {
      total.value = total.value + (element.cantidad ?? 0);
    }
  }
}