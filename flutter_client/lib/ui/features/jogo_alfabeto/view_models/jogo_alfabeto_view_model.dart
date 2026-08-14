import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../state/app_state_provider.dart';

class LetraJogo {
  final Map<String, String> letraData;
  bool pendente;

  LetraJogo({required this.letraData, this.pendente = true});
}

class JogoAlfabetoViewModel extends ChangeNotifier {
  final AppStateProvider appState;

  List<Map<String, String>> _letrasFila = [];
  int _currentLetterIndex = 0;

  Map<String, String>? _letraSorteada;
  List<LetraJogo> _opcoes = [];
  bool _acerto = false;
  String _feedback = 'VAZIO';
  int _acertosCount = 0;
  int _errosCount = 0;
  bool _isMatchComplete = false;

  String _diff = 'FACIL';

  JogoAlfabetoViewModel({
    required this.appState,
    String? dificuldade,
  }) {
    _diff = dificuldade ?? appState.currentDificuldade;
    carregarPartida();
  }

  String get dificuldade => _diff;
  Map<String, String>? get letraSorteada => _letraSorteada;
  List<LetraJogo> get opcoes => _opcoes;
  bool get acerto => _acerto;
  String get feedback => _feedback;
  int get acertosCount => _acertosCount;
  int get errosCount => _errosCount;
  bool get isMatchComplete => _isMatchComplete;

  void carregarPartida() {
    final alfabeto = appState.currentAlfabeto;
    if (alfabeto.isEmpty) return;

    final diff = _diff;
    final completedLetters = appState.getCompletedWordsForTema(
      jogo: 'JOGO_ALFABETO',
      tema: null,
      temaNomePadrao: 'Alfabeto',
      dificuldade: diff,
    );

    final uncompleted = alfabeto.where((item) => !completedLetters.contains(item['letra'])).toList();
    if (uncompleted.isNotEmpty) {
      _letrasFila = List<Map<String, String>>.from(uncompleted)..shuffle(Random());
    } else {
      _letrasFila = List<Map<String, String>>.from(alfabeto)..shuffle(Random());
    }

    _currentLetterIndex = 0;
    iniciarNovoJogo();
  }

  void clearFeedback() {
    _feedback = 'VAZIO';
    notifyListeners();
  }

  void iniciarNovoJogo() {
    final alfabeto = appState.currentAlfabeto;
    if (alfabeto.isEmpty || _letrasFila.isEmpty) return;

    if (_currentLetterIndex >= _letrasFila.length) {
      _isMatchComplete = true;
      notifyListeners();
      return;
    }

    final random = Random();
    final sorteada = _letrasFila[_currentLetterIndex];
    _currentLetterIndex++;

    final dificuldade = _diff;
    int quantidadeOpcoes = 3;
    if (dificuldade == 'MEDIO') {
      quantidadeOpcoes = 5;
    } else if (dificuldade == 'DIFICIL') {
      quantidadeOpcoes = 7;
    }

    final restantes = alfabeto.where((item) => item['letra'] != sorteada['letra']).toList();
    restantes.shuffle(random);

    final listOpcoes = [sorteada];
    final numAdicionais = min(quantidadeOpcoes - 1, restantes.length);
    for (int i = 0; i < numAdicionais; i++) {
      listOpcoes.add(restantes[i]);
    }
    listOpcoes.shuffle(random);

    _letraSorteada = sorteada;
    _opcoes = listOpcoes.map((e) => LetraJogo(letraData: e)).toList();
    _acerto = false;
    _feedback = 'VAZIO';
    _isMatchComplete = false;
    notifyListeners();
  }

  void verificarResposta(LetraJogo opcaoSelected) {
    if (_acerto || !opcaoSelected.pendente) return;

    if (opcaoSelected.letraData['letra'] == _letraSorteada?['letra']) {
      _acerto = true;
      _acertosCount++;
      _feedback = 'ACERTO';

      final diff = appState.activePersonagem?.dificuldade ?? 'FACIL';
      appState.registrarPalavraConcluida(
        jogo: 'JOGO_ALFABETO',
        tema: null,
        temaNomePadrao: 'Alfabeto',
        palavra: _letraSorteada!['letra']!,
        dificuldade: diff,
      );

      final bool roundEnded = _currentLetterIndex >= _letrasFila.length;
      appState.salvaPontuacao(
        _acertosCount,
        _errosCount,
        'JOGO_ALFABETO',
        concluido: roundEnded,
      );

      if (roundEnded) {
        _isMatchComplete = true;
      }
    } else {
      opcaoSelected.pendente = false;
      _errosCount++;
      _feedback = 'ERRO';

      appState.salvaPontuacao(
        _acertosCount,
        _errosCount,
        'JOGO_ALFABETO',
        concluido: false,
      );
    }

    notifyListeners();
  }
}
