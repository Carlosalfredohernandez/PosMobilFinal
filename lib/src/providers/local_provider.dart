import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobil/src/environment/environment.dart';
import 'package:posmobil/src/models/local.dart';
import 'package:posmobil/src/models/response_api.dart';
import 'package:posmobil/src/models/usuario.dart';

class LocalProvider extends GetConnect{
  String url = '${Environment.API_URL}api/locales';
  Usuario userSession = Usuario.fromJson(GetStorage().read('usuario') ?? {});

  Future<ResponseApi> create(Local local) async {
    Response response = await post(
        '$url/create',
        local.toJson(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }

  Future<List<Local>> findLocals() async {
    var usuario = userSession.id;
    Response response = await get(
        '$url/findLocals/$usuario',
        headers: {
          'Content-Type': 'application/json'
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    if (response.statusCode == 401) {
      Get.snackbar('Peticion Denegada', 'No esta autorizado para realizar esta peticion');
      return [];
    }

    List<Local> locales = Local.fromJsonList(response.body);
    return locales;
  }

}