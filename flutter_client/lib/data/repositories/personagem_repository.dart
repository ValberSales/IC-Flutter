import '../models/personagem.dart';
import '../storage/local_storage_service.dart';

class PersonagemRepository {
  List<Personagem> getPersonagens() => LocalStorageService.getPersonagens();
  Personagem? getActivePersonagem() => LocalStorageService.getActivePersonagem();

  Future<void> savePersonagem(Personagem p) => LocalStorageService.savePersonagem(p);
  Future<void> savePersonagensList(List<Personagem> list) => LocalStorageService.savePersonagensList(list);
  Future<void> setActivePersonagem(Personagem? p) => LocalStorageService.setActivePersonagem(p);
  Future<void> deletePersonagem(int id) => LocalStorageService.deletePersonagem(id);
}
