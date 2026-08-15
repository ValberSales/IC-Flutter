import 'package:flutter/material.dart';
import 'package:flutter_client/core/constants/app_colors.dart';
import 'package:flutter_client/data/models/relatorio_turma.dart';

class TurmaOverviewCard extends StatelessWidget {
  final RelatorioTurma relatorio;

  const TurmaOverviewCard({super.key, required this.relatorio});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        final count = isWide ? 4 : 2;

        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: isWide ? 1.8 : 1.5,
          children: [
            _buildKpiCard(
              title: 'Aproveitamento Geral',
              value: '${relatorio.taxaAproveitamentoGeral}%',
              subtitle: 'Taxa média de acertos',
              icon: Icons.track_changes_rounded,
              color: AppColors.accent,
            ),
            _buildKpiCard(
              title: 'Alunos Matriculados',
              value: '${relatorio.totalAlunos}',
              subtitle: 'Alunos nesta turma',
              icon: Icons.people_alt_rounded,
              color: AppColors.primary,
            ),
            _buildKpiCard(
              title: 'Partidas Jogadas',
              value: '${relatorio.totalPartidas}',
              subtitle: '${relatorio.totalAcertos} acertos • ${relatorio.totalErros} erros',
              icon: Icons.sports_esports_rounded,
              color: Colors.orange.shade700,
            ),
            _buildKpiCard(
              title: 'Temas Alocados',
              value: '${relatorio.temas.length}',
              subtitle: 'Atividades vinculadas',
              icon: Icons.category_rounded,
              color: Colors.purple,
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: color,
                      fontFamily: 'Fredoka',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textDark.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
