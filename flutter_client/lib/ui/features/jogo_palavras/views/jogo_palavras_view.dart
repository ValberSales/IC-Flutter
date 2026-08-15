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
import '../view_models/jogo_palavras_view_model.dart';
import '../widgets/palavra_opcao_button.dart';

class JogoPalavrasView extends StatefulWidget {
  final Atividade? atividadeTema;
  final String? dificuldade;

  const JogoPalavrasView({
    super.key,
    this.atividadeTema,
    this.dificuldade,
  });

  @override
  State<JogoPalavrasView> createState() => _JogoPalavrasViewState();
}

class _JogoPalavrasViewState extends State<JogoPalavrasView> {
  late JogoPalavrasViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppStateProvider>();
    _viewModel = JogoPalavrasViewModel(
      appState: appState,
      atividadeTema: widget.atividadeTema,
      dificuldade: widget.dificuldade,
    );
  }

  bool _dialogShowing = false;

  void _exibirCelebracaoConclusao() {
    if (_dialogShowing) return;
    _dialogShowing = true;

    final diff = _viewModel.dificuldade;
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
            totalAcertos: _viewModel.acertosCount,
            totalErros: _viewModel.errosCount,
            onVoltarTema: () {
              Navigator.of(context).pop();
            },
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
      child: Consumer<JogoPalavrasViewModel>(
        builder: (context, vm, _) {
          if (vm.isMatchComplete) {
            _exibirCelebracaoConclusao();
          }

          if (vm.selectedPalavra == null) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          final isCompact = ResponsiveLayout.isMobile(context);
          final dificuldade = vm.dificuldade;
          final correta = vm.selectedPalavra!.descricao;

          if (isCompact) {
            return Scaffold(
              backgroundColor: AppColors.bgSoft,
              body: SafeArea(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PontuacaoHeaderWidget(
                            acertos: vm.acertosCount,
                            erros: vm.errosCount,
                            atividade: 'JOGO_PALAVRAS',
                          ),
                          const SizedBox(height: 8),
                          JogoBreadcrumbWidget(
                            nomeJogo: 'Jogo de Palavras',
                            tema: widget.atividadeTema?.titulo ?? 'Membros da Família',
                            dificuldade: dificuldade,
                          ),
                          const SizedBox(height: 6),
                          Center(
                            child: MascoteFeedbackWidget(
                              feedbackType: vm.feedback,
                              clearFeedback: vm.clearFeedback,
                              scale: 0.65,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 220),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: AppColors.border, width: 2),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: DynamicImageWidget(
                                imagePath: vm.selectedPalavra!.imagem,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...List.generate(vm.opcoes.length, (index) {
                            final op = vm.opcoes[index];
                            return PalavraOpcaoButton(
                              opcao: op,
                              isAcerto: vm.acerto,
                              palavraCorreta: correta,
                              onTap: () => vm.selectOpcao(index),
                            );
                          }),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                    if (vm.acerto) _buildNextButton(),
                  ],
                ),
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: AppColors.bgSoft,
              body: SafeArea(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          PontuacaoHeaderWidget(
                            acertos: vm.acertosCount,
                            erros: vm.errosCount,
                            atividade: 'JOGO_PALAVRAS',
                          ),
                          const SizedBox(height: 12),
                          JogoBreadcrumbWidget(
                            nomeJogo: 'Jogo de Palavras',
                            tema: widget.atividadeTema?.titulo ?? 'Membros da Família',
                            dificuldade: dificuldade,
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                      side: const BorderSide(color: AppColors.border, width: 2),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Center(
                                            child: Container(
                                              constraints: const BoxConstraints(maxWidth: 360, maxHeight: 260),
                                              decoration: BoxDecoration(
                                                color: AppColors.bgSoft,
                                                borderRadius: BorderRadius.circular(24),
                                                border: Border.all(color: AppColors.secondary, width: 3.5),
                                              ),
                                              padding: const EdgeInsets.all(16),
                                              child: DynamicImageWidget(
                                                imagePath: vm.selectedPalavra!.imagem,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: MascoteFeedbackWidget(
                                              feedbackType: vm.feedback,
                                              clearFeedback: vm.clearFeedback,
                                              scale: 0.8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                // Coluna da Direita (Opções de Palavras)
                                Expanded(
                                  flex: 2,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                      side: const BorderSide(color: AppColors.border, width: 2),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Selecione a palavra correta:',
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.textDark,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 24),
                                          ...List.generate(vm.opcoes.length, (index) {
                                            final op = vm.opcoes[index];
                                            return PalavraOpcaoButton(
                                              opcao: op,
                                              isAcerto: vm.acerto,
                                              palavraCorreta: correta,
                                              onTap: () => vm.selectOpcao(index),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (vm.acerto) _buildNextButton(),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
