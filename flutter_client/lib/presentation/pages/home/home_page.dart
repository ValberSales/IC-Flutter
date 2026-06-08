import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/util/responsive_layout.dart';
import '../../../data/models/personagem.dart';
import '../../../data/sources/local_data_source.dart';
import '../../../state/app_state_provider.dart';
import '../../widgets/app_header_widget.dart';
import '../jogo_hub/jogo_hub_page.dart';

enum ETelaInicial { padrao, novoPersonagem, selecaoPersonagem }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ETelaInicial _etapa = ETelaInicial.padrao;
  late Personagem _personagemEdicao;
  bool _isMoving = false;
  final _nomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _personagemEdicao = Personagem();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  void _triggerMascotDance() {
    if (_isMoving) return;
    setState(() {
      _isMoving = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isMoving = false;
        });
      }
    });
  }

  void _mudarAvatar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecione um Avatar', textAlign: TextAlign.center),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          content: SizedBox(
            width: 400,
            height: MediaQuery.of(context).size.height * 0.6,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: LocalDataSource.avataresDisponiveis.length,
              itemBuilder: (context, index) {
                final path = LocalDataSource.avataresDisponiveis[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _personagemEdicao.avatar = path;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _personagemEdicao.avatar == path ? AppColors.secondary : Colors.transparent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.asset(path, fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _salvarPersonagem(AppStateProvider state) async {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escolha um nome!'), backgroundColor: AppColors.error),
      );
      return;
    }

    _personagemEdicao.nome = nome;
    await state.savePersonagem(_personagemEdicao);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avatar salvo com sucesso!'), backgroundColor: AppColors.accent),
    );

    setState(() {
      _etapa = ETelaInicial.selecaoPersonagem;
    });
  }

  void _consultarPontuacao(Personagem p) {
    final state = context.read<AppStateProvider>();
    final history = state.getPontuacaoHistoryForActivePersonagem();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text('Histórico de Pontos: ${p.nome}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 500,
            height: MediaQuery.of(context).size.height * 0.5,
            child: history.isEmpty
                ? const Text('Nenhuma pontuação registrada para este avatar ainda.', style: TextStyle(fontSize: 16))
                : ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final score = history[index];
                      String title = score.atividade;
                      if (title == 'JOGO_ALFABETO') title = 'Alfabeto Manual';
                      if (title == 'JOGO_MEMORIA') title = 'Jogo da Memória';
                      if (title == 'JOGO_ADIVINHACAO') title = 'Jogo de Adivinhação';
                      if (title == 'JOGO_PALAVRAS') title = 'Jogo de Palavras';
                      
                      return ListTile(
                        leading: const Icon(Icons.stars_rounded, color: AppColors.secondary, size: 28),
                        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Acertos: ${score.acertos}  •  Erros: ${score.erros}\nDificuldade: ${score.dificuldade}'),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            )
          ],
        );
      },
    );
  }

  void _excluirPersonagem(AppStateProvider state, Personagem p) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: Text('Tem certeza que deseja excluir o avatar "${p.nome}"? Todo o progresso será perdido.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Não'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              onPressed: () async {
                Navigator.pop(context);
                await state.deletePersonagem(p.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Avatar excluído com sucesso.'), backgroundColor: AppColors.info),
                );
              },
              child: const Text('Sim'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final isCompact = ResponsiveLayout.isMobile(context);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double mascotSize = screenHeight < 550 ? 120.0 : 240.0;
    final double spacing = screenHeight < 550 ? 10.0 : 20.0;

    return Scaffold(
      appBar: const AppHeaderWidget(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/planeta_2.jpg'), // background aveludado
            fit: BoxFit.cover,
            opacity: 0.12,
          ),
          color: AppColors.bgSoft,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mascot Area (Dancing or Static)
                    GestureDetector(
                      onTap: _triggerMascotDance,
                      child: Tooltip(
                        message: 'Clique em mim!',
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _isMoving
                              ? Image.asset(
                                  'assets/raccoon/gif/victory-dance.gif',
                                  key: const ValueKey('raccoon-dance'),
                                  height: mascotSize,
                                  width: mascotSize,
                                )
                              : Image.asset(
                                  'assets/raccoon/raccoon.png',
                                  key: const ValueKey('raccoon-static'),
                                  height: mascotSize,
                                  width: mascotSize,
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: spacing),

                    // DYNAMIC STAGE VIEWER
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      child: _buildStageContent(state, isCompact),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStageContent(AppStateProvider state, bool isCompact) {
    switch (_etapa) {
      // ---------------- PADRAO ----------------
      case ETelaInicial.padrao:
        return Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            children: [
              // Botão Jogar
              _buildLargeButton(
                onPressed: () {
                  if (state.activePersonagem == null) {
                    if (state.personagens.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, crie um avatar antes de jogar!'),
                          backgroundColor: AppColors.secondary,
                        ),
                      );
                      setState(() {
                        _etapa = ETelaInicial.novoPersonagem;
                        _personagemEdicao = Personagem();
                        _nomeController.clear();
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, selecione um avatar para jogar!'),
                          backgroundColor: AppColors.secondary,
                        ),
                      );
                      setState(() {
                        _etapa = ETelaInicial.selecaoPersonagem;
                      });
                    }
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const JogoHubPage()),
                  );
                },
                label: 'Jogar',
                iconPath: 'assets/icons/controller.svg',
                fallbackIcon: Icons.play_circle_fill_rounded,
                isPulse: state.activePersonagem != null,
                color: AppColors.secondary,
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border, thickness: 2),
              const SizedBox(height: 16),

              // Botão Meu Avatar (Editar)
              if (state.activePersonagem != null) ...[
                _buildLargeButton(
                  onPressed: () {
                    setState(() {
                      _personagemEdicao = state.activePersonagem!.copyWith();
                      _nomeController.text = _personagemEdicao.nome;
                      _etapa = ETelaInicial.novoPersonagem;
                    });
                  },
                  label: 'Meu avatar (${state.activePersonagem!.nome})',
                  iconPath: 'assets/icons/account-circle.svg',
                  fallbackIcon: Icons.account_circle_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
              ],

              // Botão Novo Avatar
              _buildLargeButton(
                onPressed: () {
                  setState(() {
                    _personagemEdicao = Personagem();
                    _nomeController.clear();
                    _etapa = ETelaInicial.novoPersonagem;
                  });
                },
                label: 'Novo avatar',
                iconPath: 'assets/icons/person-add.svg',
                fallbackIcon: Icons.person_add_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),

              // Botão Selecionar Avatar
              _buildLargeButton(
                onPressed: () {
                  setState(() {
                    _etapa = ETelaInicial.selecaoPersonagem;
                  });
                },
                label: 'Selecionar avatar',
                iconPath: 'assets/icons/group-search.svg',
                fallbackIcon: Icons.people_rounded,
                color: AppColors.primary,
              ),
            ],
          ),
        );

      // ---------------- NOVO PERSONAGEM ----------------
      case ETelaInicial.novoPersonagem:
        return Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _personagemEdicao.id == null ? 'Criar Novo Avatar' : 'Editar Meu Avatar',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 20),

              // Avatar preview & Selector
              Center(
                child: GestureDetector(
                  onTap: _mudarAvatar,
                  child: Stack(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 4),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(_personagemEdicao.avatar, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Input Nome
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Avatar',
                  hintText: 'Escolha um nome divertido...',
                ),
              ),
              const SizedBox(height: 20),

              // Dificuldade RadioButtons
              const Text(
                'Dificuldade das Atividades:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: 8,
                runSpacing: 8,
                children: ['FACIL', 'MEDIO', 'DIFICIL'].map((diff) {
                  String label = 'Fácil';
                  if (diff == 'MEDIO') label = 'Médio';
                  if (diff == 'DIFICIL') label = 'Difícil';
                  
                  final isSelected = _personagemEdicao.dificuldade == diff;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _personagemEdicao.dificuldade = diff;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryLight.withOpacity(0.4) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primary : AppColors.textDark.withOpacity(0.7),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Score button if editing
              if (_personagemEdicao.id != null) ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.secondary, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _consultarPontuacao(_personagemEdicao),
                  icon: const Icon(Icons.bar_chart_rounded, color: AppColors.secondary),
                  label: const Text('Consultar Pontuação', style: TextStyle(color: AppColors.secondary)),
                ),
                const SizedBox(height: 20),
              ],

              // Ações Voltar / Salvar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        side: const BorderSide(color: AppColors.border, width: 2),
                      ),
                      onPressed: () {
                        setState(() {
                          _etapa = ETelaInicial.padrao;
                        });
                      },
                      child: const Text('Voltar', style: TextStyle(color: AppColors.textDark)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _salvarPersonagem(state),
                      child: const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      // ---------------- SELECAO PERSONAGEM ----------------
      case ETelaInicial.selecaoPersonagem:
        return Container(
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Quem vai jogar agora?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 16),

              if (state.personagens.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Text(
                    'Nenhum avatar cadastrado ainda. Crie um novo avatar para começar!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.textDark),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.personagens.length,
                    itemBuilder: (context, index) {
                      final p = state.personagens[index];
                      final isActive = state.activePersonagem?.id == p.id;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primaryLight.withOpacity(0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive ? AppColors.primary : AppColors.border,
                            width: 2.5,
                          ),
                        ),
                        child: ListTile(
                          onTap: () async {
                            await state.selectPersonagem(p);
                            setState(() {
                              _etapa = ETelaInicial.padrao;
                            });
                          },
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(p.avatar),
                          ),
                          title: Text(
                            p.nome,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text('Dificuldade: ${p.dificuldade}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                            onPressed: () => _excluirPersonagem(state, p),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () {
                  setState(() {
                    _etapa = ETelaInicial.padrao;
                  });
                },
                child: const Text('Voltar'),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildLargeButton({
    required VoidCallback onPressed,
    required String label,
    required String iconPath,
    required IconData fallbackIcon,
    required Color color,
    bool isPulse = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            // Playful circular icon wrapper
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                fallbackIcon,
                color: color,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
