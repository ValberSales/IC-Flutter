import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class GameCategoryCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final String? badgeText;
  final String currentDiff;
  final ValueChanged<String> onDiffChanged;
  final double pctConclusao;
  final double? pctAcertos;
  final VoidCallback onPlay;

  const GameCategoryCardWidget({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    this.badgeText,
    required this.currentDiff,
    required this.onDiffChanged,
    required this.pctConclusao,
    required this.pctAcertos,
    required this.onPlay,
  });

  Widget _buildBadge(Color badgeColor, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: badgeColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: badgeColor,
          fontFamily: 'Fredoka',
        ),
      ),
    );
  }

  Widget _buildDiffChip(
    String code,
    String label,
    String currentDiff,
    ValueChanged<String> onChanged,
    Color activeColor,
  ) {
    final isSelected = currentDiff == code;

    return Expanded(
      child: InkWell(
        onTap: () => onChanged(code),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : activeColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: activeColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                fontFamily: 'Fredoka',
                color: isSelected ? Colors.white : activeColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: color.withOpacity(0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Header: Ícone e Badge Pill nos extremos
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    if (badgeText != null) _buildBadge(color, badgeText!),
                  ],
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Fredoka',
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.25,
                    color: AppColors.textDark.withOpacity(0.75),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Seletor de Dificuldade Individual com Botões
            Row(
              children: [
                _buildDiffChip('FACIL', 'Fácil 🌟', currentDiff, onDiffChanged, color),
                const SizedBox(width: 6),
                _buildDiffChip('MEDIO', 'Médio ✨', currentDiff, onDiffChanged, color),
                const SizedBox(width: 6),
                _buildDiffChip('DIFICIL', 'Difícil 🔥', currentDiff, onDiffChanged, color),
              ],
            ),

            const SizedBox(height: 8),

            // Indicadores de Desempenho (Conclusão e Acertos com Barra de Progresso)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.bgSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: pctAcertos != null ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: pctAcertos != null ? Alignment.centerLeft : Alignment.center,
                          child: Text(
                            'Conclusão: ${pctConclusao.toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                        ),
                      ),
                      if (pctAcertos != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Acertos: ${pctAcertos!.toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (pctConclusao / 100.0).clamp(0.0, 1.0),
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Botão Jogar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: onPlay,
                child: const Text(
                  'Jogar Agora 🚀',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Fredoka'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
