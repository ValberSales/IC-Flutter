import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TemaCardWidget extends StatelessWidget {
  final String titulo;
  final String descricao;
  final IconData icone;
  final Color cor;
  final bool isTeacherCreated;
  final bool isTurmaAssigned;
  final double pctConclusao;
  final double? pctAcertos;
  final VoidCallback onTap;

  const TemaCardWidget({
    super.key,
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.cor,
    this.isTeacherCreated = false,
    this.isTurmaAssigned = false,
    required this.pctConclusao,
    required this.pctAcertos,
    required this.onTap,
  });

  Widget _buildBadge(Color badgeColor, String text, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlight ? AppColors.accent : AppColors.primaryLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlight ? AppColors.accent : AppColors.primary.withValues(alpha: 0.3),
          width: isHighlight ? 1.5 : 1,
        ),
        boxShadow: isHighlight
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isHighlight) ...[
            const Icon(Icons.stars_rounded, size: 13, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: isHighlight ? Colors.white : AppColors.primary,
              fontFamily: 'Fredoka',
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = isTurmaAssigned
        ? AppColors.accent
        : cor.withValues(alpha: 0.25);

    return Card(
      elevation: isTurmaAssigned ? 8 : 4,
      shadowColor: isTurmaAssigned ? AppColors.accent.withValues(alpha: 0.25) : cor.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: effectiveBorderColor,
          width: isTurmaAssigned ? 2.0 : 1.2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Header: Ícone e Badge nos extremos
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
                          color: (isTurmaAssigned ? AppColors.accent : cor).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icone, size: 28, color: isTurmaAssigned ? AppColors.accent : cor),
                      ),
                      if (isTurmaAssigned)
                        _buildBadge(AppColors.accent, '🎯 Atividade da Turma', isHighlight: true)
                      else if (isTeacherCreated)
                        _buildBadge(cor, 'Turma'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      titulo,
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
                    descricao,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.25,
                      color: AppColors.textDark.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Indicadores de Desempenho (Conclusão e Acertos)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.bgSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_rounded, size: 16, color: cor),
                                const SizedBox(width: 4),
                                Text(
                                  'Conclusão: ${pctConclusao.toStringAsFixed(0)}%',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 16, color: AppColors.secondary),
                                const SizedBox(width: 4),
                                Text(
                                  'Acertos: ${pctAcertos != null ? "${pctAcertos!.toStringAsFixed(0)}%" : "-"}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (pctConclusao / 100.0).clamp(0.0, 1.0),
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(isTurmaAssigned ? AppColors.accent : cor),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
