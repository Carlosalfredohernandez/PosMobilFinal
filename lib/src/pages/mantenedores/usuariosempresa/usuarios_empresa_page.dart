// 🏢 MANTENEDOR USUARIOS EMPRESA PAGE
// Página principal para el mantenimiento de usuarios empresa

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'usuarios_empresa_controller.dart';
import 'usuarios_empresa_form_page.dart';
import 'package:posmobilfinal/src/models/usuario_empresa.dart';

class UsuariosEmpresaPage extends StatelessWidget {
  const UsuariosEmpresaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UsuariosEmpresaController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('👥 Usuarios Empresa'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Botón refrescar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refrescar,
            tooltip: 'Refrescar',
          ),
          // Botón agregar
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _mostrarFormulario(controller),
            tooltip: 'Agregar usuario',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          _buildSearchBar(controller),
          
          // Estadísticas
          _buildEstadisticas(controller),
          
          // Lista de usuarios
          Expanded(
            child: _buildUsuariosList(controller),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(controller),
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add, color: Colors.red),
        tooltip: 'Agregar usuario',
      ),
    );
  }

  // 🔍 BARRA DE BÚSQUEDA
  Widget _buildSearchBar(UsuariosEmpresaController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: TextField(
        onChanged: controller.buscar,
        decoration: InputDecoration(
          hintText: 'Buscar por RUT o nombre...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  // 📊 ESTADÍSTICAS
  Widget _buildEstadisticas(UsuariosEmpresaController controller) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard('Total', controller.totalUsuarios.toString(), Colors.blue),
          _buildStatCard('Cajeros', controller.usuariosCajero.toString(), Colors.green),
          _buildStatCard('Admins', controller.usuariosAdmin.toString(), Colors.purple),
        ],
      ),
    ));
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📋 LISTA DE USUARIOS
  Widget _buildUsuariosList(UsuariosEmpresaController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando usuarios...'),
            ],
          ),
        );
      }

      if (controller.usuariosFiltrados.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                controller.usuarios.isEmpty 
                    ? 'No hay usuarios registrados'
                    : 'No se encontraron usuarios con los filtros aplicados',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _mostrarFormulario(controller),
                icon: const Icon(Icons.add),
                label: const Text('Agregar primer usuario'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refrescar,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.usuariosFiltrados.length,
          itemBuilder: (context, index) {
            final usuario = controller.usuariosFiltrados[index];
            return _buildUsuarioCard(usuario, controller);
          },
        ),
      );
    });
  }

  // 👤 CARD DE USUARIO
  Widget _buildUsuarioCard(UsuarioEmpresa usuario, UsuariosEmpresaController controller) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getRolColor(usuario.rol),
          child: Text(
            _getRolIcon(usuario.rol),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          usuario.nombreUsuario ?? usuario.rut ?? 'Sin nombre',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RUT: ${usuario.rut ?? 'N/A'}'),
            Text('Rol: ${usuario.rol ?? 'Sin rol'}'),
            Text('Empresa: ${usuario.empresa ?? 'N/A'}'),
            Text('Local: ${usuario.localAsignado ?? 'N/A'}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, usuario, controller),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'editar', child: Row(
              children: [Icon(Icons.edit), SizedBox(width: 8), Text('Editar')],
            )),
            const PopupMenuItem(value: 'eliminar', child: Row(
              children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Eliminar')],
            )),
          ],
        ),
        onTap: () => _mostrarFormulario(controller, usuario: usuario),
      ),
    );
  }

  // 🎨 HELPERS DE UI
  Color _getRolColor(String? rol) {
    switch (rol) {
      case 'USUARIO': return Colors.purple[700]!;
      case 'CAJERO': return Colors.blue[700]!;
      default: return Colors.grey[700]!;
    }
  }

  String _getRolIcon(String? rol) {
    switch (rol) {
      case 'USUARIO': return 'A';
      case 'CAJERO': return 'C';
      default: return '?';
    }
  }

  // 🎛️ MANEJAR ACCIONES DEL MENÚ
  void _handleMenuAction(String action, UsuarioEmpresa usuario, UsuariosEmpresaController controller) {
    switch (action) {
      case 'editar':
        _mostrarFormulario(controller, usuario: usuario);
        break;
      case 'eliminar':
        _confirmarEliminarUsuario(usuario, controller);
        break;
    }
  }

  // Diálogo de confirmación y acción de eliminar
  void _confirmarEliminarUsuario(UsuarioEmpresa usuario, UsuariosEmpresaController controller) async {
    final confirmado = await showDialog<bool>(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Estás seguro de eliminar a ${usuario.nombreUsuario ?? usuario.rut}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado == true) {
      await controller.eliminarUsuario(usuario.id);
    }
  }

  // 📝 MOSTRAR FORMULARIO
  void _mostrarFormulario(UsuariosEmpresaController controller, {UsuarioEmpresa? usuario}) {
    if (usuario != null) {
      controller.prepararEdicion(usuario);
    } else {
      controller.prepararCreacion();
    }

    Get.to(() => const UsuariosEmpresaFormPage());
  }
}
