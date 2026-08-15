import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_client/data/models/turma.dart';
import 'package:flutter_client/data/models/usuario.dart';
import 'package:flutter_client/data/models/pontuacao.dart';
import 'package:flutter_client/data/models/atividade.dart';
import 'package:flutter_client/data/models/relatorio_turma.dart';
import 'package:flutter_client/data/repositories/relatorio_repository.dart';
import 'package:flutter_client/data/storage/local_storage_service.dart';
import 'package:flutter_client/data/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
    ApiService.useBackend = false;
  });

  group('RelatorioTurma Model Unit Tests', () {
    test('Serialization and Deserialization of RelatorioTurma', () {
      final relatorio = RelatorioTurma(
        turmaId: 1,
        turmaNome: 'Turma de Libras 1º Ano',
        turmaCodigo: 'LBR-1001',
        totalAlunos: 2,
        totalPartidas: 5,
        totalAcertos: 20,
        totalErros: 5,
        taxaAproveitamentoGeral: 80.0,
        alunos: [
          AlunoDesempenho(
            id: 10,
            nome: 'Aluno Teste',
            username: 'aluno_teste',
            codigoIdentificador: 'ALU-1001',
            totalPartidas: 3,
            acertos: 15,
            erros: 3,
            taxaAproveitamento: 83.3,
            dificuldadeAtual: 'FACIL',
          ),
        ],
        temas: [
          TemaRelatorio(
            id: 5,
            titulo: 'Animais em Libras',
            tipoJogo: 'JOGO_ADIVINHACAO',
            totalItens: 4,
            totalPartidas: 3,
            taxaAproveitamento: 83.3,
          ),
        ],
        evolucaoDificuldade: EvolucaoDificuldade(
          facil: 1,
          medio: 0,
          dificil: 0,
        ),
      );

      final json = relatorio.toJson();
      expect(json['turmaId'], 1);
      expect(json['turmaNome'], 'Turma de Libras 1º Ano');
      expect(json['taxaAproveitamentoGeral'], 80.0);
      expect(json['alunos'], isNotEmpty);
      expect(json['temas'], isNotEmpty);

      final restored = RelatorioTurma.fromJson(json);
      expect(restored.turmaId, 1);
      expect(restored.turmaNome, 'Turma de Libras 1º Ano');
      expect(restored.alunos.length, 1);
      expect(restored.alunos.first.nome, 'Aluno Teste');
      expect(restored.evolucaoDificuldade.facil, 1);
    });
  });

  group('RelatorioRepository Analytics & Diagnostics Tests', () {
    test('Calculates consolidated KPIs and student progress correctly', () async {
      final repository = RelatorioRepository();

      final aluno1 = Usuario(
        id: 101,
        nome: 'Lucas Silva',
        username: 'lucas',
        codigoIdentificador: 'ALU-1001',
        role: 'USER',
      );
      final aluno2 = Usuario(
        id: 102,
        nome: 'Mariana Souza',
        username: 'mariana',
        codigoIdentificador: 'ALU-1002',
        role: 'USER',
      );

      final turma = Turma(
        id: 1,
        nome: 'Turma Libras A',
        codigo: 'LBR-1001',
        alunos: [aluno1, aluno2],
        atividadesIds: [10],
      );

      // Salva pontuações para Lucas (Aproveitamento: 18 acertos, 2 erros = 90%)
      await LocalStorageService.savePontuacao(Pontuacao(
        atividade: 'JOGO_ADIVINHACAO',
        tema: 'Animais',
        acertos: 9,
        erros: 1,
        dificuldade: 'FACIL',
        usuarioId: 101,
        usuario: aluno1,
        concluido: true,
      ));
      await LocalStorageService.savePontuacao(Pontuacao(
        atividade: 'JOGO_ADIVINHACAO',
        tema: 'Cores',
        acertos: 9,
        erros: 1,
        dificuldade: 'FACIL',
        usuarioId: 101,
        usuario: aluno1,
        concluido: true,
      ));

      // Salva pontuações para Mariana (Aproveitamento: 5 acertos, 5 erros = 50%)
      await LocalStorageService.savePontuacao(Pontuacao(
        atividade: 'JOGO_ADIVINHACAO',
        tema: 'Animais',
        acertos: 5,
        erros: 5,
        dificuldade: 'FACIL',
        usuarioId: 102,
        usuario: aluno2,
        concluido: false,
      ));

      // Salva atividade temática
      await LocalStorageService.saveAtividade(Atividade(
        id: 10,
        titulo: 'Animais',
        tipoJogo: 'JOGO_ADIVINHACAO',
      ));

      final relatorio = await repository.getRelatorioTurma(turma);

      // Verificação Nível 1: Visão Consolidada
      expect(relatorio.totalAlunos, 2);
      expect(relatorio.totalPartidas, 3);
      expect(relatorio.totalAcertos, 23);
      expect(relatorio.totalErros, 7);
      // Taxa Geral: 23 / 30 = 76.7%
      expect(relatorio.taxaAproveitamentoGeral, closeTo(76.7, 0.1));

      // Verificação Nível 2: Desempenho por Aluno
      final lucasReport = relatorio.alunos.firstWhere((a) => a.id == 101);
      expect(lucasReport.totalPartidas, 2);
      expect(lucasReport.acertos, 18);
      expect(lucasReport.erros, 2);
      expect(lucasReport.taxaAproveitamento, 90.0);

      final marianaReport = relatorio.alunos.firstWhere((a) => a.id == 102);
      expect(marianaReport.totalPartidas, 1);
      expect(marianaReport.acertos, 5);
      expect(marianaReport.erros, 5);
      expect(marianaReport.taxaAproveitamento, 50.0);

      // Verificação Req 2.4: Evolução por Nível de Dificuldade (Lucas atingiu 90% em Fácil -> Médio; Mariana 50% -> Fácil)
      expect(relatorio.evolucaoDificuldade.facil, 1);
      expect(relatorio.evolucaoDificuldade.medio, 1);
      expect(lucasReport.dificuldadeCalculada, 'MEDIO');
      expect(marianaReport.dificuldadeCalculada, 'FACIL');
    });

    test('Handles memory game and 0/0 metrics safely without NaN or exceptions', () async {
      final repository = RelatorioRepository();
      final aluno = Usuario(id: 201, nome: 'Pedro', username: 'pedro', role: 'USER');
      final turma = Turma(id: 2, nome: 'Turma Vazia', codigo: 'LBR-2002', alunos: [aluno]);

      // Salva partida do jogo da memória (acertos = 0, erros = 0, concluido = true)
      await LocalStorageService.savePontuacao(Pontuacao(
        atividade: 'JOGO_MEMORIA',
        tema: 'Memoria',
        acertos: 0,
        erros: 0,
        dificuldade: 'FACIL',
        usuarioId: 201,
        usuario: aluno,
        concluido: true,
      ));

      final relatorio = await repository.getRelatorioTurma(turma);
      expect(relatorio.totalAlunos, 1);
      expect(relatorio.totalPartidas, 1);
      expect(relatorio.taxaAproveitamentoGeral, 0.0);
      expect(relatorio.taxaAproveitamentoGeral.isNaN, false);
      expect(relatorio.alunos.first.historico.first.taxaAproveitamento, 100.0);
    });
  });
}
