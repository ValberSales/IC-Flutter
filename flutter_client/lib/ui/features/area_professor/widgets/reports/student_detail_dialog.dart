import 'package:flutter/material.dart';
import 'package:flutter_client/core/constants/app_colors.dart';
import 'package:flutter_client/data/models/relatorio_turma.dart';
import 'export_report_service.dart';

class StudentDetailDialog extends StatelessWidget {
  final AlunoDesempenho aluno;
  final String turmaNome;

  const StudentDetailDialog({
    super.key,
    required this.aluno,
    required this.turmaNome,
  });

  static void show(BuildContext context, AlunoDesempenho aluno, String turmaNome) {
    showDialog(
      context: context,
      builder: (ctx) => StudentDetailDialog(aluno: aluno, turmaNome: turmaNome),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 750, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Topo com Avatar, Nome e Botão Fechar
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage(aluno.avatar),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                aluno.nome,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${aluno.username} • Turma: $turmaNome',
                          style: TextStyle(fontSize: 12, color: AppColors.textDark.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),

              // 4 Mini KPIs do Aluno
              Row(
                children: [
                  Expanded(
                    child: _buildMiniKpi(
                      'Aproveitamento',
                      '${aluno.taxaAproveitamento}%',
                      Icons.track_changes_rounded,
                      AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMiniKpi(
                      'Partidas',
                      '${aluno.totalPartidas}',
                      Icons.sports_esports_rounded,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMiniKpi(
                      'Acertos / Erros',
                      '${aluno.acertos} / ${aluno.erros}',
                      Icons.done_all_rounded,
                      Colors.orange.shade800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMiniKpi(
                      'Nível Atual',
                      aluno.dificuldadeAtual,
                      Icons.signal_cellular_alt_rounded,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Cabeçalho da Tabela de Histórico
              const Text(
                'Histórico Detalhado de Partidas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 10),

              // Tabela com Scroll
              Expanded(
                child: aluno.historico.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_toggle_off_rounded, size: 48, color: AppColors.primary.withOpacity(0.4)),
                            const SizedBox(height: 8),
                            const Text(
                              'Nenhuma partida registrada para este aluno ainda.',
                              style: TextStyle(color: AppColors.textDark),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SingleChildScrollView(
                            child: Table(
                              border: TableBorder(
                                horizontalInside: BorderSide(color: AppColors.border.withOpacity(0.5)),
                              ),
                              columnWidths: const {
                                0: FlexColumnWidth(1.8),
                                1: FlexColumnWidth(1.8),
                                2: FlexColumnWidth(1.1),
                                3: FlexColumnWidth(1.1),
                                4: FlexColumnWidth(1.1),
                                5: FlexColumnWidth(1.4),
                                6: FlexColumnWidth(1.8),
                              },
                              children: [
                                const TableRow(
                                  decoration: BoxDecoration(color: AppColors.bgSoft),
                                  children: [
                                    Padding(padding: EdgeInsets.all(10), child: Text('Jogo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                    Padding(padding: EdgeInsets.all(10), child: Text('Tema', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                    Padding(padding: EdgeInsets.all(10), child: Text('Nível', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                    Padding(padding: EdgeInsets.all(10), child: Text('Acertos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                    Padding(padding: EdgeInsets.all(10), child: Text('Erros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                    Padding(padding: EdgeInsets.all(10), child: Text('Taxa %', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                    Padding(padding: EdgeInsets.all(10), child: Text('Data/Hora', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  ],
                                ),
                                ...aluno.historico.map((p) {
                                  final dateStr = p.createdAt != null
                                      ? '${p.createdAt!.day}/${p.createdAt!.month} ${p.createdAt!.hour}:${p.createdAt!.minute.toString().padLeft(2, '0')}'
                                      : '-';

                                  String gameName = p.atividade;
                                  if (gameName == 'JOGO_ADIVINHACAO') gameName = 'Adivinhação';
                                  if (gameName == 'JOGO_PALAVRAS') gameName = 'Palavras';
                                  if (gameName == 'JOGO_MEMORIA') gameName = 'Memória';
                                  if (gameName == 'JOGO_ALFABETO') gameName = 'Alfabeto';

                                  return TableRow(
                                    children: [
                                      Padding(padding: const EdgeInsets.all(10), child: Text(gameName, style: const TextStyle(fontSize: 12))),
                                      Padding(padding: const EdgeInsets.all(10), child: Text(p.tema, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                                      Padding(padding: const EdgeInsets.all(10), child: Text(p.dificuldade, style: const TextStyle(fontSize: 11))),
                                      Padding(padding: const EdgeInsets.all(10), child: Text('${p.acertos}', style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.bold))),
                                      Padding(padding: const EdgeInsets.all(10), child: Text('${p.erros}', style: const TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.bold))),
                                      Padding(padding: const EdgeInsets.all(10), child: Text('${p.taxaAproveitamento}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                                      Padding(padding: const EdgeInsets.all(10), child: Text(dateStr, style: TextStyle(fontSize: 11, color: AppColors.textDark.withOpacity(0.7)))),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Ações Inferiores
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => ExportReportService.printAlunoReport(context, aluno, turmaNome),
                    icon: const Icon(Icons.print_rounded, size: 18),
                    label: const Text('Imprimir Ficha', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fechar', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniKpi(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 10, color: AppColors.textDark.withOpacity(0.7), fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
