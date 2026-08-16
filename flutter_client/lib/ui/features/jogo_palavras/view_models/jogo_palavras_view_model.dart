import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../data/models/atividade.dart';
import '../../../../data/models/palavra.dart';
import '../../../../data/sources/local_data_source.dart';
import '../../../../state/app_state_provider.dart';

class OpcaoPalavra {
  final String palavra;
  bool pendente;

  OpcaoPalavra({required this.palavra, this.pendente = true});
}

class JogoPalavrasViewModel extends ChangeNotifier {
  final AppStateProvider appState;
  final Atividade? atividadeTema;

  List<Palavra> _palavras = [];
  List<Palavra> _palavrasFila = [];
  int _currentWordIndex = 0;

  Palavra? _selectedPalavra;
  List<OpcaoPalavra> _opcoes = [];

  bool _acerto = false;
  String _feedback = 'VAZIO';
  int _acertosCount = 0;
  int _errosCount = 0;
  bool _isMatchComplete = false;

  String _diff = 'FACIL';

  JogoPalavrasViewModel({
    required this.appState,
    this.atividadeTema,
    String? dificuldade,
  }) {
    _diff = dificuldade ?? appState.currentDificuldade;
    carregarPalavras();
  }

  String get dificuldade => _diff;
  Palavra? get selectedPalavra => _selectedPalavra;
  List<OpcaoPalavra> get opcoes => _opcoes;
  bool get acerto => _acerto;
  String get feedback => _feedback;
  int get acertosCount => _acertosCount;
  int get errosCount => _errosCount;
  bool get isMatchComplete => _isMatchComplete;

  void carregarPalavras() {
    if (atividadeTema != null && atividadeTema!.itens.isNotEmpty) {
      _palavras = atividadeTema!.itens.map((item) {
        return Palavra(
          tipo: 'JOGO_PALAVRAS',
          descricao: item.descricao,
          imagem: item.imagem,
          opcoes: item.opcoes,
        );
      }).toList();
    } else if (appState.customPalavras.isNotEmpty) {
      _palavras = appState.customPalavras.where((p) => p.tipo == 'JOGO_PALAVRAS').toList();
    }

    if (_palavras.isEmpty) {
      _palavras = LocalDataSource.familiaPadrao.map((item) {
        return Palavra(
          tipo: 'JOGO_PALAVRAS',
          descricao: item['descricao']!,
          imagem: item['imagem']!,
          opcoes: List<String>.from(item['opcoes']),
        );
      }).toList();
    }

    final diff = _diff;
    final String temaNome = atividadeTema?.titulo ?? 'Membros da Família';
    final completedWords = appState.getCompletedWordsForTema(
      jogo: 'JOGO_PALAVRAS',
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
    final dificuldade = _diff;

    int totalOpcoes = 3;
    if (dificuldade == 'MEDIO') {
      totalOpcoes = 4;
    } else if (dificuldade == 'DIFICIL') {
      totalOpcoes = 5;
    }

    final String correta = palavraSorteada.descricao.trim();

    // 1. Prioriza os distratores cadastrados pelo professor
    final List<String> distratoresItem = palavraSorteada.opcoes
        .map((o) => o.trim())
        .where((o) => o.isNotEmpty && o.toUpperCase() != correta.toUpperCase())
        .toList();

    final List<String> distratoresSelecionados = [];
    distratoresItem.shuffle(random);
    distratoresSelecionados.addAll(distratoresItem);

    final int qtdNecessaria = totalOpcoes - 1;

    // 2. Fallback se faltar distratores
    if (distratoresSelecionados.length < qtdNecessaria) {
      final Set<String> fallbackPool = {};
      for (final p in _palavras) {
        if (p.descricao.trim().isNotEmpty) {
          fallbackPool.add(p.descricao.trim());
        }
      }
      for (final p in LocalDataSource.familiaPadrao) {
        fallbackPool.add(p['descricao']!.trim());
      }
      fallbackPool.removeWhere((w) => w.toUpperCase() == correta.toUpperCase());

      final List<String> fallbackList = fallbackPool.toList()..shuffle(random);
      for (final fb in fallbackList) {
        if (distratoresSelecionados.length >= qtdNecessaria) break;
        if (!distratoresSelecionados.any((d) => d.toUpperCase() == fb.toUpperCase())) {
          distratoresSelecionados.add(fb);
        }
      }
    }

    final List<String> distratoresFinais = distratoresSelecionados.take(qtdNecessaria).toList();
    final List<String> listaFinal = [correta, ...distratoresFinais]..shuffle(random);

    _selectedPalavra = palavraSorteada;
    _opcoes = listaFinal.map((p) => OpcaoPalavra(palavra: p, pendente: true)).toList();
    _acerto = false;
    _feedback = 'VAZIO';
    notifyListeners();
  }

  void clearFeedback() {
    _feedback = 'VAZIO';
    notifyListeners();
  }

  void selectOpcao(int index) {
    if (_acerto) return;
    if (index < 0 || index >= _opcoes.length) return;
    if (!_opcoes[index].pendente) return;

    final opcao = _opcoes[index];
    final String correta = _selectedPalavra!.descricao.trim();

    if (opcao.palavra.trim().toUpperCase() == correta.toUpperCase()) {
      _acerto = true;
      _feedback = 'ACERTO';
      _acertosCount++;

      final diff = appState.currentDificuldade;
      final String temaNome = atividadeTema?.titulo ?? 'Membros da Família';
      appState.registrarPalavraConcluida(
        jogo: 'JOGO_PALAVRAS',
        tema: atividadeTema,
        temaNomePadrao: temaNome,
        palavra: _selectedPalavra!.descricao,
        dificuldade: diff,
      );

      final bool roundEnded = _currentWordIndex >= _palavrasFila.length;
      if (roundEnded && !_isMatchComplete) {
        _isMatchComplete = true;
        appState.salvaPontuacao(
          _acertosCount,
          _errosCount,
          'JOGO_PALAVRAS',
          tema: temaNome,
          concluido: true,
        );
      }
    } else {
      opcao.pendente = false;
      _feedback = 'ERRO';
      _errosCount++;
    }

    notifyListeners();
  }
}
