import '../models/atividade.dart';
import '../services/api_service.dart';
import '../storage/local_storage_service.dart';

class AtividadeRepository {
  Future<List<Atividade>> getAtividades({bool apenasAtivas = false}) async {
    final remoteList = await ApiService.getAtividades(apenasAtivas: apenasAtivas);
    if (remoteList.isNotEmpty) {
      return remoteList;
    }
    return LocalStorageService.getAtividades();
  }

  Future<Atividade?> saveAtividade(Atividade atv) async {
    final saved = await ApiService.saveAtividade(atv);
    await LocalStorageService.saveAtividade(saved ?? atv);
    return saved ?? atv;
  }

  Future<bool> toggleAtividadeStatus(int id) async {
    final ok = await ApiService.toggleAtividadeStatus(id);
    return ok;
  }

  Future<bool> deleteAtividade(int id) async {
    final ok = await ApiService.deleteAtividade(id);
    await LocalStorageService.deleteAtividade(id);
    return ok;
  }

  Atividade? getRascunhoLocal() => LocalStorageService.getRascunhoAtividade();
  Future<void> saveRascunhoLocal(Atividade atv) => LocalStorageService.saveRascunhoAtividade(atv);
  Future<void> clearRascunhoLocal() => LocalStorageService.clearRascunhoAtividade();
}
