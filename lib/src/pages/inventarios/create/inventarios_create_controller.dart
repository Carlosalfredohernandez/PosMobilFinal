import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:posmobil/src/models/inventario.dart';
import 'package:posmobil/src/models/local.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/models/proveedores.dart';
import 'package:posmobil/src/models/response_api.dart';
import 'package:posmobil/src/models/usuario.dart';
import 'package:posmobil/src/providers/boletas_provider.dart';
import 'package:posmobil/src/providers/inventario_provider.dart';
import 'package:posmobil/src/providers/local_provider.dart';
import 'package:posmobil/src/providers/productos_provider.dart';
import 'package:posmobil/src/providers/proveedor_provider.dart';

class InventariosCreateController extends GetxController {
  List<Local> locales = <Local>[].obs;
  List<Proveedor> proveedores = <Proveedor>[].obs;
  List<Producto> productos = <Producto>[];
  TextEditingController guiaController = TextEditingController();
  TextEditingController numController = TextEditingController();
  var numero = 0.obs;
  ProductosProvider productosProvider = ProductosProvider();
  var selectedProducts = <Producto>[].obs;
  DateTime currentSelectedDate = DateTime.now();
  DateTime fecha = DateTime.now();
  LocalProvider localProvider = LocalProvider();
  ProveedorProvider proveedorProvider = ProveedorProvider();
  InventarioProvider inventarioProvider = InventarioProvider();

  var localAsignado = ''.obs;
  var prove = ''.obs;
  var total = 0.obs;
  var pago = 0.obs;
  var formaPago = '';
  String _codigoBarra = '';
  TextEditingController codigoBarraController = TextEditingController();
  TextEditingController cashController = TextEditingController();
  Usuario sesionUsuario = Usuario.fromJson(GetStorage().read('usuario') ?? {});
  BoletasProvider boletasProvider = BoletasProvider();

  InventariosCreateController() {
    getProductos();
    getLocales();
    getProveedores();
  }

  void onChangeText(String text) {
    pago.value = int.parse(text);
  }

  /*void getTotal() {
    total.value = 0;
    for (var product in selectedProducts) {
      total.value = total.value + (product.cantidad! * int.parse('${product.precioVenta}'));
    }
  }
*/
  void deleteItem(Producto product) {
    selectedProducts.remove(product);
    //getTotal();
    product.cantidad = 0;
  }

  void addItem(Producto product) {
    int index = selectedProducts.indexWhere((p) => p.id == product.id);
    selectedProducts.remove(product);
    product.cantidad = product.cantidad! + 1;
    selectedProducts.insert(index, product);
    //getTotal();
  }

  void getCantidad(Producto product, String texto) {
    product.cantidad = int.parse(texto);
  }

  void getProductos() async {
    var result = await productosProvider.getAllByUser();
    productos.clear();
    productos.addAll(result);
  }

  void getLocales() async {
    var result = await localProvider.findLocals();
    locales.clear();
    locales.addAll(result);
  }

  void goToView() {
    Get.toNamed('/inventarios/vista');
  }

  void getProveedores() async {
    var result = await proveedorProvider.getProveedor();
    proveedores.clear();
    proveedores.addAll(result);
    print(proveedores);
  }

  void createInventario() async {
    if (validador(localAsignado.value, prove.value, guiaController.text)) {
      Inventario inventario = Inventario(
        productos: selectedProducts,
        fecha: '$fecha',
        local: int.parse(localAsignado.value),
        idProvedor: int.parse(prove.value),
        idCliente: '${23}',
        idUsuarioE: '1',
        nroDocumento: int.parse(guiaController.text.trim()),
      );
      ResponseApi responseApi = await inventarioProvider.create(inventario);
      if (responseApi.success == true) {
        Get.snackbar('Registro logrado', responseApi.message ?? '');
      } else {
        Get.snackbar('Registro fallido', responseApi.message ?? '');
      }
    }
  }

  bool validador(
    String local,
    String proveedor,
    String documento,
  ) {
    if (local.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar el local asignado');
      return false;
    }
    if (proveedor.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar el proveedor');
      return false;
    }
    if (documento.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar el numero de documento');
      return false;
    }
    return true;
  }

  void addToBag(Producto product) {
    int index = selectedProducts.indexWhere((p) => p.id == product.id);
    if (index == -1) {
      if (product.cantidad == null || product.cantidad == 0) {
        product.cantidad = 0;
      }
      selectedProducts.add(product);
      //getTotal();
    } else {
      addItem(selectedProducts[index]);
    }
    //GetStorage().write('shopping_bag', selectedProducts);
  }

  // Refactor: Usar MobileScanner para escanear código de barras
  // ...existing code...

Future<void> scanBarcodeNormal(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => SizedBox(
      height: 400,
      child: MobileScanner(
        onDetect: (capture) async {
          final barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final code = barcodes.first.rawValue ?? '';
            if (code.isNotEmpty) {
              _codigoBarra = code;
              codigoBarraController.text = code;
              var result = await productosProvider.getProduct(_codigoBarra);
              if (result != null) {
                addToBag(result);
              } else {
                Get.snackbar('Error', 'Producto no encontrado');
              }
              Navigator.pop(context);
            }
          }
        },
      ),
    ),
  );
}

Future<void> code() async {
  _codigoBarra = codigoBarraController.text.trim();
  var result = await productosProvider.getProduct(_codigoBarra);
  if (result != null) {
    addToBag(result);
  } else {
    Get.snackbar('Error', 'Producto no encontrado');
  }
}
// ...existing code...

  /// Busca el producto por código de barras en la lista de productos cargados
  Future<Producto?> getProductByCodigoBarra(String codigo) async {
    try {
      return productos.firstWhere((p) => p.codigoBarra == codigo);
    } catch (_) {
      return null;
    }
  }

  /// Agrega el producto a la lista seleccionada o suma cantidad si ya existe
  void addOrUpdateSelectedProduct(Producto producto) {
  // Si ya existe, actualiza la cantidad; si no, lo agrega
  final index = selectedProducts.indexWhere((p) => p.nombreProducto == producto.nombreProducto);
  if (index == -1) {
    selectedProducts.add(producto);
  } else {
    selectedProducts[index].cantidad = producto.cantidad;
  }
  selectedProducts.refresh();
}

// ...existing code...
// ...existing code...
}
