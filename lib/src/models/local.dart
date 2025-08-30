import 'dart:convert';

Local localFromJson(String str) => Local.fromJson(json.decode(str));

String localToJson(Local data) => json.encode(data.toJson());

class Local {
  String? id;
  String? usuario;
  String? nombreLocal;
  String? posNumero;

  Local({
    this.id,
    this.usuario,
    this.nombreLocal,
    this.posNumero,
  });

  factory Local.fromJson(Map<String, dynamic> json) => Local(
    id: json["id"],
    usuario: json["usuario"],
    nombreLocal: json["nombre_local"],
    posNumero: json["pos_numero"],
  );

  static List<Local> fromJsonList(List<dynamic> jsonList) {
    List<Local> toList = [];

    for (var item in jsonList) {
      Local local = Local.fromJson(item);
      toList.add(local);
    }

    return toList;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "usuario": usuario,
    "nombre_local": nombreLocal,
    "pos_numero": posNumero,
  };
}
