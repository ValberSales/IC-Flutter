import 'package:flutter/material.dart';
import '../../../../data/models/atividade.dart';
import '../../../../data/models/usuario.dart';
import '../../../../state/app_state_provider.dart';

class AreaProfessorViewModel extends ChangeNotifier {
  final AppStateProvider appState;

  bool _isCreatingActivity = false;
  int? _editingActivityId;
  String _selectedTipoJogo = 'JOGO_ADIVINHACAO';
  String _selectedDificuldade = 'FACIL';
  String _selectedIconKey = 'pets';
  bool _selectedPublica = true;
  bool _selectedAtivo = true;
  String _categoriaFiltro = 'TODOS';
  List<ItemAtividade> _editingItens = [];

  bool _isLoginMode = true;
  bool _isAuthLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _authError;
  bool _isSyncLoading = false;
  String? _syncStatusMessage;

  AreaProfessorViewModel({required this.appState});

  bool get isCreatingActivity => _isCreatingActivity;
  int? get editingActivityId => _editingActivityId;
  String get selectedTipoJogo => _selectedTipoJogo;
  String get selectedDificuldade => _selectedDificuldade;
  String get selectedIconKey => _selectedIconKey;
  bool get selectedPublica => _selectedPublica;
  bool get selectedAtivo => _selectedAtivo;
  String get categoriaFiltro => _categoriaFiltro;
  List<ItemAtividade> get editingItens => _editingItens;

  bool get isLoginMode => _isLoginMode;
  bool get isAuthLoading => _isAuthLoading;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  String? get authError => _authError;
  bool get isSyncLoading => _isSyncLoading;
  String? get syncStatusMessage => _syncStatusMessage;

  void toggleLoginMode() {
    _isLoginMode = !_isLoginMode;
    _authError = null;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void setCategoriaFiltro(String categoria) {
    _categoriaFiltro = categoria;
    notifyListeners();
  }

  void setTipoJogo(String tipo) {
    _selectedTipoJogo = tipo;
    notifyListeners();
  }

  void setIconKey(String key) {
    _selectedIconKey = key;
    notifyListeners();
  }

  void setPublica(bool val) {
    _selectedPublica = val;
    notifyListeners();
  }

  void setAtivo(bool val) {
    _selectedAtivo = val;
    notifyListeners();
  }

  void initCreationForm({Atividade? existingAtividade}) {
    if (existingAtividade != null) {
      _editingActivityId = existingAtividade.id;
      _selectedTipoJogo = existingAtividade.tipoJogo;
      _selectedDificuldade = existingAtividade.dificuldade;
      _selectedIconKey = existingAtividade.icone ?? 'pets';
      _selectedPublica = existingAtividade.publica;
      _selectedAtivo = existingAtividade.ativo;
      _editingItens = List.from(existingAtividade.itens);
    } else {
      _editingActivityId = null;
      _selectedTipoJogo = 'JOGO_ADIVINHACAO';
      _selectedDificuldade = 'FACIL';
      _selectedIconKey = 'pets';
      _selectedPublica = true;
      _selectedAtivo = true;
      _editingItens = [];
    }
    _isCreatingActivity = true;
    notifyListeners();
  }

  void closeCreationForm() {
    _isCreatingActivity = false;
    notifyListeners();
  }

  void addItem(ItemAtividade item) {
    _editingItens.add(item);
    notifyListeners();
  }

  void updateItem(int index, ItemAtividade item) {
    if (index >= 0 && index < _editingItens.length) {
      _editingItens[index] = item;
      notifyListeners();
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < _editingItens.length) {
      _editingItens.removeAt(index);
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isAuthLoading = true;
    _authError = null;
    notifyListeners();

    try {
      await appState.login(username, password);
      _isAuthLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isAuthLoading = false;
      _authError = 'Usuário ou senha incorretos.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(Usuario user) async {
    _isAuthLoading = true;
    _authError = null;
    notifyListeners();

    try {
      await appState.register(user);
      _isAuthLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isAuthLoading = false;
      _authError = 'Erro ao realizar o cadastro. O usuário já existe?';
      notifyListeners();
      return false;
    }
  }

  Future<void> saveDraft(String titulo) async {
    final atv = Atividade(
      id: _editingActivityId,
      titulo: titulo.trim().isEmpty ? 'Sem Título (Rascunho)' : titulo.trim(),
      tipoJogo: _selectedTipoJogo,
      dificuldade: _selectedDificuldade,
      icone: _selectedIconKey,
      rascunho: true,
      ativo: _selectedAtivo,
      publica: _selectedPublica,
      itens: _editingItens,
    );
    await appState.salvarRascunhoAtividade(atv);
    _isCreatingActivity = false;
    notifyListeners();
  }

  Future<void> publishActivity(String titulo) async {
    final atv = Atividade(
      id: _editingActivityId,
      titulo: titulo.trim(),
      tipoJogo: _selectedTipoJogo,
      dificuldade: _selectedDificuldade,
      icone: _selectedIconKey,
      rascunho: false,
      ativo: _selectedAtivo,
      publica: _selectedPublica,
      itens: _editingItens,
    );
    await appState.publicarAtividade(atv);
    _isCreatingActivity = false;
    notifyListeners();
  }

  Future<String> syncClassroom(String code) async {
    _isSyncLoading = true;
    _syncStatusMessage = null;
    notifyListeners();

    final res = await appState.sincronizaSala(code.trim());
    _isSyncLoading = false;
    _syncStatusMessage = res;
    notifyListeners();
    return res;
  }

  Future<void> unlinkClassroom() async {
    await appState.desvincularTurma();
    _syncStatusMessage = "Sala desvinculada com sucesso.";
    notifyListeners();
  }
}
