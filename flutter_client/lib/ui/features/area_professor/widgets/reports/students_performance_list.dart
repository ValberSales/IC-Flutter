import 'package:flutter/material.dart';
import 'package:flutter_client/core/constants/app_colors.dart';
import 'package:flutter_client/data/models/relatorio_turma.dart';
import 'student_detail_dialog.dart';

class StudentsPerformanceList extends StatefulWidget {
  final List<AlunoDesempenho> alunos;
  final String turmaNome;

  const StudentsPerformanceList({
    super.key,
    required this.alunos,
    required this.turmaNome,
  });

  @override
  State<StudentsPerformanceList> createState() => _StudentsPerformanceListState();
}

class _StudentsPerformanceListState extends State<StudentsPerformanceList> {
  final TextEditingController _searchController = TextEditingController();
  String _filtro = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.alunos.where((a) {
      if (_filtro.isEmpty) return true;
      final q = _filtro.toLowerCase();
      return a.nome.toLowerCase().contains(q) ||
          a.username.toLowerCase().contains(q) ||
          a.codigoIdentificador.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Barra de Pesquisa de Aluno
        TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _filtro = val),
          decoration: InputDecoration(
            hintText: 'Pesquisar aluno por nome ou @username...',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (filtered.isEmpty)
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.person_search_rounded, size: 54, color: AppColors.primary.withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  Text(
                    _filtro.isEmpty ? 'Nenhum aluno matriculado nesta turma.' : 'Nenhum aluno encontrado para a busca.',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final aluno = filtered[index];
              return _buildStudentCard(context, aluno);
            },
          ),
      ],
    );
  }

  Widget _buildStudentCard(BuildContext context, AlunoDesempenho aluno) {
    Color barColor = AppColors.accent;
    if (aluno.taxaAproveitamento < 50) {
      barColor = AppColors.error;
    } else if (aluno.taxaAproveitamento < 75) {
      barColor = Colors.orange.shade700;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 480;

            final infoSection = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        aluno.nome,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '@${aluno.username} • ${aluno.totalPartidas} partida(s) • ${aluno.acertos} acerto(s)',
                  style: TextStyle(fontSize: 12, color: AppColors.textDark.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 6),

                // Barra de Progresso / Aproveitamento
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (aluno.taxaAproveitamento / 100.0).clamp(0.0, 1.0),
                          backgroundColor: AppColors.bgSoft,
                          valueColor: AlwaysStoppedAnimation<Color>(barColor),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${aluno.taxaAproveitamento}%',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: barColor),
                    ),
                  ],
                ),
              ],
            );

            final actionsSection = Row(
              mainAxisSize: isNarrow ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: isNarrow ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
              children: [
                // Badge de Dificuldade
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    aluno.dificuldadeAtual,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 10),

                // Botão Ver Ficha
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => StudentDetailDialog.show(context, aluno, widget.turmaNome),
                  icon: const Icon(Icons.visibility_rounded, size: 16),
                  label: const Text('Ver Ficha', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            );

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage(aluno.avatar),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: infoSection),
                    ],
                  ),
                  const SizedBox(height: 12),
                  actionsSection,
                ],
              );
            }

            return Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage(aluno.avatar),
                ),
                const SizedBox(width: 14),

                // Informações do Aluno
                Expanded(child: infoSection),
                const SizedBox(width: 14),

                actionsSection,
              ],
            );
          },
        ),
      ),
    );
  }
}
