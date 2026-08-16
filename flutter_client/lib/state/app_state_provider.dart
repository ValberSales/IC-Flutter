import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/pontuacao.dart';
import '../data/models/turma.dart';
import '../data/models/palavra.dart';
import '../data/models/usuario.dart';
import '../data/models/atividade.dart';
import '../data/repositories/turma_repository.dart';
import '../data/storage/local_storage_service.dart';
import '../data/storage/media_storage_service.dart';
import '../data/sources/local_data_source.dart';
import '../data/services/api_service.dart';

class AppStateProvider extends ChangeNotifier {
  final TurmaRepository _turmaRepository = TurmaRepository();

  Turma? _activeTurma;
  List<Turma> _turmas = [];
  List<Palavra> _customPalavras = [];
  List<Atividade> _atividades = [];
  Atividade? _rascunhoAtual;
  bool _isSyncing = false;
  Usuario? _currentUser;
  String? _token;
  Timer? _periodicSyncTimer;

  bool _isGuestMode = false;
  List<Usuario> _usuarios = [];
  String _currentDificuldade = 'FACIL';

  // Getters
  String get currentDificuldade => _currentUser?.dificuldade ?? _currentDificuldade;
  Turma? get activeTurma => _activeTurma;
  List<Turma> get turmas => _turmas;
  List<Palavra> get customPalavras => _customPalavras;
  List<Atividade> get atividades => _atividades;
  List<Usuario> get usuarios => _usuarios;
  Atividade? get rascunhoAtual => _rascunhoAtual;
  bool get isSyncing => _isSyncing;
  Usuario? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _token != null && _currentUser != null;
  bool get isGuestMode => _isGuestMode;

  // Letras atuais do alfabeto manual padrão
  List<Map<String, String>> get currentAlfabeto => LocalDataSource.alfabetoManualProf;

