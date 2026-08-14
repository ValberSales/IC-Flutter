import 'package:flutter/material.dart';
import '../../../../state/app_state_provider.dart';

class SelecaoTemaViewModel extends ChangeNotifier {
  final AppStateProvider appState;
  final String tipoJogo;
  String _currentDifficulty = 'FACIL';

  SelecaoTemaViewModel({
    required this.appState,
    required this.tipoJogo,
    String? initialDifficulty,
  }) {
    _currentDifficulty = initialDifficulty ?? appState.currentDificuldade;
  }

  String get currentDifficulty => _currentDifficulty;

  void setDifficulty(String diff) {
    _currentDifficulty = diff;
    appState.updatePersonagemDificuldade(diff);
    notifyListeners();
  }

  Future<void> refreshAtividades() async {
    await appState.fetchAtividadesOnline();
    notifyListeners();
  }
}
