import 'dart:convert';

UsuarioEmpresa usuarioEmpresaFromJson(String str) => UsuarioEmpresa.fromJson(json.decode(str));

String usuarioEmpresaToJson(UsuarioEmpresa data) => json.encode(data.toJson());

class UsuarioEmpresa {

  String? id;
  String? empresa;
  String? localAsignado;
  String? nombreUsuario;
  String? rol;
  String? rut;
  String? password;

  UsuarioEmpresa({
    this.id,
    this.empresa,
    this.localAsignado,
    this.nombreUsuario,
    this.rol,
    this.rut,
    this.password,
  });

  factory UsuarioEmpresa.fromJson(Map<String, dynamic> json) => UsuarioEmpresa(
    id: json["id"],
    empresa: json["empresa"],
    localAsignado: json["local_asignado"],
    nombreUsuario: json["nombre_usuario"],
    rol: json["rol"],
    rut: json["rut"],
    password: json["password"],
  );

  static List<UsuarioEmpresa> fromJsonList(List<dynamic> jsonList) {
    List<UsuarioEmpresa> toList = [];

    for (var item in jsonList) {
      UsuarioEmpresa usuarios = UsuarioEmpresa.fromJson(item);
      toList.add(usuarios);
    }

    return toList;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "empresa": empresa,
    "localAsignado": localAsignado,
    "nombreUsuario": nombreUsuario,
    "rol": rol,
    "rut": rut,
    "password": password,
  };
}
