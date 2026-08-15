import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_client/data/models/usuario.dart';
import 'package:flutter_client/data/services/api_service.dart';
import 'package:flutter_client/data/storage/local_storage_service.dart';
import 'package:flutter_client/state/app_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
    ApiService.useBackend = false; // Usa modo mock para testes unitários confiáveis
  });

  group('User Authentication and Management Tests', () {
    test('Cadastro infantil simplificado define avatar, role USER e loga usuario', () async {
      final appState = AppStateProvider();
      appState.loadInitialState();

      expect(appState.isLoggedIn, isFalse);

      final novoAluno = Usuario(
        nome: 'Maria Eduarda',
        username: 'duda',
        password: '123',
        avatar: 'assets/avatar/avatar_3.jpg',
        role: 'USER',
      );

      final success = await appState.register(novoAluno);
      expect(success, isTrue);
      expect(appState.isLoggedIn, isTrue);
      expect(appState.currentUser?.nome, equals('Maria Eduarda'));
      expect(appState.currentUser?.username, equals('duda'));
      expect(appState.currentUser?.avatar, equals('assets/avatar/avatar_3.jpg'));
      expect(appState.currentUser?.isAdmin, isFalse);
    });

    test('Modo Convidado permite jogar sem cadastro', () async {
      final appState = AppStateProvider();
      appState.loadInitialState();

      expect(appState.isGuestMode, isFalse);
      expect(appState.isLoggedIn, isFalse);

      await appState.enterGuestMode();

      expect(appState.isGuestMode, isTrue);
      expect(appState.isLoggedIn, isFalse);
    });

    test('Atualizacao de perfil altera avatar e nome com persistencia local', () async {
      final appState = AppStateProvider();
      appState.loadInitialState();

      final user = Usuario(
        id: 10,
        nome: 'Lucas Silva',
        username: 'lucas',
        password: '123',
        avatar: 'assets/avatar/avatar_1.jpg',
      );

      await appState.register(user);
      expect(appState.currentUser?.avatar, equals('assets/avatar/avatar_1.jpg'));

      final updated = await appState.updateUserProfile(
        nome: 'Lucas Gabriel',
        avatar: 'assets/avatar/avatar_7.jpg',
      );

      expect(updated, isTrue);
      expect(appState.currentUser?.nome, equals('Lucas Gabriel'));
      expect(appState.currentUser?.avatar, equals('assets/avatar/avatar_7.jpg'));

      // Valida persistência
      final savedUser = LocalStorageService.getUser();
      expect(savedUser?.nome, equals('Lucas Gabriel'));
      expect(savedUser?.avatar, equals('assets/avatar/avatar_7.jpg'));

      // Teste updateAccountDetails alterando apenas nome
      final resNome = await appState.updateAccountDetails(nome: 'Lucas Gabriel Costa');
      expect(resNome['success'], isTrue);
      expect(resNome['loginDataChanged'], isFalse);
      expect(appState.isLoggedIn, isTrue);
      expect(appState.currentUser?.nome, equals('Lucas Gabriel Costa'));

      // Teste updateAccountDetails alterando username e senha (requer logout)
      final resLogin = await appState.updateAccountDetails(
        username: 'lucas_costa',
        newPassword: 'nova_senha_456',
      );
      expect(resLogin['success'], isTrue);
      expect(resLogin['loginDataChanged'], isTrue);
      expect(appState.isLoggedIn, isFalse); // Deslogado com sucesso para forçar re-login
    });

    test('Gestao de usuarios: busca, elevacao para ADMIN e exclusao', () async {
      final appState = AppStateProvider();
      appState.loadInitialState();

      final u1 = Usuario(id: 1, nome: 'Professora Carla', username: 'carla', role: 'USER');
      final u2 = Usuario(id: 2, nome: 'Aluno Joao', username: 'joao', role: 'USER');
      await LocalStorageService.saveUsuariosList([u1, u2]);

      await appState.fetchUsuariosOnline();
      expect(appState.usuarios.length, equals(2));

      // Busca filtrada
      await appState.fetchUsuariosOnline(busca: 'Carla');
      expect(appState.usuarios.length, equals(1));
      expect(appState.usuarios.first.nome, equals('Professora Carla'));

      // Eleva Carla para ADMIN
      final promoted = await appState.updateUserRole(1, 'ADMIN');
      expect(promoted, isTrue);
      expect(appState.usuarios.first.role, equals('ADMIN'));
      expect(appState.usuarios.first.isAdmin, isTrue);

      // Exclui usuario Joao
      final deleted = await appState.deleteUser(2);
      expect(deleted, isTrue);
      expect(appState.usuarios.any((u) => u.id == 2), isFalse);
    });

    test('Reset de senha gera senha temporaria de 6 digitos e exige troca obrigatoria', () async {
      final appState = AppStateProvider();
      appState.loadInitialState();

      final aluno = Usuario(
        id: 5,
        nome: 'Mariana Lima',
        username: 'mariana',
        password: 'senha_antiga',
        role: 'USER',
      );
      await LocalStorageService.saveUsuariosList([aluno]);

      // Admin reseta a senha
      final tempPassword = await appState.resetUserPassword(5);
      expect(tempPassword, isNotNull);
      expect(tempPassword!.length, equals(6));
      expect(tempPassword, equals(tempPassword.toLowerCase()));
      expect(RegExp(r'^[a-z0-9]{6}$').hasMatch(tempPassword), isTrue);

      // Aluno faz login com a senha temporária
      final loggedIn = await appState.login('mariana', tempPassword);
      expect(loggedIn, isTrue);
      expect(appState.currentUser?.mustChangePassword, isTrue);

      // Aluno define nova senha definitiva
      final trocou = await appState.changePasswordAfterReset('mariana1234');
      expect(trocou, isTrue);
      expect(appState.currentUser?.mustChangePassword, isFalse);
    });

    test('Logout limpa sessao e modo convidado', () async {
      final appState = AppStateProvider();
      appState.loadInitialState();

      await appState.enterGuestMode();
      expect(appState.isGuestMode, isTrue);

      await appState.logout();
      expect(appState.isGuestMode, isFalse);
      expect(appState.isLoggedIn, isFalse);
      expect(appState.currentUser, isNull);
    });

    test('createUsuario gera ID unico alfanumerico UUID', () async {
      final appState = AppStateProvider();
      appState.loadInitialState();

      // 1. Criar novo Aluno
      final aluno = await appState.createUsuario(
        username: 'aluno_teste',
        nome: 'Aluno Teste',
        role: 'USER',
        password: '123',
      );
      expect(aluno, isNotNull);
      expect(aluno!.role, equals('USER'));
      expect(aluno.codigoIdentificador, isNotNull);
      expect(aluno.codigoIdentificador!.length, greaterThanOrEqualTo(32));
      expect(aluno.isAdmin, isFalse);

      // 2. Criar novo Professor / Admin
      final admin = await appState.createUsuario(
        username: 'professor_teste',
        nome: 'Professor Teste',
        role: 'ADMIN',
        password: 'admin_pass_123',
      );
      expect(admin, isNotNull);
      expect(admin!.role, equals('ADMIN'));
      expect(admin.codigoIdentificador, isNotNull);
      expect(admin.codigoIdentificador!.length, greaterThanOrEqualTo(32));
      expect(admin.isAdmin, isTrue);
    });
  });
}
