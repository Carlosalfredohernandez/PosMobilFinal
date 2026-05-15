import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/environment/environment.dart';
import 'package:posmobilfinal/src/models/boleta.dart';
import 'package:posmobilfinal/src/models/response_api.dart';
import 'package:posmobilfinal/src/models/usuario.dart';

class BoletasProvider extends GetConnect {
  String url = '${Environment.API_URL}api/boletas';

  Usuario userSession = Usuario.fromJson(GetStorage().read('usuario') ?? {});

  @override
  void onInit() {
    super.onInit();
    // Railway puede tener arranque en frio, aumentar timeout reduce falsos fallos.
    httpClient.timeout = const Duration(seconds: 25);
  }

  bool _isTransientFailure(Response response) {
    final status = response.statusCode ?? 0;
    final statusText = (response.statusText ?? '').toLowerCase();
    final bodyText = response.bodyString?.toLowerCase() ?? '';

    return status == 502 ||
        status == 503 ||
        status == 504 ||
        statusText.contains('failed to respond') ||
        bodyText.contains('failed to respond') ||
        statusText.contains('timeout') ||
        bodyText.contains('timeout');
  }

  Future<ResponseApi> create(Boleta boleta) async {
    if ((userSession.sessionToken ?? '').isEmpty) {
      return ResponseApi(
        success: false,
        message: 'Sesion expirada. Inicia sesion nuevamente para guardar la boleta.',
      );
    }

    try {
      Response? lastResponse;

      for (var attempt = 1; attempt <= 2; attempt++) {
        final response = await post(
          '$url/create',
          boleta.toJson(),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': userSession.sessionToken ?? '',
          },
        );
        lastResponse = response;

        if (!_isTransientFailure(response)) {
          if (response.body is Map<String, dynamic>) {
            return ResponseApi.fromJson(response.body);
          }

          return ResponseApi(
            success: response.isOk,
            message: response.statusText ?? 'Respuesta inesperada del servidor',
            data: response.body,
          );
        }

        if (attempt < 2) {
          await Future.delayed(const Duration(milliseconds: 900));
        }
      }

      return ResponseApi(
        success: false,
        message: 'Servidor temporalmente no disponible. Intenta nuevamente en unos segundos.',
        data: lastResponse?.body,
      );
    } catch (e) {
      return ResponseApi(
        success: false,
        message: 'Error de red al guardar boleta: $e',
      );
    }
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
    print('[DEBUG] getAllByUser response.body = ${response.body}');
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
    print('[DEBUG] getTrimedDateArray response.body = ${response.body}');
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