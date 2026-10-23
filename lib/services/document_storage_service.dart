import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class DocumentStorageService {
  static const String _workerBaseUrl = String.fromEnvironment('R2_WORKER_URL');

  Future<String> upload({
    required String companyId,
    required String documentId,
    required String kind,
    required Uint8List bytes,
    required String contentType,
  }) async {
    if (_workerBaseUrl.isEmpty) {
      throw StateError(
        'URL do Worker ausente. Compile com --dart-define=R2_WORKER_URL=...',
      );
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Faça login para enviar arquivos.');

    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw StateError('Não foi possível validar sua sessão.');
    }

    final key = [companyId, documentId, kind]
        .map(Uri.encodeComponent)
        .join('/');
    final uri = Uri.parse('$_workerBaseUrl/upload/$key');
    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': contentType,
      },
      body: bytes,
    );
    if (response.statusCode != 200) {
      var message = 'Falha no envio do arquivo (${response.statusCode}).';
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        message = body['error'] as String? ?? message;
      } catch (_) {}
      throw Exception(message);
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final url = body['url'] as String?;
    if (url == null || url.isEmpty) {
      throw const FormatException('O Worker não retornou a URL do arquivo.');
    }
    return url;
  }

  static String imageContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      default:
        return 'image/jpeg';
    }
  }
}
