import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/models/usuario.dart';
import '../environment/environment.dart';
import '../models/categoria.dart';
import '../models/response_api.dart';


class CategoriasProvider extends GetConnect {

  String url = '${Environment.API_URL}api/categorias';

  Usuario userSession = Usuario.fromJson(GetStorage().read('usuario') ?? {});

  Future<List<Categoria>> getAllByUser() async {
    String userID = userSession.id.toString();
    Response response = await get(
        '$url/getAllByUser/$userID',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    if (response.statusCode == 401) {
      Get.snackbar('Peticion denegada', 'Tu usuario no tiene permitido leer esta informacion');
      return [];
    }

    List<Categoria> categorias = Categoria.fromJsonList(response.body);

    return categorias;
  }
  Future<List<Categoria>> getNameById(String IdCategory) async {
    Response response = await get(
        '$url/getNameById/$IdCategory',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    if (response.statusCode == 401) {
      Get.snackbar('Peticion denegada', 'Tu usuario no tiene permitido leer esta informacion');
      return [];
    }

    List<Categoria> categorias = Categoria.fromJsonList(response.body);

    return categorias;
  }

  Future<ResponseApi> create(Categoria categoria) async {
    Response response = await post(
        '$url/create',
        categoria.toJson(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }

}