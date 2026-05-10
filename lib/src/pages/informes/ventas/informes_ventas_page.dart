import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobilfinal/src/models/boleta.dart';
import 'package:posmobilfinal/src/pages/informes/detalle_venta/informes_detalle_venta_page.dart';
import 'package:posmobilfinal/src/pages/informes/ventas/informes_ventas_controller.dart';
import 'package:posmobilfinal/src/pages/informes/pdf/pdf_export_page.dart';

class InformesVentasPage extends StatefulWidget {
  const InformesVentasPage({super.key});

  @override
  State<InformesVentasPage> createState() => _InformesVentasPageState();
}

class _InformesVentasPageState extends State<InformesVentasPage> {
  final InformesVentasController controlador = Get.put(InformesVentasController());

  Future<DateTime?> _selectDate(BuildContext context, DateTime initialDate) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      lastDate: DateTime.now(),
      firstDate: DateTime(2022),
      builder: (context, child) {
        return Theme(data: ThemeData.dark(), child: child!);
      },
    );
  }

  void _filtrarPorFechas() {
    if (controlador.fechaFinal.isBefore(controlador.fechaInicial)) {
      Get.snackbar('Rango inválido', 'La fecha final no puede ser menor que la fecha inicial');
      return;
    }
    controlador.updateBoletas(
      '${controlador.fechaInicial}'.substring(0, 10),
      '${controlador.fechaFinal.add(const Duration(days: 1))}'.substring(0, 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBar(
            elevation: 5,
            automaticallyImplyLeading: false,
            title: const Text('Informe de Ventas'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => controlador.regresar(),
            ),
          ),
          body: Column(
            children: [
              Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Fecha Inicial', style: TextStyle(color: Colors.black)),
                          TextButton(
                            onPressed: () async {
                              DateTime? picked = await _selectDate(context, controlador.fechaInicial);
                              if (picked != null) {
                                setState(() {
                                  controlador.fechaInicial = picked;
                                });
                              }
                            },
                            child: Text('${controlador.fechaInicial}'.substring(0, 10), style: const TextStyle(color: Colors.black)),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Fecha Final', style: TextStyle(color: Colors.black)),
                          TextButton(
                            onPressed: () async {
                              DateTime? picked = await _selectDate(context, controlador.fechaFinal);
                              if (picked != null) {
                                setState(() {
                                  controlador.fechaFinal = picked;
                                });
                              }
                            },
                            child: Text('${controlador.fechaFinal}'.substring(0, 10), style: const TextStyle(color: Colors.black)),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _filtrarPorFechas,
                        child: const Text('Filtrar'),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: controlador.boletas.isNotEmpty
                    ? ListView(
                        children: controlador.boletas.map((Boleta boleta) {
                          return ListTile(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Boleta'),
                                  actions: [
                                    Column(
                                      children: [
                                        Row(children: [Text('Numero: ${boleta.id}')]),
                                        Row(children: [Text('FECHA:  ${boleta.fecha!.substring(0, 10)}')]),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cerrar'),
                                        ),
                                      ],
                                    )
                                  ],
                                  content: SizedBox(
                                    width: 400,
                                    child: boleta.detalle == null || boleta.detalle!.isEmpty
                                        ? const Text('Sin productos en esta venta')
                                        : Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                children: const [
                                                  Expanded(child: Text('Producto', style: TextStyle(fontWeight: FontWeight.bold))),
                                                  SizedBox(width: 8),
                                                  Text('Cant.', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  SizedBox(width: 8),
                                                  Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                              Divider(),
                                              ...boleta.detalle!.map((detalle) => Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                                    child: Row(
                                                      children: [
                                                        Expanded(child: Text(detalle.nombreProducto ?? '')),
                                                        SizedBox(width: 8),
                                                        Text(detalle.cantidad ?? ''),
                                                        SizedBox(width: 8),
                                                        Text(detalle.totalLinea?.toString() ?? ''),
                                                      ],
                                                    ),
                                                  ))
                                            ],
                                          ),
                                  ),
                                ),
                              );
                            },
                            leading: const Icon(Icons.account_balance_wallet_outlined),
                            title: Text('${boleta.fecha}'),
                            subtitle: Text(
                              'Boleta: ${boleta.id} - METODO ${boleta.formaPago} - \$${boleta.valor}',
                            ),
                          );
                        }).toList(),
                      )
                    : const Center(child: Text('No se han encontrado boletas')),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.grey[800],
            splashColor: Colors.black,
            elevation: 0,
            child: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PdfExportPage(
                    boletas: controlador.boletas,
                    total: controlador.total.value,
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            elevation: 10,
            backgroundColor: Colors.grey[300],
            items: [
              BottomNavigationBarItem(
                label: 'Total: \$ ${controlador.numberFormat(controlador.total.value)}',
                icon: Icon(Icons.currency_exchange, color: Colors.grey[600]),
                tooltip: 'Total Ventas',
              ),
              BottomNavigationBarItem(
                label: 'Boletas: ${controlador.cant}',
                icon: Icon(Icons.import_contacts_sharp, color: Colors.grey[600]),
                tooltip: 'Cantidad total de boletas',
              ),
              BottomNavigationBarItem(
                label: 'Exportar',
                icon: Icon(Icons.picture_as_pdf),
                tooltip: 'Exportar la información recibida a un formato pdf ',
              )
            ],
          ),
        ));
  }
}