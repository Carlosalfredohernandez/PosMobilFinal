import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/models/usuario.dart';

import '../environment/environment.dart';
import '../models/response_api.dart';

class ProductosProvider extends GetConnect {
  String url = '${Environment.API_URL}api/productos';

  Usuario userSession = Usuario.fromJson(GetStorage().read('usuario') ?? {});

  Future<List<Producto>> findByCategory(String idCategory) async {
    Response response = await get(
        '$url/findByCategory/$idCategory',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
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
    String userID = userSession.id.toString();
    Response response = await get(
        '$url/getAllByUser/$userID',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        }
    );

    if (response.statusCode == 401) {
      Get.snackbar('Peticion denegada', 'Tu usuario no tiene permitido leer esta informacion');
      return [];
    }

    List<Producto> productos = Producto.fromJsonList(response.body);
    print(productos);
    return productos;
  }

  Future<Producto?> getProduct(String codigoBarra) async {
    Response response = await get(
        '$url/getProducto/$codigoBarra',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
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
    Response response = await post(
        '$url/create',
        producto.toJson(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        }
    );

    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }

  Future<ResponseApi> update(Producto product) async {
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
    String idUsuario = userSession.id.toString();
    Response response = await get(
        '$url/findProductsOnText/$text/$idUsuario',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        }
    );

    if (response.statusCode == 401) {
      Get.snackbar('Peticion denegada', 'Tu usuario no tiene permitido leer esta informacion');
      return [];
    }

    List<Producto> productos = Producto.fromJsonList(response.body);
    return productos;
  }

  Future<List<Producto>> findProductsOnTextWithCategory(var text, var category) async {
    String idUsuario = userSession.id.toString();
    Response response = await get(
        '$url/findProductsOnTextWithCategory/$category/$text/$idUsuario',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        }
    );

    if (response.statusCode == 401) {
      Get.snackbar('Peticion denegada', 'Tu usuario no tiene permitido leer esta informacion');
      return [];
    }

    List<Producto> productos = Producto.fromJsonList(response.body);
    return productos;
  }

  Future<ResponseApi> deshabilitar(String productId) async {
    Response response = await get(
        '$url/deshabilitar/$productId',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken!
        }
    );

    ResponseApi responseApi = ResponseApi.fromJson(response.body);
    return responseApi;
  }
}