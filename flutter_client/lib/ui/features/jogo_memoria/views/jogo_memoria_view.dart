import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/util/responsive_layout.dart';
import '../../../../state/app_state_provider.dart';
import '../../../core/celebracao_conclusao_dialog.dart';
import '../../../core/jogo_breadcrumb_widget.dart';
import '../../../core/mascote_feedback_widget.dart';
import '../../../core/pontuacao_header_widget.dart';
import '../../../core/tutorial_widget.dart';
import '../view_models/jogo_memoria_view_model.dart';
import '../widgets/memoria_card_widget.dart';

class JogoMemoriaView extends StatefulWidget {
  final String? dificuldade;

  const JogoMemoriaView({super.key, this.dificuldade});

  @override
  State<JogoMemoriaView> createState() => _JogoMemoriaViewState();
}

class _JogoMemoriaViewState extends State<JogoMemoriaView> {
  late JogoMemoriaViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppStateProvider>();
    _viewModel = JogoMemoriaViewModel(
      appState: appState,
      dificuldade: widget.dificuldade,
    );
  }

  void _exibirCelebracao() {
    final diff = _viewModel.dificuldade;
    Future.microtask(() {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => CelebracaoConclusaoDialog(
            nomeTema: 'Alfabeto em Libras',
            jogoNome: 'Jogo da Memória',
            dificuldade: diff,
            totalAcertos: _viewModel.acertosCount,
            totalErros: _viewModel.errosCount,
            onVoltarTema: () => Navigator.of(context).pop(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = ResponsiveLayout.isMobile(context);

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<JogoMemoriaViewModel>(
        builder: (context, vm, _) {
          if (vm.endGame) {
            _exibirCelebracao();
          }

          final diff = vm.dificuldade;

          return Scaffold(
            backgroundColor: AppColors.bgSoft,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  children: [
                    // 1. Barra de Navegação e Pontuação no Topo
                    PontuacaoHeaderWidget(
                      acertos: vm.acertosCount,
                      erros: vm.errosCount,
                      atividade: 'JOGO_MEMORIA',
                    ),
                    const SizedBox(height: 8),
                    // 2. Breadcrumb Card
                    JogoBreadcrumbWidget(
                      nomeJogo: 'Jogo da Memória',
                      tema: 'Alfabeto em Libras',
                      dificuldade: diff,
                    ),
                    const SizedBox(height: 6),
                    // 3. Mascote Feedback Centralizado
                    Center(
                      child: MascoteFeedbackWidget(
                        feedbackType: vm.feedback,
                        clearFeedback: vm.clearFeedback,
                        scale: 0.65,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: vm.cartas.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isCompact ? 3 : 5,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: vm.cartas.length,
                              itemBuilder: (context, index) {
                                final carta = vm.cartas[index];
                                return MemoriaCardWidget(
                                  carta: carta,
                                  onTap: () => vm.revelarCarta(carta),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
