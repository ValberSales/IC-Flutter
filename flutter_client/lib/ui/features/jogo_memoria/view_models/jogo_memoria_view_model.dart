import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../state/app_state_provider.dart';

class CartaMemoria {
  final String letra;
  final String path;
  final bool figura;
  bool revelada;
  final int uniqueId;

  CartaMemoria({
    required this.letra,
    required this.path,
    required this.figura,
    this.revelada = true,
    required this.uniqueId,
  });
}

class JogoMemoriaViewModel extends ChangeNotifier {
  final AppStateProvider appState;

  List<CartaMemoria> _cartas = [];
  CartaMemoria? _primeiraCarta;
  CartaMemoria? _segundaCarta;
  bool _bloqueado = false;
  bool _endGame = false;
  String _feedback = 'VAZIO';
  int _acertosCount = 0;
  int _errosCount = 0;
  Timer? _initialRevealTimer;
  String _diff = 'FACIL';

  JogoMemoriaViewModel({
    required this.appState,
    String? dificuldade,
  }) {
    _diff = dificuldade ?? appState.currentDificuldade;
    iniciarNovoJogo();
  }

  String get dificuldade => _diff;
  List<CartaMemoria> get cartas => _cartas;
  bool get endGame => _endGame;
  String get feedback => _feedback;
  int get acertosCount => _acertosCount;
  int get errosCount => _errosCount;

  @override
  void dispose() {
    _initialRevealTimer?.cancel();
    super.dispose();
  }

  void clearFeedback() {
    _feedback = 'VAZIO';
    notifyListeners();
  }

  void iniciarNovoJogo() {
    _initialRevealTimer?.cancel();
    final alfabeto = [...appState.currentAlfabeto];
    if (alfabeto.isEmpty) return;

    final dificuldade = _diff;
    int quantidadePares = 6;
    if (dificuldade == 'MEDIO') {
      quantidadePares = 8;
    } else if (dificuldade == 'DIFICIL') {
      quantidadePares = 10;
    }

    alfabeto.shuffle();
    final letrasSorteadas = alfabeto.take(quantidadePares).toList();

    final List<CartaMemoria> cartasTemp = [];
    int idCounter = 0;

    for (final item in letrasSorteadas) {
      final letra = item['letra']!;
      final path = item['path']!;

      cartasTemp.add(CartaMemoria(
        letra: letra,
        path: path,
        figura: false,
        revelada: true,
        uniqueId: idCounter++,
      ));

      cartasTemp.add(CartaMemoria(
        letra: letra,
        path: path,
        figura: true,
        revelada: true,
        uniqueId: idCounter++,
      ));
    }

    cartasTemp.shuffle();

    _cartas = cartasTemp;
    _primeiraCarta = null;
    _segundaCarta = null;
    _bloqueado = false;
    _endGame = false;
    _feedback = 'VAZIO';
    notifyListeners();

    _initialRevealTimer = Timer(const Duration(seconds: 5), () {
      for (var c in _cartas) {
        c.revelada = false;
      }
      notifyListeners();
    });
  }

  void revelarCarta(CartaMemoria carta) {
    if (_bloqueado || carta.revelada || (_primeiraCarta != null && _segundaCarta != null)) {
      return;
    }

    carta.revelada = true;

    if (_primeiraCarta == null) {
      _primeiraCarta = carta;
      notifyListeners();
      return;
    }

    _segundaCarta = carta;
    _bloqueado = true;
    notifyListeners();

    final bool saoPares = _primeiraCarta!.letra == _segundaCarta!.letra &&
        _primeiraCarta!.figura != _segundaCarta!.figura;

    if (saoPares) {
      final letraPar = _primeiraCarta!.letra;
      _feedback = 'ACERTO';
      _primeiraCarta = null;
      _segundaCarta = null;
      _bloqueado = false;

      // Registra o par acertado para progresso parcial
      appState.registrarPalavraConcluida(
        jogo: 'JOGO_MEMORIA',
        tema: null,
        temaNomePadrao: 'Memoria',
        palavra: letraPar,
        dificuldade: _diff,
      );

      final bool todasReveladas = _cartas.every((c) => c.revelada);
      if (todasReveladas) {
        _endGame = true;
        appState.salvaPontuacao(
          0,
          0,
          'JOGO_MEMORIA',
          tema: 'Memoria',
          concluido: true,
        );
      }
      notifyListeners();
    } else {
      _feedback = 'ERRO';
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 1000), () {
        _primeiraCarta?.revelada = false;
        _segundaCarta?.revelada = false;
        _primeiraCarta = null;
        _segundaCarta = null;
        _bloqueado = false;
        notifyListeners();
      });
    }
  }
}
