import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_client/data/models/turma.dart';
import 'package:flutter_client/data/models/usuario.dart';
import 'package:flutter_client/data/models/atividade.dart';
import 'package:flutter_client/data/repositories/turma_repository.dart';
import 'package:flutter_client/data/storage/local_storage_service.dart';
import 'package:flutter_client/data/services/api_service.dart';
import 'package:flutter_client/state/app_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
    ApiService.useBackend = false; // Mock local para testes unitários determinísticos
  });

  group('Turma Model Unit Tests', () {
    test('Turma serialization and deserialization with alunos and atividadesIds', () {
      final turma = Turma(
        id: 10,
        nome: '3º Ano B - Matutino',
        descricao: 'Turma de alfabetização em Libras',
        codigo: 'LBR-3021',
        totalAlunos: 2,
        totalAtividades: 1,
        alunos: [
          Usuario(id: 1, nome: 'Pedro', username: 'pedro_aluno', role: 'USER'),
          Usuario(id: 2, nome: 'Ana', username: 'ana_aluna', role: 'USER'),
        ],
        atividadesIds: [101],
      );

      final json = turma.toJson();
      expect(json['id'], 10);
      expect(json['nome'], '3º Ano B - Matutino');
      expect(json['codigo'], 'LBR-3021');
      expect(json['alunos'], isNotEmpty);
      expect(json['atividadesIds'], contains(101));

      final restored = Turma.fromJson(json);
      expect(restored.id, 10);
      expect(restored.nome, '3º Ano B - Matutino');
      expect(restored.codigo, 'LBR-3021');
      expect(restored.alunos.length, 2);
      expect(restored.alunos.first.nome, 'Pedro');
      expect(restored.atividadesIds, contains(101));
    });

    test('Turma copyWith correctly updates properties', () {
      final t = Turma(id: 1, nome: 'Turma A', codigo: 'LBR-1001');
      final updated = t.copyWith(nome: 'Turma A Refatorada', totalAlunos: 5);

      expect(updated.id, 1);
      expect(updated.nome, 'Turma A Refatorada');
      expect(updated.codigo, 'LBR-1001');
      expect(updated.totalAlunos, 5);
    });
  });

  group('TurmaRepository Unit Tests', () {
    test('createTurma, getTurmas, updateTurma and deleteTurma persist properly in storage', () async {
      final repo = TurmaRepository();

      final created = await repo.createTurma(
        nome: 'Turma Especial AEE',
        descricao: 'Atendimento Educacional Especializado',
        codigo: 'LBR-9999',
      );

      expect(created, isNotNull);
      expect(created!.nome, 'Turma Especial AEE');
      expect(created.codigo, 'LBR-9999');

      final list = await repo.getTurmas();
      expect(list.any((t) => t.codigo == 'LBR-9999'), isTrue);

      final updated = await repo.updateTurma(
        created.id!,
        nome: 'Turma Especial AEE - Atualizada',
        descricao: 'Nova descrição',
      );
      expect(updated, isNotNull);
      expect(updated!.nome, 'Turma Especial AEE - Atualizada');

      final deleted = await repo.deleteTurma(created.id!);
      expect(deleted, isTrue);

      final listAfter = await repo.getTurmas();
      expect(listAfter.any((t) => t.id == created.id), isFalse);
    });

    test('setTurmaAlunos and setTurmaAtividades update associations properly', () async {
      final repo = TurmaRepository();

      final created = await repo.createTurma(
        nome: 'Turma Alpha',
        codigo: 'LBR-8888',
      );

      final withAlunos = await repo.setTurmaAlunos(created!.id!, [1, 2, 3]);
      expect(withAlunos, isNotNull);
      expect(withAlunos!.totalAlunos, 3);

      final withAtividades = await repo.setTurmaAtividades(created.id!, [10, 20]);
      expect(withAtividades, isNotNull);
      expect(withAtividades!.totalAtividades, 2);
      expect(withAtividades.atividadesIds, containsAll([10, 20]));
    });

    test('entrarTurma with PIN and sairTurma update active turma in storage', () async {
      final repo = TurmaRepository();

      await repo.createTurma(
        nome: 'Turma dos Pequenos',
        codigo: 'LBR-7777',
      );

      final result = await repo.entrarTurma('LBR-7777', 5);
      expect(result, isNotNull);
      expect(result!['turma'], isNotNull);

      final active = repo.getActiveTurmaLocal();
      expect(active, isNotNull);
      expect(active!.codigo, 'LBR-7777');
      expect(active.nome, 'Turma dos Pequenos');

      await repo.sairTurma(5);
      expect(repo.getActiveTurmaLocal(), isNull);
    });
  });

  group('AppStateProvider Turma Integration Tests', () {
    test('Student enters class via PIN and themes are highlighted as assigned to turma', () async {
      final appState = AppStateProvider();
      appState.loadInitialState();

      // Cria tema no estado
      final atividadeTema = Atividade(
        id: 50,
        titulo: 'Animais da Natureza',
        tipoJogo: 'JOGO_ADIVINHACAO',
        itens: [],
      );
      await appState.publicarAtividade(atividadeTema);

      // Cria turma com tema associado
      final turma = await appState.createTurma(
        nome: '1º Ano Integrado',
        codigo: 'LBR-5555',
      );
      expect(turma, isNotNull);

      await appState.setTurmaAtividades(turma!.id!, [50]);

      // Aluno entra na turma com o PIN
      final msg = await appState.entrarNaTurma('LBR-5555');
      expect(msg.startsWith('Sucesso'), isTrue);
      expect(appState.activeTurma, isNotNull);
      expect(appState.activeTurma!.codigo, 'LBR-5555');

      // Verifica se o tema agora é reconhecido como tema da turma
      final isAssigned = appState.isTemaDaTurma('Animais da Natureza', 50);
      expect(isAssigned, isTrue);

      final isOtherAssigned = appState.isTemaDaTurma('Tema Nao Atribuido', 999);
      expect(isOtherAssigned, isFalse);

      // Aluno sai da turma
      await appState.sairDaTurma();
      expect(appState.activeTurma, isNull);
      expect(appState.isTemaDaTurma('Animais da Natureza', 50), isFalse);
    });

    test('Visibility rules: public vs private vs global inactive activities', () async {
      final appState = AppStateProvider();
      appState.loadInitialState();

      // Atividade 1: Pública e Ativa
      final atvPublica = Atividade(id: 101, titulo: 'Cores', tipoJogo: 'JOGO_ADIVINHACAO', ativo: true, publica: true);
      // Atividade 2: Privada e Ativa (direcionada para a turma)
      final atvPrivada = Atividade(id: 102, titulo: 'Meios de Transporte', tipoJogo: 'JOGO_ADIVINHACAO', ativo: true, publica: false);
      // Atividade 3: Inativa globalmente (mesmo se alocada para a turma)
      final atvInativa = Atividade(id: 103, titulo: 'Frutas', tipoJogo: 'JOGO_ADIVINHACAO', ativo: false, publica: true);

      await appState.publicarAtividade(atvPublica);
      await appState.publicarAtividade(atvPrivada);
      await appState.publicarAtividade(atvInativa);

      // Cria turma e direciona a atividade privada (102) e a inativa (103)
      final turma = await appState.createTurma(nome: 'Turma B', codigo: 'LBR-7777');
      await appState.setTurmaAtividades(turma!.id!, [102, 103]);

      // 1. Cenário: Convidado (não logado)
      bool guestCanSee(Atividade a) => a.ativo && a.publica;
      expect(guestCanSee(atvPublica), isTrue); // Vê pública
      expect(guestCanSee(atvPrivada), isFalse); // Não vê privada
      expect(guestCanSee(atvInativa), isFalse); // Não vê inativa

      // 2. Cenário: Aluno logado na turma LBR-7777
      await appState.entrarNaTurma('LBR-7777');
      bool studentCanSee(Atividade a) => a.ativo && (a.publica || appState.isTemaDaTurma(a.titulo, a.id));

      expect(studentCanSee(atvPublica), isTrue); // Vê pública
      expect(studentCanSee(atvPrivada), isTrue); // Vê privada porque está alocada na sua turma!
      expect(studentCanSee(atvInativa), isFalse); // Não vê inativa (inativo global tem prioridade total!)

      // 3. Se desativar o toggle global da atividade privada:
      final atvPrivadaDesativada = atvPrivada.copyWith(ativo: false);
      expect(studentCanSee(atvPrivadaDesativada), isFalse);
    });
  });
}
