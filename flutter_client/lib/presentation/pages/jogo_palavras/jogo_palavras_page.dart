import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/util/responsive_layout.dart';
import '../../../data/models/palavra.dart';
import '../../../data/sources/local_data_source.dart';
import '../../../state/app_state_provider.dart';
import '../../widgets/pontuacao_header_widget.dart';
import '../../widgets/mascote_feedback_widget.dart';
import '../../widgets/tutorial_widget.dart';
import '../../widgets/jogo_breadcrumb_widget.dart';
import '../../widgets/dynamic_image_widget.dart';
import '../../widgets/celebracao_conclusao_dialog.dart';

import '../../../data/models/atividade.dart';

class OpcaoPalavra {
  final String palavra;
  bool pendente;

  OpcaoPalavra({required this.palavra, this.pendente = true});
}

class JogoPalavrasPage extends StatefulWidget {
  final Atividade? atividadeTema;

  const JogoPalavrasPage({
    super.key,
    this.atividadeTema,
  });

  @override
  State<JogoPalavrasPage> createState() => _JogoPalavrasPageState();
}

class _JogoPalavrasPageState extends State<JogoPalavrasPage> {
  List<Palavra> _palavras = [];
  List<Palavra> _palavrasFila = [];
  int _currentWordIndex = 0;

  Palavra? _selectedPalavra;
  List<OpcaoPalavra> _opcoes = [];
  
