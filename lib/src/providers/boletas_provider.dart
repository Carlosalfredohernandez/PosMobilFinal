import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/environment/environment.dart';
import 'package:posmobilfinal/src/models/boleta.dart';
import 'package:posmobilfinal/src/models/response_api.dart';
import 'package:posmobilfinal/src/models/usuario.dart';

class BoletasProvider extends GetConnect {
  String url = '${Environment.API_URL}api/boletas';

  Usuario userSession = Usuario.fromJson(GetStorage().read('usuario') ?? {});

  Future<ResponseApi> create(Boleta boleta) async {
    Response response = await post(
      '$url/create',
      boleta.toJson(),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.sessionToken ?? ''
      }
    );
    ResponseApi responseApi = ResponseApi.fromJson(response.body);
    return responseApi;
  }

  Future<List<Boleta>> getAllByUser() async {
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
    if (response.body == null) {
      return [];
    }
    List<Boleta> boleta = Boleta.fromJsonList(
      response.body is List
        ? response.body
        : response.body['data'] ?? []
    );
    return boleta;
  }

  Future<List<Boleta>> getTrimedDateArray(var inicial, var fin) async {
    String userID = userSession.id.toString();
    Response response = await get(
      '$url/getTrimedDateArray/$userID/$inicial/$fin',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.sessionToken ?? ''
      }
    );

    if (response.statusCode == 401) {
      Get.snackbar('Peticion denegada', 'Tu usuario no tiene permitido leer esta informacion');
      return [];
    }
    if (response.body == null) {
      return [];
    }
    List<Boleta> boleta = Boleta.fromJsonList(
      response.body is List
        ? response.body
        : response.body['data'] ?? []
    );
    return boleta;
  }

  // Future<List<DetalleBoleta>> getSells(var idBoleta) async {
  //   Response response = await get(
  //       '$url/getSells/$idBoleta',
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': userSession.sessionToken ?? ''
  //       }
  //   );
  //   if (response.statusCode == 401) {
  //     Get.snackbar('Peticion denegada', 'Tu usuario no tiene permitido leer esta informacion');
  //     return [];
  //   }
  //   List<DetalleBoleta> detalleBoleta = DetalleBoleta.fromJsonList(response.body);
  //   return detalleBoleta;
  // }
}