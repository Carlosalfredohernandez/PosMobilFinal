import 'dart:convert';

Producto productoFromJson(String str) => Producto.fromJson(json.decode(str));

String productoToJson(Producto data) => json.encode(data.toJson());

class Producto {

  String? id;
  String? usuario;
  String? categoria;
  String? nombreProducto;
  String? descripcionProducto;
  String? codigoBarra;
  String? precioCosto;
  String? precioVenta;
  String? proveedor;
  int? cantidad;

  Producto({
    this.id,
    this.usuario,
    this.categoria,
    this.nombreProducto,
    this.descripcionProducto,
    this.codigoBarra,
    this.precioCosto,
    this.precioVenta,
    this.proveedor,
    this.cantidad,
  });
Producto copyWith({
    String? id,
    String? codigoBarra,
    String? nombreProducto,
    String? descripcionProducto,
    String? precioVenta,
    String? categoria,
    int? cantidad,
  }) {
    return Producto(
      id: id ?? this.id,
      codigoBarra: codigoBarra ?? this.codigoBarra,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      descripcionProducto: descripcionProducto ?? this.descripcionProducto,
      precioVenta: precioVenta ?? this.precioVenta,
      categoria: categoria ?? this.categoria,
      cantidad: cantidad ?? this.cantidad,
    );
  }



  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
    id: json["id"],
    usuario: json["usuario"],
    categoria: json["categoria"],
    nombreProducto: json["nombre_producto"],
    descripcionProducto: json["descripcion_producto"],
    codigoBarra: json["codigo_barra"],
    precioCosto: json["precio_costo"],
    precioVenta: json["precio_venta"],
    proveedor: json["proveedor"],
    cantidad: json["cantidad"],
  );

  static List<Producto> fromJsonList(List<dynamic> jsonList) {
    List<Producto> toList = [];

    for (var item in jsonList) {
      Producto producto = Producto.fromJson(item);
      toList.add(producto);
    }

    return toList;
  }


  Map<String, dynamic> toJson() => {
    "id": id,
    "usuario": usuario,
    "categoria": categoria,
    "nombre_producto": nombreProducto,
    "descripcion_producto": descripcionProducto,
    "codigo_barra": codigoBarra,
    "precio_costo": precioCosto,
    "precio_venta": precioVenta,
    "proveedor": proveedor,
    "cantidad": cantidad,
  };
}
