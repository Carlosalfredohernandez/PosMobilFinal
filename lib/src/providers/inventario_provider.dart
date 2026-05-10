import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/environment/environment.dart';
import 'package:posmobilfinal/src/models/detalle.dart';
import 'package:posmobilfinal/src/models/inventario.dart';
import 'package:posmobilfinal/src/models/response_api.dart';
import 'package:posmobilfinal/src/models/usuario.dart';

import '../models/producto.dart';

import 'package:collection/collection.dart';

class InventarioProvider extends GetConnect {
  /// Devuelve los movimientos (historial) de un producto por su id o código
  Future<List<Inventario>> getMovimientosPorProducto(dynamic producto) async {
    return await getByCodigo(producto);
  }

  /// Agrupa una lista de inventarios por el campo codigoProducto
  Map<dynamic, List<Inventario>> agruparPorCodigoProducto(
    List<Inventario> inventarios,
  ) {
    return groupBy(inventarios, (inv) => inv.codigoProducto);
  }

  String url = '${Environment.API_URL}api/inventario';
  Usuario userSession = Usuario.fromJson(GetStorage().read('usuario') ?? {});

  Future<ResponseApi> create(Inventario inventario) async {
    Response response = await post(
      '$url/create',
      inventario.toJson(),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.sessionToken ?? '',
      },
    );

    if (response.body == null || response.body is! Map<String, dynamic>) {
      return ResponseApi(success: false, message: 'Respuesta vacía o inesperada del servidor', data: null);
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);
    return responseApi;
  }

  Future<List<Inventario>> getAllByUser() async {
    var usuario = userSession.id;
    print('Llamando API getAllByUser para usuario: $usuario');
    Response response = await get(
      '$url/getAllByUser/$usuario',
      headers: {'Content-Type': 'application/json'},
    );
    print(
      'Respuesta recibida de getAllByUser: status ${response.statusCode}, body: ${response.body}',
    );

    if (response.statusCode == 401) {
      Get.snackbar(
        'Peticion Denegada',
        'No esta autorizado para realizar esta peticion',
      );
      return [];
    }

    List<Inventario> inventario = Inventario.fromJsonList(response.body);
    return inventario;
  }

  Future<List<Inventario>> getByCodigo(var producto) async {
    var usuario = userSession.id;
    Response response = await get(
      '$url/getByCodigo/$usuario/$producto',
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 401) {
      Get.snackbar(
        'Peticion Denegada',
        'No esta autorizado para realizar esta peticion',
      );
      return [];
    }

    List<Inventario> inventario = Inventario.fromJsonList(response.body);
    return inventario;
  }

  Future<List<Producto>> consultaInventario() async {
    String userID = userSession.id.toString();
    Response response = await get(
      '$url/consultaInventario/$userID',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.sessionToken ?? '',
      },
    );

    if (response.statusCode == 401) {
      Get.snackbar(
        'Peticion denegada',
        'Tu usuario no tiene permitido leer esta informacion',
      );
      return [];
    }

    print('API consultaInventario response.body: \\n${response.body}');
    List<Producto> productos = Producto.fromJsonList(
      response.body is List ? response.body : response.body['data'] ?? [],
    );
    return productos;
  }

  Future<List<Producto>> getAllByDate(var inicial, var fin) async {
    String userID = userSession.id.toString();
    Response response = await get(
      '$url/getAllByDate/$userID/$inicial/$fin',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.sessionToken ?? '',
      },
    );

    if (response.statusCode == 401) {
      Get.snackbar(
        'Peticion denegada',
        'Tu usuario no tiene permitido leer esta informacion',
      );
      return [];
    }

    List<Producto> productos = Producto.fromJsonList(response.body);
    // print(productos);
    return productos;
  }

  // Nuevo método para DetalleBoleta
  Future<List<DetalleBoleta>> getDetallesBoleta() async {
    var usuario = userSession.id;
    Response response = await get(
      '$url/consultaInventario/$usuario',
      //'${Environment.API_URL}/consultaInventario/$usuario',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.sessionToken ?? '',
      },
    );

    if (response.statusCode == 401) {
      Get.snackbar(
        'Peticion Denegada',
        'No está autorizado para realizar esta petición',
      );
      return [];
    }
    // Imprime el cuerpo de la respuesta para ver qué trae
    print('Respuesta DetalleBoleta: ${response.body}');

    List<DetalleBoleta> detalles = DetalleBoleta.fromJsonList(
      response.body is List ? response.body : response.body['data'] ?? [],
    );
    return detalles;
  }
}
