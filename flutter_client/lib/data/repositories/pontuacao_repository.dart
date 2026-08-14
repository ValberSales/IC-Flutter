import '../models/pontuacao.dart';
import '../storage/local_storage_service.dart';

class PontuacaoRepository {
  List<Pontuacao> getPontuacaoForPersonagem(int personagemId) {
    return LocalStorageService.getPontuacaoForPersonagem(personagemId);
  }

  Future<void> savePontuacao(Pontuacao pontuacao) {
    return LocalStorageService.savePontuacao(pontuacao);
  }

  Set<String> getCompletedWords(int personagemId, String jogo, String tema, String dificuldade) {
    return LocalStorageService.getCompletedWords(personagemId, jogo, tema, dificuldade);
  }

  Future<void> saveCompletedWord(int personagemId, String jogo, String tema, String dificuldade, String palavra) {
    return LocalStorageService.saveCompletedWord(personagemId, jogo, tema, dificuldade, palavra);
  }
}
