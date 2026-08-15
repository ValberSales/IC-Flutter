import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_client/data/models/usuario.dart';
import 'package:flutter_client/data/repositories/auth_repository.dart';
import 'package:flutter_client/data/storage/local_storage_service.dart';
import 'package:flutter_client/data/services/api_service.dart';

void main() {
  late AuthRepository authRepository;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  setUp(() {
    authRepository = AuthRepository();
    ApiService.useBackend = false;
  });

  group('AuthRepository Unit Tests', () {
    test('login saves token and user in storage', () async {
      final res = await authRepository.login('prof_ana', '123456');
      expect(res, isNotNull);
      expect(authRepository.isLoggedIn, isTrue);
      expect(authRepository.getToken(), 'mock-jwt-token-12345');
      expect(authRepository.getUser()?.username, 'prof_ana');
    });

    test('register saves token and user in storage', () async {
      final user = Usuario(nome: 'Prof Carlos', username: 'carlos', email: 'carlos@escola.com');
      final res = await authRepository.register(user);
      expect(res, isNotNull);
      expect(authRepository.isLoggedIn, isTrue);
      expect(authRepository.getUser()?.nome, 'Prof Carlos');
    });

    test('logout clears session from storage', () async {
      await authRepository.logout();
      expect(authRepository.isLoggedIn, isFalse);
      expect(authRepository.getToken(), isNull);
      expect(authRepository.getUser(), isNull);
    });
  });
}
