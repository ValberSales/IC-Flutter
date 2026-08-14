import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/util/responsive_layout.dart';
import '../../../../data/models/atividade.dart';
import '../../../../state/app_state_provider.dart';
import '../../../core/celebracao_conclusao_dialog.dart';
import '../../../core/dynamic_image_widget.dart';
import '../../../core/jogo_breadcrumb_widget.dart';
import '../../../core/mascote_feedback_widget.dart';
import '../../../core/pontuacao_header_widget.dart';
import '../../../core/tutorial_widget.dart';
import '../view_models/jogo_adivinhacao_view_model.dart';
import '../widgets/adivinhacao_header_delegate.dart';
import '../widgets/adivinhacao_sign_card.dart';
import '../widgets/adivinhacao_slots_widget.dart';

class JogoAdivinhacaoView extends StatefulWidget {
  final Atividade? atividadeTema;
  final String? dificuldade;

  const JogoAdivinhacaoView({
    super.key,
    this.atividadeTema,
    this.dificuldade,
  });

  @override
  State<JogoAdivinhacaoView> createState() => _JogoAdivinhacaoViewState();
}

class _JogoAdivinhacaoViewState extends State<JogoAdivinhacaoView> {
  late JogoAdivinhacaoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppStateProvider>();
    _viewModel = JogoAdivinhacaoViewModel(
      appState: appState,
      atividadeTema: widget.atividadeTema,
      dificuldade: widget.dificuldade,
    );
  }

  void _exibirCelebracaoConclusao() {
    final diff = _viewModel.dificuldade;
    final String temaNome = widget.atividadeTema?.titulo ?? 'Animais da Natureza';

    Future.microtask(() {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => CelebracaoConclusaoDialog(
            nomeTema: temaNome,
            jogoNome: 'Jogo de Adivinhação',
            dificuldade: diff,
            totalAcertos: _viewModel.acertosCount,
            totalErros: _viewModel.errosCount,
            onVoltarTema: () => Navigator.of(context).pop(),
          ),
        );
      }
    });
  }

  Widget _buildNextButton() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, value, child) => Transform.scale(scale: value, child: child),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              elevation: 8,
              shadowColor: AppColors.secondary.withOpacity(0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: _viewModel.iniciarRodada,
            icon: const Icon(Icons.replay_rounded, size: 28, color: Colors.white),
            label: const Text(
              'Próxima Palavra!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<JogoAdivinhacaoViewModel>(
        builder: (context, vm, _) {
          if (vm.isMatchComplete) {
            _exibirCelebracaoConclusao();
          }

          if (vm.selectedPalavra == null) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          final double screenWidth = MediaQuery.of(context).size.width;
          final isCompact = screenWidth < 600;
          final appState = vm.appState;
          final dificuldade = vm.dificuldade;
          final bool dicaLetra = dificuldade == 'FACIL';
          final List<Map<String, String>> alfabetoGrid =
              vm.displayedAlfabeto.isNotEmpty ? vm.displayedAlfabeto : appState.currentAlfabeto;
          final int crossCount = screenWidth > 860 ? 6 : (screenWidth > 600 ? 5 : 4);

          return Scaffold(
            backgroundColor: AppColors.bgSoft,
            body: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 840),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isCompact ? 16.0 : 24.0,
                              vertical: 6.0,
                            ),
                            child: Column(
                              children: [
                                // 1. Barra de Navegação e Pontuação no Topo (com Home e Como Jogar)
                                PontuacaoHeaderWidget(
                                  acertos: vm.acertosCount,
                                  erros: vm.errosCount,
                                  atividade: 'JOGO_ADIVINHACAO',
                                ),
                                const SizedBox(height: 6),
                                // 2. Breadcrumb Card (Onde estamos atualmente)
                                JogoBreadcrumbWidget(
                                  nomeJogo: 'Jogo de Adivinhação',
                                  tema: widget.atividadeTema?.titulo ?? 'Animais da Natureza',
                                  dificuldade: dificuldade,
                                ),
                                const SizedBox(height: 6),
                                // 3. Mascote Feedback Centralizado no Espaço Liberado
                                Center(
                                  child: MascoteFeedbackWidget(
                                    feedbackType: vm.feedback,
                                    clearFeedback: vm.clearFeedback,
                                    scale: isCompact ? 0.65 : 0.78,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: CustomScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              slivers: [
                                SliverPersistentHeader(
                                  pinned: true,
                                  delegate: AdivinhacaoHeaderDelegate(
                                    palavra: vm.selectedPalavra!,
                                    letrasPalavra: vm.letrasPalavra,
                                    letrasPreenchidas: vm.letrasPreenchidas,
                                    slotValidation: vm.slotValidation,
                                    activeIndex: vm.activeSlotIndex,
                                    onSlotTapped: vm.setActiveSlot,
                                    onClearTapped: vm.limparPalavra,
                                    feedback: vm.feedback,
                                    isCompact: isCompact,
                                    difficulty: dificuldade,
                                  ),
                                ),
                                SliverPadding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isCompact ? 16.0 : 24.0,
                                    vertical: 16.0,
                                  ),
                                  sliver: SliverGrid(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossCount,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 0.84,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final item = alfabetoGrid[index];
                                        return AdivinhacaoSignCard(
                                          item: item,
                                          dicaLetra: dicaLetra,
                                          onTap: () => vm.selectLetra(item),
                                        );
                                      },
                                      childCount: alfabetoGrid.length,
                                    ),
                                  ),
                                ),
                                const SliverToBoxAdapter(child: SizedBox(height: 80)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (vm.endGame) _buildNextButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
