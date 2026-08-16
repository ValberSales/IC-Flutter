import 'package:flutter/material.dart';
import 'package:flutter_client/core/constants/app_colors.dart';
import 'package:flutter_client/data/models/relatorio_turma.dart';

class GameThemeAnalyticsWidget extends StatefulWidget {
  final RelatorioTurma relatorio;

  const GameThemeAnalyticsWidget({super.key, required this.relatorio});

  @override
  State<GameThemeAnalyticsWidget> createState() => _GameThemeAnalyticsWidgetState();
}

class _GameThemeAnalyticsWidgetState extends State<GameThemeAnalyticsWidget> {
  String _selectedFiltroTipo = 'JOGO'; // 'JOGO' ou 'TEMA'
  String _selectedJogo = 'TODOS'; // 'TODOS', 'JOGO_ADIVINHACAO', 'JOGO_PALAVRAS', 'JOGO_MEMORIA', 'JOGO_ALFABETO'
  String _selectedTema = 'TODOS';

  @override
  Widget build(BuildContext context) {
    final temas = widget.relatorio.temas;
    final alunos = widget.relatorio.alunos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Seletor de Modo: Por Jogo vs. Por Tema
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterTabButton(
                        'Filtrar por Jogo',
                        Icons.sports_esports_rounded,
                        _selectedFiltroTipo == 'JOGO',
                        () => setState(() => _selectedFiltroTipo = 'JOGO'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterTabButton(
                        'Filtrar por Tema Direcionado',
                        Icons.assignment_rounded,
                        _selectedFiltroTipo == 'TEMA',
                        () => setState(() => _selectedFiltroTipo = 'TEMA'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (_selectedFiltroTipo == 'JOGO')
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChoiceChip('Todos os Jogos', 'TODOS', _selectedJogo, (v) => setState(() => _selectedJogo = v)),
                      _buildChoiceChip('Adivinhação', 'JOGO_ADIVINHACAO', _selectedJogo, (v) => setState(() => _selectedJogo = v)),
                      _buildChoiceChip('Jogo de Palavras', 'JOGO_PALAVRAS', _selectedJogo, (v) => setState(() => _selectedJogo = v)),
                      _buildChoiceChip('Memória', 'JOGO_MEMORIA', _selectedJogo, (v) => setState(() => _selectedJogo = v)),
                      _buildChoiceChip('Alfabeto', 'JOGO_ALFABETO', _selectedJogo, (v) => setState(() => _selectedJogo = v)),
                    ],
                  )
                else
                  temas.isEmpty
                      ? const Text('Nenhum tema direcionado para esta turma ainda.', style: TextStyle(color: AppColors.textDark))
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildChoiceChip('Todos os Temas', 'TODOS', _selectedTema, (v) => setState(() => _selectedTema = v)),
                            ...temas.map(
                              (t) => _buildChoiceChip(t.titulo, t.titulo, _selectedTema, (v) => setState(() => _selectedTema = v)),
                            ),
                          ],
                        ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Tabela Comparativa de Alunos para o Filtro Selecionado
        Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.border.withValues(alpha: 0.7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedFiltroTipo == 'JOGO'
                          ? 'Desempenho: ${_getNomeJogo(_selectedJogo)}'
                          : 'Desempenho: $_selectedTema',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${alunos.length} Aluno(s)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.border),

              alunos.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('Nenhum aluno cadastrado na turma.', style: TextStyle(color: AppColors.textDark)),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth > 650 ? constraints.maxWidth : 650,
                            ),
                            child: Table(
                              border: TableBorder(
                                horizontalInside: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
                              ),
                              columnWidths: const {
                                0: FlexColumnWidth(2.4),
                                1: FlexColumnWidth(1.1),
                                2: FlexColumnWidth(1.1),
                                3: FlexColumnWidth(1.1),
                                4: FlexColumnWidth(1.4),
                                5: FlexColumnWidth(1.5),
                              },
                              children: [
                                const TableRow(
                                  decoration: BoxDecoration(color: AppColors.bgSoft),
                                  children: [
                                    Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Text('Aluno', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark))),
                                    Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12), child: Text('Partidas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark))),
                                    Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12), child: Text('Acertos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark))),
                                    Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12), child: Text('Erros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark))),
                                    Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12), child: Text('Aproveitamento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark))),
                                    Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark))),
                                  ],
                                ),
                                ...alunos.map((aluno) {
                                  final filteredMatches = aluno.historico.where((p) {
                                    if (_selectedFiltroTipo == 'JOGO') {
                                      if (_selectedJogo == 'TODOS') return true;
                                      return p.atividade.toUpperCase() == _selectedJogo.toUpperCase();
                                    } else {
                                      if (_selectedTema == 'TODOS') return true;
                                      return p.tema.toLowerCase() == _selectedTema.toLowerCase();
                                    }
                                  }).toList();

                                  int pCount = filteredMatches.length;
                                  int acertos = filteredMatches.fold(0, (sum, p) => sum + p.acertos);
                                  int erros = filteredMatches.fold(0, (sum, p) => sum + p.erros);
                                  double taxa = (acertos + erros > 0) ? (acertos / (acertos + erros)) * 100.0 : 0.0;
                                  bool hasConcluido = filteredMatches.any((p) => p.concluido) || (pCount > 0 && taxa >= 80.0);

                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        child: Row(
                                          children: [
                                            CircleAvatar(radius: 14, backgroundImage: AssetImage(aluno.avatar)),
                                            const SizedBox(width: 10),
                                            Flexible(
                                              child: Text(
                                                aluno.nome,
                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), child: Text('$pCount', style: const TextStyle(fontSize: 13, color: AppColors.textDark))),
                                      Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), child: Text('$acertos', style: const TextStyle(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.bold))),
                                      Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), child: Text('$erros', style: const TextStyle(fontSize: 13, color: AppColors.error, fontWeight: FontWeight.bold))),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        child: Text('${taxa.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: pCount == 0
                                                ? AppColors.bgSoft
                                                : hasConcluido
                                                    ? Colors.green.shade100
                                                    : Colors.amber.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            pCount == 0
                                                ? 'Não Iniciado'
                                                : hasConcluido
                                                    ? '✓ Concluído'
                                                    : '⏳ Em Progresso',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: pCount == 0
                                                  ? AppColors.textDark.withValues(alpha: 0.6)
                                                  : hasConcluido
                                                      ? Colors.green.shade900
                                                      : Colors.amber.shade900,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabButton(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.bgSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? AppColors.primary : AppColors.textDark.withValues(alpha: 0.7)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.textDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, String value, String currentSelected, ValueChanged<String> onSelected) {
    final isSelected = currentSelected == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      backgroundColor: AppColors.bgSoft,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppColors.primary : AppColors.textDark,
      ),
    );
  }

  String _getNomeJogo(String key) {
    switch (key) {
      case 'JOGO_ADIVINHACAO':
        return 'Adivinhação';
      case 'JOGO_PALAVRAS':
        return 'Jogo de Palavras';
      case 'JOGO_MEMORIA':
        return 'Jogo da Memória';
      case 'JOGO_ALFABETO':
        return 'Alfabeto em Libras';
      default:
        return 'Todos os Jogos';
    }
  }
}
