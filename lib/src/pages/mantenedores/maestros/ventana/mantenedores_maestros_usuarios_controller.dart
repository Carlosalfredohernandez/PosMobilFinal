import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/models/local.dart';
import 'package:posmobil/src/models/response_api.dart';
import 'package:posmobil/src/models/usuario.dart';
import 'package:posmobil/src/providers/local_provider.dart';
import 'package:posmobil/src/providers/usuarios_empresa_provider.dart';
import 'package:posmobil/src/providers/usuarios_provider.dart';

class MantenedoresMaestrosUsuariosController extends GetxController{
  List roles = ['USUARIO','CAJERO'].obs;
  LocalProvider localProvider = LocalProvider();
  UsuariosEmpresaProvider usuariosEmpresaProvider = UsuariosEmpresaProvider();
  UsuariosProvider usuariosProvider = UsuariosProvider();
  var nombreRol = ''.obs;
  var rolId;
  var nombrelocal = ''.obs;
  List<Local> locales = <Local>[].obs;

  Usuario? usuario;

  TextEditingController telefonoController = TextEditingController();
  TextEditingController claveController = TextEditingController();
  TextEditingController confirmarClaveController = TextEditingController();
  TextEditingController comunaController = TextEditingController();
  TextEditingController numeroController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  TextEditingController regionController = TextEditingController();
  TextEditingController calleController = TextEditingController();
  String? id;
  String? rut;

  MantenedoresMaestrosUsuariosController(Usuario user){
    getLocales();
    usuario = user;
    telefonoController.text = usuario!.telefono ?? '';
    comunaController.text = usuario!.comuna ?? '';
    numeroController.text = usuario!.numero ?? '';
    regionController.text = usuario!.region ?? '';
    calleController.text = usuario!.calle ?? '';
    nombreController.text = usuario!.nombre ?? '';
    id = usuario!.id;
    rut = usuario!.rut;
  }

  void actualizar() async {

    String telefono = telefonoController.text.trim();
    String clave = claveController.text.trim();
    String confirmarClave = claveController.text.trim();
    String region = regionController.text.trim();
    String calle = calleController.text.trim();
    String numero = numeroController.text.trim();
    String comuna = comunaController.text.trim();

    if (validador(rolId,telefono,clave,confirmarClave,region,comuna,numero,calle)){
      Usuario usuario = Usuario(
          telefono: telefono,
          clave: clave,
          region: region,
          numero: numero,
          comuna: comuna,
          calle: calle,
          id: id,
          rut: rut
      );
      ResponseApi responseApi = await usuariosEmpresaProvider.update(usuario, rolId, nombrelocal.value);

      if (responseApi.success == true ){
        Get.snackbar('Proceso terminado', responseApi.message ?? '');
        Get.offNamedUntil('/mantenedores/maestros/busqueda', (route) => false);
      }
      else {
        Get.snackbar('Registro fallido', responseApi.message ?? '');
      }
    }
  }

  void getLocales() async {
    var result = await localProvider.findLocals();
    locales.clear();
    locales.addAll(result);
  }

  bool validador(
      var IdRol,
      String telefono,
      String clave,
      String confirmarClave,
      String region,
      String comuna,
      String numero,
      String calle
      ){
    if (IdRol == null ){
      return false;
    }
    if (clave.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu clave');
      return false;
    }
    if (telefono.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu numero telefonico');
      return false;
    }
    if (comuna.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu comuna de residencia');
      return false;
    }
    if (numero.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu numero de residencia');
      return false;
    }
    if (calle.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu calle de residencia');
      return false;
    }
    if (region.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu region de residencia');
      return false;
    }
    if (clave.isEmpty||confirmarClave.isEmpty){
      Get.snackbar('Formulario no valido', 'Debes ingresar tu clave');
      return false;
    }
    if (clave!= confirmarClave) {
      Get.snackbar('Formulario no valido', 'Tu clave debes confirmar tu clave');
      return false;
    }
    return true;
  }
}