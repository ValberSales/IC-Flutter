import '../models/relatorio_turma.dart';
import '../models/turma.dart';
import '../models/usuario.dart';
import '../models/pontuacao.dart';
import '../services/api_service.dart';
import '../storage/local_storage_service.dart';

class RelatorioRepository {
  double _safePercent(double value) {
    if (value.isNaN || value.isInfinite) return 0.0;
    return double.parse(value.clamp(0.0, 100.0).toStringAsFixed(1));
  }

  Future<RelatorioTurma> getRelatorioTurma(Turma turma) async {
    RelatorioTurma? onlineRelatorio;
    if (turma.id != null) {
      final onlineData = await ApiService.getRelatorioTurma(turma.id!);
      if (onlineData != null) {
        onlineRelatorio = RelatorioTurma.fromJson(onlineData);
      }
    }

    final localRelatorio = _computeLocalRelatorioTurma(turma);
    if (onlineRelatorio == null) {
      return localRelatorio;
    }

    return _mergeRelatorios(onlineRelatorio, localRelatorio);
  }

  Future<AlunoDesempenho?> getRelatorioAluno(Usuario aluno) async {
    if (aluno.id != null) {
      final onlineData = await ApiService.getRelatorioAluno(aluno.id!);
      if (onlineData != null) {
        final onlineDesempenho = AlunoDesempenho.fromJson(onlineData);
        final localDesempenho = _computeLocalRelatorioAluno(aluno);
        if (localDesempenho.totalPartidas > onlineDesempenho.totalPartidas) {
          return localDesempenho;
        }
        return onlineDesempenho;
      }
    }

    return _computeLocalRelatorioAluno(aluno);
  }

  RelatorioTurma _mergeRelatorios(RelatorioTurma online, RelatorioTurma local) {
    final List<AlunoDesempenho> mergedAlunos = [];
    final allAlunoIds = <int>{};

    for (final a in online.alunos) {
      allAlunoIds.add(a.id);
    }
    for (final a in local.alunos) {
      allAlunoIds.add(a.id);
    }

    for (final id in allAlunoIds) {
      final oList = online.alunos.where((a) => a.id == id).toList();
      final lList = local.alunos.where((a) => a.id == id).toList();

      if (oList.isNotEmpty && lList.isEmpty) {
        mergedAlunos.add(oList.first);
      } else if (lList.isNotEmpty && oList.isEmpty) {
        mergedAlunos.add(lList.first);
      } else {
        final o = oList.first;
        final l = lList.first;
        if (l.totalPartidas >= o.totalPartidas) {
          mergedAlunos.add(l);
        } else {
          mergedAlunos.add(o);
        }
      }
    }

    int totalPartidas = mergedAlunos.fold(0, (sum, a) => sum + a.totalPartidas);
    int totalAcertos = mergedAlunos.fold(0, (sum, a) => sum + a.acertos);
    int totalErros = mergedAlunos.fold(0, (sum, a) => sum + a.erros);
    double taxaGeral = (totalAcertos + totalErros > 0)
        ? (totalAcertos / (totalAcertos + totalErros)) * 100.0
        : 0.0;

    int countFacil = mergedAlunos.where((a) => a.dificuldadeAtual == 'FACIL').length;
    int countMedio = mergedAlunos.where((a) => a.dificuldadeAtual == 'MEDIO').length;
    int countDificil = mergedAlunos.where((a) => a.dificuldadeAtual == 'DIFICIL').length;

    return RelatorioTurma(
      turmaId: online.turmaId > 0 ? online.turmaId : local.turmaId,
      turmaNome: online.turmaNome.isNotEmpty ? online.turmaNome : local.turmaNome,
      turmaCodigo: online.turmaCodigo.isNotEmpty ? online.turmaCodigo : local.turmaCodigo,
      totalAlunos: mergedAlunos.length,
      totalPartidas: totalPartidas,
      totalAcertos: totalAcertos,
      totalErros: totalErros,
      taxaAproveitamentoGeral: _safePercent(taxaGeral),
      alunos: mergedAlunos,
      temas: online.temas.isNotEmpty ? online.temas : local.temas,
      evolucaoDificuldade: EvolucaoDificuldade(
        facil: countFacil,
        medio: countMedio,
        dificil: countDificil,
      ),
    );
  }

