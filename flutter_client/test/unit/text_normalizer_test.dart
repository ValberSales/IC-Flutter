import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_client/core/util/text_normalizer.dart';

void main() {
  group('TextNormalizer Unit Tests', () {
    test('should strip accents from vowels while preserving Ç', () {
      expect(TextNormalizer.removerAcentosPreservandoCedilha('Cardápio'), 'CARDAPIO');
      expect(TextNormalizer.removerAcentosPreservandoCedilha('Maçã'), 'MAÇA');
      expect(TextNormalizer.removerAcentosPreservandoCedilha('Açúcar'), 'AÇUCAR');
      expect(TextNormalizer.removerAcentosPreservandoCedilha('Vovô e Vovó'), 'VOVO E VOVO');
      expect(TextNormalizer.removerAcentosPreservandoCedilha('Mãe e Pai'), 'MAE E PAI');
      expect(TextNormalizer.removerAcentosPreservandoCedilha('coração'), 'CORAÇAO');
    });

    test('should handle words without accents unaltered', () {
      expect(TextNormalizer.removerAcentosPreservandoCedilha('Gato'), 'GATO');
      expect(TextNormalizer.removerAcentosPreservandoCedilha('Cachorro'), 'CACHORRO');
      expect(TextNormalizer.removerAcentosPreservandoCedilha('Libras'), 'LIBRAS');
    });
  });
}
