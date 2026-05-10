import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUploader {
  final SupabaseClient client;
  final String bucket;

  SupabaseUploader({required this.client, required this.bucket});

  /// Sube una imagen y retorna la URL pública
  Future<String?> uploadImage(File file, String filename) async {
    try {
      print('[SupabaseUploader] Intentando subir archivo: ${file.path} (${await file.length()} bytes)');
      final storage = client.storage.from(bucket);
      final path = filename; // Guardar en la raíz del bucket
      final response = await storage.upload(path, file);
      print('[SupabaseUploader] Respuesta de upload: $response');
      if (response.isEmpty) {
        print('[SupabaseUploader] El archivo ya existe, intentando update...');
        final updateResp = await storage.update(path, file);
        print('[SupabaseUploader] Respuesta de update: $updateResp');
      }
      // Obtén la URL pública
      final publicUrl = storage.getPublicUrl(path);
      print('[SupabaseUploader] URL pública generada: $publicUrl');
      return publicUrl;
    } catch (e, st) {
      print('[SupabaseUploader] Error: $e');
      print(st);
      rethrow;
    }
  }
}
