import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/util/responsive_layout.dart';
import '../../../../state/app_state_provider.dart';
import '../../../core/celebracao_conclusao_dialog.dart';
import '../../../core/jogo_breadcrumb_widget.dart';
import '../../../core/mascote_feedback_widget.dart';
import '../../../core/pontuacao_header_widget.dart';
import '../view_models/jogo_alfabeto_view_model.dart';
import '../widgets/alfabeto_sign_button.dart';

class JogoAlfabetoView extends StatefulWidget {
  final String? dificuldade;

  const JogoAlfabetoView({super.key, this.dificuldade});

  @override
  State<JogoAlfabetoView> createState() => _JogoAlfabetoViewState();
}

class _JogoAlfabetoViewState extends State<JogoAlfabetoView> {
  late JogoAlfabetoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppStateProvider>();
    _viewModel = JogoAlfabetoViewModel(
      appState: appState,
      dificuldade: widget.dificuldade,
    );
  }

  bool _dialogShowing = false;

  void _exibirCelebracao() {
    if (_dialogShowing) return;
    _dialogShowing = true;

    final diff = _viewModel.dificuldade;
    Future.microtask(() {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => CelebracaoConclusaoDialog(
            nomeTema: 'Alfabeto Manual',
            jogoNome: 'Alfabeto Manual',
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
              shadowColor: AppColors.secondary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: _viewModel.iniciarNovoJogo,
            icon: const Icon(Icons.replay_rounded, size: 28, color: Colors.white),
            label: const Text(
              'Próxima Letra!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = ResponsiveLayout.isMobile(context);

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<JogoAlfabetoViewModel>(
        builder: (context, vm, _) {
          if (vm.isMatchComplete) {
            _exibirCelebracao();
          }

          if (vm.letraSorteada == null) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          final diff = vm.dificuldade;
          final letraCorreta = vm.letraSorteada!['letra']!;

          return Scaffold(
            backgroundColor: AppColors.bgSoft,
            body: SafeArea(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Barra de Navegação e Pontuação no Topo
                        PontuacaoHeaderWidget(
                          acertos: vm.acertosCount,
                          erros: vm.errosCount,
                          atividade: 'JOGO_ALFABETO',
                        ),
                        const SizedBox(height: 8),
                        // 2. Breadcrumb Card
                        JogoBreadcrumbWidget(
                          nomeJogo: 'Alfabeto Manual',
                          tema: 'Letras e Sinais',
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
                        Center(
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.primary, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              letraCorreta,
                              style: const TextStyle(
                                fontSize: 68,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Qual é o sinal desta letra em Libras?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 800),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isCompact ? vm.opcoes.length : vm.opcoes.length,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.85,
                                ),
                                itemCount: vm.opcoes.length,
                                itemBuilder: (context, index) {
                                  final op = vm.opcoes[index];
                                  return AlfabetoSignButton(
                                    opcao: op,
                                    isAcerto: vm.acerto,
                                    letraCorreta: letraCorreta,
                                    onTap: () => vm.verificarResposta(op),
                                  );
                                },
                              ),
                            ),
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
        },
      ),
    );
  }
}
