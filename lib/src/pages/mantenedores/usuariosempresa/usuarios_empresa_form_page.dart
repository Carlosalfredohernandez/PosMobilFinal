// 📝 FORMULARIO USUARIOS EMPRESA PAGE
// Página de formulario para crear/editar usuarios empresa

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'usuarios_empresa_controller.dart';

class UsuariosEmpresaFormPage extends StatelessWidget {
  const UsuariosEmpresaFormPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsuariosEmpresaController>();

    // Obtener nombre de empresa logeada
    String nombreEmpresa = '';
    final usuarioEmpresaData = controller.storage.read('usuarioempresa');
    if (usuarioEmpresaData != null && usuarioEmpresaData is Map && usuarioEmpresaData['nombre_empresa'] != null) {
      nombreEmpresa = usuarioEmpresaData['nombre_empresa'].toString();
    } else if (usuarioEmpresaData != null && usuarioEmpresaData is Map && usuarioEmpresaData['empresa'] != null) {
      nombreEmpresa = usuarioEmpresaData['empresa'].toString();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hola, $nombreEmpresa',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mostrar nombre de empresa logeada
              if (nombreEmpresa.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Empresa: $nombreEmpresa',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              // Título de la sección
              _buildSectionTitle('Información del Usuario'),
              
              const SizedBox(height: 16),
              
              // Campo RUT
              _buildRutField(controller),
              
              const SizedBox(height: 16),
              
              // Campo Nombre
              _buildNombreField(controller),
              
              const SizedBox(height: 16),
              
              // Campo Empresa
              _buildEmpresaField(controller),
              
              const SizedBox(height: 16),
              
              // Campo Local
              _buildLocalField(controller),
              
              const SizedBox(height: 16),
              
              // Campo Rol
              _buildRolField(controller),
              
              const SizedBox(height: 24),
              
              // Título sección contraseña
              _buildSectionTitle('Contraseña'),
              
              const SizedBox(height: 16),
              
              // Campo Password
              _buildPasswordField(controller),
              
              const SizedBox(height: 32),
              
              // Botones
              _buildButtons(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildRutField(UsuariosEmpresaController controller) {
    return TextFormField(
      controller: controller.rutController,
      decoration: InputDecoration(
        labelText: 'RUT',
        hintText: 'Ej: 12345678-9',
        prefixIcon: const Icon(Icons.credit_card),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: TextInputType.text,
      validator: controller.validarRut,
    );
  }

  Widget _buildNombreField(UsuariosEmpresaController controller) {
    return TextFormField(
      controller: controller.nombreController,
      decoration: InputDecoration(
        labelText: 'Nombre Usuario',
        hintText: 'Ingrese el nombre del usuario',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      textCapitalization: TextCapitalization.words,
      validator: controller.validarNombre,
    );
  }

  Widget _buildEmpresaField(UsuariosEmpresaController controller) {
    // El campo empresa está oculto, se toma automáticamente desde GetStorage
    return SizedBox.shrink();
  }

  Widget _buildLocalField(UsuariosEmpresaController controller) {
    return TextFormField(
      controller: controller.localController,
      decoration: InputDecoration(
        labelText: 'Local Asignado',
        hintText: 'Local donde trabajará',
        prefixIcon: const Icon(Icons.store),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildRolField(UsuariosEmpresaController controller) {
    return Obx(() {
      // Copia local de roles para evitar modificar la lista original
      List<String> rolesDropdown = List<String>.from(controller.roles);
      // Si el rol seleccionado no está en la lista, lo agregamos temporalmente
      if (!rolesDropdown.contains(controller.selectedRol.value)) {
        rolesDropdown.add(controller.selectedRol.value);
      }
      return DropdownButtonFormField<String>(
        value: controller.selectedRol.value,
        decoration: InputDecoration(
          labelText: 'Rol',
          prefixIcon: const Icon(Icons.work),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: rolesDropdown.map((rol) {
          return DropdownMenuItem<String>(
            value: rol,
            child: Row(
              children: [
                _buildRolIcon(rol),
                const SizedBox(width: 8),
                Text(rol),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            controller.selectedRol.value = value;
          }
        },
      );
    });  }

  Widget _buildRolIcon(String rol) {
    IconData iconData;
    Color color;
    
    switch (rol) {
      case 'USUARIO':
        iconData = Icons.admin_panel_settings;
        color = Colors.purple;
        break;
      case 'CAJERO':
        iconData = Icons.point_of_sale;
        color = Colors.blue;
        break;
      default:
        iconData = Icons.person;
        color = Colors.grey;
    }
    
    return Icon(iconData, color: color, size: 20);
  }

  Widget _buildPasswordField(UsuariosEmpresaController controller) {
    return Obx(() => TextFormField(
      controller: controller.passwordController,
      obscureText: !controller.mostrarPassword.value,
      decoration: InputDecoration(
        labelText: controller.esEdicion.value ? 'Nueva Contraseña (opcional)' : 'Contraseña',
        hintText: controller.esEdicion.value ? 'Dejar vacío para mantener actual' : 'Ingrese contraseña',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            controller.mostrarPassword.value ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: controller.toggleMostrarPassword,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: controller.validarPassword,
    ));
  }

  Widget _buildButtons(UsuariosEmpresaController controller) {
    return Column(
      children: [
        // Botón principal (Guardar/Actualizar)
        Obx(() => SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: (controller.isCreating.value || controller.isUpdating.value) 
                ? null 
                : () {
                    if (controller.esEdicion.value) {
                      controller.actualizarUsuario();
                    } else {
                      controller.crearUsuario();
                    }
                  },
            icon: (controller.isCreating.value || controller.isUpdating.value)
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(controller.esEdicion.value ? Icons.save : Icons.add),
            label: Text(
              (controller.isCreating.value || controller.isUpdating.value)
                  ? 'Procesando...'
                  : (controller.esEdicion.value ? 'Actualizar Usuario' : 'Crear Usuario'),
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        )),
        
        const SizedBox(height: 12),
        
        // Botón cancelar
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              controller.limpiarFormulario();
              Get.back();
            },
            icon: const Icon(Icons.cancel),
            label: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Información adicional en modo edición
        Obx(() => controller.esEdicion.value
            ? _buildEditInfo(controller)
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildEditInfo(UsuariosEmpresaController controller) {
    final usuario = controller.selectedUsuario.value;
    if (usuario == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ℹ️ Información del Usuario',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text('ID: ${usuario.id ?? 'N/A'}'),
          Text('RUT Original: ${usuario.rut ?? 'N/A'}'),
          Text('Empresa: ${usuario.empresa ?? 'N/A'}'),
          Text('Local: ${usuario.localAsignado ?? 'N/A'}'),
        ],
      ),
    );
  }
}