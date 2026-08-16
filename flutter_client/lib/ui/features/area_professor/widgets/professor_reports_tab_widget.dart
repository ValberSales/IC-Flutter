import 'package:flutter/material.dart';
import 'package:flutter_client/core/constants/app_colors.dart';
import 'package:flutter_client/data/models/relatorio_turma.dart';
import 'package:flutter_client/data/models/turma.dart';
import 'package:flutter_client/data/repositories/relatorio_repository.dart';
import 'package:flutter_client/state/app_state_provider.dart';
import 'reports/difficulty_evolution_card.dart';
import 'reports/export_report_service.dart';
import 'reports/game_theme_analytics_widget.dart';
import 'reports/students_performance_list.dart';
import 'reports/turma_overview_card.dart';

class ProfessorReportsTabWidget extends StatefulWidget {
  final AppStateProvider state;

  const ProfessorReportsTabWidget({super.key, required this.state});

  @override
  State<ProfessorReportsTabWidget> createState() => _ProfessorReportsTabWidgetState();
}

class _ProfessorReportsTabWidgetState extends State<ProfessorReportsTabWidget> {
  final RelatorioRepository _relatorioRepository = RelatorioRepository();

  Turma? _selectedTurma;
  RelatorioTurma? _relatorio;
  bool _isLoading = false;
  int _currentSectionIndex = 0; // 0: Geral & Alunos, 1: Jogos & Temas, 2: Evolução de Dificuldade

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await widget.state.loadTurmas();
      if (mounted) {
        _initTurma();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ProfessorReportsTabWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.turmas.isNotEmpty &&
        (_selectedTurma == null || !widget.state.turmas.any((t) => t.id == _selectedTurma?.id))) {
      _selectedTurma = widget.state.turmas.first;
      _loadRelatorio();
    }
  }

  void _initTurma() {
    if (widget.state.turmas.isNotEmpty) {
      _selectedTurma = widget.state.turmas.first;
      _loadRelatorio();
    }
  }

  Future<void> _loadRelatorio() async {
    if (_selectedTurma == null) {
      if (widget.state.turmas.isNotEmpty) {
        _selectedTurma = widget.state.turmas.first;
      } else {
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final rel = await _relatorioRepository.getRelatorioTurma(_selectedTurma!);
      if (mounted) {
        setState(() {
          _relatorio = rel;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final turmas = widget.state.turmas;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Cabeçalho Padronizado da Aba
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: LayoutBuilder(
                    builder: (context, headerConstraints) {
                      final isCompact = headerConstraints.maxWidth < 650;
                      final exportButtons = _relatorio != null
                          ? Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.teal.shade800,
                                    side: BorderSide(color: Colors.teal.shade400),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  onPressed: () => ExportReportService.printTurmaReport(context, _relatorio!),
                                  icon: const Icon(Icons.print_rounded, size: 18),
                                  label: const Text('Imprimir / PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 2,
                                  ),
                                  onPressed: () => ExportReportService.exportTurmaCsv(context, _relatorio!),
                                  icon: const Icon(Icons.download_rounded, size: 18),
                                  label: const Text('Exportar CSV', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                              ],
                            )
                          : null;

                      if (isCompact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.analytics_rounded, color: Colors.teal, size: 28),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Relatórios Pedagógicos & Analytics',
                                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Acompanhe o desempenho e evolução das turmas.',
                                        style: TextStyle(fontSize: 12, color: AppColors.textDark),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (exportButtons != null) ...[
                              const SizedBox(height: 14),
                              exportButtons,
                            ],
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.teal.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.analytics_rounded, color: Colors.teal, size: 30),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Relatórios Pedagógicos & Analytics',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Acompanhe o desempenho, aproveitamento e evolução das turmas e alunos.',
                                  style: TextStyle(fontSize: 13, color: AppColors.textDark),
                                ),
                              ],
                            ),
                          ),
                          if (exportButtons != null) ...[
                            const SizedBox(width: 12),
                            exportButtons,
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Seletor de Turma
              if (turmas.isEmpty)
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.school_outlined, size: 54, color: AppColors.primaryLight),
                        SizedBox(height: 12),
                        Text(
                          'Nenhuma turma cadastrada ainda.',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Crie turmas na aba "Turmas" para acompanhar o desempenho pedagógico.',
                          style: TextStyle(fontSize: 13, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.school_rounded, color: AppColors.primary, size: 22),
                        const SizedBox(width: 10),
                        const Text(
                          'Turma Selecionada:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: _selectedTurma?.id ?? turmas.first.id,
                              items: turmas.map((t) {
                                return DropdownMenuItem<int>(
                                  value: t.id,
                                  child: Text(
                                    '${t.nome} (Código: ${t.codigo})',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                                  ),
                                );
                              }).toList(),
                              onChanged: (id) {
                                if (id != null) {
                                  final t = turmas.firstWhere((item) => item.id == id);
                                  setState(() => _selectedTurma = t);
                                  _loadRelatorio();
                                }
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Atualizar Relatório',
                          icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                          onPressed: _loadRelatorio,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Sub-Navegação por Abas
                Row(
                  children: [
                    Expanded(
                      child: _buildSectionTab(
                        0,
                        'Visão Geral & Alunos',
                        Icons.dashboard_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSectionTab(
                        1,
                        'Desempenho por Jogo & Tema',
                        Icons.sports_esports_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSectionTab(
                        2,
                        'Evolução de Dificuldade',
                        Icons.trending_up_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 4. Conteúdo Dinâmico
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(48.0),
                    child: Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: Colors.teal),
                          SizedBox(height: 12),
                          Text('Carregando métricas pedagógicas...', style: TextStyle(color: AppColors.textDark)),
                        ],
                      ),
                    ),
                  )
                else if (_relatorio != null) ...[
                  if (_currentSectionIndex == 0) ...[
                    TurmaOverviewCard(relatorio: _relatorio!),
                    const SizedBox(height: 20),
                    const Text(
                      'Desempenho Individual dos Alunos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 12),
                    StudentsPerformanceList(
                      alunos: _relatorio!.alunos,
                      turmaNome: _relatorio!.turmaNome,
                    ),
                  ] else if (_currentSectionIndex == 1) ...[
                    GameThemeAnalyticsWidget(relatorio: _relatorio!),
                  ] else ...[
                    DifficultyEvolutionCard(relatorio: _relatorio!),
                  ],
                ] else ...[
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 48, color: Colors.teal.shade300),
                          const SizedBox(height: 12),
                          const Text(
                            'Nenhum dado disponível para esta turma.',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Os alunos matriculados ainda não jogaram atividades ou os dados estão sendo sincronizados.',
                            style: TextStyle(fontSize: 13, color: AppColors.textDark),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _loadRelatorio,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTab(int index, String label, IconData icon) {
    final isSelected = _currentSectionIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentSectionIndex = index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.teal : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.teal : AppColors.textDark.withValues(alpha: 0.7)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.teal : AppColors.textDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
