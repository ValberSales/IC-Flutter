import '../models/usuario.dart';
import '../services/api_service.dart';
import '../storage/local_storage_service.dart';

class AuthRepository {
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final result = await ApiService.login(username, password);
    if (result != null && result['token'] != null && result['user'] != null) {
      final token = result['token'] as String;
      final user = Usuario.fromJson(result['user'] as Map<String, dynamic>);
      await LocalStorageService.saveToken(token);
      await LocalStorageService.saveUser(user);
    }
    return result;
  }

  Future<Map<String, dynamic>?> register(Usuario user) async {
    final result = await ApiService.cadastro(user);
    if (result != null && result['token'] != null && result['user'] != null) {
      final token = result['token'] as String;
      final savedUser = Usuario.fromJson(result['user'] as Map<String, dynamic>);
      await LocalStorageService.saveToken(token);
      await LocalStorageService.saveUser(savedUser);
    }
    return result;
  }

  Future<void> logout() async {
    await LocalStorageService.clearToken();
    await LocalStorageService.clearUser();
    await LocalStorageService.setCodigoTurma(null);
  }

  String? getToken() => LocalStorageService.getToken();
  Usuario? getUser() => LocalStorageService.getUser();
  bool get isLoggedIn => LocalStorageService.getToken() != null;
}
