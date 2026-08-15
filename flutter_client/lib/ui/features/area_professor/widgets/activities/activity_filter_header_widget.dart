import 'package:flutter/material.dart';
import 'package:flutter_client/core/constants/app_colors.dart';
import 'package:flutter_client/ui/features/area_professor/view_models/area_professor_view_model.dart';

class ActivityFilterHeaderWidget extends StatelessWidget {
  final AreaProfessorViewModel viewModel;
  final int countTodos;
  final int countAdivinhacao;
  final int countPalavras;

  const ActivityFilterHeaderWidget({
    super.key,
    required this.viewModel,
    required this.countTodos,
    required this.countAdivinhacao,
    required this.countPalavras,
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
    return Column(
      children: [
        // Card Cabeçalho
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.sports_esports_rounded, color: Colors.blue, size: 30),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gestão de Jogos e Atividades',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Crie novos temas para os jogos de Adivinhação e Palavras.',
                        style: TextStyle(fontSize: 13, color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                  onPressed: () => viewModel.initCreationForm(),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text(
                    'Criar Nova Atividade',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Barra de Filtros
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _buildCategoriaChip('TODOS', 'Todos ($countTodos)', Icons.apps_rounded),
              _buildCategoriaChip('JOGO_ADIVINHACAO', 'Adivinhação ($countAdivinhacao)', Icons.drag_indicator_rounded),
              _buildCategoriaChip('JOGO_PALAVRAS', 'Palavras ($countPalavras)', Icons.collections_rounded),
            ],
          ),
        ),
      ],
    );
  }
}
