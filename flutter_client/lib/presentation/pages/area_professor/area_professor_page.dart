import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/app_state_provider.dart';
import '../../../data/storage/local_storage_service.dart';
import '../../../services/api_service.dart';
import '../../../data/models/usuario.dart';

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
      length: 3,
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
              // ABA 1: VINCULAR TURMA
              _buildSyncTab(state, isCompact),
              
              // ABA 2: CONFIGURAÇÕES
              _buildConfigTab(state),
              
              // ABA 3: RELATÓRIOS
              _buildReportTab(state),
            ],
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
