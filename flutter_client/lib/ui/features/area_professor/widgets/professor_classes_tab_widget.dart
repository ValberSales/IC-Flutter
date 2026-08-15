import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/turma.dart';
import '../../../../state/app_state_provider.dart';
import '../view_models/area_professor_view_model.dart';
import 'classes/turma_card_widget.dart';
import 'classes/turma_form_dialog.dart';
import 'classes/alocar_alunos_dialog.dart';
import 'classes/direcionar_temas_dialog.dart';

class ProfessorClassesTabWidget extends StatefulWidget {
  final AreaProfessorViewModel viewModel;
  final AppStateProvider state;

  const ProfessorClassesTabWidget({
    super.key,
    required this.viewModel,
    required this.state,
  });

  @override
  State<ProfessorClassesTabWidget> createState() => _ProfessorClassesTabWidgetState();
}

class _ProfessorClassesTabWidgetState extends State<ProfessorClassesTabWidget> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Garante que a lista de turmas e usuários esteja sincronizada ao abrir
    widget.state.loadTurmas();
    widget.state.loadUsuarios();
  }

  void _confirmDelete(Turma turma) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Excluir Turma?', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Tem certeza que deseja excluir a turma "${turma.nome}"?\nOs vínculos com alunos e temas serão desfeitos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textDark)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.of(context).pop();
              await widget.state.deleteTurma(turma.id!);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final turmas = widget.state.turmas.where((t) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final nome = t.nome.toLowerCase();
      final codigo = t.codigo.toLowerCase();
      final desc = t.descricao.toLowerCase();
      return nome.contains(q) || codigo.contains(q) || desc.contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho da Aba de Turmas
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.class_rounded, color: AppColors.primary, size: 30),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gestão de Turmas & Atividades Direcionadas',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Crie turmas, compartilhe o PIN de acesso com alunos e direcione temas pedagógicos.',
                              style: TextStyle(fontSize: 13, color: AppColors.textDark),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        onPressed: () => TurmaFormDialog.show(context, widget.state),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('Nova Turma', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Barra de Pesquisa
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Pesquisar turma por nome, descrição ou código PIN...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Lista de Turmas
              if (turmas.isEmpty)
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(Icons.school_outlined, size: 64, color: AppColors.primary.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Nenhuma turma cadastrada ainda.'
                              : 'Nenhuma turma encontrada para a busca.',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Clique em "Nova Turma" acima para criar a primeira turma e gerar seu código PIN.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: turmas.length,
                  itemBuilder: (context, index) {
                    final turma = turmas[index];
                    return TurmaCardWidget(
                      turma: turma,
                      onEdit: () => TurmaFormDialog.show(context, widget.state, turma: turma),
                      onDelete: () => _confirmDelete(turma),
                      onAlocarAlunos: () => AlocarAlunosDialog.show(context, widget.state, turma),
                      onDirecionarTemas: () => DirecionarTemasDialog.show(context, widget.state, turma),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
