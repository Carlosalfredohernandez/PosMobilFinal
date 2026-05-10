import 'dart:convert';
import 'package:posmobilfinal/src/models/detalle.dart';
import 'package:posmobilfinal/src/models/inventario.dart';
import 'package:posmobilfinal/src/models/producto.dart';

Boleta boletaFromJson(String str) => Boleta.fromJson(json.decode(str));

String boletaToJson(Boleta data) => json.encode(data.toJson());


class Boleta {
  String? id;
  String? numero;
  String? usuario;
  String? localUsuario;
  String? fecha;
  String? valor;
  String? formaPago;
  List<Map<String, dynamic>>? productos = [];
  Inventario? inventario;
  List<DetalleBoleta>? detalle = [];

  Boleta({
    this.id,
    this.numero,
    this.usuario,
    this.localUsuario,
    this.fecha,
    this.valor,
    this.formaPago,
    this.productos,
    this.detalle,
    this.inventario
  });

  factory Boleta.fromJson(Map<String, dynamic> json) => Boleta(
    id: json["id"],
    numero: json["numero"],
    usuario: json["usuario"],
    localUsuario: json["local_usuario"],
    fecha: json["fecha"],
    valor: json["valor"],
    formaPago: json["forma_pago"],
    productos: json["productos"] != null ? List<Map<String, dynamic>>.from(json["productos"]) : [],
    inventario: json["inventario"],
    detalle: json["detalle"] == null ? [] : List<DetalleBoleta>.from(json["detalle"].map((model) => DetalleBoleta.fromJson(model))),
  );

  static List<Boleta> fromJsonList(List<dynamic> jsonList) {
    List<Boleta> toList = [];

    for (var item in jsonList) {
      Boleta boleta = Boleta.fromJson(item);
      toList.add(boleta);
    }

    return toList;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "numero": numero,
    "usuario": usuario,
    "local_usuario": localUsuario,
    "fecha": fecha,
    "valor": valor,
    "forma_pago": formaPago,
    "productos": productos,
    "inventario": inventario,
    "detalle": detalle,
  };
}
