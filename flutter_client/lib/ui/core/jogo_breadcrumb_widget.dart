import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class JogoBreadcrumbWidget extends StatelessWidget {
  final String nomeJogo;
  final String? tema;
  final String? dificuldade;

  const JogoBreadcrumbWidget({
    super.key,
    required this.nomeJogo,
    this.tema,
    this.dificuldade,
  });

  String _formatDificuldade(String? diff) {
    if (diff == null) return 'Fácil 🌟';
    switch (diff.toUpperCase()) {
      case 'MEDIO':
      case 'MÉDIO':
        return 'Médio ✨';
      case 'DIFICIL':
      case 'DIFÍCIL':
        return 'Difícil 🔥';
      default:
        return 'Fácil 🌟';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        spacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sports_esports_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                nomeJogo,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          if (tema != null && tema!.isNotEmpty) ...[
            Text(
              '•',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey.shade400,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.style_rounded, size: 16, color: AppColors.secondary),
                const SizedBox(width: 4),
                Text(
                  'Tema: $tema',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textDark.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
          Text(
            '•',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey.shade400,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Nível: ${_formatDificuldade(dificuldade)}',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
