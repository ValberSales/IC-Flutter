import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'mascote_feedback_widget.dart';

class CelebracaoConclusaoDialog extends StatelessWidget {
  final String nomeTema;
  final String jogoNome;
  final String dificuldade;
  final int totalAcertos;
  final int totalErros;
  final VoidCallback onVoltarTema;

  const CelebracaoConclusaoDialog({
    super.key,
    required this.nomeTema,
    required this.jogoNome,
    required this.dificuldade,
    required this.totalAcertos,
    required this.totalErros,
    required this.onVoltarTema,
  });

  String get _diffLabel {
    switch (dificuldade) {
      case 'MEDIO':
        return 'Médio ✨';
      case 'DIFICIL':
        return 'Difícil 🔥';
      default:
        return 'Fácil 🌟';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animação de Entrada do Ícone/Troféu
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, val, child) {
                return Transform.scale(
                  scale: val,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.accentLight.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 3),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 72,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              '🎉 PARABÉNS! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                fontFamily: 'Fredoka',
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Você concluiu 100% das palavras do tema "$nomeTema" no Nível $_diffLabel!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: AppColors.textDark.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 20),

            // Mascote em Modo Comemoração
            MascoteFeedbackWidget(
              feedbackType: 'ACERTO',
              clearFeedback: () {},
              scale: 0.8,
            ),
            const SizedBox(height: 20),

            // Placar Final
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgSoft,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: (jogoNome.toLowerCase().contains('memória') || jogoNome.toLowerCase().contains('memoria'))
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 28),
                        SizedBox(width: 10),
                        Text(
                          'Conclusão: 100%',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.secondary),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Acertos',
                              style: TextStyle(fontSize: 13, color: AppColors.textDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$totalAcertos',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.accent),
                            ),
                          ],
                        ),
                        Container(width: 1, height: 32, color: AppColors.border),
                        Column(
                          children: [
                            const Text(
                              'Erros',
                              style: TextStyle(fontSize: 13, color: AppColors.textDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$totalErros',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.error),
                            ),
                          ],
                        ),
                        Container(width: 1, height: 32, color: AppColors.border),
                        Column(
                          children: [
                            const Text(
                              'Conclusão',
                              style: TextStyle(fontSize: 13, color: AppColors.textDark),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              '100%',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.secondary),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),

            // Botão Principal: Voltar ao Seletor de Temas
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 6,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onVoltarTema();
                },
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                label: const Text(
                  'Voltar aos Temas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
