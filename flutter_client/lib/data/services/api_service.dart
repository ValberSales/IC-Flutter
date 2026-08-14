import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/atividade.dart';
import '../models/personagem.dart';
import '../models/pontuacao.dart';
import '../models/turma.dart';
import '../models/palavra.dart';
import '../models/usuario.dart';
import '../storage/local_storage_service.dart';

class ApiService {
  // Flag para controle de ambiente real vs estático (Java 25 Spring Boot backend)
  static bool useBackend = true;
  
  static const String baseUrl = 'http://localhost:8081/api';

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
      print('Erro no login: $e');
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
      print('Erro no cadastro: $e');
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
      print('Erro no upload da imagem no MinIO: $e');
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
      print('Servidor indisponível ou erro ao buscar atividades, usando cache local: $e');
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
      print('Erro ao salvar atividade no backend Java: $e');
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
      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao alternar status da atividade no backend Java: $e');
      return false;
    }
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
      print('Erro ao excluir atividade no backend Java: $e');
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
      print('Erro ao buscar rascunho de atividade no backend Java: $e');
    }
    return LocalStorageService.getRascunhoAtividade();
  }

  // --- TURMA / SINCRONIZAÇÃO ---

  static Future<Map<String, dynamic>?> buscaPeloCodigo(String codigo) async {
    if (!useBackend) {
      await Future.delayed(const Duration(seconds: 1));
      if (codigo == "12345") {
        return {
          "turma": Turma(
            id: 1,
            nome: "Turma de Libras - Alfabetização A",
            codigo: "12345",
            createdAt: DateTime.now(),
          ).toJson(),
          "message": "Sala carregada com sucesso!"
        };
      }
      return null;
    }

    try {
      final url = Uri.parse('$baseUrl/turmas/busca/$codigo');
      final response = await http.get(url, headers: _getHeaders(includeContentType: false));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Erro ao buscar código da turma: $e');
    }
    return null;
  }

  // --- PERSONAGEM ---

  static Future<Personagem?> salvaPersonagem(Personagem p) async {
    if (!useBackend) {
      return p;
    }

    try {
      final url = Uri.parse('$baseUrl/personagens');
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(p.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Personagem.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Erro ao salvar personagem no servidor: $e');
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
      print('Erro ao salvar pontuação no servidor: $e');
    }
    return null;
  }

  static Future<List<Pontuacao>> buscaPontuacaoPersonagem(int personagemId) async {
    if (!useBackend) {
      return [];
    }

    try {
      final url = Uri.parse('$baseUrl/pontuacoes/personagem/$personagemId');
      final response = await http.get(url, headers: _getHeaders(includeContentType: false));

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => Pontuacao.fromJson(e)).toList();
      }
    } catch (e) {
      print('Erro ao buscar pontuações no servidor: $e');
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
      print('Erro ao buscar usuários no servidor: $e');
    }

    return LocalStorageService.getUsuariosList();
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
      print('Erro ao atualizar usuário no servidor: $e');
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
      print('Erro ao excluir usuário no servidor: $e');
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
      print('Erro ao resetar senha no servidor: $e');
    }
    return null;
  }
}
