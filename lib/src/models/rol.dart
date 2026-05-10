import 'dart:convert';

Rol rolFromJson(String str) => Rol.fromJson(json.decode(str));

String rolToJson(Rol data) => json.encode(data.toJson());

class Rol {

  String? id;
  String? nombre;
  String? ruta;

  Rol({
    this.id,
    this.nombre,
    this.ruta,
  });


  factory Rol.fromJson(Map<String, dynamic> json) => Rol(
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
