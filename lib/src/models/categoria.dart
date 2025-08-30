import 'dart:convert';

Categoria categoriaFromJson(String str) => Categoria.fromJson(json.decode(str));

String categoriaToJson(Categoria data) => json.encode(data.toJson());

class Categoria {

  String? id;
  String? usuario;
  String? nombreCategoria;

  Categoria({
    this.id,
    this.usuario,
    this.nombreCategoria,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
    id: json["id"],
    usuario: json["usuario"],
    nombreCategoria: json["nombre_categoria"],
  );

  static List<Categoria> fromJsonList(List<dynamic> jsonList) {
    List<Categoria> toList = [];

    for (var item in jsonList) {
      Categoria categoria = Categoria.fromJson(item);
      toList.add(categoria);
    }

    return toList;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "usuario": usuario,
    "nombre_categoria": nombreCategoria,
  };
}
