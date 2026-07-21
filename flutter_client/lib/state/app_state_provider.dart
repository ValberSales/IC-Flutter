import 'package:flutter/material.dart';
import '../data/models/personagem.dart';
import '../data/models/pontuacao.dart';
import '../data/models/turma.dart';
import '../data/models/palavra.dart';
import '../data/models/usuario.dart';
import '../data/models/atividade.dart';
import '../data/storage/local_storage_service.dart';
import '../data/sources/local_data_source.dart';
import '../services/api_service.dart';

class AppStateProvider extends ChangeNotifier {
  Personagem? _activePersonagem;
  List<Personagem> _personagens = [];
  Turma? _activeTurma;
  List<Palavra> _customPalavras = [];
  List<Atividade> _atividades = [];
  Atividade? _rascunhoAtual;
  bool _useLegacyLetters = false;
  bool _isSyncing = false;
  Usuario? _currentUser;
  String? _token;

  // Getters
  Personagem? get activePersonagem => _activePersonagem;
  List<Personagem> get personagens => _personagens;
  Turma? get activeTurma => _activeTurma;
  List<Palavra> get customPalavras => _customPalavras;
  List<Atividade> get atividades => _atividades;
  Atividade? get rascunhoAtual => _rascunhoAtual;
  bool get useLegacyLetters => _useLegacyLetters;
  bool get isSyncing => _isSyncing;
  Usuario? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _token != null;

  // Letras atuais do alfabeto manual dependendo da configuração
  List<Map<String, String>> get currentAlfabeto {
    return _useLegacyLetters
        ? LocalDataSource.alfabetoManualOriginal
        : LocalDataSource.alfabetoManualProf;
  }

  // Inicializa o estado lendo do LocalStorage
  void loadInitialState() {
    _useLegacyLetters = LocalStorageService.getUseLegacyLetters();
    _personagens = LocalStorageService.getPersonagens();
    _activePersonagem = LocalStorageService.getActivePersonagem();
    _token = LocalStorageService.getToken();
    _currentUser = LocalStorageService.getUser();
    _atividades = LocalStorageService.getAtividades();
    _rascunhoAtual = LocalStorageService.getRascunhoAtividade();
    
    // Tenta restabelecer turma se já estiver salva localmente
    final codigoTurma = LocalStorageService.getCodigoTurma();
    if (codigoTurma != null) {
      _loadMockTurmaForCode(codigoTurma);
    }
    notifyListeners();
  }


  // --- CARREGAMENTO DE TURMA LOCAL ---
  void _loadMockTurmaForCode(String code) {
    if (code == "12345") {
      _activeTurma = Turma(
        id: 1,
        nome: "Turma de Libras - Alfabetização A",
        codigo: "12345",
      );
      _customPalavras = [
        Palavra(
          id: 101,
          tipo: "JOGO_ADIVINHACAO",
          descricao: "Gato",
          imagem: "assets/animais/gato.png",
        ),
        Palavra(
          id: 102,
          tipo: "JOGO_ADIVINHACAO",
          descricao: "Cachorro",
          imagem: "assets/animais/cachorro.png",
        ),
        Palavra(
          id: 103,
          tipo: "JOGO_PALAVRAS",
          descricao: "Mãe",
          imagem: "assets/familia/mae.jpg",
          opcoes: ["Mãe", "Pai", "Tia"],
        ),
      ];
    }
  }

  // --- CONFIGURAÇÃO DAS LETRAS ---
  Future<void> setUseLegacyLetters(bool value) async {
    _useLegacyLetters = value;
    await LocalStorageService.setUseLegacyLetters(value);
    notifyListeners();
  }

  // --- AUTENTICAÇÃO ---

