import 'dart:convert';

DetalleBoleta detalleBoletaFromJson(String str) => DetalleBoleta.fromJson(json.decode(str));

String detalleBoletaToJson(DetalleBoleta data) => json.encode(data.toJson());

class DetalleBoleta {

  String? id;
  String? numero;
  String? fecha;
  String? valor;
  String? idProducto;
  String? cantidad;
  String? valorLinea;
  int? totalLinea;
  String? nombreProducto;

  DetalleBoleta({
    this.id,
    this.numero,
    this.fecha,
    this.valor,
    this.idProducto,
    this.cantidad,
    this.valorLinea,
    this.totalLinea,
    this.nombreProducto,
  });

  factory DetalleBoleta.fromJson(Map<String, dynamic> json) => DetalleBoleta(
    id: json["id"],
    numero: json["numero"],
    fecha: json["fecha"],
    valor: json["valor"],
    idProducto: json["id_producto"],
    cantidad: json["Cantidad"],
    valorLinea: json["ValorLinea"],
    totalLinea: json["TotalLinea"],
    nombreProducto: json["nombre_producto"],
  );

  static List<DetalleBoleta> fromJsonList(List<dynamic> jsonList) {
    List<DetalleBoleta> toList = [];

    for (var item in jsonList) {
      DetalleBoleta boleta = DetalleBoleta.fromJson(item);
      toList.add(boleta);
    }

    return toList;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "numero": numero,
    "fecha": fecha,
    "valor": valor,
    "id_producto": idProducto,
    "Cantidad": cantidad,
    "ValorLinea": valorLinea,
    "TotalLinea": totalLinea,
    "nombre_producto": nombreProducto,
  };
}