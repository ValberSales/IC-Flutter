import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TemaCardWidget extends StatelessWidget {
  final String titulo;
  final String descricao;
  final IconData icone;
  final Color cor;
  final bool isTeacherCreated;
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
    required this.pctConclusao,
    required this.pctAcertos,
    required this.onTap,
  });

  Widget _buildBadge(Color badgeColor, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          fontFamily: 'Fredoka',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: cor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: cor.withOpacity(0.25), width: 1.5),
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
              // Top Header: Ícone e Badge 'Turma' nos extremos
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
                          color: cor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icone, size: 28, color: cor),
                      ),
                      if (isTeacherCreated) _buildBadge(cor, 'Turma'),
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
                      color: AppColors.textDark.withOpacity(0.75),
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
                                const Icon(Icons.task_alt_rounded, size: 16, color: AppColors.accent),
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
                        valueColor: AlwaysStoppedAnimation<Color>(cor),
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
