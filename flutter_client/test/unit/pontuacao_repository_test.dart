import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_client/data/models/usuario.dart';
import 'package:flutter_client/data/models/pontuacao.dart';
import 'package:flutter_client/data/repositories/pontuacao_repository.dart';
import 'package:flutter_client/data/storage/local_storage_service.dart';

void main() {
  late PontuacaoRepository repository;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  setUp(() {
    repository = PontuacaoRepository();
  });

  group('PontuacaoRepository Unit Tests', () {
    test('save and retrieve scores for user', () async {
      final p1 = Pontuacao(
        atividade: 'JOGO_ADIVINHACAO',
        acertos: 5,
        erros: 1,
        concluido: true,
        usuarioId: 10,
        usuario: Usuario(id: 10, nome: 'Aluno Teste', username: 'alunoteste'),
      );

      await repository.savePontuacao(p1);
      final history = repository.getPontuacaoForUsuario(10);
      expect(history.length, 1);
      expect(history.first.acertos, 5);
      expect(history.first.erros, 1);
    });

    test('save and retrieve completed words tracking per difficulty', () async {
      await repository.saveCompletedWord(10, 'JOGO_ADIVINHACAO', 'Animais', 'FACIL', 'Gato');
      await repository.saveCompletedWord(10, 'JOGO_ADIVINHACAO', 'Animais', 'FACIL', 'Cachorro');

      final words = repository.getCompletedWords(10, 'JOGO_ADIVINHACAO', 'Animais', 'FACIL');
      expect(words.contains('Gato'), isTrue);
      expect(words.contains('Cachorro'), isTrue);
      expect(words.contains('Papagaio'), isFalse);
    });
  });
}
