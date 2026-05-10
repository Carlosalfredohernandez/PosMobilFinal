import 'dart:convert';

import 'package:posmobilfinal/src/models/rol.dart';

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
  List<Rol>? roles = [];
    int? rol; // Added the rol field
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
    this.roles,
    this.rol
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: json["id"],
    nombre: json["nombre"],
    rut: json["rut"],
    region: json["region"],
    comuna: json["comuna"],
    calle: json["calle"],
    numero: json["numero"],
    localOficina: json["local_asignado"],
    telefono: json["telefono"],
    clave: json["clave"],
    tipoContrato: json["tipo_contrato"],
    email: json["email"],
    sessionToken: json["session_token"],
    roles: json["roles"] == null
      ? []
      : (json["roles"] is String
        ? List<Rol>.from(
          (jsonDecode(json["roles"]) as List).map((model) => Rol.fromJson(model)))
        : List<Rol>.from(json["roles"].map((model) => Rol.fromJson(model)))),
    rol: json["rol"] is int ? json["rol"] : int.tryParse(json["rol"]?.toString() ?? ""), // Deserialize rol
  );

  static List<Usuario> fromJsonList(List<dynamic> jsonList) {
    List<Usuario> toList = [];

    for (var item in jsonList) {
      Usuario usuarios = Usuario.fromJson(item);
      toList.add(usuarios);
    }

    return toList;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (nombre != null) data["nombre"] = nombre;
    if (rut != null) data["rut"] = rut;
    if (region != null) data["region"] = region;
    if (comuna != null) data["comuna"] = comuna;
    if (calle != null) data["calle"] = calle;
    if (numero != null) data["numero"] = numero;
    if (telefono != null) data["telefono"] = telefono;
    if (clave != null) data["clave"] = clave;
    if (tipoContrato != null) data["tipo_contrato"] = tipoContrato;
    if (email != null) data["email"] = email;
    // No enviar: id, rol, roles, session_token, local_oficina
    return data;
  }
}
