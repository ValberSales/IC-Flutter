import '../models/pontuacao.dart';
import '../storage/local_storage_service.dart';

class PontuacaoRepository {
  List<Pontuacao> getPontuacaoForUsuario(int usuarioId) {
    return LocalStorageService.getPontuacaoForUsuario(usuarioId);
  }

  List<Pontuacao> getPontuacaoForPersonagem(int personagemId) => getPontuacaoForUsuario(personagemId);

  Future<void> savePontuacao(Pontuacao pontuacao) {
    return LocalStorageService.savePontuacao(pontuacao);
  }

  Set<String> getCompletedWords(int usuarioId, String jogo, String tema, String dificuldade) {
    return LocalStorageService.getCompletedWords(usuarioId, jogo, tema, dificuldade);
  }

  Future<void> saveCompletedWord(int usuarioId, String jogo, String tema, String dificuldade, String palavra) {
    return LocalStorageService.saveCompletedWord(usuarioId, jogo, tema, dificuldade, palavra);
  }
}
