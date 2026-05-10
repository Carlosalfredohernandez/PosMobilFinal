import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobilfinal/src/models/usuario.dart';
import 'package:posmobilfinal/src/providers/empresas_provider.dart';
import 'package:posmobilfinal/src/pages/mantenedores/maestros/ventana/mantenedores_maestros_usuarios_page.dart';

class UsuariosListPage extends StatefulWidget {
  const UsuariosListPage({Key? key}) : super(key: key);

  @override
  State<UsuariosListPage> createState() => _UsuariosListPageState();
}

class _UsuariosListPageState extends State<UsuariosListPage> {
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
      setState(() {
        _usuarios = usuarios;
      });
    } catch (e) {
      print('Error al cargar usuarios: $e');
      Get.snackbar('Error', 'No se pudieron cargar los usuarios');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _abrirEdicionUsuario(Usuario? usuario) async {
    await Get.to(() => MantenedoresMaestrosUsuariosPage(usuario: usuario));
    _cargarUsuarios(); // Refresca la lista al volver
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarUsuarios,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _abrirEdicionUsuario(null),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _usuarios.length,
              itemBuilder: (context, index) {
                final usuario = _usuarios[index];
                return ListTile(
                  title: Text(usuario.nombre ?? ''),
                  subtitle: Text(usuario.email ?? ''),
                  onTap: () => _abrirEdicionUsuario(usuario),
                );
              },
            ),
    );
  }
}
