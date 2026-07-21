import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/app_state_provider.dart';
import '../../../data/storage/local_storage_service.dart';
import '../../../services/api_service.dart';
import '../../../data/models/usuario.dart';
import '../../../data/models/atividade.dart';

class AreaProfessorPage extends StatefulWidget {
  const AreaProfessorPage({super.key});

  @override
  State<AreaProfessorPage> createState() => _AreaProfessorPageState();
}

class _AreaProfessorPageState extends State<AreaProfessorPage> {
  final TextEditingController _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _statusMessage;

  // Authentication controllers and keys
  final _authFormKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoginMode = true;
  bool _isAuthLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _authError;

  // Activity Management Form State
  bool _isCreatingActivity = false;
  int? _editingActivityId;
  final TextEditingController _tituloController = TextEditingController();
  String _selectedTipoJogo = 'JOGO_ADIVINHACAO';
  String _selectedDificuldade = 'FACIL';
  List<ItemAtividade> _editingItens = [];
  final TextEditingController _itemDescricaoController = TextEditingController();
  final TextEditingController _itemImagemController = TextEditingController();
  final TextEditingController _itemOpcoesController = TextEditingController();


  @override
  void initState() {
    super.initState();
    final state = context.read<AppStateProvider>();
    if (state.activeTurma != null) {
      _codeController.text = state.activeTurma!.codigo;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _confirmPasswordController.dispose();
    _tituloController.dispose();
    _itemDescricaoController.dispose();
    _itemImagemController.dispose();
    _itemOpcoesController.dispose();
    super.dispose();
  }


  Future<void> _handleSync() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final state = context.read<AppStateProvider>();
    final result = await state.sincronizaSala(_codeController.text.trim());
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _statusMessage = result;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: result.startsWith('Sucesso') ? AppColors.accent : AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleUnlink() async {
    final state = context.read<AppStateProvider>();
    await state.desvincularTurma();
    _codeController.clear();
    setState(() {
      _statusMessage = "Sala desvinculada com sucesso.";
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Turma desvinculada com sucesso.'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_authFormKey.currentState!.validate()) return;
    
    setState(() {
      _isAuthLoading = true;
      _authError = null;
    });

    try {
      final state = context.read<AppStateProvider>();
      await state.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        setState(() {
          _isAuthLoading = false;
          _usernameController.clear();
          _passwordController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthLoading = false;
          _authError = 'Usuário ou senha incorretos.';
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_authFormKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _authError = 'As senhas não coincidem.';
      });
      return;
    }
    
    setState(() {
      _isAuthLoading = true;
      _authError = null;
    });

    try {
      final state = context.read<AppStateProvider>();
      final user = Usuario(
        nome: _nameController.text.trim(),
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      await state.register(user);

      if (mounted) {
        setState(() {
          _isAuthLoading = false;
          _nameController.clear();
          _emailController.clear();
          _usernameController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthLoading = false;
          _authError = 'Erro ao realizar o cadastro. O usuário já existe?';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final isCompact = MediaQuery.of(context).size.width < 600;

    // Check login state
    if (!state.isLoggedIn) {
      return _buildAuthScreen(state, isCompact);
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text(
            'Área do Professor & Responsável',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.primaryLight,
            indicatorColor: AppColors.secondary,
            indicatorWeight: 4,
            tabs: [
              Tab(icon: Icon(Icons.add_task_rounded), text: 'Gestão de Atividades'),
              Tab(icon: Icon(Icons.sync_rounded), text: 'Vincular Turma'),
              Tab(icon: Icon(Icons.settings_rounded), text: 'Configurações'),
              Tab(icon: Icon(Icons.analytics_rounded), text: 'Relatórios'),
            ],
          ),
        ),
        body: Container(
          color: AppColors.bgSoft,
          child: TabBarView(
            children: [
              // ABA 1: GESTÃO DE ATIVIDADES
              _buildActivityTab(state, isCompact),

              // ABA 2: VINCULAR TURMA
              _buildSyncTab(state, isCompact),
              
              // ABA 3: CONFIGURAÇÕES
              _buildConfigTab(state),
              
              // ABA 4: RELATÓRIOS
              _buildReportTab(state),
            ],
          ),
        ),
      ),
    );
  }

  void _initCreationForm({Atividade? existingAtividade}) {
    if (existingAtividade != null) {
      _editingActivityId = existingAtividade.id;
      _tituloController.text = existingAtividade.titulo;
      _selectedTipoJogo = existingAtividade.tipoJogo;
      _selectedDificuldade = existingAtividade.dificuldade;
      _editingItens = List.from(existingAtividade.itens);
    } else {
      _editingActivityId = null;
      _tituloController.clear();
      _selectedTipoJogo = 'JOGO_ADIVINHACAO';
      _selectedDificuldade = 'FACIL';
      _editingItens = [];
    }
    _itemDescricaoController.clear();
    _itemImagemController.clear();
    _itemOpcoesController.clear();
    setState(() {
      _isCreatingActivity = true;
    });
  }

  Future<void> _saveProgressDraft(AppStateProvider state) async {
    if (_tituloController.text.trim().isEmpty && _editingItens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insira ao menos o tema ou um item para salvar rascunho.'),
          backgroundColor: AppColors.info,
        ),
      );
      return;
    }

    final atv = Atividade(
      id: _editingActivityId,
      titulo: _tituloController.text.trim().isEmpty ? 'Sem Título (Rascunho)' : _tituloController.text.trim(),
      tipoJogo: _selectedTipoJogo,
      dificuldade: _selectedDificuldade,
      rascunho: true,
      ativo: true,
      itens: _editingItens,
    );

    await state.salvarRascunhoAtividade(atv);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('💾 Progresso salvo como rascunho! Você pode continuar mais tarde.'),
          backgroundColor: AppColors.secondary,
        ),
      );
      setState(() {
        _isCreatingActivity = false;
      });
    }
  }

  Future<void> _publishActivity(AppStateProvider state) async {
    if (_tituloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe o tema/título da atividade.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_editingItens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione ao menos 1 item/palavra à atividade.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final atv = Atividade(
      id: _editingActivityId,
      titulo: _tituloController.text.trim(),
      tipoJogo: _selectedTipoJogo,
      dificuldade: _selectedDificuldade,
      rascunho: false,
      ativo: true,
      itens: _editingItens,
    );

    await state.publicarAtividade(atv);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Atividade publicada com sucesso! Ela já está disponível no aplicativo.'),
          backgroundColor: AppColors.accent,
        ),
      );
      setState(() {
        _isCreatingActivity = false;
      });
    }
  }

  Widget _buildActivityTab(AppStateProvider state, bool isCompact) {
    if (isCompact) {
      return _buildMobileRestrictionWidget();
    }

    if (_isCreatingActivity) {
      return _buildActivityWizard(state);
    }

    return _buildActivityListDashboard(state);
  }

  Widget _buildMobileRestrictionWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.laptop_mac_rounded,
                    size: 64,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Criação de Atividades Exclusiva para Web e Tablet',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Para garantir a melhor experiência na criação de novas atividades, temas, palavras e imagens, acesse esta funcionalidade em um computador ou tablet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.textDark.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityListDashboard(AppStateProvider state) {
    final rascunho = state.rascunhoAtual;
    final atividades = state.atividades;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Gestão de Jogos e Atividades',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Crie novos temas para os jogos de Adivinhação e Palavras',
                    style: TextStyle(fontSize: 14, color: AppColors.textDark),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _initCreationForm(),
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text(
                  'Criar Nova Atividade',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Card de Rascunho se houver progresso salvo
          if (rascunho != null)
            Card(
              color: AppColors.secondaryLight.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.secondary, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.history_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Você possui um cadastro em andamento! 💾',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                          Text(
                            'Tema: ${rascunho.titulo.isEmpty ? "Sem Título" : rascunho.titulo} • ${rascunho.itens.length} itens cadastrados',
                            style: TextStyle(fontSize: 14, color: AppColors.textDark.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      onPressed: () async {
                        await state.descartarRascunho();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Rascunho descartado.')),
                          );
                        }
                      },
                      child: const Text('Descartar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                      onPressed: () => _initCreationForm(existingAtividade: rascunho),
                      icon: const Icon(Icons.edit_rounded, color: Colors.white),
                      label: const Text('Continuar Cadastro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),

          if (rascunho != null) const SizedBox(height: 20),

          // Lista de Atividades Cadastradas
          if (atividades.isEmpty)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    const Icon(Icons.gamepad_rounded, size: 64, color: AppColors.primaryLight),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhuma atividade criada ainda',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Clique no botão "Criar Nova Atividade" acima para cadastrar temas e palavras personalizadas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: atividades.length,
              itemBuilder: (context, index) {
                final atv = atividades[index];
                final isAdivinhacao = atv.tipoJogo == 'JOGO_ADIVINHACAO';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isAdivinhacao ? AppColors.accent : AppColors.info).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isAdivinhacao ? Icons.drag_indicator_rounded : Icons.collections_rounded,
                        color: isAdivinhacao ? AppColors.accent : AppColors.info,
                        size: 32,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          atv.titulo,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: atv.ativo ? AppColors.accentLight : AppColors.errorLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            atv.ativo ? 'Ativo' : 'Inativo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: atv.ativo ? AppColors.accent : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        'Tipo: ${isAdivinhacao ? 'Adivinhação' : 'Jogo de Palavras'}  •  ${atv.itens.length} palavras  •  Dificuldade: ${atv.dificuldade}',
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: atv.ativo,
                          activeColor: AppColors.accent,
                          onChanged: (val) {
                            state.toggleAtividadeStatus(atv.id!, val);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                          onPressed: () => _initCreationForm(existingAtividade: atv),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Excluir Atividade?'),
                                content: Text('Tem certeza que deseja excluir "${atv.titulo}"?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      state.deleteAtividade(atv.id!);
                                    },
                                    child: const Text('Excluir', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActivityWizard(AppStateProvider state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _editingActivityId == null ? 'Nova Atividade / Tema' : 'Editar Atividade',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          setState(() {
                            _isCreatingActivity = false;
                          });
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Passo 1: Informações Básicas
                  const Text(
                    '1. Informações da Atividade',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Tema / Título (ex: Frutas, Escola, Objetos)',
                      prefixIcon: Icon(Icons.label_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedTipoJogo,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de Jogo',
                            prefixIcon: Icon(Icons.gamepad_rounded),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'JOGO_ADIVINHACAO', child: Text('Adivinhação (Libras)')),
                            DropdownMenuItem(value: 'JOGO_PALAVRAS', child: Text('Jogo de Palavras (Associação)')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedTipoJogo = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedDificuldade,
                          decoration: const InputDecoration(
                            labelText: 'Dificuldade',
                            prefixIcon: Icon(Icons.star_rounded),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'FACIL', child: Text('Fácil 🌟')),
                            DropdownMenuItem(value: 'MEDIO', child: Text('Médio ✨')),
                            DropdownMenuItem(value: 'DIFICIL', child: Text('Difícil 🔥')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedDificuldade = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Passo 2: Palavras & Imagens
                  const Text(
                    '2. Cadastrar Palavras e Imagens',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _itemDescricaoController,
                                decoration: const InputDecoration(
                                  labelText: 'Palavra / Descrição (ex: Gato, Maçã)',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _itemImagemController,
                                decoration: const InputDecoration(
                                  labelText: 'Caminho/URL da Imagem',
                                  hintText: 'assets/animais/gato.png',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_selectedTipoJogo == 'JOGO_PALAVRAS') ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _itemOpcoesController,
                            decoration: const InputDecoration(
                              labelText: 'Opções de resposta (separadas por vírgula)',
                              hintText: 'Maçã, Banana, Uva, Laranja',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                            onPressed: () {
                              final desc = _itemDescricaoController.text.trim();
                              if (desc.isEmpty) return;

                              String img = _itemImagemController.text.trim();
                              if (img.isEmpty) {
                                img = 'assets/animais/gato.png'; // Padrão
                              }

                              List<String> opcs = [];
                              if (_selectedTipoJogo == 'JOGO_PALAVRAS') {
                                final rawOpcs = _itemOpcoesController.text.trim();
                                if (rawOpcs.isNotEmpty) {
                                  opcs = rawOpcs.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                                }
                                if (!opcs.contains(desc)) {
                                  opcs.insert(0, desc);
                                }
                              }

                              setState(() {
                                _editingItens.add(ItemAtividade(
                                  descricao: desc,
                                  imagem: img,
                                  opcoes: opcs,
                                ));
                                _itemDescricaoController.clear();
                                _itemImagemController.clear();
                                _itemOpcoesController.clear();
                              });
                            },
                            icon: const Icon(Icons.add_rounded, color: Colors.white),
                            label: const Text('Adicionar Palavra', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lista dos Itens já adicionados
                  if (_editingItens.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Nenhuma palavra adicionada a este tema ainda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.error),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _editingItens.length,
                      itemBuilder: (context, index) {
                        final item = _editingItens[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  item.imagem,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            title: Text(item.descricao, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: item.opcoes.isNotEmpty
                                ? Text('Opções: ${item.opcoes.join(", ")}')
                                : Text('Imagem: ${item.imagem}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_rounded, color: AppColors.error),
                              onPressed: () {
                                setState(() {
                                  _editingItens.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),

                  const Divider(height: 36),

                  // Rodapé de Ações com "Salvar Progresso (Rascunho)" e "Publicar"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _isCreatingActivity = false;
                          });
                        },
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Voltar'),
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.secondary,
                              side: const BorderSide(color: AppColors.secondary, width: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                            onPressed: () => _saveProgressDraft(state),
                            icon: const Icon(Icons.save_rounded),
                            label: const Text('Salvar Progresso (Rascunho)', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                            onPressed: () => _publishActivity(state),
                            icon: const Icon(Icons.publish_rounded, color: Colors.white),
                            label: const Text('Publicar Atividade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildAuthScreen(AppStateProvider state, bool isCompact) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          _isLoginMode ? 'Entrar na Área do Professor' : 'Cadastro de Professor',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: AppColors.bgSoft,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _authFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          _isLoginMode ? Icons.lock_person_rounded : Icons.person_add_rounded,
                          size: 80,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isLoginMode ? 'Área do Professor' : 'Crie sua Conta',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLoginMode
                              ? 'Faça login para acompanhar o progresso dos seus alunos e gerenciar turmas.'
                              : 'Cadastre-se para sincronizar salas de aula e criar palavras personalizadas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textDark.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        if (!_isLoginMode) ...[
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Nome Completo',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, insira seu nome.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, insira seu e-mail.';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                return 'Por favor, insira um e-mail válido.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Usuário (username)',
                            prefixIcon: Icon(Icons.alternate_email_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, insira um nome de usuário.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira sua senha.';
                            }
                            if (value.length < 6) {
                              return 'A senha deve ter pelo menos 6 caracteres.';
                            }
                            return null;
                          },
                        ),
                        
                        if (!_isLoginMode) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirmar Senha',
                              prefixIcon: const Icon(Icons.lock_reset_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, confirme sua senha.';
                              }
                              if (value != _passwordController.text) {
                                return 'As senhas não coincidem.';
                              }
                              return null;
                            },
                          ),
                        ],
                        
                        const SizedBox(height: 16),
                        
                        if (_authError != null) ...[
                          Text(
                            _authError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        if (_isAuthLoading)
                          const Center(child: CircularProgressIndicator())
                        else ...[
                          ElevatedButton(
                            onPressed: _isLoginMode ? _handleLogin : _handleRegister,
                            child: Text(_isLoginMode ? 'Entrar' : 'Cadastrar'),
                          ),
                          const SizedBox(height: 16),
                          
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                            onPressed: () {
                              setState(() {
                                _isLoginMode = !_isLoginMode;
                                _authError = null;
                                _authFormKey.currentState?.reset();
                              });
                            },
                            child: Text(
                              _isLoginMode
                                  ? 'Não tem uma conta? Cadastre-se'
                                  : 'Já tem uma conta? Faça Login',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncTab(AppStateProvider state, bool isCompact) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.connect_without_contact_rounded,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Vincular com o Servidor',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Digite o código fornecido pelo sistema do educador para carregar as palavras personalizadas e avatares dos alunos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textDark.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Código da Turma',
                        hintText: 'Ex: 12345',
                        prefixIcon: Icon(Icons.vpn_key_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, insira o código da turma.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    
                    // Tip para as stakeholders testarem
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.infoLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.info.withOpacity(0.5)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.info),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Dica de Teste: Digite o código "12345" para simular a sincronização com sucesso.',
                              style: TextStyle(fontSize: 13, color: AppColors.textDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    if (_statusMessage != null) ...[
                      Text(
                        _statusMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _statusMessage!.startsWith('Sucesso')
                              ? AppColors.accent
                              : AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      ElevatedButton(
                        onPressed: _handleSync,
                        child: const Text('Vincular Turma'),
                      ),
                      if (state.activeTurma != null) ...[
                        const SizedBox(height: 12),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: _handleUnlink,
                          child: const Text(
                            'Desvincular Turma',
                            style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSobreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Sobre o Projeto',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Este projeto foi desenvolvido como parte do Trabalho de Conclusão de Curso (TCC) no curso de Análise e Desenvolvimento de Sistemas da UTFPR.\n\nA aplicação tem como objetivo apoiar a alfabetização bilíngue de crianças surdas entre 4 e 5 anos, com foco na Língua Brasileira de Sinais (Libras) e no alfabeto manual.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(height: 20),
                Divider(),
                SizedBox(height: 10),
                Text(
                  'Desenvolvedor:\nLuan Filipe Finatto',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 12),
                Text(
                  'Orientadora:\nProfª. Drª. Rúbia Eliza de Oliveira Schultz Ascari',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 12),
                Text(
                  'Coorientadoras:\nProfª. Me. Mirelia Flausino Vogel\nProfª. Me. Aline Brancalione',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 20),
                Text(
                  '© 2025 - Luan Finatto.\nTodos os direitos reservados.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfigTab(AppStateProvider state) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24.0),
        child: Card(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  children: [
                    Icon(Icons.settings_suggest_rounded, color: AppColors.secondary, size: 36),
                    SizedBox(width: 12),
                    Text(
                      'Configurações Básicas',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(height: 32),
                
                // Toggle do Alfabeto
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Utilizar Alfabeto Original',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: const Text(
                    'Usa as ilustrações originais vetorizadas para Libras ao invés das fotos reais das professoras.',
                    style: TextStyle(fontSize: 14),
                  ),
                  trailing: Switch(
                    value: state.useLegacyLetters,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      state.setUseLegacyLetters(val);
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Modo Sincronização Server real (Para Stakeholders verem que está pronto)
                const Text(
                  'Modo de Backend',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Conectar o aplicativo ao backend local na porta 50990.',
                        style: TextStyle(color: AppColors.textDark.withOpacity(0.7), fontSize: 14),
                      ),
                    ),
                    Switch(
                      value: ApiService.useBackend,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          ApiService.useBackend = val;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(val 
                              ? 'Conectado ao backend local (http://localhost:50990/server)' 
                              : 'Retornado ao modo estático (Offline Mock)'),
                            backgroundColor: AppColors.info,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const Divider(height: 32),
                
                // Botão Sobre o Projeto
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => _showSobreDialog(context),
                  icon: const Icon(Icons.info_outline_rounded),
                  label: const Text('Sobre o Projeto'),
                ),
                const SizedBox(height: 12),
                
                // Botão Sair da Conta (Logout)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error, width: 2),
                    foregroundColor: AppColors.error,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    await state.logout();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Conta encerrada com sucesso.'),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sair da Conta', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildReportTab(AppStateProvider state) {
    final allScores = LocalStorageService.getPontuacoes();

    if (state.personagens.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline_rounded, size: 64, color: AppColors.primaryLight),
              SizedBox(height: 12),
              Text(
                'Nenhum aluno/avatar cadastrado ainda.',
                style: TextStyle(fontSize: 18, color: AppColors.textDark),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Desempenho dos Alunos',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          
          ...state.personagens.map((p) {
            final pScores = allScores.where((s) => s.personagem?.id == p.id).toList();
            
            return Card(
              margin: const EdgeInsets.only(bottom: 20),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(p.avatar),
                ),
                title: Text(
                  p.nome,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text('Dificuldade: ${p.dificuldade}  •  ${pScores.length} Partidas jogadas'),
                children: [
                  if (pScores.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Nenhuma partida registrada para este aluno ainda.'),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Table(
                        border: TableBorder.all(color: AppColors.border, width: 1, borderRadius: BorderRadius.circular(8)),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1.5),
                        },
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(color: AppColors.primaryLight),
                            children: [
                              Padding(padding: EdgeInsets.all(10), child: Text('Jogo', style: TextStyle(fontWeight: FontWeight.bold))),
                              Padding(padding: EdgeInsets.all(10), child: Text('Acertos', style: TextStyle(fontWeight: FontWeight.bold))),
                              Padding(padding: EdgeInsets.all(10), child: Text('Erros', style: TextStyle(fontWeight: FontWeight.bold))),
                              Padding(padding: EdgeInsets.all(10), child: Text('Data', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                          ),
                          ...pScores.map((score) {
                            String gameName = score.atividade;
                            if (gameName == 'JOGO_ALFABETO') gameName = 'Alfabeto';
                            if (gameName == 'JOGO_MEMORIA') gameName = 'Memória';
                            if (gameName == 'JOGO_ADIVINHACAO') gameName = 'Adivinhação';
                            if (gameName == 'JOGO_PALAVRAS') gameName = 'Palavras';
                            
                            final dateStr = score.createdAt != null 
                              ? "${score.createdAt!.day}/${score.createdAt!.month} ${score.createdAt!.hour}:${score.createdAt!.minute.toString().padLeft(2, '0')}"
                              : '-';

                            return TableRow(
                              children: [
                                Padding(padding: const EdgeInsets.all(10), child: Text(gameName)),
                                Padding(padding: const EdgeInsets.all(10), child: Text('${score.acertos}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold))),
                                Padding(padding: const EdgeInsets.all(10), child: Text('${score.erros}', style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold))),
                                Padding(padding: const EdgeInsets.all(10), child: Text(dateStr)),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
