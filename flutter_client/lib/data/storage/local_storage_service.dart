import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/personagem.dart';
import '../models/pontuacao.dart';
import '../models/usuario.dart';

class LocalStorageService {
  static late final SharedPreferences _prefs;

  static const String _keyPersonagens = 'JOGO_LIBRAS_PERSONAGENS';
  static const String _keyPontuacoes = 'JOGO_LIBRAS_PONTUACOES';
  static const String _keyActivePersonagemId = 'JOGO_LIBRAS_ACTIVE_PERSONAGEM_ID';
  static const String _keyCodigoTurma = 'CODIGO_TURMA';
  static const String _keyLetrasAntigas = 'LETRAS_ANTIGAS';
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'logged_in_user';

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

    list.add(score);
    await _prefs.setString(_keyPontuacoes, jsonEncode(list.map((item) => item.toJson()).toList()));
  }

  static List<Pontuacao> getPontuacaoForPersonagem(int personagemId) {
    final all = getPontuacoes();
    return all.where((score) => score.personagem?.id == personagemId).toList();
  }
}
