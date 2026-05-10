import 'dart:convert';

import 'package:posmobilfinal/src/models/producto.dart';

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
    cantidad: (() {
      final dynamic val = json["cantidad"];
      if (val == null) return null;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) {
        final parsed = int.tryParse(val);
        if (parsed != null) return parsed;
        final parsedDouble = double.tryParse(val);
        if (parsedDouble != null) return parsedDouble.toInt();
      }
      return null;
    })(),
    valor: (() {
      final dynamic val = json["valor"];
      if (val == null) return null;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) {
        final parsed = int.tryParse(val);
        if (parsed != null) return parsed;
        final parsedDouble = double.tryParse(val);
        if (parsedDouble != null) return parsedDouble.toInt();
      }
      return null;
    })(),
    idProvedor: json["id_provedor"],
    observacion: json["observacion"],
    tipoMovimiento: json["tipo_movimiento"],
    productos: json["productos"],
    local: (() {
      final dynamic val = json["local"];
      if (val == null) return null;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) {
        final parsed = int.tryParse(val);
        if (parsed != null) return parsed;
        final parsedDouble = double.tryParse(val);
        if (parsedDouble != null) return parsedDouble.toInt();
      }
      return null;
    })(),
    nroDocumento: json["numero_documento"],
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
    "numero_documento": nroDocumento,
  };
}