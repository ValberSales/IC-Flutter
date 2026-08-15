import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pontuacao.dart';
import '../models/usuario.dart';
import '../models/atividade.dart';
import '../models/turma.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;

  static const String _keyPontuacoes = 'JOGO_LIBRAS_PONTUACOES';
  static const String _keyCodigoTurma = 'CODIGO_TURMA';
  static const String _keyActiveTurma = 'ACTIVE_TURMA';
  static const String _keyTurmasList = 'JOGO_LIBRAS_TURMAS_LIST';
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'logged_in_user';
  static const String _keyAtividades = 'JOGO_LIBRAS_ATIVIDADES';
  static const String _keyRascunhoAtividade = 'JOGO_LIBRAS_RASCUNHO_ATIVIDADE';
  static const String _keyGuestMode = 'IS_GUEST_MODE';
  static const String _keyUsuariosList = 'JOGO_LIBRAS_USUARIOS_LIST';


  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- CONFIGURAÇÕES GERAIS ---

  static String? getCodigoTurma() {
    return _prefs.getString(_keyCodigoTurma);
  }

  static Future<void> setCodigoTurma(String? value) async {
    if (value == null) {
      await _prefs.remove(_keyCodigoTurma);
    } else {
      await _prefs.setString(_keyCodigoTurma, value);
    }
  }

  // --- AUTENTICAÇÃO ---

  static Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  static String? getToken() {
    return _prefs.getString(_keyToken);
  }

  static Future<void> clearToken() async {
    await _prefs.remove(_keyToken);
  }

  static Future<void> saveUser(Usuario user) async {
    await _prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  static Usuario? getUser() {
    final raw = _prefs.getString(_keyUser);
    if (raw == null) return null;
    try {
      return Usuario.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearUser() async {
    await _prefs.remove(_keyUser);
  }

  // --- MODO CONVIDADO ---

  static bool isGuestMode() {
    return _prefs.getBool(_keyGuestMode) ?? false;
  }

  static Future<void> setGuestMode(bool value) async {
    await _prefs.setBool(_keyGuestMode, value);
  }

  // --- CACHE DE USUÁRIOS (OFFLINE-FIRST) ---

  static List<Usuario> getUsuarios() => getUsuariosList();

  static List<Usuario> getUsuariosList() {
    final raw = _prefs.getString(_keyUsuariosList);
    if (raw == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((item) => Usuario.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveUsuariosList(List<Usuario> list) async {
    final jsonList = list.map((u) => u.toJson()).toList();
    await _prefs.setString(_keyUsuariosList, jsonEncode(jsonList));
  }

  // --- PONTUAÇÃO ---

  static List<Pontuacao> getPontuacoes() {
    final raw = _prefs.getString(_keyPontuacoes);
    if (raw == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((item) => Pontuacao.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> savePontuacao(Pontuacao score, {int? oldId}) async {
    final list = getPontuacoes();

    final newTot = score.acertos + score.erros;
    final double newTaxa = (score.atividade.toUpperCase() == 'JOGO_MEMORIA')
        ? (score.concluido ? 100.0 : 0.0)
        : (newTot > 0 ? (score.acertos / newTot) * 100.0 : 0.0);

    final scoreUid = score.usuarioId ?? score.usuario?.id;

    // Procura registro prévio do mesmo aluno para o mesmo jogo, tema e dificuldade
    final matchIndex = list.indexWhere((existing) {
      if (oldId != null && existing.id == oldId) return true;
      if (score.id != null && existing.id == score.id) return true;

      final existingUid = existing.usuarioId ?? existing.usuario?.id;
      final sameUser = scoreUid != null && existingUid != null && scoreUid == existingUid;
      if (!sameUser) return false;

      final sameAtividade = existing.atividade.toUpperCase() == score.atividade.toUpperCase();
      final sameTema = (existing.tema ?? existing.atividade).trim().toUpperCase() == (score.tema ?? score.atividade).trim().toUpperCase();
      final sameDiff = (existing.dificuldade).toUpperCase() == (score.dificuldade).toUpperCase();

      return sameAtividade && sameTema && sameDiff;
    });

    if (matchIndex != -1) {
      final existing = list[matchIndex];
      final oldTot = existing.acertos + existing.erros;
      final double oldTaxa = (existing.atividade.toUpperCase() == 'JOGO_MEMORIA')
          ? (existing.concluido ? 100.0 : 0.0)
          : (oldTot > 0 ? (existing.acertos / oldTot) * 100.0 : 0.0);

      // Mescla progresso de itens
      if (score.progressoItens != null && score.progressoItens!.trim().isNotEmpty) {
        final Set<String> merged = {};
        if (existing.progressoItens != null) {
          merged.addAll(existing.progressoItens!.split(','));
        }
        merged.addAll(score.progressoItens!.split(','));
        existing.progressoItens = merged.join(',');
      }

      if (newTaxa >= oldTaxa || oldId != null) {
        // Sobrescreve com o aproveitamento atualizado/evoluído
        score.id = existing.id ?? score.id;
        score.createdAt = DateTime.now();
        if (score.progressoItens == null || score.progressoItens!.isEmpty) {
          score.progressoItens = existing.progressoItens;
        }
        list[matchIndex] = score;
      } else {
        // Mantém a melhor pontuação anterior mas atualiza o progresso mesclado
        list[matchIndex] = existing;
        await savePontuacoesList(list);
        return;
      }
    } else {
      if (score.id == null) {
        int minId = -1;
        for (final existing in list) {
          if (existing.id != null && existing.id! < minId) {
            minId = existing.id!;
          }
        }
        score.id = minId - 1;
        score.createdAt = DateTime.now();
      }
      list.add(score);
    }
    await savePontuacoesList(list);
  }

  static Future<void> savePontuacoesList(List<Pontuacao> list) async {
    await _prefs.setString(_keyPontuacoes, jsonEncode(list.map((item) => item.toJson()).toList()));
  }

  static List<Pontuacao> getPontuacaoForUsuario(int usuarioId) {
    final all = getPontuacoes();
    return all.where((score) => (score.usuarioId == usuarioId || score.usuario?.id == usuarioId)).toList();
  }

  // --- PROGRESSO E CONCLUSÃO DE PALAVRAS ---
  static const String _keyCompletedWords = 'ic_completed_words';

  static Set<String> getCompletedWords(int usuarioId, String jogo, String temaKey, String dificuldade) {
    final raw = _prefs.getString(_keyCompletedWords);
    if (raw == null) return {};
    try {
      final Map<String, dynamic> map = jsonDecode(raw);
      final key = '${usuarioId}_${jogo}_${temaKey}_$dificuldade';
      final List<dynamic>? list = map[key];
      return list != null ? list.map((e) => e.toString()).toSet() : {};
    } catch (e) {
      return {};
    }
  }

  static Future<void> saveCompletedWord(int usuarioId, String jogo, String temaKey, String dificuldade, String palavra) async {
    final raw = _prefs.getString(_keyCompletedWords);
    Map<String, dynamic> map = {};
    if (raw != null) {
      try {
        map = Map<String, dynamic>.from(jsonDecode(raw));
      } catch (_) {}
    }
    final key = '${usuarioId}_${jogo}_${temaKey}_$dificuldade';
    final List<String> current = (map[key] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    if (!current.contains(palavra)) {
      current.add(palavra);
      map[key] = current;
      await _prefs.setString(_keyCompletedWords, jsonEncode(map));
    }
  }

  // --- ATIVIDADES E RASCUNHOS ---

  static List<Atividade> getAtividades() {
    final raw = _prefs.getString(_keyAtividades);
    if (raw == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((item) => Atividade.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveAtividadesList(List<Atividade> list) async {
    await _prefs.setString(_keyAtividades, jsonEncode(list.map((item) => item.toJson()).toList()));
  }

  static Future<void> saveAtividade(Atividade atv) async {
    final list = getAtividades();
    if (atv.id == null) {
      int minId = -1;
      for (final existing in list) {
        if (existing.id != null && existing.id! < minId) {
          minId = existing.id!;
        }
      }
      atv.id = minId - 1;
      atv.createdAt = DateTime.now();
    }

    final index = list.indexWhere((item) => item.id == atv.id);
    if (index != -1) {
      list[index] = atv;
    } else {
      list.add(atv);
    }

    await _prefs.setString(_keyAtividades, jsonEncode(list.map((item) => item.toJson()).toList()));
  }

  static Future<void> deleteAtividade(int id) async {
    final list = getAtividades();
    list.removeWhere((item) => item.id == id);
    await _prefs.setString(_keyAtividades, jsonEncode(list.map((item) => item.toJson()).toList()));
  }

  static Atividade? getRascunhoAtividade() {
    final raw = _prefs.getString(_keyRascunhoAtividade);
    if (raw == null) return null;
    try {
      return Atividade.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveRascunhoAtividade(Atividade? draft) async {
    if (draft == null) {
      await _prefs.remove(_keyRascunhoAtividade);
    } else {
      await _prefs.setString(_keyRascunhoAtividade, jsonEncode(draft.toJson()));
    }
  }

  static Future<void> clearRascunhoAtividade() async {
    await _prefs.remove(_keyRascunhoAtividade);
  }

  // --- TURMAS (OFFLINE STORAGE) ---

  static List<Turma> getTurmas() {
    final raw = _prefs.getString(_keyTurmasList);
    if (raw == null) {
      return [
        Turma(
          id: 1,
          nome: "Turma de Libras - Alfabetização A",
          descricao: "Turma de introdução e alfabetização básica em Libras",
          codigo: "LBR-1001",
          totalAlunos: 0,
          totalAtividades: 0,
          atividadesIds: const [],
          createdAt: DateTime.now(),
        ),
      ];
    }
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Turma.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveTurmas(List<Turma> turmas) async {
    await _prefs.setString(_keyTurmasList, jsonEncode(turmas.map((t) => t.toJson()).toList()));
  }

  static Turma? getActiveTurma() {
    final raw = _prefs.getString(_keyActiveTurma);
    if (raw == null) return null;
    try {
      return Turma.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  static Future<void> setActiveTurma(Turma? turma) async {
    if (turma == null) {
      await _prefs.remove(_keyActiveTurma);
      await _prefs.remove(_keyCodigoTurma);
    } else {
      await _prefs.setString(_keyActiveTurma, jsonEncode(turma.toJson()));
      await _prefs.setString(_keyCodigoTurma, turma.codigo);
    }
  }
}

