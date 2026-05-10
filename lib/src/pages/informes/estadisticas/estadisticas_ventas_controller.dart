import 'package:get/get.dart';
import 'package:posmobilfinal/src/models/detalle.dart';
import 'package:posmobilfinal/src/providers/boletas_provider.dart';

class EstadisticasVentasController extends GetxController {
  DateTime? fechaInicialFiltro;
  DateTime? fechaFinalFiltro;
  String filtroProducto = '';
  String filtroCategoria = '';

  var detallesBoleta = <DetalleBoleta>[].obs;
  final BoletasProvider boletasProvider = BoletasProvider();

  int get totalProductosVendidos =>
      detallesBoleta.fold(0, (sum, det) => sum + (int.tryParse(det.cantidad ?? '0') ?? 0));

  // Mostrar todos los productos vendidos
  Future<void> mostrarTodos() async {
    try {
      print('Usuario en sesión: \\${boletasProvider.userSession.id}');
      final boletas = await boletasProvider.getAllByUser();
      print('Boletas recibidas de la API: \\${boletas.length}');
      detallesBoleta.value = boletas.expand((b) => b.detalle ?? <DetalleBoleta>[]).toList();
      print('Detalles de boleta totales: \\${detallesBoleta.length}');
    } catch (e) {
      detallesBoleta.clear();
      print('Error al obtener boletas: \\${e.toString()}');
      Get.snackbar('Error', 'No se pudo cargar el detalle de boletas');
    }
  }

  // Mostrar productos por rango de fechas
  Future<void> mostrarPorRango(DateTime desde, DateTime hasta) async {
    try {
      // Ajustar fechas para incluir todo el día final (límite superior exclusivo)
      final desdeInicio = DateTime(desde.year, desde.month, desde.day, 0, 0, 0);
      final hastaExclusivo = DateTime(hasta.year, hasta.month, hasta.day, 0, 0, 0).add(const Duration(days: 1));
      final boletas = await boletasProvider.getTrimedDateArray(
        desdeInicio.toIso8601String(),
        hastaExclusivo.toIso8601String(),
      );
      detallesBoleta.value = boletas.expand((b) => b.detalle ?? <DetalleBoleta>[]).toList();
    } catch (e) {
      detallesBoleta.clear();
      Get.snackbar('Error', 'No se pudo cargar el detalle de boletas');
    }
  }

  // Mostrar productos por categoría
  Future<void> mostrarPorCategoria(String categoria) async {
    try {
      final boletas = await boletasProvider.getAllByUser();
      // No existe campo 'categoria' en DetalleBoleta, así que filtramos por nombreProducto o similar
      detallesBoleta.value = boletas.expand((b) => b.detalle ?? <DetalleBoleta>[]).where((d) => (d.nombreProducto ?? '').toLowerCase().contains(categoria.toLowerCase())).toList();
    } catch (e) {
      detallesBoleta.clear();
      Get.snackbar('Error', 'No se pudo cargar el detalle de boletas');
    }
  }

  // Buscar producto individualmente
  Future<void> buscarProducto(String nombre) async {
    try {
      final boletas = await boletasProvider.getAllByUser();
      detallesBoleta.value = boletas.expand((b) => b.detalle ?? <DetalleBoleta>[]).where((d) => (d.nombreProducto ?? '').toLowerCase().contains(nombre.toLowerCase())).toList();
    } catch (e) {
      detallesBoleta.clear();
      Get.snackbar('Error', 'No se pudo cargar el detalle de boletas');
    }
  }

  void regresar() {
    Get.back();
  }
}