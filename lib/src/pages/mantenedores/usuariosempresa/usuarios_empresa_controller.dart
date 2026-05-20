
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/models/usuario_empresa.dart';
import 'package:posmobilfinal/src/models/response_api.dart';
import 'package:posmobilfinal/src/providers/usuarios_empresa_provider.dart';

// 🏢 CONTROLADOR MANTENEDOR USUARIOS EMPRESA
// Controlador para el mantenimiento de usuarios empresa

class UsuariosEmpresaController extends GetxController {
  final UsuariosEmpresaProvider provider = UsuariosEmpresaProvider();
  final GetStorage storage = GetStorage();

  // Observables
  RxList<UsuarioEmpresa> usuarios = <UsuarioEmpresa>[].obs;
  RxBool isLoading = false.obs;
  RxBool isCreating = false.obs;
  RxBool isUpdating = false.obs;
  RxString searchText = ''.obs;
  Rx<UsuarioEmpresa?> selectedUsuario = Rx<UsuarioEmpresa?>(null);

  // Controladores de formulario
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController rutController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // El campo empresa ya no se usa en el formulario, siempre se toma desde GetStorage
  // final TextEditingController empresaController = TextEditingController();
  final TextEditingController localController = TextEditingController();
  RxString selectedRol = 'CAJERO'.obs;
  RxBool mostrarPassword = false.obs;
  RxBool esEdicion = false.obs;

  // Lista de roles disponibles
  List<String> roles = ['USUARIO', 'CAJERO'];

  // Filtros
  RxList<UsuarioEmpresa> usuariosFiltrados = <UsuarioEmpresa>[].obs;

  @override
  void onInit() {
    super.onInit();
    print('🏢 UsuariosEmpresaController iniciado');
    cargarUsuarios();
    // Escuchar cambios en el texto de búsqueda
    searchText.listen((_) => aplicarFiltros());
  }

  @override
  void onClose() {
    rutController.dispose();
    nombreController.dispose();
    passwordController.dispose();
    // empresaController.dispose(); // Eliminado, ya no se usa
    localController.dispose();
    super.onClose();
  }

