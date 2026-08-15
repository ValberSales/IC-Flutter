import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/personagem.dart';
import '../models/pontuacao.dart';
import '../models/usuario.dart';
import '../models/atividade.dart';
import '../models/turma.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;

  static const String _keyPersonagens = 'JOGO_LIBRAS_PERSONAGENS';
  static const String _keyPontuacoes = 'JOGO_LIBRAS_PONTUACOES';
  static const String _keyActivePersonagemId = 'JOGO_LIBRAS_ACTIVE_PERSONAGEM_ID';
  static const String _keyCodigoTurma = 'CODIGO_TURMA';
  static const String _keyActiveTurma = 'ACTIVE_TURMA';
  static const String _keyTurmasList = 'JOGO_LIBRAS_TURMAS_LIST';
  static const String _keyLetrasAntigas = 'LETRAS_ANTIGAS';
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

  static bool getUseLegacyLetters() {
    return _prefs.getBool(_keyLetrasAntigas) ?? false;
  }

  static Future<void> setUseLegacyLetters(bool value) async {
    await _prefs.setBool(_keyLetrasAntigas, value);
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

  // --- PERSONAGEM ---

  static List<Personagem> getPersonagens() {
    final raw = _prefs.getString(_keyPersonagens);
    if (raw == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((item) => Personagem.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> savePersonagem(Personagem p) async {
    final list = getPersonagens();
    if (p.id == null) {
      // Gerar ID negativo para indicar registro offline
      int minId = -1;
      for (final existing in list) {
        if (existing.id != null && existing.id! < minId) {
          minId = existing.id!;
        }
      }
      p.id = minId - 1;
      p.createdAt = DateTime.now();
    }

    // Se já existe, atualiza, senão adiciona
    final index = list.indexWhere((item) => item.id == p.id);
    if (index != -1) {
      list[index] = p;
    } else {
      list.add(p);
    }

    await savePersonagensList(list);
    
    // Se for o personagem ativo atualmente, atualiza o ativo
    final activeId = getActivePersonagemId();
    if (activeId == p.id) {
      await setActivePersonagem(p);
    }
  }

  static Future<void> savePersonagensList(List<Personagem> list) async {
    await _prefs.setString(_keyPersonagens, jsonEncode(list.map((item) => item.toJson()).toList()));
  }

  static Future<void> deletePersonagem(int id) async {
    final list = getPersonagens();
    list.removeWhere((item) => item.id == id);
    await _prefs.setString(_keyPersonagens, jsonEncode(list.map((item) => item.toJson()).toList()));

    // Remover também as pontuações associadas a esse personagem
    final scoreList = getPontuacoes();
    scoreList.removeWhere((item) => item.personagem?.id == id);
    await _prefs.setString(_keyPontuacoes, jsonEncode(scoreList.map((item) => item.toJson()).toList()));

    // Se o personagem removido era o ativo, limpa o ativo
    final activeId = getActivePersonagemId();
    if (activeId == id) {
      await _prefs.remove(_keyActivePersonagemId);
    }
  }

  static int? getActivePersonagemId() {
    return _prefs.getInt(_keyActivePersonagemId);
  }

  static Personagem? getActivePersonagem() {
    final activeId = getActivePersonagemId();
    if (activeId == null) return null;
    final list = getPersonagens();
    try {
      return list.firstWhere((item) => item.id == activeId);
    } catch (_) {
      return null;
    }
  }

  static Future<void> setActivePersonagem(Personagem? p) async {
    if (p == null || p.id == null) {
      await _prefs.remove(_keyActivePersonagemId);
    } else {
      await _prefs.setInt(_keyActivePersonagemId, p.id!);
    }
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

  static Future<void> savePontuacao(Pontuacao score) async {
    final list = getPontuacoes();
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

    final index = list.indexWhere((item) => item.id == score.id);
    if (index != -1) {
      list[index] = score;
    } else {
      list.add(score);
    }
    await savePontuacoesList(list);
  }

  static Future<void> savePontuacoesList(List<Pontuacao> list) async {
    await _prefs.setString(_keyPontuacoes, jsonEncode(list.map((item) => item.toJson()).toList()));
  }

  static List<Pontuacao> getPontuacaoForPersonagem(int personagemId) {
    final all = getPontuacoes();
    return all.where((score) => score.personagem?.id == personagemId).toList();
  }

  // --- PROGRESSO E CONCLUSÃO DE PALAVRAS ---
  static const String _keyCompletedWords = 'ic_completed_words';

  static Set<String> getCompletedWords(int personagemId, String jogo, String temaKey, String dificuldade) {
    final raw = _prefs.getString(_keyCompletedWords);
    if (raw == null) return {};
    try {
      final Map<String, dynamic> map = jsonDecode(raw);
      final key = '${personagemId}_${jogo}_${temaKey}_$dificuldade';
      final List<dynamic>? list = map[key];
      return list != null ? list.map((e) => e.toString()).toSet() : {};
    } catch (e) {
      return {};
    }
  }

  static Future<void> saveCompletedWord(int personagemId, String jogo, String temaKey, String dificuldade, String palavra) async {
    final raw = _prefs.getString(_keyCompletedWords);
    Map<String, dynamic> map = {};
    if (raw != null) {
      try {
        map = Map<String, dynamic>.from(jsonDecode(raw));
      } catch (_) {}
    }
    final key = '${personagemId}_${jogo}_${temaKey}_$dificuldade';
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

