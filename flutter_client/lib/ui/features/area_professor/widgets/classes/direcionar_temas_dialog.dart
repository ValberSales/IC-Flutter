import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/turma.dart';
import '../../../../../data/models/atividade.dart';
import '../../../../../state/app_state_provider.dart';

class DirecionarTemasDialog extends StatefulWidget {
  final Turma turma;
  final AppStateProvider state;

  const DirecionarTemasDialog({
    super.key,
    required this.turma,
    required this.state,
  });

  static Future<void> show(BuildContext context, AppStateProvider state, Turma turma) {
    return showDialog(
      context: context,
      builder: (_) => DirecionarTemasDialog(turma: turma, state: state),
    );
  }

  @override
  State<DirecionarTemasDialog> createState() => _DirecionarTemasDialogState();
}

class _DirecionarTemasDialogState extends State<DirecionarTemasDialog> {
  final Set<int> _selectedAtvIds = {};
  String _searchQuery = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final currentTurma = widget.state.turmas.firstWhere(
      (t) => t.id == widget.turma.id,
      orElse: () => widget.turma,
    );
    _selectedAtvIds.addAll(currentTurma.atividadesIds);
  }

  Future<void> _salvarDirecionamento() async {
    setState(() => _isSaving = true);
    try {
      final updated = await widget.state.setTurmaAtividades(widget.turma.id!, _selectedAtvIds.toList());
      await widget.state.loadTurmas();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(updated != null
                ? 'Temas direcionados com sucesso! ${_selectedAtvIds.length} tema(s) vinculados.'
                : 'Erro ao direcionar temas.'),
            backgroundColor: updated != null ? AppColors.accent : AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final todasAtividades = widget.state.atividades.where((a) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final t = a.titulo.toLowerCase();
      return t.contains(q);
    }).toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_turned_in_rounded, color: AppColors.secondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Direcionar Temas: ${widget.turma.nome}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Fredoka'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Marque os temas de jogos que ficarão em destaque para os alunos desta turma:',
            style: TextStyle(fontSize: 13, color: AppColors.textDark.withOpacity(0.7)),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        height: 480,
        child: Column(
          children: [
            // Barra de busca e ações rápidas
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Buscar tema por título...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      filled: true,
                      fillColor: AppColors.bgSoft,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedAtvIds.addAll(todasAtividades.map((a) => a.id).whereType<int>());
                    });
                  },
                  child: const Text('Todos', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedAtvIds.clear()),
                  child: const Text('Limpar', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista de atividades/temas
            Expanded(
              child: todasAtividades.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'Nenhum tema cadastrado ainda no sistema.'
                            : 'Nenhum tema encontrado com o termo buscado.',
                        style: TextStyle(color: AppColors.textDark.withOpacity(0.6)),
                      ),
                    )
                  : ListView.separated(
                      itemCount: todasAtividades.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, idx) {
                        final atv = todasAtividades[idx];
                        final isSelected = atv.id != null && _selectedAtvIds.contains(atv.id);
                        final isAdivinhacao = atv.tipoJogo == 'JOGO_ADIVINHACAO';

                        return CheckboxListTile(
                          value: isSelected,
                          activeColor: AppColors.secondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isAdivinhacao
                                  ? AppColors.primary.withOpacity(0.12)
                                  : AppColors.secondary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isAdivinhacao ? Icons.pets_rounded : Icons.diversity_3_rounded,
                              color: isAdivinhacao ? AppColors.primary : AppColors.secondary,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            atv.titulo,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            '${isAdivinhacao ? "Adivinhação" : "Palavras"} • ${atv.itens.length} palavras cadastradas',
                            style: TextStyle(fontSize: 12, color: AppColors.textDark.withOpacity(0.7)),
                          ),
                          onChanged: (checked) {
                            if (atv.id == null) return;
                            setState(() {
                              if (checked == true) {
                                _selectedAtvIds.add(atv.id!);
                              } else {
                                _selectedAtvIds.remove(atv.id!);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: AppColors.textDark)),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _isSaving ? null : _salvarDirecionamento,
          icon: _isSaving
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.check_circle_rounded, size: 18),
          label: Text('Salvar (${_selectedAtvIds.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
