import 'dart:convert';

Proveedor proveedorFromJson(String str) => Proveedor.fromJson(json.decode(str));

String proveedorToJson(Proveedor data) => json.encode(data.toJson());

class Proveedor {

  String? id;
  String? nombre;
  String? telefono;
  String? email;
  String? direccion;
  String? contrato;
  int? idUsuario;

  Proveedor({
    this.id,
    this.nombre,
    this.telefono,
    this.email,
    this.direccion,
    this.contrato,
    this.idUsuario,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) => Proveedor(
    id: json["id"],
    nombre: json["nombre"],
    telefono: json["telefono"],
    email: json["email"],
    direccion: json["direccion"],
    contrato: json["contrato"],
    idUsuario: json["id_usuario"],
  );

  static List<Proveedor> fromJsonList(List<dynamic> jsonList) {
    List<Proveedor> toList = [];

    for (var item in jsonList) {
      Proveedor proveedor = Proveedor.fromJson(item);
      toList.add(proveedor);
    }

    return toList;
  }

  Map<String, dynamic> toJson() => {
    "id": id != null ? int.tryParse(id!) : null,
    "nombre": nombre,
    "telefono": telefono,
    "email": email,
    "direccion": direccion,
    "contrato": (contrato == null || contrato!.isEmpty) ? "SI" : contrato,
    "id_usuario": idUsuario,
  };
}