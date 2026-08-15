import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_client/data/models/atividade.dart';
import 'package:flutter_client/data/repositories/atividade_repository.dart';
import 'package:flutter_client/data/storage/local_storage_service.dart';
import 'package:flutter_client/data/services/api_service.dart';

void main() {
  late AtividadeRepository atividadeRepository;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  setUp(() {
    atividadeRepository = AtividadeRepository();
    ApiService.useBackend = false;
  });

  group('AtividadeRepository Unit Tests', () {
    test('saveAtividade and getAtividades persist properly', () async {
      final atv = Atividade(
        id: 99,
        titulo: 'Cores em Libras',
        tipoJogo: 'JOGO_PALAVRAS',
        icone: 'palette',
        itens: [
          ItemAtividade(
            descricao: 'Azul',
            imagem: 'assets/cores/azul.png',
            opcoes: ['Azul', 'Verde', 'Amarelo', 'Vermelho', 'Preto'],
          ),
        ],
      );

      final saved = await atividadeRepository.saveAtividade(atv);
      expect(saved, isNotNull);
      expect(saved!.titulo, 'Cores em Libras');
      expect(saved.itens.first.opcoes.length, 5);

      final list = await atividadeRepository.getAtividades();
      expect(list.any((a) => a.id == 99 || a.titulo == 'Cores em Libras'), isTrue);
    });

    test('draft save, retrieve and clear work correctly', () async {
      final draft = Atividade(
        titulo: 'Rascunho de Instrumentos',
        tipoJogo: 'JOGO_ADIVINHACAO',
        rascunho: true,
        itens: [
          ItemAtividade(descricao: 'Violão', imagem: 'assets/violao.png'),
        ],
      );

      await atividadeRepository.saveRascunhoLocal(draft);
      final retrieved = atividadeRepository.getRascunhoLocal();
      expect(retrieved, isNotNull);
      expect(retrieved!.titulo, 'Rascunho de Instrumentos');

      await atividadeRepository.clearRascunhoLocal();
      expect(atividadeRepository.getRascunhoLocal(), isNull);
    });
  });
}
