import 'package:flutter/material.dart';
import 'package:flutter_client/core/constants/app_colors.dart';
import 'package:flutter_client/data/models/atividade.dart';
import 'package:flutter_client/state/app_state_provider.dart';
import 'package:flutter_client/ui/core/icon_picker_dialog.dart';
import 'package:flutter_client/ui/features/area_professor/view_models/area_professor_view_model.dart';

class ActivityCardItemWidget extends StatelessWidget {
  final Atividade atv;
  final AreaProfessorViewModel viewModel;
  final AppStateProvider state;

  const ActivityCardItemWidget({
    super.key,
    required this.atv,
    required this.viewModel,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final isAdivinhacao = atv.tipoJogo == 'JOGO_ADIVINHACAO';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: atv.ativo
              ? (isAdivinhacao ? AppColors.accent.withValues(alpha: 0.4) : AppColors.info.withValues(alpha: 0.4))
              : AppColors.error.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: (isAdivinhacao ? AppColors.accent : AppColors.info).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            atv.icone != null && atv.icone!.isNotEmpty
                ? IconPickerDialogWidget.getIconData(atv.icone)
                : (isAdivinhacao ? Icons.drag_indicator_rounded : Icons.collections_rounded),
            color: isAdivinhacao ? AppColors.accent : AppColors.info,
            size: 26,
          ),
        ),
        title: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(atv.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // Badge Status Global
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: atv.ativo ? AppColors.accentLight : AppColors.errorLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    atv.ativo ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    size: 13,
                    color: atv.ativo ? AppColors.accent : AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    atv.ativo ? 'Ativo' : 'Inativo',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: atv.ativo ? AppColors.accent : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            // Badge Visibilidade
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: atv.publica
                    ? AppColors.primaryLight.withValues(alpha: 0.2)
                    : Colors.amber.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    atv.publica ? Icons.public_rounded : Icons.lock_rounded,
                    size: 13,
                    color: atv.publica ? AppColors.primaryDark : Colors.amber.shade900,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    atv.publica ? 'Pública' : 'Privada (Turmas)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: atv.publica ? AppColors.primaryDark : Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tipo: ${isAdivinhacao ? 'Adivinhação (Libras)' : 'Jogo de Palavras (Associação)'}  •  ${atv.itens.length} palavra(s)',
                style: TextStyle(fontSize: 13, color: AppColors.textDark.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: 2),
              Text(
                !atv.ativo
                    ? '⚠️ Desativado globalmente (não aparece para ninguém).'
                    : (atv.publica
                        ? '🌐 Visível para convidados e turmas.'
                        : '🔒 Visível somente para turmas com tema direcionado.'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: !atv.ativo
                      ? AppColors.error
                      : (atv.publica ? AppColors.primary : Colors.amber.shade900),
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Toggle 1: Pública / Privada
            Tooltip(
              message: atv.publica
                  ? 'Tornar Privada (exclusiva para turmas direcionadas)'
                  : 'Tornar Pública (visível para convidados e todos)',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: atv.publica
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: atv.publica
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : Colors.amber.shade700.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      atv.publica ? Icons.public_rounded : Icons.lock_rounded,
                      size: 16,
                      color: atv.publica ? AppColors.primary : Colors.amber.shade900,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      atv.publica ? 'Pública' : 'Privada',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: atv.publica ? AppColors.primary : Colors.amber.shade900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Switch(
                      value: atv.publica,
                      activeThumbColor: AppColors.primary,
                      inactiveThumbColor: Colors.amber.shade800,
                      inactiveTrackColor: Colors.amber.shade200,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (val) => state.toggleAtividadePublica(atv.id!, val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Toggle 2: Ativo / Inativo Global
            Tooltip(
              message: atv.ativo
                  ? 'Desativar tema globalmente'
                  : 'Ativar tema no sistema',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: atv.ativo
                      ? AppColors.accent.withValues(alpha: 0.08)
                      : AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: atv.ativo
                        ? AppColors.accent.withValues(alpha: 0.3)
                        : AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      atv.ativo ? Icons.power_settings_new_rounded : Icons.power_off_rounded,
                      size: 16,
                      color: atv.ativo ? AppColors.accent : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      atv.ativo ? 'Ativa' : 'Inativa',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: atv.ativo ? AppColors.accent : AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Switch(
                      value: atv.ativo,
                      activeThumbColor: AppColors.accent,
                      inactiveThumbColor: AppColors.error,
                      inactiveTrackColor: AppColors.errorLight,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (val) => state.toggleAtividadeStatus(atv.id!, val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            IconButton(
              tooltip: 'Editar Tema',
              icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
              onPressed: () => viewModel.initCreationForm(existingAtividade: atv),
            ),
            IconButton(
              tooltip: 'Excluir Tema',
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
  }
}
