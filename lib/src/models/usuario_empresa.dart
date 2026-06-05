import 'dart:convert';

UsuarioEmpresa usuarioEmpresaFromJson(String str) => UsuarioEmpresa.fromJson(json.decode(str));

String usuarioEmpresaToJson(UsuarioEmpresa data) => json.encode(data.toJson());


class UsuarioEmpresa {
  String? id;
  String? empresa;
  String? localAsignado;
  String? nombreUsuario;
  String? rol; // Siempre String, aunque venga como int
  String? rut;
  String? password;
  String? nombre;
  String? email;
  String? telefono;
  String? comuna;
  String? calle;
  String? numero;
  String? region;
  String? tipoContrato;
  String? apiKey;
  dynamic roles;
  String? sessionToken;

  UsuarioEmpresa({
    this.id,
    this.empresa,
    this.localAsignado,
    this.nombreUsuario,
    this.rol,
    this.rut,
    this.password,
    this.nombre,
    this.email,
    this.telefono,
    this.comuna,
    this.calle,
    this.numero,
    this.region,
    this.tipoContrato,
    this.apiKey,
    this.roles,
    this.sessionToken,
  });

  factory UsuarioEmpresa.fromJson(Map<String, dynamic> json) => UsuarioEmpresa(
    id: json["id"] != null ? json["id"].toString() : null,
    empresa: json["empresa"] != null ? json["empresa"].toString() : (json["nombre"] != null ? json["nombre"].toString() : null),
    localAsignado: json["local_asignado"] != null ? json["local_asignado"].toString() : null,
    nombreUsuario: json["nombre_usuario"] != null ? json["nombre_usuario"].toString() : null,
    rol: json["rol"] != null ? json["rol"].toString() : null,
    rut: json["rut"] != null ? json["rut"].toString() : null,
    password: json["password"],
    nombre: json["nombre"],
    email: json["email"],
    telefono: json["telefono"] != null ? json["telefono"].toString() : null,
    comuna: json["comuna"],
    calle: json["calle"],
    numero: json["numero"] != null ? json["numero"].toString() : null,
    region: json["region"],
    tipoContrato: json["tipo_contrato"],
    apiKey: json["api_key"]?.toString() ?? json["apiKey"]?.toString() ?? json["x_api_key"]?.toString(),
    roles: json["roles"],
    sessionToken: json["session_token"] ?? json["sessionToken"],
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
    "local_asignado": localAsignado,
    "nombre_usuario": nombreUsuario,
    "rol": rol,
    "session_token": sessionToken,
    "rut": rut,
    "password": password,
    "nombre": nombre,
    "email": email,
    "telefono": telefono,
    "comuna": comuna,
    "calle": calle,
    "numero": numero,
    "region": region,
    "tipo_contrato": tipoContrato,
    "api_key": apiKey,
    "roles": roles,
  };
}
