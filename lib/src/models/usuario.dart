import 'dart:convert';

import 'package:posmobil/src/models/rol.dart';

Usuario usuarioFromJson(String str) => Usuario.fromJson(json.decode(str));

String usuarioToJson(Usuario data) => json.encode(data.toJson());

class Usuario {
  String? id;
  String? nombre;
  String? rut;
  String? region;
  String? comuna;
  String? calle;
  String? numero;
  String? localOficina;
  String? telefono;
  String? clave;
  String? tipoContrato;
  String? email;
  String? sessionToken;
  List<rol>? roles = [];

  Usuario({
    this.id,
    this.nombre,
    this.rut,
    this.region,
    this.comuna,
    this.calle,
    this.numero,
    this.localOficina,
    this.telefono,
    this.clave,
    this.tipoContrato,
    this.email,
    this.sessionToken,
    this.roles
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: json["id"],
    nombre: json["nombre"],
    rut: json["rut"],
    region: json["region"],
    comuna: json["comuna"],
    calle: json["calle"],
    numero: json["numero"],
    localOficina: json["local_oficina"],
    telefono: json["telefono"],
    clave: json["clave"],
    tipoContrato: json["tipo_contrato"],
    email: json["email"],
    sessionToken: json["session_token"],
    roles: json["roles"] == null ? [] : List<rol>.from(json["roles"].map((model) => rol.fromJson(model))),

  );

  static List<Usuario> fromJsonList(List<dynamic> jsonList) {
    List<Usuario> toList = [];

    for (var item in jsonList) {
      Usuario usuarios = Usuario.fromJson(item);
      toList.add(usuarios);
    }

    return toList;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
    "rut": rut,
    "region": region,
    "comuna": comuna,
    "calle": calle,
    "numero": numero,
    "local_oficina": localOficina,
    "telefono": telefono,
    "clave": clave,
    "tipo_contrato": tipoContrato,
    "email": email,
    "session_token": sessionToken,
    'roles': roles
  };
}
