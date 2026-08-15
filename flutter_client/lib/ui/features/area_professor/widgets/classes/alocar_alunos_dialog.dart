import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/turma.dart';
import '../../../../../data/models/usuario.dart';
import '../../../../../state/app_state_provider.dart';

class AlocarAlunosDialog extends StatefulWidget {
  final Turma turma;
  final AppStateProvider state;

  const AlocarAlunosDialog({
    super.key,
    required this.turma,
    required this.state,
  });

  static Future<void> show(BuildContext context, AppStateProvider state, Turma turma) {
    return showDialog(
      context: context,
      builder: (_) => AlocarAlunosDialog(turma: turma, state: state),
    );
  }

  @override
  State<AlocarAlunosDialog> createState() => _AlocarAlunosDialogState();
}

class _AlocarAlunosDialogState extends State<AlocarAlunosDialog> {
  final Set<int> _selectedIds = {};
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isSaving = false;
  List<Usuario> _allUsers = [];

  @override
  void initState() {
    super.initState();
    // Inicializa com os IDs já alocados na turma mais recente no estado
    final currentTurma = widget.state.turmas.firstWhere(
      (t) => t.id == widget.turma.id,
      orElse: () => widget.turma,
    );
    final initialIds = currentTurma.alunos.map((a) => a.id).whereType<int>();
    _selectedIds.addAll(initialIds);
    _carregarUsuarios();
  }

  Future<void> _carregarUsuarios() async {
    setState(() => _isLoading = true);
    await widget.state.loadUsuarios();
    setState(() {
      _allUsers = widget.state.usuarios;
      _isLoading = false;
    });
  }

  Future<void> _salvarAlocacao() async {
    setState(() => _isSaving = true);
    try {
      final updated = await widget.state.setTurmaAlunos(widget.turma.id!, _selectedIds.toList());
      await widget.state.loadTurmas();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(updated != null
                ? 'Alocação salva! ${_selectedIds.length} aluno(s) vinculados à turma.'
                : 'Erro ao salvar alocação de alunos.'),
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
    // Alunos filtrados (exclui admins se desejar ou permite todos alunos)
    final alunos = _allUsers
        .where((u) => (u.role != 'ADMIN'))
        .where((u) {
          if (_searchQuery.isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          final nome = (u.nome ?? '').toLowerCase();
          final username = (u.username ?? '').toLowerCase();
          final codigo = (u.codigoIdentificador ?? '').toLowerCase();
          return nome.contains(q) || username.contains(q) || codigo.contains(q);
        })
        .toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Alocar Alunos: ${widget.turma.nome}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Fredoka'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Selecione os alunos que farão parte desta turma:',
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
                      hintText: 'Buscar aluno por nome ou ID...',
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
                      _selectedIds.addAll(alunos.map((a) => a.id).whereType<int>());
                    });
                  },
                  child: const Text('Todos', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedIds.clear()),
                  child: const Text('Limpar', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista de alunos
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : alunos.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.isEmpty ? 'Nenhum aluno cadastrado.' : 'Nenhum aluno encontrado.',
                            style: TextStyle(color: AppColors.textDark.withOpacity(0.6)),
                          ),
                        )
                      : ListView.separated(
                          itemCount: alunos.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, idx) {
                            final aluno = alunos[idx];
                            final isSelected = aluno.id != null && _selectedIds.contains(aluno.id);

                            return CheckboxListTile(
                              value: isSelected,
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              secondary: CircleAvatar(
                                radius: 18,
                                backgroundImage: AssetImage(aluno.avatar ?? 'assets/avatar/avatar_1.jpg'),
                              ),
                              title: Text(
                                aluno.nome ?? aluno.username ?? 'Aluno Sem Nome',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              subtitle: Text(
                                'ID: ${aluno.codigoIdentificador ?? "-"} • @${aluno.username ?? "-"}',
                                style: TextStyle(fontSize: 12, color: AppColors.textDark.withOpacity(0.7)),
                              ),
                              onChanged: (checked) {
                                if (aluno.id == null) return;
                                setState(() {
                                  if (checked == true) {
                                    _selectedIds.add(aluno.id!);
                                  } else {
                                    _selectedIds.remove(aluno.id!);
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
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _isSaving ? null : _salvarAlocacao,
          icon: _isSaving
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.save_rounded, size: 18),
          label: Text('Salvar (${_selectedIds.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
