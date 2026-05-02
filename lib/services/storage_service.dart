// lib/services/storage_service.dart
// Adapté pour Flutter Web — pas de dart:io

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class StorageService {
  // ── Cloudinary config ──
  static const _cloudName = 'dtthbibks';
  static const _uploadPreset = 'imgsPdfs';
  static const _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/auto/upload';

  /// Upload des bytes (image ou PDF) vers Cloudinary.
  /// [fileName] : nom du fichier ex: 'photo.jpg'
  /// [folder]   : 'produits' ou 'justificatifs'
  /// Retourne l'URL publique ou null en cas d'erreur.
  static Future<String?> uploadFileBytes({
    required Uint8List bytes,
    required String fileName,
    required String folder,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));

      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder;

      // Sur le web on passe les bytes directement
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final result = json.decode(utf8.decode(responseData));

      if (response.statusCode == 200) {
        final url = result['secure_url'] as String;
        debugPrint('[Cloudinary] ✅ Upload réussi: $url');
        return url;
      } else {
        debugPrint("[Cloudinary] ❌ Erreur: ${result['error']['message']}");
        return null;
      }
    } catch (e) {
      debugPrint('[Cloudinary] ❌ Erreur inattendue: $e');
      return null;
    }
  }

  /// Raccourci image produit
  static Future<String?> uploadProductImage({
    required Uint8List bytes,
    required String fileName,
  }) {
    return uploadFileBytes(
      bytes: bytes,
      fileName: fileName,
      folder: 'produits',
    );
  }

  /// Raccourci justificatif
  static Future<String?> uploadJustificatif({
    required Uint8List bytes,
    required String fileName,
  }) {
    return uploadFileBytes(
      bytes: bytes,
      fileName: fileName,
      folder: 'justificatifs',
    );
  }
}