  bool _acerto = false;
  String _feedback = 'VAZIO';
  int _acertosCount = 0;
  int _errosCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarPalavras();
    });
  }

  void _carregarPalavras() {
    final state = context.read<AppStateProvider>();
    
    if (widget.atividadeTema != null && widget.atividadeTema!.itens.isNotEmpty) {
      _palavras = widget.atividadeTema!.itens.map((item) {
        return Palavra(
          tipo: 'JOGO_PALAVRAS',
          descricao: item.descricao,
          imagem: item.imagem,
          opcoes: item.opcoes,
        );
      }).toList();
    } else if (state.customPalavras.isNotEmpty) {
      _palavras = state.customPalavras.where((p) => p.tipo == 'JOGO_PALAVRAS').toList();
    }
    
    // Se não houver palavras da turma, usa a lista mockada (Família)
    if (_palavras.isEmpty) {
      _palavras = LocalDataSource.familiaPadrao.map((item) {
        return Palavra(
          tipo: 'JOGO_PALAVRAS',
          descricao: item['descricao']!,
          imagem: item['imagem']!,
          opcoes: List<String>.from(item['opcoes']),
        );
      }).toList();
    }

    final diff = state.activePersonagem?.dificuldade ?? 'FACIL';
    final String temaNome = widget.atividadeTema?.titulo ?? 'Membros da Família';
    final completedWords = state.getCompletedWordsForTema(
      jogo: 'JOGO_PALAVRAS',
      tema: widget.atividadeTema,
      temaNomePadrao: temaNome,
      dificuldade: diff,
    );

    final uncompleted = _palavras.where((p) => !completedWords.contains(p.descricao)).toList();
    if (uncompleted.isNotEmpty) {
      _palavrasFila = List<Palavra>.from(uncompleted)..shuffle(Random());
    } else {
      _palavrasFila = List<Palavra>.from(_palavras)..shuffle(Random());
    }

    _currentWordIndex = 0;

    _iniciarRodada();
  }

  void _exibirCelebracaoConclusao() {
    final state = context.read<AppStateProvider>();
    final diff = state.activePersonagem?.dificuldade ?? 'FACIL';
    final String temaNome = widget.atividadeTema?.titulo ?? 'Membros da Família';

    Future.microtask(() {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => CelebracaoConclusaoDialog(
            nomeTema: temaNome,
            jogoNome: 'Jogo de Palavras',
            dificuldade: diff,
            totalAcertos: _acertosCount,
            totalErros: _errosCount,
            onVoltarTema: () {
              Navigator.of(context).pop();
            },
          ),
        );
      }
    });
  }

  void _iniciarRodada() {
    if (_palavrasFila.isEmpty) return;

    if (_currentWordIndex >= _palavrasFila.length) {
      _exibirCelebracaoConclusao();
      return;
    }

    final palavraSorteada = _palavrasFila[_currentWordIndex];
    _currentWordIndex++;

    final random = Random();
    final state = context.read<AppStateProvider>();
    final dificuldade = state.activePersonagem?.dificuldade ?? 'FACIL';

    // Determina número total de opções com base na dificuldade do perfil do aluno
    int totalOpcoes = 3;
    if (dificuldade == 'MEDIO') {
      totalOpcoes = 4;
    } else if (dificuldade == 'DIFICIL') {
      totalOpcoes = 5;
    }

    // Coleta banco global de palavras/descrições para usar como distratores reais
    final Set<String> distractorPool = {};
    for (final p in _palavras) {
      if (p.descricao.trim().isNotEmpty) {
        distractorPool.add(p.descricao.trim());
      }
    }
    for (final at in state.atividades) {
      for (final item in at.itens) {
        if (item.descricao.trim().isNotEmpty) {
          distractorPool.add(item.descricao.trim());
        }
      }
    }
    for (final item in LocalDataSource.familiaPadrao) {
      distractorPool.add(item['descricao']!);
    }
    for (final item in LocalDataSource.animaisPadrao) {
      distractorPool.add(item['descricao']!);
    }

    // Remove a resposta correta da lista de distratores
    final String correta = palavraSorteada.descricao.trim();
    distractorPool.remove(correta);

    final List<String> distractors = distractorPool.toList()..shuffle(random);
    final int qtdDistratores = totalOpcoes - 1;
    final List<String> distratoresSelecionados = distractors.take(qtdDistratores).toList();

    final List<String> listOpcoesFinal = [correta, ...distratoresSelecionados]..shuffle(random);

    setState(() {
      _selectedPalavra = palavraSorteada;
      _opcoes = listOpcoesFinal.map((p) => OpcaoPalavra(palavra: p)).toList();
      _acerto = false;
      _feedback = 'VAZIO';
    });
  }

  void _verificarResposta(OpcaoPalavra opcaoSelected) {
    if (_acerto || !opcaoSelected.pendente) return;

    final state = context.read<AppStateProvider>();

    if (opcaoSelected.palavra == _selectedPalavra?.descricao) {
      setState(() {
        _acerto = true;
        _acertosCount++;
        _feedback = 'ACERTO';
      });

      final diff = state.activePersonagem?.dificuldade ?? 'FACIL';
      final String temaNome = widget.atividadeTema?.titulo ?? 'Membros da Família';
      state.registrarPalavraConcluida(
        jogo: 'JOGO_PALAVRAS',
        tema: widget.atividadeTema,
        temaNomePadrao: temaNome,
        palavra: _selectedPalavra!.descricao,
        dificuldade: diff,
      );

      final bool isMatchComplete = _currentWordIndex >= _palavrasFila.length;

      state.salvaPontuacao(
        _acertosCount,
        _errosCount,
        'JOGO_PALAVRAS',
        tema: temaNome,
        concluido: isMatchComplete,
      );

      if (isMatchComplete) {
        _exibirCelebracaoConclusao();
      }
    } else {
      final String temaNome = widget.atividadeTema?.titulo ?? 'Membros da Família';
      setState(() {
        opcaoSelected.pendente = false;
        _errosCount++;
        _feedback = 'ERRO';
      });
      state.salvaPontuacao(
        _acertosCount,
        _errosCount,
        'JOGO_PALAVRAS',
        tema: temaNome,
        concluido: false,
      );
    }
  }

  Widget _buildHeader() {
    final state = context.watch<AppStateProvider>();
    final diff = state.activePersonagem?.dificuldade ?? 'FACIL';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        JogoBreadcrumbWidget(
          nomeJogo: 'Jogo de Palavras',
          tema: widget.atividadeTema?.titulo ?? 'Membros da Família',
          dificuldade: diff,
        ),
        PontuacaoHeaderWidget(
          acertos: _acertosCount,
          erros: _errosCount,
          atividade: 'JOGO_PALAVRAS',
        ),
        const SizedBox(height: 12),

        // Ajuda e Mascot
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const TutorialWidget(atividade: 'JOGO_PALAVRAS'),
            MascoteFeedbackWidget(
              feedbackType: _feedback,
              clearFeedback: () {
                setState(() {
                  _feedback = 'VAZIO';
                });
              },
              scale: 0.65,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageWidget({double? height}) {
    return Center(
      child: Container(
        height: height,
        constraints: height == null ? const BoxConstraints(maxWidth: 320, maxHeight: 260) : null,
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.info, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: DynamicImageWidget(
              imagePath: _selectedPalavra!.imagem,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridOpcoes(bool isCompact, {required bool isScrollable}) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: GridView.builder(
          shrinkWrap: true,
          physics: isScrollable ? const NeverScrollableScrollPhysics() : null,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isCompact ? 1 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isCompact ? 5.5 : 4,
          ),
          itemCount: _opcoes.length,
          itemBuilder: (context, index) {
            final opcao = _opcoes[index];
            final isCorrect = opcao.palavra == _selectedPalavra?.descricao && _acerto;
            
            Color btnColor = Colors.white;
            Color txtColor = AppColors.textDark;
            BorderSide border = const BorderSide(color: AppColors.border, width: 2);
            Widget? overlay;

            if (isCorrect) {
              btnColor = AppColors.accentLight.withOpacity(0.4);
              txtColor = AppColors.accent;
              border = const BorderSide(color: AppColors.accent, width: 3);
              overlay = const Icon(Icons.check_circle_rounded, color: AppColors.accent);
            } else if (!opcao.pendente) {
              btnColor = AppColors.errorLight.withOpacity(0.4);
              txtColor = AppColors.error;
              border = const BorderSide(color: AppColors.error, width: 3);
              overlay = const Icon(Icons.close_rounded, color: AppColors.error);
            }

            return InkWell(
              onTap: () => _verificarResposta(opcao),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: btnColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.fromBorderSide(border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        opcao.palavra,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: txtColor,
                        ),
                      ),
                    ),
                    if (overlay != null) overlay,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSoft,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = ResponsiveLayout.isMobile(context);
            // If the screen is too small in height, we use a scrollable layout
            // to avoid rendering overflow errors.
            final bool useScrollLayout = constraints.maxHeight < 680;

            Widget content;
            if (useScrollLayout) {
              content = SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 12),
                    if (_selectedPalavra != null) ...[
                      _buildImageWidget(height: 180),
                      const SizedBox(height: 16),
                      _buildGridOpcoes(isCompact, isScrollable: true),
                      const SizedBox(height: 100), // extra padding so button doesn't cover options
                    ],
                  ],
                ),
              );
            } else {
              content = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 12),
                  if (_selectedPalavra != null) ...[
                    Expanded(
                      flex: isCompact ? 3 : 4,
                      child: _buildImageWidget(),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      flex: isCompact ? 3 : 2,
                      child: _buildGridOpcoes(isCompact, isScrollable: false),
                    ),
                  ],
                ],
              );
            }

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: content,
                ),

                // Botão "Jogar" (Próxima rodada) flutuante quando acerta
                if (_acerto)
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                            elevation: 8,
                            shadowColor: AppColors.secondary.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _iniciarRodada,
                          icon: const Icon(Icons.replay_rounded, size: 28, color: Colors.white),
                          label: const Text(
                            'Próxima Foto!',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
