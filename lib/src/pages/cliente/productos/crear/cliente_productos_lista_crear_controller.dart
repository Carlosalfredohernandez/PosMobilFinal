import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posmobilfinal/src/utils/supabase_upload.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/models/categoria.dart';
import 'package:posmobilfinal/src/models/producto.dart';
import 'package:posmobilfinal/src/models/response_api.dart';
import 'package:posmobilfinal/src/models/usuario.dart';
import 'package:posmobilfinal/src/providers/categorias_provider.dart';
import 'package:posmobilfinal/src/providers/productos_provider.dart';

class ClienteProductosListaCrearController extends GetxController {
  // Sube la imagen seleccionada a Supabase Storage y retorna la URL pública
  Future<String?> subirImagenASupabase(File imagen) async {
    try {
      final supabase = Supabase.instance.client;
      final uploader = SupabaseUploader(client: supabase, bucket: 'imagenescubo');
      final nombreArchivo = 'productos/${const Uuid().v4()}.jpg';
      final url = await uploader.uploadImage(imagen, nombreArchivo);
      print('[SupabaseUploader] URL devuelta: $url');
      return url;
    } catch (e, st) {
      print('[SupabaseUploader] Error al subir imagen: $e');
      print(st);
      Get.snackbar('Error', 'No se pudo subir la imagen: $e');
      return null;
    }
  }
    Rx<File?> imagenSeleccionada = Rx<File?>(null);
    final ImagePicker picker = ImagePicker();

    Future<void> seleccionarImagen(BuildContext context) async {
      showModalBottomSheet(
        context: context,
        builder: (_) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Tomar foto'),
                onTap: () async {
                  final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                  if (pickedFile != null) {
                    imagenSeleccionada.value = File(pickedFile.path);
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Seleccionar de galería'),
                onTap: () async {
                  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                  if (pickedFile != null) {
                    imagenSeleccionada.value = File(pickedFile.path);
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
    }
  String _codigoBarra = 'Desconocido';
  Usuario sesionUsuario = Usuario.fromJson(GetStorage().read('usuario'));
  TextEditingController nombreProductoController = TextEditingController();
  TextEditingController descripcionProductoController = TextEditingController();
  TextEditingController codigoBarraController = TextEditingController();
  TextEditingController precioVentaController = TextEditingController();
  CategoriasProvider categoriasProvider = CategoriasProvider();

  var nombreCategoria = ''.obs;
  List<Categoria> categorias = <Categoria>[].obs;
  ProductosProvider productosProvider = ProductosProvider();

  ClienteProductosListaCrearController() {
    getCategorias();
  }

  Future<void> scanBarcodeNormal(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: 400,
        child: MobileScanner(
          onDetect: (capture) async {
            final barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final code = barcodes.first.rawValue ?? '';
              if (code.isNotEmpty) {
                _codigoBarra = code;
                codigoBarraController.text = code;
                Navigator.pop(context);
              }
            }
          },
        ),
      ),
    );
  }

  void getCategorias() async {
    var result = await categoriasProvider.getAllByUser();
    categorias.clear();
    categorias.addAll(result);
  }

  void createProduct(BuildContext context) async {
    String usuario = sesionUsuario.id.toString();
    String nombreProducto = nombreProductoController.text.trim();
    String descripcionProducto = descripcionProductoController.text.trim();
    String codigoBarra = codigoBarraController.text.trim();
    String precioCosto = "0";
    String precioVenta = precioVentaController.text.trim();
    String proveedor = "Sin Espesificar";

    print('[DEBUG] createProduct llamado');
    print('[DEBUG] usuario: $usuario');
    print('[DEBUG] nombreProducto: $nombreProducto');
    print('[DEBUG] descripcionProducto: $descripcionProducto');
    print('[DEBUG] codigoBarra: $codigoBarra');
    print('[DEBUG] precioVenta: $precioVenta');
    print('[DEBUG] proveedor: $proveedor');
    print('[DEBUG] categoria: ${nombreCategoria.value}');
    print('[DEBUG] imagenSeleccionada: ${imagenSeleccionada.value}');

    if (isValidForm()) {
      String? urlImagen;
      if (imagenSeleccionada.value != null) {
        print('[DEBUG] Subiendo imagen a Supabase...');
        urlImagen = await subirImagenASupabase(imagenSeleccionada.value!);
        print('[DEBUG] URL imagen subida: $urlImagen');
        if (urlImagen == null) {
          print('[DEBUG] Error al subir imagen');
          Get.snackbar('Error', 'No se pudo subir la imagen');
          return;
        }
      }
      Producto producto = Producto(
        usuario: usuario,
        nombreProducto: nombreProducto,
        descripcionProducto: descripcionProducto,
        codigoBarra: codigoBarra,
        precioCosto: precioCosto,
        precioVenta: precioVenta,
        proveedor: proveedor,
        categoria: nombreCategoria.value,
        imagenUrl: urlImagen,
      );
      print('[DEBUG] Enviando producto a productosProvider.create...');
      try {
        ResponseApi responseApi = await productosProvider.create(producto);
        print('[DEBUG] Respuesta productosProvider.create: \\${responseApi.toJson()}');
        getCategorias();
        Get.snackbar('Proceso terminado', responseApi.message ?? '');
        print('[DEBUG] Navegando a /inicio/cliente');
        Get.offAllNamed('/inicio/cliente');
      } catch (e, st) {
        print('[DEBUG] Error al crear producto: $e');
        print(st);
        Get.snackbar('Error', 'No se pudo crear el producto: $e');
      }
    } else {
      print('[DEBUG] Formulario no válido');
    }
    getCategorias();
  }

  void regresar() {
    Get.offNamedUntil('/mantenedores/productos', (route) => false);
  }

  bool isValidForm() {
    return true;
  }

  void clearForm() {
    nombreProductoController.text = '';
    descripcionProductoController.text = '';
    precioVentaController.text = '';
    nombreCategoria.value = '';
    update();
  }
}