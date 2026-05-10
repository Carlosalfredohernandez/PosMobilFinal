import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../utils/supabase_upload.dart';
import 'package:posmobilfinal/supabase_config.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:posmobilfinal/src/models/producto.dart';
import 'package:posmobilfinal/src/models/response_api.dart';
import 'package:posmobilfinal/src/pages/mantenedores/productos/mantenedores_productos_controller.dart';
import 'package:posmobilfinal/src/providers/productos_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ClienteProductosEditarController extends GetxController {
      // Sube la imagen seleccionada a Supabase Storage y retorna la URL
      Future<File> comprimirImagen(File file) async {
        final dir = await getTemporaryDirectory();
        final targetPath = '${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        var result = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          targetPath,
          quality: 60, // Puedes ajustar la calidad
          minWidth: 800,
          minHeight: 800,
        );
        if (result != null) {
          return File(result.path);
        } else {
          return file;
        }
      }

      Future<String?> subirImagenASupabase(File imagen) async {
        print('[DEBUG] [subirImagenASupabase] Iniciando subida de imagen a Supabase...');
        try {
          final uploader = SupabaseUploader(
            client: Supabase.instance.client,
            bucket: 'imagenescubo', // Actualizado: nuevo nombre del bucket
          );
          final nombreArchivo = '${const Uuid().v4()}.jpg';
          // Comprimir antes de subir
          final imagenComprimida = await comprimirImagen(imagen);
          print('[DEBUG] [subirImagenASupabase] Imagen comprimida: ${imagenComprimida.path} (${await imagenComprimida.length()} bytes)');
          final url = await uploader.uploadImage(imagenComprimida, nombreArchivo);
          print('[DEBUG] [subirImagenASupabase] URL obtenida: ' + (url ?? 'null'));
          if (url == null) {
            Get.snackbar('Error', 'No se pudo obtener la URL de la imagen subida.');
          }
          return url;
        } catch (e, st) {
          print('[ERROR] [subirImagenASupabase] Error subiendo imagen: $e');
          print(st);
          Get.snackbar('Error', 'No se pudo subir la imagen: $e');
          return null;
        }
      }
    Rx<File?> imagenSeleccionada = Rx<File?>(null);
    final ImagePicker picker = ImagePicker();
  Producto? product;
  var nombreProductoController = TextEditingController();
  var descripcionProductoController = TextEditingController();
  var codigoBarraController = TextEditingController();
  var precioVentaController = TextEditingController();
  ProductosProvider productosProvider = ProductosProvider();
  var productId = '';
  MantenedoresProductosController menu = Get.find();

  ClienteProductosEditarController(Producto producto) {
    product = producto;
    nombreProductoController.text = product?.nombreProducto ?? '';
    descripcionProductoController.text = product?.descripcionProducto ?? '';
    codigoBarraController.text = product?.codigoBarra ?? '';
    precioVentaController.text = product?.precioVenta ?? '';
    productId = product?.id ?? '';
    // Si el producto ya tiene imagen, no se carga como File, solo se muestra desde la URL en el widget
  }

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

  // Refactor: Usar MobileScanner para escanear código de barras
  Future<void> scanBarcode(BuildContext context) async {
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
              codigoBarraController.text = code;
              Navigator.pop(context);
            }
          }
        },
      ),
    ),
  );
}

  void actualizarProducto(BuildContext context) async {
      print('[DEBUG] actualizarProducto llamado');
      print('[DEBUG] nombre: ' + nombreProductoController.text.trim());
      print('[DEBUG] descripcion: ' + descripcionProductoController.text.trim());
      print('[DEBUG] codigo: ' + codigoBarraController.text.trim());
      print('[DEBUG] precioV: ' + precioVentaController.text.trim());
    String nombre = nombreProductoController.text.trim();
    String descripcion = descripcionProductoController.text.trim();
    String codigo = codigoBarraController.text.trim();
    String precioV = precioVentaController.text.trim();

    if (isValidForm(nombre, descripcion, codigo, precioV)) {
      print('[DEBUG] Formulario válido');
      String? urlImagen = product?.imagenUrl;
      if (imagenSeleccionada.value != null) {
        print('[DEBUG] Hay imagen seleccionada, subiendo a Supabase...');
        urlImagen = await subirImagenASupabase(imagenSeleccionada.value!);
        print('[DEBUG] URL imagen subida: ' + (urlImagen ?? 'null'));
        if (urlImagen == null) {
          print('[DEBUG] Error al subir imagen');
          Get.snackbar('Error', 'No se pudo subir la imagen');
          return;
        }
      }
      Producto producto = Producto(
        nombreProducto: nombre,
        id: productId,
        descripcionProducto: descripcion,
        codigoBarra: codigo,
        precioVenta: precioV,
        imagenUrl: urlImagen,
      );
      print('[DEBUG] Producto a actualizar: ' + producto.toString());
      ResponseApi responseApi = await productosProvider.update(producto);
      print('[DEBUG] Respuesta backend: ' + responseApi.toJson().toString());
      if (responseApi.success == true) {
        print('[DEBUG] Actualización exitosa, refrescando lista...');
        var result = await productosProvider.getAllByUser();
        menu.productos.clear();
        menu.productos.addAll(result);
        Get.snackbar('Proceso terminado', responseApi.message ?? '');
        // Regresar automáticamente a la lista de productos
        Future.delayed(const Duration(milliseconds: 500), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
      } else {
        print('[DEBUG] Fallo en la actualización');
        Get.snackbar('Proceso fallido', responseApi.message ?? '');
      }
    } else {
      print('[DEBUG] Formulario inválido');
    }
  }

  void deshabilitar(var productId) async {
    ResponseApi responseApi = await productosProvider.deshabilitar(productId);
    var result = await productosProvider.getAllByUser();
    menu.productos.clear();
    menu.productos.addAll(result);
    Get.snackbar('Proceso terminado', responseApi.message ?? '');
  }

  bool isValidForm(
    String nombre,
    String descripcion,
    String codigo,
    String precioV,
  ) {
    if (nombre.isEmpty) {
      Get.snackbar('Proceso Denegado', 'El nombre no puede estar vacío');
      return false;
    }
    if (descripcion.isEmpty) {
      Get.snackbar('Proceso Denegado', 'La descripción no puede estar vacía');
      return false;
    }
    if (codigo.isEmpty) {
      Get.snackbar('Proceso Denegado', 'El código de barra no puede estar vacío');
      return false;
    }
    if (precioV.isEmpty) {
      Get.snackbar('Proceso Denegado', 'El precio de venta no puede estar vacío');
      return false;
    }
    return true;
  }
  void scanBarcodeNormal(BuildContext context) async {
  await scanBarcode(context);
}
}