  Future<bool> login(String username, String password) async {
    try {
      final result = await ApiService.login(username, password);
      if (result != null && result['token'] != null && result['user'] != null) {
        _token = result['token'] as String;
        _currentUser = Usuario.fromJson(result['user'] as Map<String, dynamic>);
        await LocalStorageService.saveToken(_token!);
        await LocalStorageService.saveUser(_currentUser!);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Erro ao fazer login: $e');
    }
    return false;
  }

  Future<bool> register(Usuario user) async {
    try {
      final result = await ApiService.cadastro(user);
      if (result != null && result['token'] != null && result['user'] != null) {
        _token = result['token'] as String;
        _currentUser = Usuario.fromJson(result['user'] as Map<String, dynamic>);
        await LocalStorageService.saveToken(_token!);
        await LocalStorageService.saveUser(_currentUser!);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Erro ao cadastrar: $e');
    }
    return false;
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    _activeTurma = null;
    _customPalavras = [];
    await LocalStorageService.clearToken();
    await LocalStorageService.clearUser();
    await LocalStorageService.setCodigoTurma(null);
    notifyListeners();
  }

  // --- GERENCIAMENTO DE PERSONAGENS ---

  Future<void> selectPersonagem(Personagem p) async {
    _activePersonagem = p;
    await LocalStorageService.setActivePersonagem(p);
    notifyListeners();
  }

  Future<void> savePersonagem(Personagem p) async {
    await LocalStorageService.savePersonagem(p);
    _personagens = LocalStorageService.getPersonagens();
    
    // Se não havia personagem ativo, ou se atualizamos o ativo atual
    if (_activePersonagem == null || _activePersonagem!.id == p.id) {
      _activePersonagem = LocalStorageService.getActivePersonagem();
    }
    
    notifyListeners();
  }

  Future<void> deletePersonagem(int id) async {
    await LocalStorageService.deletePersonagem(id);
    _personagens = LocalStorageService.getPersonagens();
    
    if (_activePersonagem?.id == id) {
      _activePersonagem = null;
    }
    
    notifyListeners();
  }

  // --- HISTÓRICO DE PONTUAÇÃO ---

  List<Pontuacao> getPontuacaoHistoryForActivePersonagem() {
    if (_activePersonagem == null || _activePersonagem!.id == null) return [];
    return LocalStorageService.getPontuacaoForPersonagem(_activePersonagem!.id!);
  }

  Future<void> salvaPontuacao(int acertos, int erros, String atividade) async {
    if (_activePersonagem == null) return;
    
    // Regra do Angular: Só salva se houver progresso mínimo (ou para testes, salvamos sempre)
    // No Angular original: if (pontuacao.acertos < 5 && pontuacao.erros < 5) return;
    // Vamos salvar sempre no protótipo para facilitar a demonstração visual das stakeholders.

    final pontuacao = Pontuacao(
      atividade: atividade,
      acertos: acertos,
      erros: erros,
      dificuldade: _activePersonagem!.dificuldade,
      personagem: _activePersonagem,
    );

    // Salva localmente primeiro
    await LocalStorageService.savePontuacao(pontuacao);
    
    // Se a turma estiver ativa e o ID do personagem for válido (positivo / sincronizado com o servidor),
    // tenta enviar para o backend
    if (_activeTurma != null && _activePersonagem!.id! > 0) {
      final savedOnline = await ApiService.salvaPontuacao(pontuacao);
      if (savedOnline != null) {
        print('Pontuação sincronizada com sucesso no backend!');
      }
    }
    
    notifyListeners();
  }

  // --- SINCRONIZAÇÃO DE SALA (CÓDIGO DA TURMA) ---

  Future<String> sincronizaSala(String codigo) async {
    _isSyncing = true;
    notifyListeners();

    try {
      final result = await ApiService.buscaPeloCodigo(codigo);
      _isSyncing = false;

      if (result != null && result['turma'] != null) {
        // Salva código localmente
        await LocalStorageService.setCodigoTurma(codigo);
        
        // Limpar personagens da sala anterior (opcional, como no Angular)
        // No Angular: await IndexDbService.limpaPersonagensSala();
        
        // Mapeia os dados do json
        _activeTurma = Turma.fromJson(result['turma']);
        
        final List<dynamic> palavrasJson = result['palavras'] ?? [];
        _customPalavras = palavrasJson.map((item) => Palavra.fromJson(item)).toList();

        final List<dynamic> personagensJson = result['personagens'] ?? [];
        final List<Personagem> personagensTurma = personagensJson.map((item) => Personagem.fromJson(item)).toList();

        // Mescla personagens locais com os da turma
        // Primeiro remove os que têm ID positivo (que pertenciam a turmas antigas)
        _personagens.removeWhere((p) => p.id != null && p.id! > 0);
        
        // Adiciona os novos personagens da turma
        for (final p in personagensTurma) {
          await LocalStorageService.savePersonagem(p);
        }
        
        _personagens = LocalStorageService.getPersonagens();
        
        // Se o personagem atual foi excluído da lista, limpa o ativo
        if (_activePersonagem != null && !_personagens.any((p) => p.id == _activePersonagem!.id)) {
          _activePersonagem = null;
          await LocalStorageService.setActivePersonagem(null);
        }

        notifyListeners();
        return "Sucesso: Sala carregada com sucesso!";
      } else {
        notifyListeners();
        return result?['message'] ?? "Erro: Código da turma inválido.";
      }
    } catch (e) {
      _isSyncing = false;
      notifyListeners();
      return "Erro: Ocorreu uma falha ao conectar ao servidor.";
    }
  }

  Future<void> desvincularTurma() async {
    await LocalStorageService.setCodigoTurma(null);
    _activeTurma = null;
    _customPalavras = [];
    
    // Remove personagens com ID positivo (que vieram do backend)
    _personagens.removeWhere((p) => p.id != null && p.id! > 0);
    // Persiste a lista limpa
    await LocalStorageService.savePersonagensList(_personagens);
    
    if (_activePersonagem != null && _activePersonagem!.id! > 0) {
      _activePersonagem = null;
      await LocalStorageService.setActivePersonagem(null);
    }
    
    notifyListeners();
  }

  // --- GESTÃO DE ATIVIDADES E RASCUNHOS (PROFESSOR) ---

  Future<void> salvarRascunhoAtividade(Atividade atv) async {
    atv.rascunho = true;
    _rascunhoAtual = atv;
    await LocalStorageService.saveRascunhoAtividade(atv);
    notifyListeners();
  }

  Future<void> publicarAtividade(Atividade atv) async {
    atv.rascunho = false;
    if (_currentUser != null) {
      atv.criadoPor = _currentUser!.nome;
    }
    await LocalStorageService.saveAtividade(atv);
    await LocalStorageService.clearRascunhoAtividade();
    _rascunhoAtual = null;
    _atividades = LocalStorageService.getAtividades();
    notifyListeners();
  }

  Future<void> toggleAtividadeStatus(int id, bool ativo) async {
    final list = LocalStorageService.getAtividades();
    final index = list.indexWhere((a) => a.id == id);
    if (index != -1) {
      list[index].ativo = ativo;
      await LocalStorageService.saveAtividade(list[index]);
      _atividades = LocalStorageService.getAtividades();
      notifyListeners();
    }
  }

  Future<void> deleteAtividade(int id) async {
    await LocalStorageService.deleteAtividade(id);
    _atividades = LocalStorageService.getAtividades();
    notifyListeners();
  }

  Future<void> descartarRascunho() async {
    await LocalStorageService.clearRascunhoAtividade();
    _rascunhoAtual = null;
    notifyListeners();
  }

  // --- MÉTRICAS DE DESEMPENHO POR TEMA / ATIVIDADE ---

  double getCompletionPercentage(String atividadeTipo, String tema) {
    final history = getPontuacaoHistoryForActivePersonagem();
    final filtered = history.where((p) => p.atividade == atividadeTipo).toList();
    if (filtered.isEmpty) return 0.0;
    
    int totalAcertos = 0;
    for (final p in filtered) {
      totalAcertos += p.acertos;
    }
    // Consideramos uma meta de 10 acertos por tema para 100% de conclusão no protótipo
    final double pct = (totalAcertos / 10.0) * 100.0;
    return pct > 100.0 ? 100.0 : pct;
  }

  double getAccuracyPercentage(String atividadeTipo, String tema) {
    final history = getPontuacaoHistoryForActivePersonagem();
    final filtered = history.where((p) => p.atividade == atividadeTipo).toList();
    if (filtered.isEmpty) return 100.0; // Padrão se não jogou ainda

    int totalAcertos = 0;
    int totalErros = 0;
    for (final p in filtered) {
      totalAcertos += p.acertos;
      totalErros += p.erros;
    }

    final int total = totalAcertos + totalErros;
    if (total == 0) return 100.0;

    return (totalAcertos / total) * 100.0;
  }
}

