import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/util/text_normalizer.dart';
import '../../../../data/models/atividade.dart';
import '../../../../data/models/palavra.dart';
import '../../../../data/sources/local_data_source.dart';
import '../../../../state/app_state_provider.dart';

class JogoAdivinhacaoViewModel extends ChangeNotifier {
  final AppStateProvider appState;
  final Atividade? atividadeTema;

  List<Palavra> _palavras = [];
  List<Palavra> _palavrasFila = [];
  int _currentWordIndex = 0;

  Palavra? _selectedPalavra;
  List<String> _letrasPalavra = [];
  List<Map<String, String>?> _letrasPreenchidas = [];
  List<bool?> _slotValidation = [];
  List<Map<String, String>> _displayedAlfabeto = [];
  int _activeSlotIndex = 0;

  bool _endGame = false;
  String _feedback = 'VAZIO';
  int _acertosCount = 0;
  int _errosCount = 0;
  bool _isMatchComplete = false;

  String _diff = 'FACIL';

  JogoAdivinhacaoViewModel({
    required this.appState,
    this.atividadeTema,
    String? dificuldade,
  }) {
    _diff = dificuldade ?? appState.currentDificuldade;
    carregarPalavras();
  }

  String get dificuldade => _diff;
  Palavra? get selectedPalavra => _selectedPalavra;
  List<String> get letrasPalavra => _letrasPalavra;
  List<Map<String, String>?> get letrasPreenchidas => _letrasPreenchidas;
  List<bool?> get slotValidation => _slotValidation;
  List<Map<String, String>> get displayedAlfabeto => _displayedAlfabeto;
  int get activeSlotIndex => _activeSlotIndex;
  bool get endGame => _endGame;
  String get feedback => _feedback;
  int get acertosCount => _acertosCount;
  int get errosCount => _errosCount;
  bool get isMatchComplete => _isMatchComplete;

  void carregarPalavras() {
    if (atividadeTema != null && atividadeTema!.itens.isNotEmpty) {
      _palavras = atividadeTema!.itens.map((item) {
        return Palavra(
          tipo: 'JOGO_ADIVINHACAO',
          descricao: item.descricao,
          imagem: item.imagem,
        );
      }).toList();
    } else if (appState.customPalavras.isNotEmpty) {
      _palavras = appState.customPalavras.where((p) => p.tipo == 'JOGO_ADIVINHACAO').toList();
    }

    if (_palavras.isEmpty) {
      _palavras = LocalDataSource.animaisPadrao.map((item) {
        return Palavra(
          tipo: 'JOGO_ADIVINHACAO',
          descricao: item['descricao']!,
          imagem: item['imagem']!,
        );
      }).toList();
    }

    final diff = _diff;
    final String temaNome = atividadeTema?.titulo ?? 'Animais da Natureza';
    final completedWords = appState.getCompletedWordsForTema(
      jogo: 'JOGO_ADIVINHACAO',
      tema: atividadeTema,
      temaNomePadrao: temaNome,
      dificuldade: diff,
    );

    final uncompleted = _palavras.where((p) => !completedWords.contains(p.descricao)).toList();
    if (uncompleted.isNotEmpty) {
      _palavrasFila = List<Palavra>.from(uncompleted)..shuffle(Random());
    } else {
      _palavrasFila = List<Palavra>.from(_palavras)..shuffle(Random());
    }

    _currentWordIndex = 0;
    iniciarRodada();
  }

  void iniciarRodada() {
    if (_palavrasFila.isEmpty) return;

    if (_currentWordIndex >= _palavrasFila.length) {
      _isMatchComplete = true;
      notifyListeners();
      return;
    }

    final palavraSorteada = _palavrasFila[_currentWordIndex];
    _currentWordIndex++;

    final random = Random();
    final palavraTexto = TextNormalizer.removerAcentosPreservandoCedilha(palavraSorteada.descricao);

    List<Map<String, String>> alfabeto = List<Map<String, String>>.from(appState.currentAlfabeto);
    if (_diff == 'DIFICIL') {
      alfabeto.shuffle(random);
    }

    _selectedPalavra = palavraSorteada;
    _letrasPalavra = palavraTexto.split('');
    _letrasPreenchidas = List.generate(palavraTexto.length, (_) => null);
    _slotValidation = List.generate(palavraTexto.length, (_) => null);
    _displayedAlfabeto = alfabeto;
    _activeSlotIndex = 0;
    _endGame = false;
    _feedback = 'VAZIO';
    _isMatchComplete = false;
    notifyListeners();
  }

  void setActiveSlot(int index) {
    if (_endGame) {
      _endGame = false;
      _slotValidation = List.generate(_letrasPalavra.length, (_) => null);
      _feedback = 'VAZIO';
    }
    _letrasPreenchidas[index] = null;
    _activeSlotIndex = index;
    notifyListeners();
  }

  void limparPalavra() {
    _letrasPreenchidas = List.generate(_letrasPalavra.length, (_) => null);
    _slotValidation = List.generate(_letrasPalavra.length, (_) => null);
    _activeSlotIndex = 0;
    _feedback = 'VAZIO';
    _endGame = false;
    notifyListeners();
  }

  void clearFeedback() {
    _feedback = 'VAZIO';
    notifyListeners();
  }

  void selectLetra(Map<String, String> letraData) {
    if (_endGame) return;
    if (_activeSlotIndex < 0 || _activeSlotIndex >= _letrasPalavra.length) return;

    _letrasPreenchidas[_activeSlotIndex] = letraData;
    _feedback = 'VAZIO';

    // Procura o próximo slot vazio
    _activeSlotIndex = _letrasPreenchidas.indexOf(null);

    // Quando preencher todas as letras
    if (_activeSlotIndex == -1) {
      bool temErro = false;

      for (int i = 0; i < _letrasPalavra.length; i++) {
        final String digitado = TextNormalizer.removerAcentosPreservandoCedilha(_letrasPreenchidas[i]?['letra'] ?? '');
        final String correto = TextNormalizer.removerAcentosPreservandoCedilha(_letrasPalavra[i]);
        if (digitado == correto) {
          _slotValidation[i] = true;
        } else {
          _slotValidation[i] = false;
          temErro = true;
        }
      }

      if (temErro) {
        _errosCount++;
        _feedback = 'ERRO';
        _endGame = false; // Bloqueia avanço para próxima palavra
      } else {
        _acertosCount++;
        _feedback = 'ACERTO';
        _endGame = true; // Libera avanço com acerto total

        final diff = appState.activePersonagem?.dificuldade ?? 'FACIL';
        final String temaNome = atividadeTema?.titulo ?? 'Animais da Natureza';
        appState.registrarPalavraConcluida(
          jogo: 'JOGO_ADIVINHACAO',
          tema: atividadeTema,
          temaNomePadrao: temaNome,
          palavra: _selectedPalavra!.descricao,
          dificuldade: diff,
        );
      }

      final String temaNome = atividadeTema?.titulo ?? 'Animais da Natureza';
      final bool roundEnded = _currentWordIndex >= _palavrasFila.length && !temErro;

      appState.salvaPontuacao(
        _acertosCount,
        _errosCount,
        'JOGO_ADIVINHACAO',
        tema: temaNome,
        concluido: roundEnded,
      );

      if (roundEnded) {
        _isMatchComplete = true;
      }
    }

    notifyListeners();
  }
}
