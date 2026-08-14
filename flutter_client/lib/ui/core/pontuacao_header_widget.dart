import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../state/app_state_provider.dart';
import 'tutorial_widget.dart';

class PontuacaoHeaderWidget extends StatelessWidget {
  final int acertos;
  final int erros;
  final String atividade;

  const PontuacaoHeaderWidget({
    super.key,
    required this.acertos,
    required this.erros,
    required this.atividade,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final activeChar = state.activePersonagem;
    
    // Check if tablet or web for responsive sizing
    final isCompact = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10.0 : 20.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botões de Ação (Home + Como Jogar)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botão Home
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.home_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                tooltip: 'Voltar para o Início',
              ),
              const SizedBox(width: 8),
              // Botão Como Jogar (Ícone)
              TutorialWidget(
                atividade: atividade,
                isIconOnly: true,
              ),
            ],
          ),
          
          // Personagem Ativo (Avatar + Nome)
          if (activeChar != null)
            Row(
              children: [
                CircleAvatar(
                  radius: isCompact ? 18 : 24,
                  backgroundImage: AssetImage(activeChar.avatar),
                  backgroundColor: AppColors.primaryLight,
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 8),
                  Text(
                    activeChar.nome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ],
            )
          else
            const SizedBox(),

          // Painel de Pontuação (Acertos e Erros)
          Row(
            children: [
              // Acertos
              _buildScoreBadge(
                context: context,
                label: 'Acertos',
                value: acertos,
                color: AppColors.accent,
                icon: Icons.star_rounded,
                isCompact: isCompact,
              ),
              const SizedBox(width: 8),
              // Erros
              _buildScoreBadge(
                context: context,
                label: 'Erros',
                value: erros,
                color: AppColors.error,
                icon: Icons.sentiment_very_dissatisfied_rounded,
                isCompact: isCompact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBadge({
    required BuildContext context,
    required String label,
    required int value,
    required Color color,
    required IconData icon,
    required bool isCompact,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 14,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isCompact ? 18 : 22),
          const SizedBox(width: 4),
          if (!isCompact)
            Text(
              '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.textDark.withOpacity(0.7),
              ),
            ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: Text(
              '$value',
              key: ValueKey<int>(value),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: isCompact ? 14 : 16,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
