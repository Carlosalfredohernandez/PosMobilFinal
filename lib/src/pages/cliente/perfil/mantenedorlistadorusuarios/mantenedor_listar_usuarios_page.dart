import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/pages/cliente/perfil/mantenedorlistadorusuarios/mantenedor_listar_usuarios_controller.dart';
import 'package:posmobil/src/models/usuario_empresa.dart';

class MantenedorListarUsuariosPage extends StatelessWidget {
  final UsuarioEmpresaController controlador = Get.put(UsuarioEmpresaController());
  final Rx<UsuarioEmpresa?> usuarioSeleccionado = Rx<UsuarioEmpresa?>(null);
  final RxBool esCreacion = false.obs;

  // Cambia aquí: define los roles como lista de mapas con id y nombre
  final List<Map<String, String>> roles = [
    {'id': '1', 'nombre': 'USUARIO'},
    {'id': '2', 'nombre': 'CAJERO'},
  ];

  MantenedorListarUsuariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de Usuarios Empresa'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Crear Usuario Empresa',
            onPressed: () {
              esCreacion.value = true;
              usuarioSeleccionado.value = UsuarioEmpresa(); // Usuario vacío para crear
            },
          )
        ],
      ),
      body: Obx(() {
        if (usuarioSeleccionado.value == null) {
          return _grillaUsuarios(context);
        } else {
          return _formularioUsuario(context, usuarioSeleccionado.value!, esCreacion.value);
        }
      }),
    );
  }

  Widget _grillaUsuarios(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final usuarios = controlador.usuarios;
        if (usuarios.isEmpty) {
          return const Center(child: Text('No hay usuarios disponibles'));
        }
        return ListView.builder(
          key: ValueKey(usuarios.length),
          itemCount: usuarios.length,
          itemBuilder: (_, index) {
            final usuario = usuarios[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(usuario.nombreUsuario ?? ''),
                subtitle: Text(usuario.empresa ?? ''),
                trailing: ElevatedButton(
                  onPressed: () {
                    esCreacion.value = false;
                    usuarioSeleccionado.value = usuario;
                  },
                  child: const Text('Editar'),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _formularioUsuario(BuildContext context, UsuarioEmpresa usuario, bool esCreacion) {
    final empresaController = TextEditingController(text: usuario.empresa ?? '');
    final nombreController = TextEditingController(text: usuario.nombreUsuario ?? '');
    final rutController = TextEditingController(text: usuario.rut ?? '');
    final passwordController = TextEditingController(text: usuario.password ?? '');

    // Combo de locales: selecciona el id como valor
    final RxString localSeleccionado = (usuario.localAsignado ?? '').obs;
    // Combo de roles: selecciona el id como valor
    final RxString rolSeleccionado = (usuario.rol ?? '').obs;

    void mostrarError(String mensaje) {
      Get.snackbar('Validación', mensaje, backgroundColor: Colors.red[100]);
    }

    bool validarCampos() {
      if (empresaController.text.trim().isEmpty) {
        mostrarError('El campo Empresa es obligatorio');
        return false;
      }
      if (localSeleccionado.value.isEmpty) {
        mostrarError('Debes seleccionar un Local Asignado');
        return false;
      }
      if (nombreController.text.trim().isEmpty) {
        mostrarError('El campo Nombre Usuario es obligatorio');
        return false;
      }
      if (rolSeleccionado.value.isEmpty) {
        mostrarError('Debes seleccionar un Rol');
        return false;
      }
      if (rutController.text.trim().isEmpty) {
        mostrarError('El campo RUT es obligatorio');
        return false;
      }
      if (esCreacion && passwordController.text.trim().isEmpty) {
        mostrarError('El campo Contraseña es obligatorio');
        return false;
      }
      return true;
    }

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.blueGrey,
              blurRadius: 15,
              offset: Offset(0, 0.75),
            )
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            TextField(
              controller: empresaController,
              decoration: const InputDecoration(
                labelText: 'Empresa',
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 10),
            // Combo de Locales (usa el id como value)
            Obx(() => DropdownButtonFormField<String>(
              value: controlador.locales.any((local) => (local.id?.toString() ?? '') == localSeleccionado.value)
                  ? (localSeleccionado.value.isNotEmpty ? localSeleccionado.value : null)
                  : null,
              items: controlador.locales
                  .where((local) => local.id != null && (local.nombreLocal ?? '').isNotEmpty)
                  .map((local) {
                final idLocal = local.id!.toString();
                final nombreLocal = local.nombreLocal ?? '';
                return DropdownMenuItem<String>(
                  value: idLocal,
                  child: Text(nombreLocal),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) localSeleccionado.value = value;
              },
              decoration: const InputDecoration(
                labelText: 'Local Asignado',
                prefixIcon: Icon(Icons.store),
              ),
            )),
            const SizedBox(height: 10),
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre Usuario',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 10),
            // Combo de Roles (usa el id como value)
            Obx(() => DropdownButtonFormField<String>(
              value: roles.any((rol) => rol['id'] == rolSeleccionado.value)
                  ? (rolSeleccionado.value.isNotEmpty ? rolSeleccionado.value : null)
                  : null,
              items: roles.map((rol) {
                return DropdownMenuItem<String>(
                  value: rol['id'],
                  child: Text(rol['nombre']!),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) rolSeleccionado.value = value;
              },
              decoration: const InputDecoration(
                labelText: 'Rol',
                prefixIcon: Icon(Icons.badge),
              ),
            )),
            const SizedBox(height: 10),
            TextField(
              controller: rutController,
              decoration: const InputDecoration(
                labelText: 'RUT',
                prefixIcon: Icon(Icons.credit_card),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!validarCampos()) return;
                      if (esCreacion) {
                        UsuarioEmpresa nuevoUsuario = UsuarioEmpresa(
                          empresa: empresaController.text.trim(),
                          localAsignado: localSeleccionado.value,
                          nombreUsuario: nombreController.text.trim(),
                          rol: rolSeleccionado.value,
                          rut: rutController.text.trim(),
                          password: passwordController.text.trim(),
                        );
                        await controlador.crearUsuario(nuevoUsuario);
                      } else {
                        await controlador.actualizarUsuario(
                          usuario,
                          empresaController.text.trim(),
                          localSeleccionado.value,
                          nombreController.text.trim(),
                          rolSeleccionado.value,
                          rutController.text.trim(),
                          passwordController.text.trim().isNotEmpty
                              ? passwordController.text.trim()
                              : usuario.password ?? '', // Usa la contraseña anterior si no se ingresó una nueva
                        );
                      }
                      usuarioSeleccionado.value = null;
                      await controlador.cargarUsuarios();
                    },
                    child: Text(esCreacion ? 'Crear' : 'Actualizar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      usuarioSeleccionado.value = null;
                      await controlador.cargarUsuarios();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text('Volver'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}