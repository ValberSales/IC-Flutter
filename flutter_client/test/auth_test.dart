import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_client/data/storage/local_storage_service.dart';
import 'package:flutter_client/data/models/usuario.dart';
import 'package:flutter_client/data/services/api_service.dart';
import 'package:flutter_client/state/app_state_provider.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  group('LocalStorageService Auth Tests', () {
    test('should save, get and clear token', () async {
      expect(LocalStorageService.getToken(), isNull);
      await LocalStorageService.saveToken('my-token');
      expect(LocalStorageService.getToken(), 'my-token');
      await LocalStorageService.clearToken();
      expect(LocalStorageService.getToken(), isNull);
    });

    test('should save, get and clear user', () async {
      expect(LocalStorageService.getUser(), isNull);
      final user = Usuario(id: 1, nome: 'Test User', username: 'test');
      await LocalStorageService.saveUser(user);
      final retrieved = LocalStorageService.getUser();
      expect(retrieved, isNotNull);
      expect(retrieved!.nome, 'Test User');
      expect(retrieved.username, 'test');
      await LocalStorageService.clearUser();
      expect(LocalStorageService.getUser(), isNull);
    });
  });

  group('ApiService Auth Tests', () {
    test('login returns mock token and user when useBackend is false', () async {
      ApiService.useBackend = false;
      final response = await ApiService.login('admin', 'admin');
      expect(response, isNotNull);
      expect(response!['token'], 'mock-jwt-token-12345');
      expect(response['user']['username'], 'admin');
    });

    test('cadastro returns mock token and user when useBackend is false', () async {
      ApiService.useBackend = false;
      final user = Usuario(nome: 'New User', username: 'newuser');
      final response = await ApiService.cadastro(user);
      expect(response, isNotNull);
      expect(response!['token'], 'mock-jwt-token-12345');
      expect(response['user']['nome'], 'New User');
    });
  });

  group('AppStateProvider Auth Tests', () {
    test('login, loadInitialState and logout update state correctly', () async {
      ApiService.useBackend = false;
      final provider = AppStateProvider();
      provider.loadInitialState();
      expect(provider.isLoggedIn, isFalse);
      expect(provider.currentUser, isNull);

      await provider.login('testuser', 'password');
      expect(provider.isLoggedIn, isTrue);
      expect(provider.currentUser!.username, 'testuser');
      expect(provider.token, 'mock-jwt-token-12345');

      // Test loadInitialState re-populates state
      final newProvider = AppStateProvider();
      newProvider.loadInitialState();
      expect(newProvider.isLoggedIn, isTrue);
      expect(newProvider.currentUser!.username, 'testuser');

      await newProvider.logout();
      expect(newProvider.isLoggedIn, isFalse);
      expect(newProvider.currentUser, isNull);
    });
  });
}
