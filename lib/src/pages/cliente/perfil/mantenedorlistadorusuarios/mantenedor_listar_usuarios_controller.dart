import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:posmobilfinal/src/models/local.dart';
import 'package:posmobilfinal/src/models/response_api.dart';
import 'package:posmobilfinal/src/models/usuario_empresa.dart';
import 'package:posmobilfinal/src/providers/local_provider.dart';
import 'package:posmobilfinal/src/providers/usuarios_empresa_provider.dart';

class UsuarioEmpresaController extends GetxController {
  var usuarios = <UsuarioEmpresa>[].obs;
  var roles = ['USUARIO', 'CAJERO'].obs;
  var nombreRol = ''.obs;
  var rolId;
  var nombrelocal = ''.obs;
  var locales = <Local>[].obs;

  final LocalProvider localProvider = LocalProvider();
  final UsuariosEmpresaProvider usuariosEmpresaProvider = UsuariosEmpresaProvider();

  TextEditingController empresaController = TextEditingController();
  TextEditingController localController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  TextEditingController rolController = TextEditingController();
  TextEditingController rutController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    cargarUsuarios();
    getLocales();
  }

  Future<void> cargarUsuarios() async {
    usuarios.value = await usuariosEmpresaProvider.findUsers();
  }

  Future<void> actualizarUsuario(
    UsuarioEmpresa usuario,
    String empresa,
    String localAsignado,
    String nombreUsuario,
    String rol,
    String rut,
    String password,
  ) async {
    usuario.empresa = empresa;
    usuario.localAsignado = localAsignado;
    usuario.nombreUsuario = nombreUsuario;
    usuario.rol = rol;
    usuario.rut = rut;
    usuario.password = password ?? '';

    ResponseApi responseApi = await usuariosEmpresaProvider.update(usuario, usuario.rol, usuario.localAsignado);

    if (responseApi.success == true) {
      Get.snackbar('Proceso terminado', responseApi.message ?? '');
      Get.offNamedUntil('/inicio/cliente/mantenedorlistadorusuarios', (route) => false);
    } else {
      Get.snackbar('Registro fallido', responseApi.message ?? '');
    }

    await cargarUsuarios();
  }
// ...existing code...

  Future<void> crearUsuario(UsuarioEmpresa usuario) async {
    ResponseApi responseApi = await usuariosEmpresaProvider.create(usuario);

    if (responseApi.success == true) {
      Get.snackbar('Usuario creado', responseApi.message ?? '');
      await cargarUsuarios();
      Get.offNamedUntil('/inicio/cliente/mantenedorlistadorusuarios', (route) => false);
    } else {
      Get.snackbar('Error al crear', responseApi.message ?? '');
    }
  }

// ...existing code...
  Future<void> getLocales() async {
    var result = await localProvider.findLocals();
    locales.clear();
    locales.addAll(result);
  }

  bool validador(
    String empresa,
    String localAsignado,
    String nombreUsuario,
    String rol,
    String rut,
    String password,
  ) {
    if (empresa.isEmpty) {
      Get.snackbar('Formulario no válido', 'Debes ingresar la empresa');
      return false;
    }
    if (localAsignado.isEmpty) {
      Get.snackbar('Formulario no válido', 'Debes ingresar el local asignado');
      return false;
    }
    if (nombreUsuario.isEmpty) {
      Get.snackbar('Formulario no válido', 'Debes ingresar el nombre de usuario');
      return false;
    }
    if (rol.isEmpty) {
      Get.snackbar('Formulario no válido', 'Debes ingresar el rol');
      return false;
    }
    if (rut.isEmpty) {
      Get.snackbar('Formulario no válido', 'Debes ingresar el RUT');
      return false;
    }
    if (password.isEmpty) {
      Get.snackbar('Formulario no válido', 'Debes ingresar la contraseña');
      return false;
    }
    return true;
  }
}