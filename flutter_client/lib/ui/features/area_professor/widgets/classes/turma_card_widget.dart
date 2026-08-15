import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/turma.dart';

class TurmaCardWidget extends StatelessWidget {
  final Turma turma;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAlocarAlunos;
  final VoidCallback onDirecionarTemas;

  const TurmaCardWidget({
    super.key,
    required this.turma,
    required this.onEdit,
    required this.onDelete,
    required this.onAlocarAlunos,
    required this.onDirecionarTemas,
  });

  @override
  Widget build(BuildContext context) {
    final totalAlunos = turma.alunos.isNotEmpty ? turma.alunos.length : turma.totalAlunos;
    final totalTemas = turma.atividadesIds.isNotEmpty ? turma.atividadesIds.length : turma.totalAtividades;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            // Ícone da Turma
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 14),

            // Informações Centrais da Turma
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          turma.nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // PIN Badge clicável para cópia rápida
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: turma.codigo));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('PIN ${turma.codigo} copiado com sucesso!'),
                              backgroundColor: AppColors.accent,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.vpn_key_rounded, size: 12, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                'PIN: ${turma.codigo}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.copy_rounded, size: 12, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (turma.descricao.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      turma.descricao,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textDark.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  // Badges de Contagem (Alunos e Temas)
                  Row(
                    children: [
                      _buildBadge(Icons.people_alt_rounded, '$totalAlunos Aluno(s)', AppColors.primary),
                      const SizedBox(width: 8),
                      _buildBadge(Icons.sports_esports_rounded, '$totalTemas Tema(s)', Colors.orange.shade800),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Ações da Turma
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onAlocarAlunos,
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                  label: const Text('Alunos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                  ),
                  onPressed: onDirecionarTemas,
                  icon: const Icon(Icons.assignment_turned_in_rounded, size: 16),
                  label: const Text('Temas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 20),
                  tooltip: 'Editar Turma',
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                  tooltip: 'Excluir Turma',
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
