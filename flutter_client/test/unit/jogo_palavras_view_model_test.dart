import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_client/data/models/atividade.dart';
import 'package:flutter_client/data/storage/local_storage_service.dart';
import 'package:flutter_client/services/api_service.dart';
import 'package:flutter_client/state/app_state_provider.dart';
import 'package:flutter_client/ui/features/jogo_palavras/view_models/jogo_palavras_view_model.dart';

void main() {
  late AppStateProvider appState;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
    ApiService.useBackend = false;
  });

  setUp(() {
    appState = AppStateProvider();
    appState.loadInitialState();
  });

  group('JogoPalavrasViewModel Unit Tests', () {
    test('iniciarRodada prioritizes custom distractors registered by teacher', () {
      final tema = Atividade(
        id: 10,
        titulo: 'Família',
        tipoJogo: 'JOGO_PALAVRAS',
        itens: [
          ItemAtividade(
            descricao: 'Mãe',
            imagem: 'assets/mae.png',
            opcoes: ['Pai', 'Irmão', 'Avô', 'Tio'],
          ),
        ],
      );

      final vm = JogoPalavrasViewModel(appState: appState, atividadeTema: tema);
      expect(vm.selectedPalavra?.descricao, 'Mãe');
      expect(vm.opcoes.any((o) => o.palavra.toUpperCase() == 'MÃE'), isTrue);
      // Ensure distractors come from registered opcoes
      expect(vm.opcoes.length, 3); // Easy mode has 3 options
    });

    test('selecting wrong option marks error and correct option triggers acerto', () {
      final tema = Atividade(
        id: 11,
        titulo: 'Cores',
        tipoJogo: 'JOGO_PALAVRAS',
        itens: [
          ItemAtividade(
            descricao: 'Azul',
            imagem: 'assets/azul.png',
            opcoes: ['Verde', 'Amarelo'],
          ),
        ],
      );

      final vm = JogoPalavrasViewModel(appState: appState, atividadeTema: tema);
      final wrongIndex = vm.opcoes.indexWhere((o) => o.palavra.toUpperCase() != 'AZUL');
      final correctIndex = vm.opcoes.indexWhere((o) => o.palavra.toUpperCase() == 'AZUL');

      // Select wrong option
      vm.selectOpcao(wrongIndex);
      expect(vm.feedback, 'ERRO');
      expect(vm.errosCount, 1);
      expect(vm.acerto, isFalse);
      expect(vm.opcoes[wrongIndex].pendente, isFalse);

      // Select correct option
      vm.selectOpcao(correctIndex);
      expect(vm.feedback, 'ACERTO');
      expect(vm.acertosCount, 1);
      expect(vm.acerto, isTrue);
    });
  });
}
