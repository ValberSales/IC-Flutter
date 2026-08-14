import 'package:flutter/material.dart';
import '../../../../data/models/usuario.dart';
import '../../../../state/app_state_provider.dart';

class HomeViewModel extends ChangeNotifier {
  final AppStateProvider appState;

  bool _isCadastroMode = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isMoving = false;

  // Campos de Cadastro
  String _cadastroNome = '';
  String _cadastroUsername = '';
  String _cadastroPassword = '';
  String _selectedAvatar = 'assets/avatar/avatar_1.jpg';

  // Campos de Login
  String _loginIdentifier = '';
  String _loginPassword = '';

  HomeViewModel({required this.appState});

  bool get isCadastroMode => _isCadastroMode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isMoving => _isMoving;

  String get cadastroNome => _cadastroNome;
  String get cadastroUsername => _cadastroUsername;
  String get cadastroPassword => _cadastroPassword;
  String get selectedAvatar => _selectedAvatar;

  String get loginIdentifier => _loginIdentifier;
  String get loginPassword => _loginPassword;

  void setCadastroMode(bool value) {
    _isCadastroMode = value;
    _errorMessage = null;
    notifyListeners();
  }

  void setSelectedAvatar(String avatar) {
    _selectedAvatar = avatar;
    notifyListeners();
  }

  void setLoginIdentifier(String val) {
    _loginIdentifier = val;
  }

  void setLoginPassword(String val) {
    _loginPassword = val;
  }

  void setCadastroNome(String val) {
    _cadastroNome = val;
  }

  void setCadastroUsername(String val) {
    _cadastroUsername = val;
  }

  void setCadastroPassword(String val) {
    _cadastroPassword = val;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void triggerMascotDance() {
    if (_isMoving) return;
    _isMoving = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 3), () {
      _isMoving = false;
      notifyListeners();
    });
  }

  Future<bool> executeLogin() async {
    if (_loginIdentifier.trim().isEmpty || _loginPassword.trim().isEmpty) {
      _errorMessage = 'Por favor, informe seu Usuário/ID e Senha.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final success = await appState.login(_loginIdentifier.trim(), _loginPassword.trim());

    _isLoading = false;
    if (!success) {
      _errorMessage = 'Usuário/ID ou senha incorretos.';
    }
    notifyListeners();
    return success;
  }

  Future<bool> executeRegister() async {
    if (_cadastroNome.trim().isEmpty) {
      _errorMessage = 'Por favor, informe o nome da criança ou professor.';
      notifyListeners();
      return false;
    }

    if (_cadastroUsername.trim().isEmpty) {
      _errorMessage = 'Por favor, escolha um nome de usuário (@username).';
      notifyListeners();
      return false;
    }

    if (_cadastroPassword.trim().isEmpty) {
      _errorMessage = 'Por favor, digite uma senha.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final newUser = Usuario(
      nome: _cadastroNome.trim(),
      username: _cadastroUsername.trim(),
      password: _cadastroPassword.trim(),
      avatar: _selectedAvatar,
      role: 'USER',
    );

    final success = await appState.register(newUser);

    _isLoading = false;
    if (!success) {
      _errorMessage = 'Nome de usuário já em uso ou erro na conexão.';
    }
    notifyListeners();
    return success;
  }

  Future<void> playAsGuest() async {
    await appState.enterGuestMode();
    notifyListeners();
  }
}