  bool _isScoreOfAluno(Pontuacao s, Usuario aluno) {
    if (s.usuarioId != null && aluno.id != null && s.usuarioId == aluno.id) return true;
    if (s.usuario?.id != null && aluno.id != null && s.usuario!.id == aluno.id) return true;
    if (s.usuario?.username != null && aluno.username != null &&
        s.usuario!.username!.trim().toLowerCase() == aluno.username!.trim().toLowerCase()) {
      return true;
    }
    return false;
  }

  RelatorioTurma _computeLocalRelatorioTurma(Turma turma) {
    final allScores = LocalStorageService.getPontuacoes();
    final allAtividades = LocalStorageService.getAtividades();

    final alunos = turma.alunos.isNotEmpty
        ? turma.alunos
        : LocalStorageService.getUsuariosList().where((u) => turma.alunoIds.contains(u.id)).toList();

    final turmaAtividades = allAtividades.where((a) => turma.atividadesIds.contains(a.id)).toList();
    final turmaThemeTitles = turmaAtividades.map((a) => a.titulo.trim().toUpperCase()).toSet();

    final List<AlunoDesempenho> alunosList = [];

    for (final aluno in alunos) {
      final pScores = allScores.where((s) => _isScoreOfAluno(s, aluno)).toList();

      int pPartidas = pScores.length;
      int pAcertos = pScores.fold(0, (sum, s) => sum + s.acertos);
      int pErros = pScores.fold(0, (sum, s) => sum + s.erros);
      double pTaxa = (pAcertos + pErros > 0) ? (pAcertos / (pAcertos + pErros)) * 100.0 : 0.0;

      // Filtra partidas nos temas da turma para diagnóstico de nível
      final turmaScores = pScores.where((s) {
        final sTema = (s.tema ?? s.atividade).trim().toUpperCase();
        return turmaThemeTitles.contains(sTema);
      }).toList();

      String calculatedLevel = 'FACIL';
      final hasDificilDominado = turmaScores.any((s) =>
          s.dificuldade.toUpperCase() == 'DIFICIL' &&
          ((s.acertos + s.erros > 0 && ((s.acertos / (s.acertos + s.erros)) * 100.0) >= 70.0) ||
              (s.atividade.toUpperCase() == 'JOGO_MEMORIA' && s.concluido)));
      final hasMedioDominado = turmaScores.any((s) =>
          s.dificuldade.toUpperCase() == 'MEDIO' &&
          ((s.acertos + s.erros > 0 && ((s.acertos / (s.acertos + s.erros)) * 100.0) >= 70.0) ||
              (s.atividade.toUpperCase() == 'JOGO_MEMORIA' && s.concluido)));
      final hasFacilDominado = turmaScores.any((s) =>
          s.dificuldade.toUpperCase() == 'FACIL' &&
          ((s.acertos + s.erros > 0 && ((s.acertos / (s.acertos + s.erros)) * 100.0) >= 70.0) ||
              (s.atividade.toUpperCase() == 'JOGO_MEMORIA' && s.concluido)));

      if (hasDificilDominado) {
        calculatedLevel = 'DIFICIL';
      } else if (hasMedioDominado || hasFacilDominado) {
        calculatedLevel = 'MEDIO';
      } else {
        calculatedLevel = 'FACIL';
      }

      final List<PartidaHistorico> historico = pScores.map((s) {
        final tot = s.acertos + s.erros;
        double tax = 0.0;
        if (s.atividade.toUpperCase() == 'JOGO_MEMORIA') {
          tax = s.concluido ? 100.0 : 0.0;
        } else if (tot > 0) {
          tax = (s.acertos / tot) * 100.0;
        }
        return PartidaHistorico(
          id: s.id,
          atividade: s.atividade,
          tema: s.tema ?? s.atividade,
          acertos: s.acertos,
          erros: s.erros,
          dificuldade: s.dificuldade,
          concluido: s.concluido,
          createdAt: s.createdAt,
          taxaAproveitamento: _safePercent(tax),
        );
      }).toList();

      alunosList.add(AlunoDesempenho(
        id: aluno.id ?? 0,
        nome: aluno.nome ?? aluno.username ?? 'Aluno',
        username: aluno.username ?? '',
        codigoIdentificador: aluno.codigoIdentificador ?? '',
        avatar: aluno.avatar ?? 'assets/avatar/avatar_1.jpg',
        totalPartidas: pPartidas,
        acertos: pAcertos,
        erros: pErros,
        taxaAproveitamento: _safePercent(pTaxa),
        dificuldadeAtual: calculatedLevel,
        dificuldadeCalculada: calculatedLevel,
        historico: historico,
      ));
    }

    int totalPartidas = alunosList.fold(0, (sum, a) => sum + a.totalPartidas);
    int totalAcertos = alunosList.fold(0, (sum, a) => sum + a.acertos);
    int totalErros = alunosList.fold(0, (sum, a) => sum + a.erros);
    double taxaGeral = (totalAcertos + totalErros > 0)
        ? (totalAcertos / (totalAcertos + totalErros)) * 100.0
        : 0.0;

    int countFacil = alunosList.where((a) => a.dificuldadeCalculada == 'FACIL').length;
    int countMedio = alunosList.where((a) => a.dificuldadeCalculada == 'MEDIO').length;
    int countDificil = alunosList.where((a) => a.dificuldadeCalculada == 'DIFICIL').length;

    // Temas da Turma
    final List<TemaRelatorio> temasList = [];
    for (final atv in turmaAtividades) {
      final temaScores = allScores.where((s) => s.tema == atv.titulo || s.atividade == atv.titulo).toList();
      int tAcertos = temaScores.fold(0, (sum, s) => sum + s.acertos);
      int tErros = temaScores.fold(0, (sum, s) => sum + s.erros);
      double tTaxa = (tAcertos + tErros > 0) ? (tAcertos / (tAcertos + tErros)) * 100.0 : 0.0;

      temasList.add(TemaRelatorio(
        id: atv.id ?? 0,
        titulo: atv.titulo,
        tipoJogo: atv.tipoJogo,
        totalItens: atv.itens.length,
        totalPartidas: temaScores.length,
        taxaAproveitamento: _safePercent(tTaxa),
      ));
    }

    return RelatorioTurma(
      turmaId: turma.id ?? 0,
      turmaNome: turma.nome,
      turmaCodigo: turma.codigo,
      totalAlunos: alunos.length,
      totalPartidas: totalPartidas,
      totalAcertos: totalAcertos,
      totalErros: totalErros,
      taxaAproveitamentoGeral: _safePercent(taxaGeral),
      alunos: alunosList,
      temas: temasList,
      evolucaoDificuldade: EvolucaoDificuldade(
        facil: countFacil,
        medio: countMedio,
        dificil: countDificil,
      ),
    );
  }

