import 'package:xml/xml.dart' as xml;

Map<String, dynamic> parseBoletaXml(String xmlString) {
  final xmlDoc = xml.XmlDocument.parse(xmlString);

  // Extraer datos generales
  final folio = xmlDoc.findAllElements('Folio').isNotEmpty ? xmlDoc.findAllElements('Folio').first.text : '';
  final emisor = xmlDoc.findAllElements('RUTEmisor').isNotEmpty ? xmlDoc.findAllElements('RUTEmisor').first.text : '';
  final razonSocial = xmlDoc.findAllElements('RznSocEmisor').isNotEmpty ? xmlDoc.findAllElements('RznSocEmisor').first.text : '';
  final giro = xmlDoc.findAllElements('GiroEmisor').isNotEmpty ? xmlDoc.findAllElements('GiroEmisor').first.text : '';
  final direccion = xmlDoc.findAllElements('DirOrigen').isNotEmpty ? xmlDoc.findAllElements('DirOrigen').first.text : '';
  final total = int.tryParse(xmlDoc.findAllElements('MntTotal').isNotEmpty ? xmlDoc.findAllElements('MntTotal').first.text : '0') ?? 0;

  // Detalle de productos (manejar campos opcionales)
  final detalles = xmlDoc.findAllElements('Detalle').map((d) => {
    'nombre': d.findElements('NmbItem').isNotEmpty ? d.findElements('NmbItem').first.text : '',
    'cantidad': d.findElements('QtyItem').isNotEmpty
        ? double.tryParse(d.findElements('QtyItem').first.text)?.toInt() ?? 1
        : 1, // Si no hay QtyItem, poner 1
    'precio': d.findElements('PrcItem').isNotEmpty
        ? double.tryParse(d.findElements('PrcItem').first.text)?.toInt() ?? 0
        : (d.findElements('MontoItem').isNotEmpty ? int.tryParse(d.findElements('MontoItem').first.text) ?? 0 : 0),
    'monto': d.findElements('MontoItem').isNotEmpty ? int.tryParse(d.findElements('MontoItem').first.text) ?? 0 : 0,
  }).toList();

  // Extraer TED (timbre electrónico)
  final tedNode = xmlDoc.findAllElements('TED').isNotEmpty ? xmlDoc.findAllElements('TED').first : null;
  final ted = tedNode != null ? tedNode.toXmlString(pretty: true) : '';
  final tedDD = tedNode != null && tedNode.findElements('DD').isNotEmpty ? tedNode.findElements('DD').first.text : '';

  return {
    'folio': folio,
    'rut_emisor': emisor,
    'razon_social': razonSocial,
    'direccion': direccion,
    'giro': giro,
    'total': total,
    'detalle': detalles,
    'ted': ted,
    'ted_dd': tedDD,
  };
}
