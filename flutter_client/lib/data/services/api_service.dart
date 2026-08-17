import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:http/http.dart' as http;
import '../models/atividade.dart';
import '../models/pontuacao.dart';
import '../models/turma.dart';
import '../models/usuario.dart';
import '../storage/local_storage_service.dart';

class ApiService {
  // Flag para controle de ambiente real vs estático (Java 25 Spring Boot backend)
  static bool useBackend = true;
  
  static String get hostUrl {
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8081';
    }
    return 'http://localhost:8081';
  }

  static String get baseUrl => '$hostUrl/api';

  // Helper para obter headers de requisição com autenticação
  static Map<String, String> _getHeaders({bool includeContentType = true}) {
    final Map<String, String> headers = {};
    if (includeContentType) {
      headers['Content-Type'] = 'application/json';
    }
    if (useBackend) {
      final token = LocalStorageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        headers['auth'] = token;
      }
    }
    return headers;
  }

  // --- AUTENTICAÇÃO ---

  static Future<Map<String, dynamic>?> login(String username, String password) async {
    if (!useBackend) {
      final list = LocalStorageService.getUsuariosList();
      Usuario user;
      try {
        user = list.firstWhere(
          (u) =>
              (u.username?.toLowerCase() == username.toLowerCase() ||
                  u.codigoIdentificador?.toLowerCase() == username.toLowerCase()),
        );
      } catch (_) {
        user = Usuario(
          id: 1,
          nome: username,
          username: username,
          email: '$username@exemplo.com',
        );
      }
      return {
        'token': 'mock-jwt-token-12345',
        'user': user.toJson(),
      };
    }

    try {
      final url = Uri.parse('$baseUrl/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Erro no login: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> cadastro(Usuario user) async {
    if (!useBackend) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'token': 'mock-jwt-token-12345',
        'user': user.toJson(),
      };
    }

    try {
      final url = Uri.parse('$baseUrl/auth/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Erro no cadastro: $e');
    }
    return null;
  }

  // --- UPLOAD DE IMAGEM (MinIO S3) ---

  static Future<String?> uploadImagem(Uint8List bytes, String filename) async {
    try {
      final url = Uri.parse('$baseUrl/files/upload');
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(_getHeaders(includeContentType: false));
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'] as String?;
      }
    } catch (e) {
      debugPrint('Erro no upload da imagem no MinIO: $e');
    }
    return null;
  }

  // --- ATIVIDADES (PROFESSOR) ---

  static Future<List<Atividade>> getAtividades({bool apenasAtivas = false}) async {
    if (!useBackend) {
      return LocalStorageService.getAtividades();
    }

    try {
      final queryParam = apenasAtivas ? '?apenasAtivas=true' : '';
      final url = Uri.parse('$baseUrl/atividades$queryParam');
      final response = await http
          .get(url, headers: _getHeaders(includeContentType: false))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        final atividades = list.map((e) => Atividade.fromJson(e)).toList();
        if (atividades.isNotEmpty) {
          // Atualiza cache local
          await LocalStorageService.saveAtividadesList(atividades);
        }
        return atividades;
      }
    } catch (e) {
      debugPrint('Servidor indisponível ou erro ao buscar atividades, usando cache local: $e');
    }
    return LocalStorageService.getAtividades();
  }

  static Future<Atividade?> saveAtividade(Atividade atividade) async {
    if (!useBackend) {
      await LocalStorageService.saveAtividade(atividade);
      return atividade;
    }

    try {
      final isUpdate = atividade.id != null;
      final url = isUpdate ? Uri.parse('$baseUrl/atividades/${atividade.id}') : Uri.parse('$baseUrl/atividades');
      final response = isUpdate
          ? await http.put(url, headers: _getHeaders(), body: jsonEncode(atividade.toJson()))
          : await http.post(url, headers: _getHeaders(), body: jsonEncode(atividade.toJson()));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Atividade.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Erro ao salvar atividade no backend Java: $e');
    }
    await LocalStorageService.saveAtividade(atividade);
    return atividade;
  }

  static Future<bool> toggleAtividadeStatus(int id) async {
    if (!useBackend) {
      final atividades = LocalStorageService.getAtividades();
      final index = atividades.indexWhere((a) => a.id == id);
      if (index != -1) {
        atividades[index].ativo = !atividades[index].ativo;
        await LocalStorageService.saveAtividade(atividades[index]);
        return true;
      }
      return false;
    }

    try {
      final url = Uri.parse('$baseUrl/atividades/$id/status');
      final response = await http.patch(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final atividades = LocalStorageService.getAtividades();
        final index = atividades.indexWhere((a) => a.id == id);
        if (index != -1) {
          atividades[index].ativo = !atividades[index].ativo;
          await LocalStorageService.saveAtividade(atividades[index]);
        }
        return true;
      }
    } catch (e) {
      debugPrint('Erro ao alternar status da atividade no backend Java: $e');
    }
    return false;
  }

  static Future<bool> toggleAtividadePublica(int id, {bool? publica}) async {
    if (!useBackend) {
      final atividades = LocalStorageService.getAtividades();
      final index = atividades.indexWhere((a) => a.id == id);
      if (index != -1) {
        atividades[index].publica = publica ?? !atividades[index].publica;
        await LocalStorageService.saveAtividade(atividades[index]);
        return true;
      }
      return false;
    }

    try {
      final query = publica != null ? '?publica=$publica' : '';
      final url = Uri.parse('$baseUrl/atividades/$id/publica$query');
      final response = await http.patch(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final atividades = LocalStorageService.getAtividades();
        final index = atividades.indexWhere((a) => a.id == id);
        if (index != -1) {
          atividades[index].publica = publica ?? !atividades[index].publica;
          await LocalStorageService.saveAtividade(atividades[index]);
        }
        return true;
      }
    } catch (e) {
      debugPrint('Erro ao alternar visibilidade publica/privada da atividade: $e');
    }
    return false;
  }

  static Future<bool> deleteAtividade(int id) async {
    if (!useBackend) {
      await LocalStorageService.deleteAtividade(id);
      return true;
    }

    try {
      final url = Uri.parse('$baseUrl/atividades/$id');
      final response = await http.delete(url, headers: _getHeaders(includeContentType: false));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Erro ao excluir atividade no backend Java: $e');
      return false;
    }
  }

  static Future<Atividade?> getRascunhoAtividade() async {
    if (!useBackend) {
      return LocalStorageService.getRascunhoAtividade();
    }

    try {
      final url = Uri.parse('$baseUrl/atividades/rascunho');
      final response = await http.get(url, headers: _getHeaders(includeContentType: false));

      if (response.statusCode == 200) {
        return Atividade.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Erro ao buscar rascunho de atividade no backend Java: $e');
    }
    return LocalStorageService.getRascunhoAtividade();
  }

  // --- TURMA / GESTÃO DE TURMAS ---

  static Future<List<Turma>> getTurmas() async {
    if (!useBackend) {
      return LocalStorageService.getTurmas();
    }
    try {
      final url = Uri.parse('$baseUrl/turmas');
      final response = await http.get(url, headers: _getHeaders(includeContentType: false));
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        return list.map((e) => Turma.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      }
    } catch (e) {
      debugPrint('Erro ao buscar turmas no backend: $e');
    }
    return LocalStorageService.getTurmas();
  }

  static Future<Turma?> getTurma(int id) async {
    if (!useBackend) {
      final turmas = LocalStorageService.getTurmas();
      return turmas.firstWhere((t) => t.id == id, orElse: () => Turma(id: id));
    }
    try {
      final url = Uri.parse('$baseUrl/turmas/$id');
      final response = await http.get(url, headers: _getHeaders(includeContentType: false));
      if (response.statusCode == 200) {
        return Turma.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Erro ao buscar detalhes da turma $id: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> buscaPeloCodigo(String codigo) async {
    if (!useBackend) {
      await Future.delayed(const Duration(milliseconds: 300));
      final turmas = LocalStorageService.getTurmas();
      final clean = codigo.trim().toUpperCase();
      final match = turmas.where((t) => t.codigo.toUpperCase() == clean);
      if (match.isNotEmpty) {
        return {
          "turma": match.first.toJson(),
          "message": "Turma encontrada com sucesso!"
        };
      }
      return null;
    }

    try {
      final url = Uri.parse('$baseUrl/turmas/busca/${codigo.trim().toUpperCase()}');
      final response = await http.get(url, headers: _getHeaders(includeContentType: false));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Erro ao buscar código da turma: $e');
    }
    return null;
  }

  static Future<Turma?> createTurma(Map<String, dynamic> payload) async {
    if (!useBackend) {
      final nova = Turma(
        id: DateTime.now().millisecondsSinceEpoch,
        nome: payload['nome'] as String? ?? 'Nova Turma',
        descricao: payload['descricao'] as String? ?? '',
        codigo: payload['codigo'] as String? ?? 'LBR-${DateTime.now().millisecondsSinceEpoch % 10000}',
        createdAt: DateTime.now(),
      );
      final list = LocalStorageService.getTurmas();
      list.add(nova);
      await LocalStorageService.saveTurmas(list);
      return nova;
    }
    try {
      final url = Uri.parse('$baseUrl/turmas');
      final response = await http.post(url, headers: _getHeaders(), body: jsonEncode(payload));
      if (response.statusCode == 200) {
        return Turma.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Erro ao criar turma: $e');
    }
    return null;
  }

  static Future<Turma?> updateTurma(int id, Map<String, dynamic> payload) async {
    if (!useBackend) {
      final list = LocalStorageService.getTurmas();
      final idx = list.indexWhere((t) => t.id == id);
      if (idx != -1) {
        list[idx] = list[idx].copyWith(
          nome: payload['nome'] as String?,
          descricao: payload['descricao'] as String?,
          codigo: payload['codigo'] as String?,
        );
        await LocalStorageService.saveTurmas(list);
        return list[idx];
      }
      return null;
    }
    try {
      final url = Uri.parse('$baseUrl/turmas/$id');
      final response = await http.put(url, headers: _getHeaders(), body: jsonEncode(payload));
      if (response.statusCode == 200) {
        return Turma.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Erro ao atualizar turma $id: $e');
    }
    return null;
  }

  static Future<bool> deleteTurma(int id) async {
    if (!useBackend) {
      final list = LocalStorageService.getTurmas();
      list.removeWhere((t) => t.id == id);
      await LocalStorageService.saveTurmas(list);
      return true;
    }
    try {
      final url = Uri.parse('$baseUrl/turmas/$id');
      final response = await http.delete(url, headers: _getHeaders(includeContentType: false));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Erro ao deletar turma $id: $e');
    }
    return false;
  }

  static Future<Turma?> setTurmaAlunos(int id, List<int> alunoIds) async {
    if (useBackend) {
      try {
        final url = Uri.parse('$baseUrl/turmas/$id/alunos');
        final response = await http.post(
          url,
          headers: _getHeaders(),
          body: jsonEncode({"alunoIds": alunoIds}),
        );
        if (response.statusCode == 200) {
          final resTurma = Turma.fromJson(jsonDecode(response.body));
          final list = LocalStorageService.getTurmas();
          final idx = list.indexWhere((t) => t.id == id);
          if (idx != -1) {
            list[idx] = resTurma;
          } else {
            list.add(resTurma);
          }
          await LocalStorageService.saveTurmas(list);
          return resTurma;
        } else {
          debugPrint('Erro backend setTurmaAlunos status ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        debugPrint('Erro ao salvar alunos da turma $id via API: $e');
      }
    }

    // Fallback Local
    final list = LocalStorageService.getTurmas();
    final idx = list.indexWhere((t) => t.id == id);
    if (idx != -1) {
      final allUsers = LocalStorageService.getUsuarios();
      final allocated = allUsers.where((u) => u.id != null && alunoIds.contains(u.id)).toList();
      list[idx] = list[idx].copyWith(
        alunos: allocated,
        totalAlunos: alunoIds.length,
      );
      await LocalStorageService.saveTurmas(list);
      return list[idx];
    }
    return null;
  }

  static Future<Turma?> removeAlunoTurma(int turmaId, int alunoId) async {
    if (useBackend) {
      try {
        final url = Uri.parse('$baseUrl/turmas/$turmaId/alunos/$alunoId');
        final response = await http.delete(url, headers: _getHeaders(includeContentType: false));
        if (response.statusCode == 200) {
          return Turma.fromJson(jsonDecode(response.body));
        }
      } catch (e) {
        debugPrint('Erro ao remover aluno $alunoId da turma $turmaId: $e');
      }
    }

    final list = LocalStorageService.getTurmas();
    final idx = list.indexWhere((t) => t.id == turmaId);
    if (idx != -1) {
      final alunos = list[idx].alunos.where((a) => a.id != alunoId).toList();
      list[idx] = list[idx].copyWith(alunos: alunos, totalAlunos: alunos.length);
      await LocalStorageService.saveTurmas(list);
      return list[idx];
    }
    return null;
  }

  static Future<Turma?> setTurmaAtividades(int id, List<int> atividadeIds) async {
    if (useBackend) {
      try {
        final url = Uri.parse('$baseUrl/turmas/$id/atividades');
        final response = await http.post(
          url,
          headers: _getHeaders(),
          body: jsonEncode({"atividadeIds": atividadeIds}),
        );
        if (response.statusCode == 200) {
          final resTurma = Turma.fromJson(jsonDecode(response.body));
          final list = LocalStorageService.getTurmas();
          final idx = list.indexWhere((t) => t.id == id);
          if (idx != -1) {
            list[idx] = resTurma;
          } else {
            list.add(resTurma);
          }
          await LocalStorageService.saveTurmas(list);
          return resTurma;
        } else {
          debugPrint('Erro backend setTurmaAtividades status ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        debugPrint('Erro ao atribuir temas/atividades à turma $id via API: $e');
      }
    }

    // Fallback Local
    final list = LocalStorageService.getTurmas();
    final idx = list.indexWhere((t) => t.id == id);
    if (idx != -1) {
      list[idx] = list[idx].copyWith(
        atividadesIds: atividadeIds,
        totalAtividades: atividadeIds.length,
      );
      await LocalStorageService.saveTurmas(list);
      return list[idx];
    }
    return null;
  }

  static Future<Map<String, dynamic>?> entrarTurma(String codigo, int? alunoId) async {
    if (!useBackend) {
      final res = await buscaPeloCodigo(codigo);
      if (res != null && res['turma'] != null) {
        final turma = Turma.fromJson(res['turma']);
        await LocalStorageService.setActiveTurma(turma);
        await LocalStorageService.setCodigoTurma(turma.codigo);
        return res;
      }
      return null;
    }
    try {
      final url = Uri.parse('$baseUrl/turmas/entrar');
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          "codigo": codigo.trim().toUpperCase(),
          "alunoId": alunoId,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Erro ao entrar na turma: $e');
    }
    return null;
  }

  static Future<bool> sairTurma(int? alunoId) async {
    await LocalStorageService.setActiveTurma(null);
    await LocalStorageService.setCodigoTurma(null);
    if (!useBackend) {
      return true;
    }
    try {
      final url = Uri.parse('$baseUrl/turmas/sair');
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({"alunoId": alunoId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Erro ao sair da turma: $e');
    }
    return true;
  }

  static Future<Turma?> getTurmaDoAluno(int alunoId) async {
    if (!useBackend) {
      final active = LocalStorageService.getActiveTurma();
      if (active != null) {
        final list = LocalStorageService.getTurmas();
        final match = list.where((t) => t.id == active.id || t.codigo == active.codigo);
        if (match.isNotEmpty) {
          final t = match.first;
          final isAlunoEnrolled = t.alunos.any((a) => a.id == alunoId) || (t.alunoIds.contains(alunoId));
          if (isAlunoEnrolled) return t;
        }
      }
      return null;
    }
    try {
      final url = Uri.parse('$baseUrl/turmas/aluno/$alunoId');
      final response = await http.get(url, headers: _getHeaders(includeContentType: false));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final trimmed = response.body.trim();
        if (trimmed == '{}' || trimmed == 'null' || trimmed.isEmpty) {
          return null;
        }
        final map = jsonDecode(response.body);
        if (map is Map<String, dynamic> && map.containsKey('id') && map['id'] != null) {
          return Turma.fromJson(map);
        }
        return null;
      }
    } catch (e) {
      debugPrint('Erro ao buscar turma do aluno $alunoId: $e');
    }
    return null;
  }

  // --- PONTUAÇÃO ---

  static Future<Pontuacao?> salvaPontuacao(Pontuacao score) async {
    if (!useBackend) {
      return score;
    }

    try {
      final url = Uri.parse('$baseUrl/pontuacoes');
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(score.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Pontuacao.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Erro ao salvar pontuação no servidor: $e');
    }
    return null;
  }

  static Future<List<Pontuacao>> buscaPontuacaoUsuario(int usuarioId) async {
    if (!useBackend) {
      return [];
    }

    try {
      final url = Uri.parse('$baseUrl/pontuacoes/usuario/$usuarioId');
      final response = await http.get(url, headers: _getHeaders(includeContentType: false));

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => Pontuacao.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Erro ao buscar pontuações no servidor: $e');
    }
    return [];
  }

  // --- GESTÃO DE USUÁRIOS (ÁREA DO PROFESSOR) ---

  static Future<List<Usuario>> getUsuarios({String? busca}) async {
    if (!useBackend) {
      final cached = LocalStorageService.getUsuariosList();
      if (busca != null && busca.trim().isNotEmpty) {
        final term = busca.trim().toLowerCase();
        return cached.where((u) {
          final nome = (u.nome ?? '').toLowerCase();
          final username = (u.username ?? '').toLowerCase();
          final idCode = (u.codigoIdentificador ?? '').toLowerCase();
          return nome.contains(term) || username.contains(term) || idCode.contains(term);
        }).toList();
      }
      return cached;
    }

    try {
      final uri = Uri.parse('$baseUrl/usuarios').replace(
        queryParameters: (busca != null && busca.trim().isNotEmpty)
            ? {'busca': busca.trim()}
            : null,
      );

      final response = await http.get(uri, headers: _getHeaders(includeContentType: false));

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        final result = list.map((e) => Usuario.fromJson(e)).toList();
        await LocalStorageService.saveUsuariosList(result);
        return result;
      }
    } catch (e) {
      debugPrint('Erro ao buscar usuários no servidor: $e');
    }

    return LocalStorageService.getUsuariosList();
  }

  static Future<Usuario?> createUsuario({
    required String username,
    String? nome,
    String? password,
    String role = 'USER',
    String? avatar,
    bool mustChangePassword = false,
  }) async {
    if (!useBackend) {
      final list = LocalStorageService.getUsuariosList();
      final random = math.Random();
      final hexChars = '0123456789abcdef';
      final uuid = List.generate(32, (_) => hexChars[random.nextInt(16)]).join();
      final formattedUuid = '${uuid.substring(0,8)}-${uuid.substring(8,12)}-${uuid.substring(12,16)}-${uuid.substring(16,20)}-${uuid.substring(20,32)}';
      final newUser = Usuario(
        id: DateTime.now().millisecondsSinceEpoch,
        nome: nome != null && nome.isNotEmpty ? nome : username,
        username: username,
        password: password ?? '123456',
        role: role.toUpperCase(),
        codigoIdentificador: formattedUuid,
        avatar: avatar ?? 'assets/avatar/avatar_1.jpg',
        mustChangePassword: mustChangePassword,
      );
      list.add(newUser);
      await LocalStorageService.saveUsuariosList(list);
      return newUser;
    }

    try {
      final url = Uri.parse('$baseUrl/usuarios');
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          'username': username,
          'nome': nome,
          'password': password,
          'role': role,
          'avatar': avatar,
          'mustChangePassword': mustChangePassword,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final created = Usuario.fromJson(jsonDecode(response.body));
        final list = LocalStorageService.getUsuariosList();
        list.add(created);
        await LocalStorageService.saveUsuariosList(list);
        return created;
      }
    } catch (e) {
      debugPrint('Erro ao criar usuário no servidor: $e');
    }
    return null;
  }

  static Future<Usuario?> updateUsuario(Usuario user) async {
    if (user.id == null) return null;

    if (!useBackend) {
      final list = LocalStorageService.getUsuariosList();
      final index = list.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        list[index] = user;
      } else {
        list.add(user);
      }
      await LocalStorageService.saveUsuariosList(list);
      return user;
    }

    try {
      final url = Uri.parse('$baseUrl/usuarios/${user.id}');
      final response = await http.put(
        url,
        headers: _getHeaders(),
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        return Usuario.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Erro ao atualizar usuário no servidor: $e');
    }
    return null;
  }

  static Future<bool> deleteUsuario(int id) async {
    if (!useBackend) {
      final list = LocalStorageService.getUsuariosList();
      list.removeWhere((u) => u.id == id);
      await LocalStorageService.saveUsuariosList(list);
      return true;
    }

    try {
      final url = Uri.parse('$baseUrl/usuarios/$id');
      final response = await http.delete(url, headers: _getHeaders(includeContentType: false));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Erro ao excluir usuário no servidor: $e');
    }
    return false;
  }

  static Future<String?> resetPassword(int userId) async {
    if (!useBackend) {
      const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
      final random = math.Random();
      final tempPassword = List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();

      final list = LocalStorageService.getUsuariosList();
      final index = list.indexWhere((u) => u.id == userId);
      if (index != -1) {
        list[index].password = tempPassword;
        list[index].mustChangePassword = true;
        await LocalStorageService.saveUsuariosList(list);
      }
      return tempPassword;
    }

    try {
      final url = Uri.parse('$baseUrl/usuarios/$userId/reset-password');
      final response = await http.post(
        url,
        headers: _getHeaders(includeContentType: false),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['tempPassword'] as String?;
      }
    } catch (e) {
      debugPrint('Erro ao resetar senha no servidor: $e');
    }
    return null;
  }

  static Future<bool> changePassword({required String username, required String newPassword}) async {
    if (!useBackend) {
      final list = LocalStorageService.getUsuariosList();
      final index = list.indexWhere((u) => (u.username ?? '').toLowerCase() == username.toLowerCase());
      if (index != -1) {
        list[index].password = newPassword.trim();
        list[index].mustChangePassword = false;
        await LocalStorageService.saveUsuariosList(list);
        return true;
      }
      return false;
    }

    try {
      final url = Uri.parse('$baseUrl/usuarios/change-password');
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          'username': username,
          'newPassword': newPassword.trim(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Erro ao trocar senha no servidor: $e');
    }
    return false;
  }

  // --- RELATÓRIOS PEDAGÓGICOS & ANALYTICS ---

  static Future<Map<String, dynamic>?> getRelatorioTurma(int turmaId) async {
    if (!useBackend) return null;

    try {
      final url = Uri.parse('$baseUrl/relatorios/turma/$turmaId');
      final response = await http.get(url, headers: _getHeaders(includeContentType: false));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Erro ao obter relatório da turma $turmaId do servidor: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getRelatorioAluno(int alunoId) async {
    if (!useBackend) return null;

    try {
      final url = Uri.parse('$baseUrl/relatorios/aluno/$alunoId');
      final response = await http.get(url, headers: _getHeaders(includeContentType: false));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Erro ao obter relatório do aluno $alunoId do servidor: $e');
    }
    return null;
  }
}
