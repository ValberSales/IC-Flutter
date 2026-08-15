import '../models/turma.dart';
import '../services/api_service.dart';
import '../storage/local_storage_service.dart';

class TurmaRepository {
  Future<List<Turma>> getTurmas() async {
    return await ApiService.getTurmas();
  }

  Future<Turma?> getTurma(int id) async {
    return await ApiService.getTurma(id);
  }

  Future<Turma?> createTurma({
    required String nome,
    String? descricao,
    String? codigo,
    int? usuarioId,
  }) async {
    final payload = {
      'nome': nome,
      'descricao': descricao ?? '',
      'codigo': codigo,
      'usuarioId': usuarioId,
    };
    return await ApiService.createTurma(payload);
  }

  Future<Turma?> updateTurma(
    int id, {
    required String nome,
    String? descricao,
    String? codigo,
  }) async {
    final payload = {
      'nome': nome,
      'descricao': descricao ?? '',
      'codigo': codigo,
    };
    return await ApiService.updateTurma(id, payload);
  }

  Future<bool> deleteTurma(int id) async {
    return await ApiService.deleteTurma(id);
  }

  Future<Turma?> setTurmaAlunos(int id, List<int> alunoIds) async {
    return await ApiService.setTurmaAlunos(id, alunoIds);
  }

  Future<Turma?> removeAlunoTurma(int turmaId, int alunoId) async {
    return await ApiService.removeAlunoTurma(turmaId, alunoId);
  }

  Future<Turma?> setTurmaAtividades(int id, List<int> atividadeIds) async {
    return await ApiService.setTurmaAtividades(id, atividadeIds);
  }

  Future<Map<String, dynamic>?> entrarTurma(String codigo, int? alunoId) async {
    return await ApiService.entrarTurma(codigo, alunoId);
  }

  Future<bool> sairTurma(int? alunoId) async {
    return await ApiService.sairTurma(alunoId);
  }

  Future<Turma?> getTurmaDoAluno(int alunoId) async {
    return await ApiService.getTurmaDoAluno(alunoId);
  }

  Turma? getActiveTurmaLocal() {
    return LocalStorageService.getActiveTurma();
  }

  Future<void> setActiveTurmaLocal(Turma? turma) async {
    await LocalStorageService.setActiveTurma(turma);
  }
}
