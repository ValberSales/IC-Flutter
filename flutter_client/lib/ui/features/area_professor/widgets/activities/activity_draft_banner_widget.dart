import 'package:flutter/material.dart';
import 'package:flutter_client/core/constants/app_colors.dart';
import 'package:flutter_client/data/models/atividade.dart';
import 'package:flutter_client/state/app_state_provider.dart';
import 'package:flutter_client/ui/features/area_professor/view_models/area_professor_view_model.dart';

class ActivityDraftBannerWidget extends StatelessWidget {
  final Atividade rascunho;
  final AreaProfessorViewModel viewModel;
  final AppStateProvider state;

  const ActivityDraftBannerWidget({
    super.key,
    required this.rascunho,
    required this.viewModel,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_note_rounded, color: AppColors.secondary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Você tem um rascunho não salvo!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tema: "${rascunho.titulo.isNotEmpty ? rascunho.titulo : 'Sem título'}" (${rascunho.itens.length} palavras cadastradas)',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textDark.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                state.descartarRascunho();
              },
              child: const Text('Descartar'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => viewModel.initCreationForm(existingAtividade: rascunho),
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text('Continuar Edição'),
            ),
          ],
        ),
      ),
    );
  }
}
