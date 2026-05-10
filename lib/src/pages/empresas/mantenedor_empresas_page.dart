import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobilfinal/src/models/usuario.dart';
import 'package:posmobilfinal/src/providers/empresas_provider.dart';

class MantenedorEmpresasPage extends StatefulWidget {
  const MantenedorEmpresasPage({Key? key}) : super(key: key);

  @override
  State<MantenedorEmpresasPage> createState() => _MantenedorEmpresasPageState();
}

class _MantenedorEmpresasPageState extends State<MantenedorEmpresasPage> {
  final EmpresasProvider _provider = EmpresasProvider();
  List<Usuario> _usuarios = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => _isLoading = true);
    try {
      final usuarios = await _provider.getUsuarios();
      print('Respuesta backend (usuarios): $usuarios');
      setState(() {
        _usuarios = usuarios;
      });
    } catch (e) {
      print('Error al cargar empresas: $e');
      Get.snackbar('Error', 'No se pudieron cargar las empresas');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarDialogoUsuario({Usuario? usuario}) {
    final nombreController = TextEditingController(text: usuario?.nombre ?? '');
    final rutController = TextEditingController(text: usuario?.rut ?? '');
    final emailController = TextEditingController(text: usuario?.email ?? '');
    final claveController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(usuario == null ? 'Crear Empresa' : 'Editar Empresa'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: rutController,
                  decoration: const InputDecoration(labelText: 'RUT'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                if (usuario == null)
                  TextField(
                    controller: claveController,
                    decoration: const InputDecoration(labelText: 'Clave'),
                    obscureText: true,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nombre = nombreController.text.trim();
                final rut = rutController.text.trim();
                final email = emailController.text.trim();
                final clave = claveController.text.trim();
                if (nombre.isEmpty || rut.isEmpty || email.isEmpty || (usuario == null && clave.isEmpty)) {
                  Get.snackbar('Campos requeridos', 'Completa todos los campos');
                  return;
                }
                if (usuario == null) {
                  // Crear
                  await _provider.crearUsuario(nombre, rut, email, clave);
                } else {
                  // Editar
                  await _provider.editarUsuario(usuario.id!, nombre, rut, email);
                }
                Navigator.of(context).pop();
                _cargarUsuarios();
              },
              child: Text(usuario == null ? 'Crear' : 'Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _eliminarUsuario(String id) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Empresa'),
        content: const Text('¿Estás seguro de eliminar esta empresa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado == true) {
      await _provider.eliminarUsuario(id);
      _cargarUsuarios();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mantenedor Empresas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarUsuarios,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoUsuario(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _usuarios.length,
              itemBuilder: (context, index) {
                final usuario = _usuarios[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(usuario.nombre ?? ''),
                    subtitle: Text('RUT: ${usuario.rut ?? ''}\nEmail: ${usuario.email ?? ''}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _mostrarDialogoUsuario(usuario: usuario),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarUsuario(usuario.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
