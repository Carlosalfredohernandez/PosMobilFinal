import 'package:flutter/material.dart';
import 'package:posmobilfinal/src/models/detalle.dart';
import 'dart:async';

import 'package:get/get.dart';
import 'package:posmobilfinal/src/pages/informes/estadisticas/estadisticas_ventas_controller.dart';
import 'package:fl_chart/fl_chart.dart';

class GraficoTortaEstadisticasPage extends StatefulWidget {
  final EstadisticasVentasController controlador;
  final DateTime? fechaInicial;
  final DateTime? fechaFinal;

  const GraficoTortaEstadisticasPage({
    Key? key,
    required this.controlador,
    this.fechaInicial,
    this.fechaFinal,
  }) : super(key: key);

  @override
  State<GraficoTortaEstadisticasPage> createState() =>
      _GraficoTortaEstadisticasPageState();
}

class _GraficoTortaEstadisticasPageState
    extends State<GraficoTortaEstadisticasPage> {
  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.controlador.detallesBoleta.listen((_) {
      if (mounted) setState(() {});
    });
  }

  Map<String, double> _agruparPorProducto(List<DetalleBoleta> detalles) {
    final Map<String, double> data = {};
    for (var det in detalles) {
      final nombre = det.nombreProducto ?? 'Sin nombre';
      final cantidad = double.tryParse(det.cantidad ?? '0') ?? 0.0;
      data[nombre] = (data[nombre] ?? 0.0) + cantidad;
    }
    return data;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Widget _buildBarChart(Map<String, double> dataMap) {
    // Ordenar dataMap de mayor a menor cantidad
    final sortedEntries = dataMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final labels = sortedEntries.map((e) => e.key).toList();
    final values = sortedEntries.map((e) => e.value.toDouble()).toList();
    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < labels.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (values[i] is num) ? (values[i] as num).toDouble() : 0.0,
              color: Colors.blue,
              width: 18,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    // Ancho dinámico: 60px por barra, mínimo 300
    final chartWidth = (labels.length * 60)
        .toDouble()
        .clamp(300, 10000)
        .toDouble();
    return SizedBox(
      height: 300,
      width: chartWidth,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final idx = value.toInt();
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Transform.rotate(
                      angle: -0.5,
                      child: Text(
                        idx >= 0 && idx < labels.length ? labels[idx] : '',
                        style: const TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Aplicar el mismo filtro que en la página principal
    final detalles =
        widget.controlador.filtroProducto.isNotEmpty &&
            widget.controlador.filtroProducto.length >= 3
        ? widget.controlador.detallesBoleta
              .where(
                (d) => (d.nombreProducto ?? '').toLowerCase().contains(
                  widget.controlador.filtroProducto.toLowerCase(),
                ),
              )
              .toList()
        : widget.controlador.detallesBoleta;
    final dataMap = _agruparPorProducto(detalles);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfico de Productos Vendidos'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.fechaInicial != null && widget.fechaFinal != null)
              Text(
                'Periodo: ${widget.fechaInicial!.toString().substring(0, 10)} - ${widget.fechaFinal!.toString().substring(0, 10)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildBarChart(dataMap),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: dataMap.isNotEmpty
                  ? ListView(
                      children: dataMap.entries
                          .map(
                            (e) => ListTile(
                              title: Text(e.key),
                              trailing: Text(e.value.toString()),
                            ),
                          )
                          .toList(),
                    )
                  : const Center(child: Text('No hay datos para mostrar.')),
            ),
          ],
        ),
      ),
    );
  }
}