  // Inicializa o estado lendo do LocalStorage e tentando sincronizar com o servidor
  void loadInitialState() {
    _token = LocalStorageService.getToken();
    _currentUser = LocalStorageService.getUser();
    if (_currentUser?.dificuldade != null) {
      _currentDificuldade = _currentUser!.dificuldade;
    }
    _isGuestMode = LocalStorageService.isGuestMode();
    _usuarios = LocalStorageService.getUsuariosList();
    _atividades = LocalStorageService.getAtividades();
    _rascunhoAtual = LocalStorageService.getRascunhoAtividade();
    _turmas = LocalStorageService.getTurmas();
    _activeTurma = LocalStorageService.getActiveTurma();
    
    // Limpa registros inflados locais mantendo apenas o melhor aproveitamento por tema/jogo
    _cleanAndRetainBestScores();

    // Tenta restabelecer turma se já estiver salva localmente
    final codigoTurma = LocalStorageService.getCodigoTurma();
    if (codigoTurma != null && _activeTurma == null) {
      _loadMockTurmaForCode(codigoTurma);
    }

    notifyListeners();

    // Sincroniza atividades, usuários e turmas do servidor em segundo plano imediatamente
    fetchAtividadesOnline();
    fetchUsuariosOnline();
    fetchTurmasOnline();
    fetchAlunoTurmaOnline();
    syncPontuacoesPendentes();

    // Inicia polling de sincronização em segundo plano (a cada 5 segundos para atualizações instantâneas)
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchAtividadesOnline();
      fetchUsuariosOnline();
      fetchTurmasOnline();
      syncPontuacoesPendentes();
      if (_currentUser != null) {
        fetchAlunoTurmaOnline();
      }
    });
  }

  Future<void> fetchTurmasOnline() async {
    try {
      final list = await _turmaRepository.getTurmas();
      if (list.isNotEmpty) {
        _turmas = list;
        await LocalStorageService.saveTurmas(list);
      }

      // Se for ADMIN/Professor e tem uma turma selecionada, atualiza os dados locais
      if (_currentUser?.role == 'ADMIN') {
        if (_activeTurma != null) {
          final updated = _turmas.where((t) => t.id == _activeTurma!.id || t.codigo == _activeTurma!.codigo);
          if (updated.isNotEmpty) {
            _activeTurma = updated.first;
            await LocalStorageService.setActiveTurma(_activeTurma);
          }
        }
        notifyListeners();
      } else if (_currentUser != null) {
        // Se for aluno, consulta a alocação oficial em tempo real
        await fetchAlunoTurmaOnline();
      } else {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar turmas: $e');
    }
  }

  Future<void> fetchAlunoTurmaOnline() async {
    if (_currentUser == null || _currentUser!.id == null) return;
    try {
      final t = await _turmaRepository.getTurmaDoAluno(_currentUser!.id!);
      if (t != null) {
        _activeTurma = t;
        await LocalStorageService.setActiveTurma(t);
        await LocalStorageService.setCodigoTurma(t.codigo);
      } else {
        // Aluno não está em nenhuma turma (ou foi removido pelo professor)
        if (_activeTurma != null) {
          _activeTurma = null;
          await LocalStorageService.setActiveTurma(null);
          await LocalStorageService.setCodigoTurma(null);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao sincronizar turma do aluno logado: $e');
    }
  }

  bool isTemaDaTurma(String temaTitulo, int? temaId) {
    if (_activeTurma == null) return false;
    if (temaId != null && _activeTurma!.atividadesIds.contains(temaId)) {
      return true;
    }
    if (_activeTurma!.atividadesIds.isNotEmpty) {
      for (final atv in _atividades) {
        if (_activeTurma!.atividadesIds.contains(atv.id)) {
          if (atv.titulo.trim().toLowerCase() == temaTitulo.trim().toLowerCase()) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Future<void> fetchAtividadesOnline() async {
    try {
      final onlineList = await ApiService.getAtividades(apenasAtivas: false);
      if (onlineList.isNotEmpty) {
        onlineList.sort((a, b) => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()));
        _atividades = onlineList;
        notifyListeners();
        // Pré-download em background de todas as mídias para funcionamento offline
        MediaStorageService.prefetchAtividadesMedia(_atividades);
      }
      await syncPontuacoesPendentes();
    } catch (e) {
      debugPrint('Sincronização offline mantida: $e');
    }
  }

  Future<void> loadTurmas() => fetchTurmasOnline();
  Future<void> loadUsuarios({String? busca}) => fetchUsuariosOnline(busca: busca);

  Future<void> fetchUsuariosOnline({String? busca}) async {
    try {
      final list = await ApiService.getUsuarios(busca: busca);
      if (list.isNotEmpty || busca != null) {
        _usuarios = list;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar usuários: $e');
    }
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

  // --- AUTENTICAÇÃO E PERFIL ---

  Future<void> enterGuestMode() async {
    _isGuestMode = true;
    await LocalStorageService.setGuestMode(true);
    notifyListeners();
  }

  Future<bool> login(String identifier, String password) async {
    try {
      final result = await ApiService.login(identifier, password);
      if (result != null && result['token'] != null && result['user'] != null) {
        _token = result['token'] as String;
        _currentUser = Usuario.fromJson(result['user'] as Map<String, dynamic>);
        if (_currentUser?.dificuldade != null) {
          _currentDificuldade = _currentUser!.dificuldade;
        }
        _isGuestMode = false;
        await LocalStorageService.setGuestMode(false);
        await LocalStorageService.saveToken(_token!);
        await LocalStorageService.saveUser(_currentUser!);

        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Erro ao fazer login: $e');
    }
    return false;
  }

  Future<bool> register(Usuario user) async {
    try {
      final result = await ApiService.cadastro(user);
      if (result != null && result['token'] != null && result['user'] != null) {
        _token = result['token'] as String;
        _currentUser = Usuario.fromJson(result['user'] as Map<String, dynamic>);
        if (_currentUser?.dificuldade != null) {
          _currentDificuldade = _currentUser!.dificuldade;
        }
        _isGuestMode = false;
        await LocalStorageService.setGuestMode(false);
        await LocalStorageService.saveToken(_token!);
        await LocalStorageService.saveUser(_currentUser!);

        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Erro ao cadastrar: $e');
    }
    return false;
  }

  Future<bool> updateUserProfile({String? nome, String? avatar}) async {
    if (_currentUser == null) return false;

    if (nome != null && nome.trim().isNotEmpty) {
      _currentUser!.nome = nome.trim();
    }
    if (avatar != null && avatar.trim().isNotEmpty) {
      _currentUser!.avatar = avatar.trim();
    }

    await LocalStorageService.saveUser(_currentUser!);
    await ApiService.updateUsuario(_currentUser!);
    notifyListeners();
    return true;
  }

  Future<Map<String, dynamic>> updateAccountDetails({
    String? nome,
    String? username,
    String? newPassword,
    String? avatar,
  }) async {
    if (_currentUser == null) {
      return {'success': false, 'error': 'Usuário não autenticado.'};
    }

    final bool loginDataChanged = (username != null &&
            username.trim().isNotEmpty &&
            username.trim().toLowerCase() != (_currentUser!.username ?? '').toLowerCase()) ||
        (newPassword != null && newPassword.trim().isNotEmpty);

    final updatedUser = Usuario(
      id: _currentUser!.id,
      nome: (nome != null && nome.trim().isNotEmpty) ? nome.trim() : _currentUser!.nome,
      username: (username != null && username.trim().isNotEmpty) ? username.trim() : _currentUser!.username,
      password: (newPassword != null && newPassword.trim().isNotEmpty) ? newPassword.trim() : null,
      avatar: (avatar != null && avatar.trim().isNotEmpty) ? avatar.trim() : _currentUser!.avatar,
      codigoIdentificador: _currentUser!.codigoIdentificador,
      role: _currentUser!.role,
      email: _currentUser!.email,
      dificuldade: _currentUser!.dificuldade,
    );

    try {
      final updated = await ApiService.updateUsuario(updatedUser);
      if (updated != null) {
        if (loginDataChanged) {
          await logout();
          return {
            'success': true,
            'loginDataChanged': true,
            'message': 'Dados de login alterados com sucesso! Por favor, entre novamente.',
          };
        } else {
          _currentUser = updated;
          await LocalStorageService.saveUser(_currentUser!);
          notifyListeners();
          return {
            'success': true,
            'loginDataChanged': false,
            'message': 'Perfil atualizado com sucesso!',
          };
        }
      } else {
        return {'success': false, 'error': 'Erro ao atualizar dados no servidor ou nome de usuário já em uso.'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erro de conexão: $e'};
    }
  }

  Future<String?> resetUserPassword(int userId) async {
    final tempPassword = await ApiService.resetPassword(userId);
    if (tempPassword != null) {
      final index = _usuarios.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _usuarios[index].mustChangePassword = true;
        await LocalStorageService.saveUsuariosList(_usuarios);
      }
      if (_currentUser?.id == userId) {
        _currentUser!.mustChangePassword = true;
        await LocalStorageService.saveUser(_currentUser!);
      }
      notifyListeners();
      return tempPassword;
    }
    return null;
  }

  Future<bool> changePasswordAfterReset(String newPassword) async {
    if (_currentUser == null) return false;
    final username = _currentUser!.username ?? '';
    if (username.isEmpty) return false;

    try {
      final success = await ApiService.changePassword(
        username: username,
        newPassword: newPassword.trim(),
      );

      if (success || !ApiService.useBackend) {
        _currentUser!.password = newPassword.trim();
        _currentUser!.mustChangePassword = false;
        await LocalStorageService.saveUser(_currentUser!);

        final list = LocalStorageService.getUsuariosList();
        final idx = list.indexWhere((u) => (u.username ?? '').toLowerCase() == username.toLowerCase() || u.id == _currentUser!.id);
        if (idx != -1) {
          list[idx].password = newPassword.trim();
          list[idx].mustChangePassword = false;
          await LocalStorageService.saveUsuariosList(list);
        }

        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Erro ao alterar senha obrigatória: $e');
    }
    return false;
  }

  Future<bool> updateUserRole(int id, String newRole) async {
    final index = _usuarios.indexWhere((u) => u.id == id);
    if (index != -1) {
      _usuarios[index].role = newRole;
      await LocalStorageService.saveUsuariosList(_usuarios);
      await ApiService.updateUsuario(_usuarios[index]);

      if (_currentUser?.id == id) {
        _currentUser!.role = newRole;
        await LocalStorageService.saveUser(_currentUser!);
      }

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<Usuario?> createUsuario({
    required String username,
    String? nome,
    String? password,
    String role = 'USER',
    String? avatar,
    bool mustChangePassword = false,
  }) async {
    final created = await ApiService.createUsuario(
      username: username,
      nome: nome,
      password: password,
      role: role,
      avatar: avatar,
      mustChangePassword: mustChangePassword,
    );
    if (created != null) {
      final index = _usuarios.indexWhere((u) => u.id == created.id);
      if (index == -1) {
        _usuarios.add(created);
      } else {
        _usuarios[index] = created;
      }
      notifyListeners();
    }
    return created;
  }

  Future<bool> deleteUser(int id) async {
    final success = await ApiService.deleteUsuario(id);
    if (success) {
      _usuarios.removeWhere((u) => u.id == id);
      await LocalStorageService.saveUsuariosList(_usuarios);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    _isGuestMode = false;
    _activeTurma = null;
    _customPalavras = [];
    await LocalStorageService.setGuestMode(false);
    await LocalStorageService.clearToken();
    await LocalStorageService.clearUser();
    await LocalStorageService.setCodigoTurma(null);
    notifyListeners();
  }

  // --- GERENCIAMENTO DE DIFICULDADE ---

  Future<void> updateDificuldade(String diff) async {
    _currentDificuldade = diff;
    if (_currentUser != null) {
      _currentUser!.dificuldade = diff;
      await LocalStorageService.saveUser(_currentUser!);
      await ApiService.updateUsuario(_currentUser!);
    }
    notifyListeners();
  }

  Future<void> updatePersonagemDificuldade(String diff) => updateDificuldade(diff);

  // --- HISTÓRICO DE PONTUAÇÃO ---

  List<Pontuacao> getPontuacaoHistoryForCurrentUser() {
    final uid = _currentUser?.id ?? 0;
    return LocalStorageService.getPontuacaoForUsuario(uid);
  }

  List<Pontuacao> getPontuacaoHistoryForActivePersonagem() => getPontuacaoHistoryForCurrentUser();

  Future<void> salvaPontuacao(
    int acertos,
    int erros,
    String atividade, {
    String? tema,
    bool concluido = false,
    String? progressoItens,
  }) async {
    final pontuacao = Pontuacao(
      usuarioId: _currentUser?.id,
      usuario: _currentUser,
      atividade: atividade,
      acertos: acertos,
      erros: erros,
      dificuldade: currentDificuldade,
      sincronizado: false,
      concluido: concluido,
      tema: tema,
      progressoItens: progressoItens,
    );

    // Salva localmente primeiro
    await LocalStorageService.savePontuacao(pontuacao);
    
    // Tenta sincronizar imediatamente se possível
    await syncPontuacoesPendentes();
    
    notifyListeners();
  }

  Future<void> syncPontuacoesPendentes() async {
    try {
      final allScores = LocalStorageService.getPontuacoes();
      final unsynced = allScores.where((s) => !s.sincronizado).toList();
      if (unsynced.isEmpty) return;

      for (final score in unsynced) {
        final oldId = score.id;
        final uid = score.usuarioId ?? score.usuario?.id;
        if (uid != null && uid > 0) {
          final onlineScore = await ApiService.salvaPontuacao(score);
          if (onlineScore != null) {
            score.sincronizado = true;
            if (onlineScore.id != null) {
              score.id = onlineScore.id;
            }
            await LocalStorageService.savePontuacao(score, oldId: oldId);
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar pontuções pendentes: $e');
    }
  }

  void _cleanAndRetainBestScores() {
    try {
      final list = LocalStorageService.getPontuacoes();
      if (list.isEmpty) return;

      final Map<String, Pontuacao> bestMap = {};
      for (final s in list) {
        final uid = s.usuarioId ?? s.usuario?.id ?? 0;
        final atv = s.atividade.toUpperCase();
        final tema = (s.tema ?? s.atividade).trim().toUpperCase();
        final diff = s.dificuldade.toUpperCase();
        final key = '${uid}_${atv}_${tema}_$diff';

        final tot = s.acertos + s.erros;
        final taxa = (atv == 'JOGO_MEMORIA') ? (s.concluido ? 100.0 : 0.0) : (tot > 0 ? (s.acertos / tot) * 100.0 : 0.0);

        if (!bestMap.containsKey(key)) {
          bestMap[key] = s;
        } else {
          final currentBest = bestMap[key]!;
          final curTot = currentBest.acertos + currentBest.erros;
          final curTaxa = (currentBest.atividade.toUpperCase() == 'JOGO_MEMORIA')
              ? (currentBest.concluido ? 100.0 : 0.0)
              : (curTot > 0 ? (currentBest.acertos / curTot) * 100.0 : 0.0);

          if (taxa >= curTaxa) {
            bestMap[key] = s;
          }
        }
      }

      LocalStorageService.savePontuacoesList(bestMap.values.toList());
    } catch (e) {
      debugPrint('Erro ao limpar pontuacoes duplicadas locais: $e');
    }
  }

  // --- GESTÃO DE TURMAS (CRUD, ALUNOS E TEMAS) ---

  Future<Turma?> createTurma({
    required String nome,
    String? descricao,
    String? codigo,
  }) async {
    final t = await _turmaRepository.createTurma(
      nome: nome,
      descricao: descricao,
      codigo: codigo,
      usuarioId: _currentUser?.id,
    );
    if (t != null) {
      _turmas.insert(0, t);
      await LocalStorageService.saveTurmas(_turmas);
      notifyListeners();
      fetchTurmasOnline();
    }
    return t;
  }

  Future<Turma?> updateTurma(
    int id, {
    required String nome,
    String? descricao,
    String? codigo,
  }) async {
    final t = await _turmaRepository.updateTurma(
      id,
      nome: nome,
      descricao: descricao,
      codigo: codigo,
    );
    if (t != null) {
      final idx = _turmas.indexWhere((item) => item.id == id);
      if (idx != -1) {
        _turmas[idx] = t;
      }
      if (_activeTurma?.id == id) {
        _activeTurma = t;
        await LocalStorageService.setActiveTurma(t);
      }
      await LocalStorageService.saveTurmas(_turmas);
      notifyListeners();
      fetchTurmasOnline();
    }
    return t;
  }

  Future<bool> deleteTurma(int id) async {
    final success = await _turmaRepository.deleteTurma(id);
    if (success) {
      _turmas.removeWhere((t) => t.id == id);
      if (_activeTurma?.id == id) {
        _activeTurma = null;
        await LocalStorageService.setActiveTurma(null);
      }
      await LocalStorageService.saveTurmas(_turmas);
      notifyListeners();
    }
    return success;
  }

  Future<Turma?> setTurmaAlunos(int turmaId, List<int> alunoIds) async {
    final t = await _turmaRepository.setTurmaAlunos(turmaId, alunoIds);
    if (t != null) {
      final idx = _turmas.indexWhere((item) => item.id == turmaId);
      if (idx != -1) {
        _turmas[idx] = t;
      }
      if (_activeTurma?.id == turmaId) {
        _activeTurma = t;
        await LocalStorageService.setActiveTurma(t);
      }
      await LocalStorageService.saveTurmas(_turmas);
      notifyListeners();
    }
    return t;
  }

  Future<Turma?> removeAlunoFromTurma(int turmaId, int alunoId) async {
    final t = await _turmaRepository.removeAlunoTurma(turmaId, alunoId);
    if (t != null) {
      final idx = _turmas.indexWhere((item) => item.id == turmaId);
      if (idx != -1) {
        _turmas[idx] = t;
      }
      if (_activeTurma?.id == turmaId && _currentUser?.id == alunoId) {
        _activeTurma = null;
        await LocalStorageService.setActiveTurma(null);
      }
      await LocalStorageService.saveTurmas(_turmas);
      notifyListeners();
    }
    return t;
  }

  Future<Turma?> setTurmaAtividades(int turmaId, List<int> atividadeIds) async {
    final t = await _turmaRepository.setTurmaAtividades(turmaId, atividadeIds);
    if (t != null) {
      final idx = _turmas.indexWhere((item) => item.id == turmaId);
      if (idx != -1) {
        _turmas[idx] = t;
      }
      if (_activeTurma?.id == turmaId) {
        _activeTurma = t;
        await LocalStorageService.setActiveTurma(t);
      }
      await LocalStorageService.saveTurmas(_turmas);
      notifyListeners();
    }
    return t;
  }

  Future<String> entrarNaTurma(String codigo) async {
    if (codigo.trim().isEmpty) return "Por favor, digite o código da turma.";
    _isSyncing = true;
    notifyListeners();

    try {
      final res = await _turmaRepository.entrarTurma(codigo, _currentUser?.id);
      _isSyncing = false;

      if (res != null && res['turma'] != null) {
        final turma = Turma.fromJson(Map<String, dynamic>.from(res['turma'] as Map));
        _activeTurma = turma;
        await LocalStorageService.setActiveTurma(turma);
        await LocalStorageService.setCodigoTurma(turma.codigo);
        notifyListeners();
        return "Sucesso: Você agora faz parte da turma '${turma.nome}'!";
      } else {
        notifyListeners();
        return res?['message'] ?? "Turma não encontrada para o código informado.";
      }
    } catch (e) {
      _isSyncing = false;
      notifyListeners();
      return "Erro ao conectar ao servidor.";
    }
  }

  Future<void> sairDaTurma() async {
    await _turmaRepository.sairTurma(_currentUser?.id);
    _activeTurma = null;
    await LocalStorageService.setActiveTurma(null);
    await LocalStorageService.setCodigoTurma(null);
    notifyListeners();
  }

  // --- SINCRONIZAÇÃO LEGADA DE SALA ---

  Future<String> sincronizaSala(String codigo) async {
    return await entrarNaTurma(codigo);
  }

  Future<void> desvincularTurma() async {
    await sairDaTurma();
  }

  // --- GESTÃO DE ATIVIDADES E RASCUNHOS (PROFESSOR) ---

  Future<void> salvarRascunhoAtividade(Atividade atv) async {
    atv.rascunho = true;
    _rascunhoAtual = atv;
    await ApiService.saveAtividade(atv);
    await LocalStorageService.saveRascunhoAtividade(atv);
    notifyListeners();
  }

  Future<void> publicarAtividade(Atividade atv) async {
    atv.rascunho = false;
    if (_currentUser != null) {
      atv.criadoPor = _currentUser!.nome;
    }
    await ApiService.saveAtividade(atv);
    await LocalStorageService.clearRascunhoAtividade();
    _rascunhoAtual = null;
    await fetchAtividadesOnline();
  }

  Future<void> toggleAtividadeStatus(int id, bool ativo) async {
    final idx = _atividades.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _atividades[idx].ativo = ativo;
      _atividades.sort((a, b) => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()));
      notifyListeners();
    }
    await ApiService.toggleAtividadeStatus(id);
    await fetchAtividadesOnline();
  }

  Future<void> toggleAtividadePublica(int id, bool publica) async {
    final idx = _atividades.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _atividades[idx].publica = publica;
      _atividades.sort((a, b) => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()));
      notifyListeners();
    }
    await ApiService.toggleAtividadePublica(id, publica: publica);
    await fetchAtividadesOnline();
  }

  Future<void> deleteAtividade(int id) async {
    await ApiService.deleteAtividade(id);
    await fetchAtividadesOnline();
  }

  Future<void> descartarRascunho() async {
    await LocalStorageService.clearRascunhoAtividade();
    _rascunhoAtual = null;
    notifyListeners();
  }

  // --- MÉTRICAS DE DESEMPENHO POR TEMA / DIFICULDADE / JOGO ---

  Future<void> registrarPalavraConcluida({
    required String jogo,
    Atividade? tema,
    required String temaNomePadrao,
    required String palavra,
    required String dificuldade,
  }) async {
    final int uid = _currentUser?.id ?? 0;
    final String temaKey = tema?.id != null ? tema!.id.toString() : temaNomePadrao;
    await LocalStorageService.saveCompletedWord(uid, jogo, temaKey, dificuldade, palavra);
    notifyListeners();
  }

  Set<String> getCompletedWordsForTema({
    required String jogo,
    Atividade? tema,
    required String temaNomePadrao,
    required String dificuldade,
  }) {
    final int uid = _currentUser?.id ?? 0;
    final String temaKey = tema?.id != null ? tema!.id.toString() : temaNomePadrao;
    return LocalStorageService.getCompletedWords(uid, jogo, temaKey, dificuldade);
  }

  double getTemaCompletionPercentage({
    required String jogo,
    Atividade? tema,
    required String temaNomePadrao,
    required int totalItens,
    required String dificuldade,
  }) {
    final completed = getCompletedWordsForTema(
      jogo: jogo,
      tema: tema,
      temaNomePadrao: temaNomePadrao,
      dificuldade: dificuldade,
    );
    if (totalItens <= 0) return 0.0;
    final double pct = (completed.length / totalItens) * 100.0;
    return pct > 100.0 ? 100.0 : pct;
  }

  List<Atividade> getAtividadesVisiveis(String tipoJogo) {
    return _atividades.where((a) {
      if (a.tipoJogo != tipoJogo) return false;
      if (!a.ativo) return false;
      if (a.rascunho) return false;

      final bool isAlocadaNaTurma = isTemaDaTurma(a.titulo, a.id);

      // Convidado / Não logado só visualiza atividades públicas
      if (isGuestMode || !isLoggedIn) {
        return a.publica;
      }

      // Aluno logado visualiza se for pública OU se for direcionada à sua turma ativa
      return a.publica || isAlocadaNaTurma;
    }).toList();
  }

  double getOverallGameProgress(String jogo) {
    final int uid = _currentUser?.id ?? 0;
    int totalPossivel = 0;
    int totalConcluido = 0;
    final diffs = ['FACIL', 'MEDIO', 'DIFICIL'];

    if (jogo == 'JOGO_ADIVINHACAO' || jogo == 'JOGO_PALAVRAS') {
      final temasVisiveis = getAtividadesVisiveis(jogo);

      if (temasVisiveis.isNotEmpty) {
        for (final atv in temasVisiveis) {
          final int count = atv.itens.isNotEmpty ? atv.itens.length : (jogo == 'JOGO_ADIVINHACAO' ? 5 : 4);
          final String key = atv.id != null ? atv.id.toString() : atv.titulo;
          for (final diff in diffs) {
            totalPossivel += count;
            totalConcluido += LocalStorageService.getCompletedWords(uid, jogo, key, diff).length;
          }
        }
      } else {
        return 0.0;
      }
    } else if (jogo == 'JOGO_ALFABETO') {
      for (final diff in diffs) {
        totalPossivel += 26;
        totalConcluido += LocalStorageService.getCompletedWords(uid, jogo, 'Alfabeto', diff).length;
      }
    } else if (jogo == 'JOGO_MEMORIA') {
      final paresPorNivel = {'FACIL': 6, 'MEDIO': 8, 'DIFICIL': 10};
      for (final diff in diffs) {
        totalPossivel += paresPorNivel[diff] ?? 6;
        totalConcluido += LocalStorageService.getCompletedWords(uid, jogo, 'Memoria', diff).length;
      }
    }

    if (totalPossivel <= 0) return 0.0;
    final double pct = (totalConcluido / totalPossivel) * 100.0;
    return pct > 100.0 ? 100.0 : pct;
  }

  double getCompletionPercentage(String atividadeTipo, String tema) {
    return getTemaCompletionPercentage(
      jogo: atividadeTipo,
      tema: null,
      temaNomePadrao: tema,
      totalItens: 5,
      dificuldade: currentDificuldade,
    );
  }

  double? getAccuracyPercentage(String atividadeTipo, String tema, {String? dificuldade}) {
    final history = getPontuacaoHistoryForCurrentUser();
    final diff = dificuldade ?? currentDificuldade;

    // Considera apenas partidas 100% concluídas daquele tema e daquela dificuldade específica
    final filtered = history.where((p) {
      return p.atividade == atividadeTipo &&
             p.dificuldade == diff &&
             p.concluido == true &&
             (tema.isEmpty || p.tema == null || p.tema == tema);
    }).toList();

    if (filtered.isEmpty) return null;

    double somaPorcentagens = 0.0;
    for (final p in filtered) {
      final int total = p.acertos + p.erros;
      if (total > 0) {
        somaPorcentagens += (p.acertos / total) * 100.0;
      } else {
        somaPorcentagens += 100.0;
      }
    }

    return somaPorcentagens / filtered.length;
  }

  double? getOverallGameAccuracy(String jogo) {
    final history = getPontuacaoHistoryForCurrentUser();

    // Considera apenas partidas 100% concluídas do jogo em qualquer tema ou nível
    final filtered = history.where((p) {
      return p.atividade == jogo && p.concluido == true;
    }).toList();

    if (filtered.isEmpty) return null;

    double somaPorcentagens = 0.0;
    for (final p in filtered) {
      final int total = p.acertos + p.erros;
      if (total > 0) {
        somaPorcentagens += (p.acertos / total) * 100.0;
      } else {
        somaPorcentagens += 100.0;
      }
    }

    return somaPorcentagens / filtered.length;
  }
}

