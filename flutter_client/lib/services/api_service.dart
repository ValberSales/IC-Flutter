import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/personagem.dart';
import '../data/models/pontuacao.dart';
import '../data/models/turma.dart';
import '../data/models/palavra.dart';
import '../data/models/usuario.dart';
import '../data/storage/local_storage_service.dart';

class ApiService {
  // Flag para controle de ambiente estático vs real
  static bool useBackend = false;
  
  static const String baseUrl = 'http://localhost:50990/server';

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
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'token': 'mock-jwt-token-12345',
        'user': Usuario(
          id: 1,
          nome: 'Usuário de Teste',
          username: username,
          email: '$username@exemplo.com',
        ).toJson(),
      };
    }

    try {
      final url = Uri.parse('$baseUrl/login');
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
      final url = Uri.parse('$baseUrl/cadastro');
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

  // --- TURMA / SINCRONIZAÇÃO ---

  static Future<Map<String, dynamic>?> buscaPeloCodigo(String codigo) async {
    if (!useBackend) {
      // Retorna uma resposta mockada após 1 segundo
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulando código da turma "12345"
      if (codigo == "12345") {
        return {
          "turma": Turma(
            id: 1,
            nome: "Turma de Libras - Alfabetização A",
            codigo: "12345",
            createdAt: DateTime.now(),
          ).toJson(),
          "palavras": [
            Palavra(
              id: 101,
              tipo: "JOGO_ADIVINHACAO",
              descricao: "Gato",
              imagem: "assets/animais/gato.png",
            ).toJson(),
            Palavra(
              id: 102,
              tipo: "JOGO_ADIVINHACAO",
              descricao: "Cachorro",
              imagem: "assets/animais/cachorro.png",
            ).toJson(),
            Palavra(
              id: 103,
              tipo: "JOGO_PALAVRAS",
              descricao: "Mãe",
              imagem: "assets/familia/mae.jpg",
              opcoes: ["Mãe", "Pai", "Tia"],
            ).toJson(),
          ],
          "personagens": [
            Personagem(
              id: 10,
              nome: "Joãozinho (Turma)",
              dificuldade: "FACIL",
              avatar: "assets/avatar/avatar_3.jpg",
            ).toJson(),
            Personagem(
              id: 11,
              nome: "Mariazinha (Turma)",
              dificuldade: "MEDIO",
              avatar: "assets/avatar/avatar_6.jpg",
            ).toJson()
          ],
          "message": "Sala carregada com sucesso!"
        };
      } else {
        return {
          "turma": null,
          "palavras": [],
          "personagens": [],
          "message": "Turma não encontrada! Verifique o código."
        };
      }
    }

    try {
      final url = Uri.parse('$baseUrl/turma-busca/$codigo');
      final response = await http.get(url, headers: _getHeaders(includeContentType: false));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao buscar código da turma: $e');
      return null;
    }
  }

  // --- PERSONAGEM ---

  static Future<Personagem?> salvaPersonagem(Personagem p) async {
    if (!useBackend) {
      // Mock de salvamento
      return p;
    }

    try {
      final url = Uri.parse('$baseUrl/personagem');
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
      // Mock de salvamento
      return score;
    }

    try {
      final url = Uri.parse('$baseUrl/pontuacao');
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
      final url = Uri.parse('$baseUrl/pontuacao-personagem/$personagemId');
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
}
