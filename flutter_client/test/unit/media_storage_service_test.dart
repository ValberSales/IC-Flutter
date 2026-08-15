import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_client/data/models/atividade.dart';
import 'package:flutter_client/data/storage/media_storage_service.dart';

void main() {
  group('MediaStorageService Unit Tests', () {
    test('generateMediaFilename produces deterministic SHA-256 filenames with proper extensions', () {
      final url1 = 'https://servidor.com/imagens/gato.png';
      final url2 = 'https://servidor.com/imagens/gato.png';
      final url3 = 'https://servidor.com/imagens/cachorro.jpg';
      final videoUrl = 'https://servidor.com/videos/aula_libras_animais.mp4';

      final filename1 = MediaStorageService.generateMediaFilename(url1, type: MediaType.image);
      final filename2 = MediaStorageService.generateMediaFilename(url2, type: MediaType.image);
      final filename3 = MediaStorageService.generateMediaFilename(url3, type: MediaType.image);
      final videoFilename = MediaStorageService.generateMediaFilename(videoUrl, type: MediaType.video);

      // Determinismo
      expect(filename1, equals(filename2));
      expect(filename1.endsWith('.png'), isTrue);

      // Unicidade
      expect(filename1, isNot(equals(filename3)));
      expect(filename3.endsWith('.jpg'), isTrue);

      // Vídeo
      expect(videoFilename.endsWith('.mp4'), isTrue);
    });

    test('generateMediaFilename assigns default extension when URL lacks one', () {
      final urlSemExtensao = '/api/media/files/download?id=123';

      final imgFilename = MediaStorageService.generateMediaFilename(urlSemExtensao, type: MediaType.image);
      final videoFilename = MediaStorageService.generateMediaFilename(urlSemExtensao, type: MediaType.video);

      expect(imgFilename.endsWith('.jpg'), isTrue);
      expect(videoFilename.endsWith('.mp4'), isTrue);
    });

    test('resolveFullUrl handles absolute, relative and server paths', () {
      final absolute = 'https://s3.aws.com/bucket/img.png';
      expect(MediaStorageService.resolveFullUrl(absolute), equals(absolute));

      final relativeSlash = '/api/files/test.png';
      expect(MediaStorageService.resolveFullUrl(relativeSlash).contains('/files/test.png'), isTrue);
    });

    test('isCacheableUrl filters assets, data URIs and accepts network media', () {
      expect(MediaStorageService.isCacheableUrl('assets/alfabeto/A.png'), isFalse);
      expect(MediaStorageService.isCacheableUrl('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA=='), isFalse);
      expect(MediaStorageService.isCacheableUrl(''), isFalse);

      expect(MediaStorageService.isCacheableUrl('https://example.com/sinal.png'), isTrue);
      expect(MediaStorageService.isCacheableUrl('/api/media/files/video.mp4'), isTrue);
      expect(MediaStorageService.isCacheableUrl('uploads/custom_sign.jpg'), isTrue);
    });

    test('ItemAtividade serializes and deserializes video field seamlessly', () {
      final itemComVideo = ItemAtividade(
        descricao: 'Gato em Libras',
        imagem: 'https://exemplo.com/gato.png',
        video: 'https://exemplo.com/gato_libras.mp4',
        opcoes: ['Gato', 'Cachorro', 'Pássaro'],
      );

      final json = itemComVideo.toJson();
      expect(json['descricao'], 'Gato em Libras');
      expect(json['imagem'], 'https://exemplo.com/gato.png');
      expect(json['video'], 'https://exemplo.com/gato_libras.mp4');
      expect(json['opcoes'].length, 3);

      final restored = ItemAtividade.fromJson(json);
      expect(restored.descricao, 'Gato em Libras');
      expect(restored.imagem, 'https://exemplo.com/gato.png');
      expect(restored.video, 'https://exemplo.com/gato_libras.mp4');
      expect(restored.opcoes, contains('Gato'));
    });
  });
}
