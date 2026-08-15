import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_client/data/models/atividade.dart';
import 'package:flutter_client/data/storage/local_storage_service.dart';
import 'package:flutter_client/data/services/api_service.dart';
import 'package:flutter_client/state/app_state_provider.dart';
import 'package:flutter_client/ui/features/jogo_adivinhacao/view_models/jogo_adivinhacao_view_model.dart';

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

  group('JogoAdivinhacaoViewModel Unit Tests', () {
    test('iniciarRodada normalizes accents preserving Ç', () {
      final tema = Atividade(
        id: 1,
        titulo: 'Alimentos',
        tipoJogo: 'JOGO_ADIVINHACAO',
        itens: [
          ItemAtividade(descricao: 'Maçã', imagem: 'assets/maca.png'),
        ],
      );

      final vm = JogoAdivinhacaoViewModel(appState: appState, atividadeTema: tema);
      expect(vm.selectedPalavra?.descricao, 'Maçã');
      expect(vm.letrasPalavra, ['M', 'A', 'Ç', 'A']);
    });

    test('error blocks advance, records error and clear resets slots', () {
      final tema = Atividade(
        id: 2,
        titulo: 'Animais',
        tipoJogo: 'JOGO_ADIVINHACAO',
        itens: [
          ItemAtividade(descricao: 'Gato', imagem: 'assets/gato.png'),
        ],
      );

      final vm = JogoAdivinhacaoViewModel(appState: appState, atividadeTema: tema);
      expect(vm.endGame, isFalse);

      // Typing wrong letters: 'G', 'O', 'T', 'A' instead of 'G', 'A', 'T', 'O'
      vm.selectLetra({'letra': 'G', 'path': 'g.png'});
      vm.selectLetra({'letra': 'O', 'path': 'o.png'});
      vm.selectLetra({'letra': 'T', 'path': 't.png'});
      vm.selectLetra({'letra': 'A', 'path': 'a.png'});

      // Since 'O' != 'A' and 'A' != 'O', there is an error
      expect(vm.feedback, 'ERRO');
      expect(vm.errosCount, 1);
      expect(vm.endGame, isFalse); // CANNOT advance!

      // Limpar palavra
      vm.limparPalavra();
      expect(vm.feedback, 'VAZIO');
      expect(vm.letrasPreenchidas.every((e) => e == null), isTrue);
      expect(vm.activeSlotIndex, 0);

      // Now typing correct letters: 'G', 'A', 'T', 'O'
      vm.selectLetra({'letra': 'G', 'path': 'g.png'});
      vm.selectLetra({'letra': 'A', 'path': 'a.png'});
      vm.selectLetra({'letra': 'T', 'path': 't.png'});
      vm.selectLetra({'letra': 'O', 'path': 'o.png'});

      expect(vm.feedback, 'ACERTO');
      expect(vm.acertosCount, 1);
      expect(vm.endGame, isTrue); // CAN advance!
    });
  });
}