  AlunoDesempenho _computeLocalRelatorioAluno(Usuario aluno) {
    final allScores = LocalStorageService.getPontuacoes();
    final pScores = allScores.where((s) => _isScoreOfAluno(s, aluno)).toList();

    int pPartidas = pScores.length;
    int pAcertos = pScores.fold(0, (sum, s) => sum + s.acertos);
    int pErros = pScores.fold(0, (sum, s) => sum + s.erros);
    double pTaxa = (pAcertos + pErros > 0) ? (pAcertos / (pAcertos + pErros)) * 100.0 : 0.0;

    String diff = 'FACIL';
    if (pScores.isNotEmpty && pScores.first.dificuldade.isNotEmpty) {
      diff = pScores.first.dificuldade;
    }

    final List<PartidaHistorico> historico = pScores.map((s) {
      final tot = s.acertos + s.erros;
      double tax = 0.0;
      if (s.atividade.toUpperCase() == 'JOGO_MEMORIA') {
        tax = s.concluido ? 100.0 : 0.0;
      } else if (tot > 0) {
        tax = (s.acertos / tot) * 100.0;
      }
      return PartidaHistorico(
        id: s.id,
        atividade: s.atividade,
        tema: s.tema ?? s.atividade,
        acertos: s.acertos,
        erros: s.erros,
        dificuldade: s.dificuldade,
        concluido: s.concluido,
        createdAt: s.createdAt,
        taxaAproveitamento: _safePercent(tax),
      );
    }).toList();

    return AlunoDesempenho(
      id: aluno.id ?? 0,
      nome: aluno.nome ?? aluno.username ?? 'Aluno',
      username: aluno.username ?? '',
      codigoIdentificador: aluno.codigoIdentificador ?? '',
      avatar: aluno.avatar ?? 'assets/avatar/avatar_1.png',
      totalPartidas: pPartidas,
      acertos: pAcertos,
      erros: pErros,
      taxaAproveitamento: _safePercent(pTaxa),
      dificuldadeAtual: diff,
      historico: historico,
    );
  }
}
