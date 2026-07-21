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
          opcoes: item.opcoes.isNotEmpty ? item.opcoes : [item.descricao, 'Opção 2', 'Opção 3'],
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

    _iniciarRodada();
  }


  void _iniciarRodada() {
    if (_palavras.isEmpty) return;

    final random = Random();
    final palavraSorteada = _palavras[random.nextInt(_palavras.length)];
    final state = context.read<AppStateProvider>();
    final dificuldade = state.activePersonagem?.dificuldade ?? 'FACIL';

    // Monta opções baseadas na palavra sorteada e na dificuldade
    final List<String> listOpcoesTemp = [...palavraSorteada.opcoes];
    
    // Garante que a palavra correta está nas opções
    if (!listOpcoesTemp.contains(palavraSorteada.descricao)) {
      listOpcoesTemp.add(palavraSorteada.descricao);
    }

    // Embaralha as opções
    listOpcoesTemp.shuffle();

    // Limita as opções de acordo com a dificuldade
    int limite = listOpcoesTemp.length;
    if (dificuldade == 'FACIL') {
      limite = 3;
    } else if (dificuldade == 'MEDIO') {
      limite = 4;
    }

    var listOpcoesFinal = listOpcoesTemp.take(limite).toList();

    // Garante denovo que a correta foi mantida na lista truncada
    if (!listOpcoesFinal.contains(palavraSorteada.descricao)) {
      listOpcoesFinal.removeLast();
      listOpcoesFinal.add(palavraSorteada.descricao);
      listOpcoesFinal.shuffle();
    }

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
      state.salvaPontuacao(_acertosCount, _errosCount, 'JOGO_PALAVRAS');
    } else {
      setState(() {
        opcaoSelected.pendente = false;
        _errosCount++;
        _feedback = 'ERRO';
      });
      state.salvaPontuacao(_acertosCount, _errosCount, 'JOGO_PALAVRAS');
    }
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header de Pontuação
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
            child: Image.asset(
              _selectedPalavra!.imagem,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported_rounded,
                  size: 80,
                  color: AppColors.primaryLight,
                );
              },
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