  // 🗑️ ELIMINAR USUARIO
  Future<void> eliminarUsuario(String? id) async {
    if (id == null) {
      mostrarError('ID de usuario no válido');
      return;
    }
    try {
      isLoading.value = true;
      final response = await provider.eliminarUsuario(id);
      if (response.success == true) {
        mostrarExito('Usuario eliminado correctamente');
        await cargarUsuarios();
      } else {
        mostrarError('No se pudo eliminar: [200b${response.message}');
      }
    } catch (e) {
      mostrarError('Error eliminando usuario: $e');
    } finally {
      isLoading.value = false;
    }
  }
  // FILTRAR USUARIOS SEGÚN BÚSQUEDA
  void aplicarFiltros() {
    List<UsuarioEmpresa> usuariosFiltradosList = usuarios.toList();
    if (searchText.value.isNotEmpty) {
      final searchLower = searchText.value.toLowerCase();
      usuariosFiltradosList = usuariosFiltradosList.where((usuario) {
        return (usuario.rut ?? '').toLowerCase().contains(searchLower) ||
               (usuario.nombreUsuario ?? '').toLowerCase().contains(searchLower);
      }).toList();
    }
    usuariosFiltrados.value = usuariosFiltradosList;
  }
  // CARGAR USUARIOS DESDE EL PROVIDER
  Future<void> cargarUsuarios() async {
    try {
      isLoading.value = true;
      final lista = await provider.findUsers();
      usuarios.value = lista;
      aplicarFiltros();
    } catch (e) {
      mostrarError('Error cargando usuarios: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ➕ CREAR USUARIO
  Future<void> crearUsuario() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    // Validación de campos obligatorios
    if (rutController.text.trim().isEmpty ||
        nombreController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        localController.text.trim().isEmpty) {
      mostrarError('Todos los campos son obligatorios.');
      return;
    }

    try {
      isCreating.value = true;
      print('➕ Creando usuario...');

      // Obtener el código de empresa desde GetStorage (siempre, sin ingreso manual)
      String? codigoEmpresa;
      final usuarioEmpresaData = storage.read('usuarioempresa');
      print('🟦 Contenido actual de GetStorage (usuarioempresa): $usuarioEmpresaData');
      if (usuarioEmpresaData != null && usuarioEmpresaData is Map) {
        if (usuarioEmpresaData['empresa'] != null) {
          codigoEmpresa = usuarioEmpresaData['empresa'].toString();
        } else if (usuarioEmpresaData['nombre'] != null) {
          codigoEmpresa = usuarioEmpresaData['nombre'].toString();
        }
      } else {
        codigoEmpresa = null;
      }
      int? localAsignadoInt;
      try {
        localAsignadoInt = int.parse(localController.text.trim());
      } catch (_) {
        mostrarError('El campo Local debe ser un número');
        isCreating.value = false;
        return;
      }
      final usuario = UsuarioEmpresa(
        rut: rutController.text.trim(),
        nombreUsuario: nombreController.text.trim(),
        password: passwordController.text,
        rol: selectedRol.value,
        empresa: codigoEmpresa,
        localAsignado: localAsignadoInt.toString(),
      );
      print('🟦 Enviando usuario al backend:');
      print('JSON enviado: ' + usuario.toJson().toString());
      print('empresa: \'${usuario.empresa}\'');
      print('local_asignado: \'${usuario.localAsignado}\'');
      print('nombre_usuario: \'${usuario.nombreUsuario}\'');
      print('rol: \'${usuario.rol}\'');
      print('rut: \'${usuario.rut}\'');
      print('password: \'${usuario.password}\'');

      final ResponseApi response = await provider.create(usuario);
      print('🟧 response.message: ${response.message}');
      print('🟧 response.body: ${response.toJson()}');

      if (response.success == true) {
        mostrarExito('Usuario creado exitosamente');
        limpiarFormulario();
        cargarUsuarios();
        Get.back();
      } else {
        mostrarError('Error al crear usuario: ${response.message}');
      }
    } catch (e) {
      print('❌ Error creando usuario: $e');
      mostrarError('Error inesperado al crear usuario');
    } finally {
      isCreating.value = false;
    }
  }

  // ✏️ ACTUALIZAR USUARIO
  Future<void> actualizarUsuario() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    // Validación de campos obligatorios
    if (rutController.text.trim().isEmpty ||
        nombreController.text.trim().isEmpty ||
        localController.text.trim().isEmpty) {
      mostrarError('Todos los campos son obligatorios.');
      return;
    }

    if (selectedUsuario.value == null) {
      mostrarError('No hay usuario seleccionado');
      return;
    }

    try {
      isUpdating.value = true;
      print('✏️ Actualizando usuario...');

      // Obtener el código de empresa desde GetStorage (igual que en crearUsuario)
      String? codigoEmpresa;
      final usuarioEmpresaData = storage.read('usuarioempresa');
      print('🟦 Contenido actual de GetStorage (usuarioempresa): $usuarioEmpresaData');
      if (usuarioEmpresaData != null && usuarioEmpresaData is Map) {
        if (usuarioEmpresaData['empresa'] != null) {
          codigoEmpresa = usuarioEmpresaData['empresa'].toString();
        } else if (usuarioEmpresaData['nombre'] != null) {
          codigoEmpresa = usuarioEmpresaData['nombre'].toString();
        }
      } else {
        codigoEmpresa = null;
      }
      int? localAsignadoInt;
      try {
        localAsignadoInt = int.parse(localController.text.trim());
      } catch (_) {
        mostrarError('El campo Local debe ser un número');
        isUpdating.value = false;
        return;
      }
      final usuario = UsuarioEmpresa(
        id: selectedUsuario.value!.id,
        rut: rutController.text.trim(),
        nombreUsuario: nombreController.text.trim(),
        password: passwordController.text.isNotEmpty ? passwordController.text : null,
        rol: selectedRol.value,
        empresa: codigoEmpresa,
        localAsignado: localAsignadoInt.toString(),
      );

      // Obtener índices de rol y local (simplificado para este ejemplo)
      final rolIndex = roles.indexOf(selectedRol.value);
      final localIndex = 1; // Simplificado

      final ResponseApi response = await provider.update(usuario, rolIndex, localIndex);

      if (response.success == true) {
        mostrarExito('Usuario actualizado exitosamente');
        limpiarFormulario();
        cargarUsuarios();
        Get.back();
      } else {
        mostrarError('Error al actualizar usuario: ${response.message}');
      }
    } catch (e) {
      print('❌ Error actualizando usuario: $e');
      mostrarError('Error inesperado al actualizar usuario');
    } finally {
      isUpdating.value = false;
    }
  }

  // 📝 PREPARAR EDICIÓN
  void prepararEdicion(UsuarioEmpresa usuario) {
    selectedUsuario.value = usuario;
    rutController.text = usuario.rut ?? '';
    nombreController.text = usuario.nombreUsuario ?? '';
    passwordController.clear();
    // empresaController.text = usuario.empresa ?? ''; // Ya no se usa
    localController.text = usuario.localAsignado ?? '';
    selectedRol.value = usuario.rol ?? 'CAJERO';
    esEdicion.value = true;
  }

  // 🆕 PREPARAR CREACIÓN
  void prepararCreacion() {
    limpiarFormulario();
    esEdicion.value = false;
  }

  // 🧹 LIMPIAR FORMULARIO
  void limpiarFormulario() {
    rutController.clear();
    nombreController.clear();
    passwordController.clear();
    // empresaController.clear(); // Ya no se usa
    localController.clear();
    selectedRol.value = 'CAJERO';
    selectedUsuario.value = null;
    esEdicion.value = false;
  }

  // 🔍 BUSCAR
  void buscar(String texto) {
    searchText.value = texto;
  }

  // 🔄 REFRESCAR
  Future<void> refrescar() async {
    await cargarUsuarios();
  }

  // Validadores
  String? validarRut(String? value) {
    if (value == null || value.isEmpty) {
      return 'RUT es requerido';
    }
    return null;
  }

  String? validarNombre(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nombre es requerido';
    }
    return null;
  }

  String? validarPassword(String? value) {
    if (esEdicion.value && (value == null || value.isEmpty)) {
      return null;
    }
    if (value == null || value.isEmpty) {
      return 'Password es requerido';
    }
    return null;
  }

  // UI helpers
  void mostrarError(String mensaje) {
    Get.snackbar(
      'Error',
      mensaje,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[800],
      duration: const Duration(seconds: 3),
    );
  }

  void mostrarExito(String mensaje) {
    Get.snackbar(
      'Éxito',
      mensaje,
      backgroundColor: Colors.green[100],
      colorText: Colors.green[800],
      duration: const Duration(seconds: 2),
    );
  }

  void toggleMostrarPassword() {
    mostrarPassword.value = !mostrarPassword.value;
  }

  // Getters para estadísticas
  int get totalUsuarios => usuarios.length;
  int get usuariosCajero => usuarios.where((u) => u.rol == 'CAJERO').length;
  int get usuariosAdmin => usuarios.where((u) => u.rol == 'USUARIO').length;
}
