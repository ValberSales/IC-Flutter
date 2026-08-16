import 'package:flutter/material.dart';
import 'package:flutter_client/core/constants/app_colors.dart';
import 'package:flutter_client/data/models/relatorio_turma.dart';

class DifficultyEvolutionCard extends StatelessWidget {
  final RelatorioTurma relatorio;

  const DifficultyEvolutionCard({super.key, required this.relatorio});

  @override
  Widget build(BuildContext context) {
    final evolucao = relatorio.evolucaoDificuldade;
    final total = relatorio.totalAlunos > 0 ? relatorio.totalAlunos : 1;

    final double pctFacil = (evolucao.facil / total) * 100.0;
    final double pctMedio = (evolucao.medio / total) * 100.0;
    final double pctDificil = (evolucao.dificil / total) * 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Card de Diagnóstico de Dificuldade
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.trending_up_rounded, color: Colors.purple, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Distribuição por Nível de Dificuldade',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Total: ${relatorio.totalAlunos} Aluno(s)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.purple),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Barra Segmentada de Distribuição
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 14,
                    child: Row(
                      children: [
                        if (evolucao.facil > 0)
                          Expanded(
                            flex: evolucao.facil,
                            child: Container(color: Colors.green.shade500),
                          ),
                        if (evolucao.medio > 0)
                          Expanded(
                            flex: evolucao.medio,
                            child: Container(color: Colors.amber.shade600),
                          ),
                        if (evolucao.dificil > 0)
                          Expanded(
                            flex: evolucao.dificil,
                            child: Container(color: Colors.red.shade500),
                          ),
                        if (relatorio.totalAlunos == 0)
                          Expanded(
                            child: Container(color: AppColors.bgSoft),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Legenda e Contagens
                Wrap(
                  spacing: 16,
                  runSpacing: 10,
                  alignment: WrapAlignment.spaceAround,
                  children: [
                    _buildLegendItem('Fácil (Iniciante)', '${evolucao.facil} aluno(s) (${pctFacil.toStringAsFixed(0)}%)', Colors.green.shade600),
                    _buildLegendItem('Médio (Intermediário)', '${evolucao.medio} aluno(s) (${pctMedio.toStringAsFixed(0)}%)', Colors.amber.shade700),
                    _buildLegendItem('Difícil (Avançado)', '${evolucao.dificil} aluno(s) (${pctDificil.toStringAsFixed(0)}%)', Colors.red.shade600),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Lista de Estudantes e Nível Calculado
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.workspace_premium_rounded, color: AppColors.primary, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Nível Pedagógico dos Estudantes',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'O nível é diagnosticado quando o aluno alcança 70% ou mais de aproveitamento nos temas vinculados a esta turma.',
                  style: TextStyle(fontSize: 12, color: AppColors.textDark.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 16),

                if (relatorio.alunos.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        'Nenhum estudante matriculado nesta turma.',
                        style: TextStyle(fontSize: 14, color: AppColors.textDark.withValues(alpha: 0.6)),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: relatorio.alunos.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final aluno = relatorio.alunos[index];
                      return _buildStudentLevelTile(context, aluno);
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentLevelTile(BuildContext context, AlunoDesempenho aluno) {
    final diff = aluno.dificuldadeCalculada.toUpperCase();
    Color badgeColor = Colors.green.shade600;
    Color badgeBg = Colors.green.shade50;
    String badgeLabel = 'Nível Fácil';

    if (diff == 'DIFICIL') {
      badgeColor = Colors.red.shade600;
      badgeBg = Colors.red.shade50;
      badgeLabel = 'Nível Difícil';
    } else if (diff == 'MEDIO') {
      badgeColor = Colors.amber.shade800;
      badgeBg = Colors.amber.shade50;
      badgeLabel = 'Nível Médio';
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: AssetImage(aluno.avatar),
      ),
      title: Text(
        aluno.nome,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        '@${aluno.username} • ${aluno.totalPartidas} partida(s)',
        style: TextStyle(fontSize: 12, color: AppColors.textDark.withValues(alpha: 0.7)),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: badgeBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
        ),
        child: Text(
          badgeLabel,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: badgeColor),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text(subtitle, style: TextStyle(fontSize: 10, color: AppColors.textDark.withValues(alpha: 0.7))),
          ],
        ),
      ],
    );
  }
}
