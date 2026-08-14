import 'package:flutter/material.dart';
import '../../../../state/app_state_provider.dart';

class JogoHubViewModel extends ChangeNotifier {
  final AppStateProvider appState;

  String _diffAlfabeto = 'FACIL';
  String _diffMemoria = 'FACIL';
  String _diffAdivinhacao = 'FACIL';
  String _diffPalavras = 'FACIL';

  JogoHubViewModel({required this.appState}) {
    final defaultDiff = appState.currentDificuldade;
    _diffAlfabeto = defaultDiff;
    _diffMemoria = defaultDiff;
    _diffAdivinhacao = defaultDiff;
    _diffPalavras = defaultDiff;
  }

  String get diffAlfabeto => _diffAlfabeto;
  String get diffMemoria => _diffMemoria;
  String get diffAdivinhacao => _diffAdivinhacao;
  String get diffPalavras => _diffPalavras;

  void setDiffAlfabeto(String diff) {
    _diffAlfabeto = diff;
    appState.updatePersonagemDificuldade(diff);
    notifyListeners();
  }

  void setDiffMemoria(String diff) {
    _diffMemoria = diff;
    appState.updatePersonagemDificuldade(diff);
    notifyListeners();
  }

  void setDiffAdivinhacao(String diff) {
    _diffAdivinhacao = diff;
    appState.updatePersonagemDificuldade(diff);
    notifyListeners();
  }

  void setDiffPalavras(String diff) {
    _diffPalavras = diff;
    appState.updatePersonagemDificuldade(diff);
    notifyListeners();
  }

  Future<void> refreshAtividades() async {
    await appState.fetchAtividadesOnline();
    notifyListeners();
  }
}
