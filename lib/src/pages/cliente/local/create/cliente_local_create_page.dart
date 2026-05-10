
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobilfinal/src/pages/cliente/local/create/cliente_local_create_controller.dart';
import 'package:posmobilfinal/src/models/local.dart';
import 'package:posmobilfinal/src/models/response_api.dart';

class ClienteLocalCreatePage extends StatefulWidget {
  const ClienteLocalCreatePage({super.key});

  @override
  State<ClienteLocalCreatePage> createState() => _ClienteLocalCreatePageState();
}

class _ClienteLocalCreatePageState extends State<ClienteLocalCreatePage> {
  final ClienteLocalCreateController controlador = Get.put(ClienteLocalCreateController());
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    controlador.cargarLocales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header degradado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: const Text(
                'MANTENCIÓN DE LOCALES',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            // Buscador
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar local por nombre',
                  prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                  filled: true,
                  fillColor: const Color(0xFFF0F4FA),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _busqueda = value.trim().toLowerCase();
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            // Lista de locales en Card
            Expanded(
              child: Obx(() {
                final locales = controlador.locales;
                if (locales.isEmpty) {
                  return const Center(child: Text('No hay locales registrados'));
                }
                final localesFiltrados = _busqueda.isEmpty
                    ? locales
                    : locales.where((l) => (l.nombreLocal ?? '').toLowerCase().contains(_busqueda)).toList();
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: localesFiltrados.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: Text('No se encontraron locales con ese nombre')),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemCount: localesFiltrados.length,
                          itemBuilder: (context, index) {
                            final local = localesFiltrados[index];
                            return ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Icon(Icons.store, color: Colors.white),
                              ),
                              title: Text(
                                local.nombreLocal ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('N°: ${local.posNumero ?? ''}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                    onPressed: () {
                                      _mostrarDialogoLocal(context, local, false);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    tooltip: 'Eliminar',
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Confirmar eliminación'),
                                          content: Text('¿Estás seguro de que deseas eliminar el local "${local.nombreLocal ?? ''}"?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(),
                                              child: const Text('Cancelar'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.redAccent,
                                              ),
                                              onPressed: () async {
                                                await controlador.eliminarLocal(local);
                                                Navigator.of(context).pop();
                                                setState(() {});
                                              },
                                              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarDialogoLocal(context, Local(), true);
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
        tooltip: 'Agregar local',
      ),
    );
  }

  void _mostrarDialogoLocal(BuildContext context, Local local, bool esCreacion) {
    final nombreController = TextEditingController(text: local.nombreLocal ?? '');
    final numeroController = TextEditingController(text: local.posNumero ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    esCreacion ? 'Nuevo Local' : 'Editar Local',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blueAccent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _campoTextoNombre(nombreController),
                  _campoTextoNumero(numeroController),
                  const SizedBox(height: 24),
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

                      await controlador.cargarLocales();

                      if (esCreacion) {
                        final existeNumero = controlador.locales.any((l) => l.posNumero == numero);
                        if (existeNumero) {
                          Get.snackbar('Validación', 'Ya existe un local con ese número', backgroundColor: Colors.red[100]);
                          return;
                        }
                        ResponseApi? response = await controlador.crearLocal(nombre, numero);
                        if (response != null && response.success == true) {
                          Navigator.of(context).pop();
                          setState(() {});
                        }
                      } else {
                        final existeNumero = controlador.locales.any((l) => l.id != local.id && l.posNumero == numero);
                        if (existeNumero) {
                          Get.snackbar('Validación', 'Ya existe un local con ese número', backgroundColor: Colors.red[100]);
                          return;
                        }
                        ResponseApi? response = await controlador.editarLocal(local, nombre, numero);
                        if (response != null && response.success == true) {
                          Navigator.of(context).pop();
                          setState(() {});
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(esCreacion ? 'GUARDAR' : 'GUARDAR CAMBIOS', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.blueAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('CANCELAR', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _campoTextoNombre(TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: 'Nombre del Local',
        prefixIcon: const Icon(Icons.store, color: Colors.blueAccent),
        filled: true,
        fillColor: const Color(0xFFF0F4FA),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _campoTextoNumero(TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Número de Local',
        prefixIcon: const Icon(Icons.numbers, color: Colors.blueAccent),
        filled: true,
        fillColor: const Color(0xFFF0F4FA),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}