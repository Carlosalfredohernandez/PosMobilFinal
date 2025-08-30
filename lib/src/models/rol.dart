import 'dart:convert';

rol rolFromJson(String str) => rol.fromJson(json.decode(str));

String rolToJson(rol data) => json.encode(data.toJson());

class rol {

  String? id;
  String? nombre;
  String? ruta;

  rol({
    this.id,
    this.nombre,
    this.ruta,
  });


  factory rol.fromJson(Map<String, dynamic> json) => rol(
    id: json["id"],
    nombre: json["nombre"],
    ruta: json["ruta"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
    "ruta": ruta,
  };
}
