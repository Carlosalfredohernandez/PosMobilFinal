import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/pages/cliente/local/create/cliente_local_create_controller.dart';
import 'package:posmobil/src/models/local.dart';
import 'package:posmobil/src/models/response_api.dart';

class ClienteLocalCreatePage extends StatelessWidget {
  final ClienteLocalCreateController controlador = Get.put(ClienteLocalCreateController());

  ClienteLocalCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('LOCALES')),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                _mostrarModalLocal(context, Local(), true);
              },
              child: const Text('Crear'),
            ),
          ),
        ],
      ),
      body: Obx(() => _grillaLocales(context)),
    );
  }

  Widget _grillaLocales(BuildContext context) {
    final locales = controlador.locales;
    if (locales.isEmpty) {
      return const Center(child: Text('No hay locales disponibles'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: locales.length,
      itemBuilder: (_, index) {
        final local = locales[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: ListTile(
            leading: const Icon(Icons.store),
            title: Text(local.nombreLocal ?? ''),
            subtitle: Text('N°: ${local.posNumero ?? ''}'),
            trailing: ElevatedButton(
              onPressed: () {
                _mostrarModalLocal(context, local, false);
              },
              child: const Text('Editar'),
            ),
          ),
        );
      },
    );
  }

  void _mostrarModalLocal(BuildContext context, Local local, bool esCreacion) {
    final nombreController = TextEditingController(text: local.nombreLocal ?? '');
    final numeroController = TextEditingController(text: local.posNumero ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(esCreacion ? 'Crear Local' : 'Editar Local'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Local',
                    prefixIcon: Icon(Icons.store),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: numeroController,
                  decoration: const InputDecoration(
                    labelText: 'Número de Local',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nombre = nombreController.text.trim();
                final numero = numeroController.text.trim();

                if (nombre.isEmpty) {
                  Get.snackbar('Validación', 'El nombre del local es obligatorio', backgroundColor: Colors.red[100]);
                  return;
                }
                if (numero.isEmpty) {
                  Get.snackbar('Validación', 'El número del local es obligatorio', backgroundColor: Colors.red[100]);
                  return;
                }

                // Refresca la lista antes de validar duplicados
                await controlador.cargarLocales();

                if (esCreacion) {
                  // Validar que el número de local sea único
                  final existeNumero = controlador.locales.any((l) => l.posNumero == numero);
                  if (existeNumero) {
                    Get.snackbar('Validación', 'Ya existe un local con ese número', backgroundColor: Colors.red[100]);
                    return;
                  }
                  ResponseApi? response = await controlador.crearLocal(nombre, numero);
                  if (response != null && response.success == true) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                } else {
                  // Validar que el número de local sea único (excepto el mismo local)
                  final existeNumero = controlador.locales.any((l) =>
                    l.id != local.id && l.posNumero == numero
                  );
                  if (existeNumero) {
                    Get.snackbar('Validación', 'Ya existe un local con ese número', backgroundColor: Colors.red[100]);
                    return;
                  }
                  ResponseApi? response = await controlador.editarLocal(local, nombre, numero);
                  if (response != null && response.success == true) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                }
              },
              child: Text(esCreacion ? 'Crear' : 'Actualizar'),
            ),
          ],
        );
      },
    );
  }
}