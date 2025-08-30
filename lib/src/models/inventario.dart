import 'dart:convert';

import 'package:posmobil/src/models/producto.dart';

Inventario inventarioFromJson(String str) => Inventario.fromJson(json.decode(str));

String inventarioToJson(Inventario data) => json.encode(data.toJson());

class Inventario {

  String? idInventario;
  String? idCliente;
  String? fecha;
  String? idUsuarioE;
  String? codigoProducto;
  int? cantidad;
  int? valor;
  int? local;
  int? idProvedor;
  String? observacion;
  String? tipoMovimiento;
  int? nroDocumento;
  List<Producto>? productos = [];

  Inventario({
    this.idInventario,
    this.idCliente,
    this.fecha,
    this.idUsuarioE,
    this.codigoProducto,
    this.cantidad,
    this.valor,
    this.idProvedor,
    this.observacion,
    this.tipoMovimiento,
    this.productos,
    this.local,
    this.nroDocumento,
  });

  factory Inventario.fromJson(Map<String, dynamic> json) => Inventario(
    idInventario: json["id_inventario"],
    idCliente: json["id_cliente"],
    fecha: json["fecha"],
    idUsuarioE: json["id_usuarioE"],
    codigoProducto: json["codigo_producto"],
    cantidad: json["cantidad"],
    valor: json["valor"],
    idProvedor: json["id_provedor"],
    observacion: json["observacion"],
    tipoMovimiento: json["tipo_movimiento"],
    productos: json["productos"],
    local: json["local"],
    nroDocumento: json["nro_documento"],
  );

  static List<Inventario> fromJsonList(List<dynamic> jsonList) {
    List<Inventario> toList = [];

    for (var item in jsonList) {
      Inventario inventario = Inventario.fromJson(item);
      toList.add(inventario);
    }

    return toList;
  }

  Map<String, dynamic> toJson() => {
    "id_inventario": idInventario,
    "id_cliente": idCliente,
    "fecha": fecha,
    "id_usuarioE": idUsuarioE,
    "codigo_producto": codigoProducto,
    "cantidad": cantidad,
    "valor": valor,
    "id_provedor": idProvedor,
    "observacion": observacion,
    "tipo_movimiento": tipoMovimiento,
    "productos": productos,
    "local": local,
    "nro_documento": nroDocumento,
  };
}