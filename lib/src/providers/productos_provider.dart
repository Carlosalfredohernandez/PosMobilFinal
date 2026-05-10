import 'package:get/get.dart';
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/models/producto.dart';
import 'package:posmobilfinal/src/models/usuario.dart';

import '../environment/environment.dart';
import '../models/response_api.dart';


class ProductosProvider extends GetConnect {
  String url = '${Environment.API_URL}api/productos';

  Usuario get userSession => Usuario.fromJson(GetStorage().read('usuario') ?? {});

  void printUsuarioSessionDebug() {
    final raw = GetStorage().read('usuario');
    print('🟨 [PROVIDER] Usuario bruto en storage:');
    print(raw);
    final usuario = Usuario.fromJson(raw ?? {});
    print('🟨 [PROVIDER] Usuario.sessionToken: \\${usuario.sessionToken}\\');
  }

  Future<List<Producto>> findByCategory(String idCategory) async {
    printUsuarioSessionDebug();
    final session = userSession;
    Response response = await get(
        '$url/findByCategory/$idCategory',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': session.sessionToken ?? ''
        }
    );

    if (response.statusCode == 401) {
      Get.snackbar('Peticion denegada', 'Tu usuario no tiene permitido leer esta informacion');
      return [];
    }

    List<Producto> productos = Producto.fromJsonList(response.body);

    return productos;
  }

  Future<List<Producto>> getAllByUser() async {
    printUsuarioSessionDebug();
    final session = userSession;
    String userID = session.id.toString();
    Response response = await get(
        '$url/getAllByUser/$userID',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': session.sessionToken ?? ''
        }
    );

    if (response.statusCode == 401) {
      Get.snackbar('Peticion denegada', 'Tu usuario no tiene permitido leer esta informacion');
      return [];
    }

    List<Producto> productos = Producto.fromJsonList(response.body);
    // print(productos);
    return productos;
  }

  Future<Producto?> getProduct(String codigoBarra) async {
    printUsuarioSessionDebug();
    final session = userSession;
    Response response = await get(
        '$url/getProducto/$codigoBarra',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': session.sessionToken ?? ''
        }
    );
    if (response.body == null) {
      Get.snackbar('Peticion denegada', 'No existe el producto');
      return null;
    }
    try {
      Producto producto = Producto.fromJson(response.body);
      return producto;
    } catch (e) {
      Get.snackbar('Error', 'No se pudo convertir el producto');
      return null;
    }
  }

  Future<ResponseApi> create(Producto producto) async {
    printUsuarioSessionDebug();
    final session = userSession;
    Response response = await post(
        '$url/create',
        producto.toJson(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': session.sessionToken ?? ''
        }
    );

    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }

  Future<ResponseApi> update(Producto product) async {
    printUsuarioSessionDebug();
    Response response = await put(
        '$url/update',
        product.toJson(),
        headers:{
          'Content-Type': 'application/json'
        }
    );
    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo actualizar la informacion');
      return ResponseApi();
    }
    if (response.statusCode == 401) {
      Get.snackbar('Error', 'No esta autorizado para realizar esta peticion');
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);
    return responseApi;
  }

  Future<List<Producto>> findProductsOnText(var text) async {
    printUsuarioSessionDebug();
    final session = userSession;
    // Obtener el objeto usuarioempresa desde GetStorage
    final usuarioEmpresaRaw = GetStorage().read('usuarioempresa');
    String? empresa;
    if (usuarioEmpresaRaw is Map && usuarioEmpresaRaw['empresa'] != null) {
      empresa = usuarioEmpresaRaw['empresa'].toString();
    } else {
      print('❗ No se encontró el campo empresa en usuarioempresa');
      empresa = '';
    }
    String textLower = text.toString().toLowerCase();
    print('🔎 [findProductsOnText] Buscando "$textLower" para empresa $empresa');
    print('🔑 Token usado: ${session.sessionToken}');
    Response response = await get(
        '$url/findProductsOnText/$textLower/$empresa',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': session.sessionToken ?? ''
        }
    );

    print('🌐 Status: ${response.statusCode}');
    print('🌐 Body: ${response.body}');

    if (response.statusCode == 401) {
      Get.snackbar('Peticion denegada', 'Tu usuario no tiene permitido leer esta informacion');
      return [];
    }

    dynamic body = response.body;
    // Si la respuesta es String, decodificar JSON
    if (body is String) {
      try {
        body = body.isNotEmpty ? jsonDecode(body) : [];
      } catch (e) {
        print('❗ Error decodificando body: $e');
        body = [];
      }
    }
    List<Producto> productos = Producto.fromJsonList(body);
    print('📦 Productos recibidos: ${productos.length}');
    for (var p in productos) {
      print('➡️ ${p.nombreProducto} | ${p.codigoBarra}');
    }
    return productos;
  }

  Future<List<Producto>> findProductsOnTextWithCategory(var text, var category) async {
    printUsuarioSessionDebug();
    final session = userSession;
    String idUsuario = session.id.toString();
    Response response = await get(
        '$url/findProductsOnTextWithCategory/$category/$text/$idUsuario',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': session.sessionToken ?? ''
        }
    );

    if (response.statusCode == 401) {
      Get.snackbar('Peticion denegada', 'Tu usuario no tiene permitido leer esta informacion');
      return [];
    }

    List<Producto> productos = Producto.fromJsonList(response.body);
    print('[DEBUG] JSON productos recibidos:');
    print(response.body);
    return productos;
  }

  Future<ResponseApi> deshabilitar(String productId) async {
    printUsuarioSessionDebug();
    final session = userSession;
    Response response = await get(
        '$url/deshabilitar/$productId',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': session.sessionToken!
        }
    );

    ResponseApi responseApi = ResponseApi.fromJson(response.body);
    return responseApi;
  }
}