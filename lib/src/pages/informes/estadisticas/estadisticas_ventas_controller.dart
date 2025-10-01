import 'package:get/get.dart';
import 'package:posmobil/src/models/detalle.dart';
import 'package:posmobil/src/providers/inventario_provider.dart';

class EstadisticasVentasController extends GetxController {
  // Variables públicas para filtros
  DateTime? fechaInicialFiltro;
  DateTime? fechaFinalFiltro;
  String filtroProducto = '';

  var detallesBoleta = <DetalleBoleta>[].obs;

  final InventarioProvider inventarioProvider = InventarioProvider();

  int get totalProductosVendidos =>
      detallesBoleta.fold(0, (sum, det) => sum + (int.tryParse(det.cantidad ?? '0') ?? 0));

  // Filtra DetalleBoleta por producto, fechas y nombre
  Future<void> filtrarInventario(String idProducto) async {
    try {
      final boletaList = await inventarioProvider.getDetallesBoleta();
      List<DetalleBoleta> filtrados = boletaList;

      // Filtrar por producto si corresponde
      if (idProducto.isNotEmpty) {
        filtrados = filtrados.where((det) => (det.idProducto ?? '').contains(idProducto)).toList();
      }

      // Filtrar por fechas si corresponde
      if (fechaInicialFiltro != null && fechaFinalFiltro != null) {
        filtrados = filtrados.where((det) {
          final fecha = DateTime.tryParse(det.fecha ?? '');
          if (fecha == null) return false;
          return !fecha.isBefore(fechaInicialFiltro!) && !fecha.isAfter(fechaFinalFiltro!);
        }).toList();
      }

      // Filtrar por nombre de producto si corresponde
      if (filtroProducto.isNotEmpty && filtroProducto.length >= 3) {
        filtrados = filtrados.where((det) =>
          (det.nombreProducto ?? '').toLowerCase().contains(filtroProducto.toLowerCase())
        ).toList();
      }

      detallesBoleta.value = filtrados;
    } catch (e) {
      detallesBoleta.clear();
      Get.snackbar('Error', 'No se pudo cargar el detalle de boletas');
    }
  }

  void regresar() {
    Get.back();
  }
}