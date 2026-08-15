import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/atividade.dart';
import '../services/api_service.dart';

enum MediaType {
  image,
  video,
}

class MediaStorageService {
  static const String _mediaBaseFolder = 'alfabetiza_libras_media';
  static const String _imagesFolder = 'images';
  static const String _videosFolder = 'videos';

  /// Retorna o diretório base de mídias no dispositivo (ou nulo se executando na Web).
  static Future<Directory?> getMediaDirectory({MediaType type = MediaType.image}) async {
    if (kIsWeb) return null;

    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final subFolder = type == MediaType.video ? _videosFolder : _imagesFolder;
      final mediaDir = Directory('${appDocDir.path}/$_mediaBaseFolder/$subFolder');

      if (!await mediaDir.exists()) {
        await mediaDir.create(recursive: true);
      }
      return mediaDir;
    } catch (e) {
      debugPrint('MediaStorageService: Erro ao acessar diretório de mídia: $e');
      return null;
    }
  }

  /// Gera um nome de arquivo determinístico e seguro baseado no hash SHA-256 do URL/caminho.
  static String generateMediaFilename(String url, {MediaType type = MediaType.image}) {
    final cleanUrl = url.trim();
    final hash = sha256.convert(utf8.encode(cleanUrl)).toString().substring(0, 24);

    // Extrai extensão se existente
    String ext = '';
    final uri = Uri.tryParse(cleanUrl);
    final path = uri != null ? uri.path : cleanUrl;
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex != -1) {
      final candidate = path.substring(dotIndex).toLowerCase();
      if (candidate.length <= 5 && !candidate.contains('/')) {
        ext = candidate;
      }
    }

    if (ext.isEmpty) {
      ext = type == MediaType.video ? '.mp4' : '.jpg';
    }

    return '$hash$ext';
  }

  /// Retorna a URL completa para download HTTP caso o caminho seja relativo
  static String resolveFullUrl(String path) {
    final clean = path.trim();
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return clean;
    }
    if (clean.startsWith('/')) {
      return '${ApiService.baseUrl.replaceAll('/api', '')}$clean';
    }
    return '${ApiService.baseUrl}/files/$clean';
  }

  /// Verifica se a URL é elegível para armazenamento em disco nativo
  static bool isCacheableUrl(String path) {
    final clean = path.trim();
    if (clean.isEmpty) return false;
    if (clean.startsWith('assets/') || clean.startsWith('data:image')) return false;
    return true;
  }

  /// Retorna o [File] armazenado localmente se já foi baixado e existir no disco.
  static Future<File?> getLocalMediaFile(String url, {MediaType type = MediaType.image}) async {
    if (kIsWeb || !isCacheableUrl(url)) return null;

    final dir = await getMediaDirectory(type: type);
    if (dir == null) return null;

    final filename = generateMediaFilename(url, type: type);
    final file = File('${dir.path}/$filename');

    if (await file.exists()) {
      return file;
    }
    return null;
  }

  /// Baixa a mídia da rede e a salva de forma persistente no disco local.
  static Future<File?> downloadAndCacheMedia(
    String url, {
    MediaType type = MediaType.image,
    Map<String, String>? headers,
  }) async {
    if (kIsWeb || !isCacheableUrl(url)) return null;

    try {
      final dir = await getMediaDirectory(type: type);
      if (dir == null) return null;

      final filename = generateMediaFilename(url, type: type);
      final targetFile = File('${dir.path}/$filename');

      // Se já existe, retorna diretamente
      if (await targetFile.exists()) {
        return targetFile;
      }

      final fullUrl = resolveFullUrl(url);
      final response = await http.get(Uri.parse(fullUrl), headers: headers);

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        await targetFile.writeAsBytes(response.bodyBytes, flush: true);
        return targetFile;
      }
    } catch (e) {
      debugPrint('MediaStorageService: Falha ao baixar mídia $url: $e');
    }
    return null;
  }

  /// Varre uma lista de atividades e realiza o pré-download em segundo plano de todas as mídias
  static Future<void> prefetchAtividadesMedia(List<Atividade> atividades) async {
    if (kIsWeb) return;

    for (final atividade in atividades) {
      for (final item in atividade.itens) {
        // Pré-download de imagem
        if (item.imagem.isNotEmpty && isCacheableUrl(item.imagem)) {
          downloadAndCacheMedia(item.imagem, type: MediaType.image);
        }

        // Pré-download de vídeo (pavimentação para a funcionalidade futura)
        if (item.video != null && item.video!.isNotEmpty && isCacheableUrl(item.video!)) {
          downloadAndCacheMedia(item.video!, type: MediaType.video);
        }
      }
    }
  }

  /// Retorna o espaço total ocupado pelas mídias salvas em bytes.
  static Future<int> getStorageUsageBytes({MediaType? type}) async {
    if (kIsWeb) return 0;

    int totalBytes = 0;
    final typesToScan = type != null ? [type] : [MediaType.image, MediaType.video];

    for (final t in typesToScan) {
      final dir = await getMediaDirectory(type: t);
      if (dir != null && await dir.exists()) {
        final files = dir.listSync(recursive: true);
        for (final f in files) {
          if (f is File) {
            totalBytes += await f.length();
          }
        }
      }
    }
    return totalBytes;
  }

  /// Limpa os arquivos de mídia armazenados em cache local.
  static Future<void> clearMediaCache({MediaType? type}) async {
    if (kIsWeb) return;

    final typesToClear = type != null ? [type] : [MediaType.image, MediaType.video];

    for (final t in typesToClear) {
      final dir = await getMediaDirectory(type: t);
      if (dir != null && await dir.exists()) {
        try {
          await dir.delete(recursive: true);
          await dir.create(recursive: true);
        } catch (e) {
          debugPrint('MediaStorageService: Erro ao limpar cache de mídia: $e');
        }
      }
    }
  }
}
