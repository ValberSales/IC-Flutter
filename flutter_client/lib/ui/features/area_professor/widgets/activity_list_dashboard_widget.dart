import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/atividade.dart';
import '../../../../state/app_state_provider.dart';
import '../../../core/icon_picker_dialog.dart';
import '../view_models/area_professor_view_model.dart';

class ActivityListDashboardWidget extends StatelessWidget {
  final AreaProfessorViewModel viewModel;
  final AppStateProvider state;

  const ActivityListDashboardWidget({
    super.key,
    required this.viewModel,
    required this.state,
  });

  Widget _buildCategoriaChip(String key, String label, IconData icon) {
    final isSelected = viewModel.categoriaFiltro == key;
    return Expanded(
      child: InkWell(
        onTap: () => viewModel.setCategoriaFiltro(key),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.textDark.withOpacity(0.7)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textDark.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rascunho = state.rascunhoAtual;
    final atividades = state.atividades;

    final countTodos = atividades.length;
    final countAdivinhacao = atividades.where((a) => a.tipoJogo == 'JOGO_ADIVINHACAO').length;
    final countPalavras = atividades.where((a) => a.tipoJogo == 'JOGO_PALAVRAS').length;

    final atividadesExibidas = atividades.where((a) {
      if (viewModel.categoriaFiltro == 'JOGO_ADIVINHACAO') return a.tipoJogo == 'JOGO_ADIVINHACAO';
      if (viewModel.categoriaFiltro == 'JOGO_PALAVRAS') return a.tipoJogo == 'JOGO_PALAVRAS';
      return true;
    }).toList()
      ..sort((a, b) => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Gestão de Jogos e Atividades',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Crie novos temas para os jogos de Adivinhação e Palavras',
                    style: TextStyle(fontSize: 14, color: AppColors.textDark),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => viewModel.initCreationForm(),
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text(
                  'Criar Nova Atividade',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Card de Rascunho se houver progresso salvo
          if (rascunho != null)
            Card(
              color: AppColors.secondaryLight.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.secondary, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.history_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Você possui um cadastro em andamento! 💾',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                          Text(
                            'Tema: ${rascunho.titulo.isEmpty ? "Sem Título" : rascunho.titulo} • ${rascunho.itens.length} itens cadastrados',
                            style: TextStyle(fontSize: 14, color: AppColors.textDark.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      onPressed: () => state.descartarRascunho(),
                      child: const Text('Descartar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                      onPressed: () => viewModel.initCreationForm(existingAtividade: rascunho),
                      icon: const Icon(Icons.edit_rounded, color: Colors.white),
                      label: const Text('Continuar Cadastro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),

          if (rascunho != null) const SizedBox(height: 20),

          // Seletor de Categorias por Tipo de Jogo
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.bgSoft,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                _buildCategoriaChip('TODOS', 'Todos os Jogos ($countTodos)', Icons.apps_rounded),
                const SizedBox(width: 6),
                _buildCategoriaChip('JOGO_ADIVINHACAO', 'Adivinhação ($countAdivinhacao)', Icons.pets_rounded),
                const SizedBox(width: 6),
                _buildCategoriaChip('JOGO_PALAVRAS', 'Jogo de Palavras ($countPalavras)', Icons.diversity_3_rounded),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Lista de Atividades
          if (atividadesExibidas.isEmpty)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: const Padding(
                padding: EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    Icon(Icons.gamepad_rounded, size: 64, color: AppColors.primaryLight),
                    SizedBox(height: 16),
                    Text('Nenhuma atividade encontrada nesta categoria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Clique no botão "Criar Nova Atividade" acima para cadastrar.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textDark)),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: atividadesExibidas.length,
              itemBuilder: (context, index) {
                final atv = atividadesExibidas[index];
                final isAdivinhacao = atv.tipoJogo == 'JOGO_ADIVINHACAO';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isAdivinhacao ? AppColors.accent : AppColors.info).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        atv.icone != null && atv.icone!.isNotEmpty
                            ? IconPickerDialogWidget.getIconData(atv.icone)
                            : (isAdivinhacao ? Icons.drag_indicator_rounded : Icons.collections_rounded),
                        color: isAdivinhacao ? AppColors.accent : AppColors.info,
                        size: 32,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(atv.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: atv.ativo ? AppColors.accentLight : AppColors.errorLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            atv.ativo ? 'Ativo' : 'Inativo',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: atv.ativo ? AppColors.accent : AppColors.error),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        'Tipo: ${isAdivinhacao ? 'Adivinhação (Libras)' : 'Jogo de Palavras (Associação)'}  •  ${atv.itens.length} palavra(s) cadastrada(s)',
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: atv.ativo,
                          activeColor: AppColors.accent,
                          onChanged: (val) => state.toggleAtividadeStatus(atv.id!, val),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                          onPressed: () => viewModel.initCreationForm(existingAtividade: atv),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Excluir Atividade?'),
                                content: Text('Tem certeza que deseja excluir "${atv.titulo}"?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      state.deleteAtividade(atv.id!);
                                    },
                                    child: const Text('Excluir', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
