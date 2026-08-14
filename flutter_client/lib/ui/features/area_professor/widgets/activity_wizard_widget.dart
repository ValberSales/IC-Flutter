import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/atividade.dart';
import '../../../../state/app_state_provider.dart';
import '../../../core/dynamic_image_widget.dart';
import '../../../core/icon_picker_dialog.dart';
import '../../../core/item_atividade_modal.dart';
import '../view_models/area_professor_view_model.dart';

class ActivityWizardWidget extends StatefulWidget {
  final AreaProfessorViewModel viewModel;
  final AppStateProvider state;

  const ActivityWizardWidget({
    super.key,
    required this.viewModel,
    required this.state,
  });

  @override
  State<ActivityWizardWidget> createState() => _ActivityWizardWidgetState();
}

class _ActivityWizardWidgetState extends State<ActivityWizardWidget> {
  late TextEditingController _tituloController;

  @override
  void initState() {
    super.initState();
    final atv = widget.state.atividades.where((a) => a.id == widget.viewModel.editingActivityId).firstOrNull;
    _tituloController = TextEditingController(text: atv?.titulo ?? widget.state.rascunhoAtual?.titulo ?? '');
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        vm.editingActivityId == null ? 'Nova Atividade / Tema' : 'Editar Atividade',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: vm.closeCreationForm,
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Passo 1: Informações Básicas
                  const Text(
                    '1. Informações da Atividade',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Tema / Título (ex: Frutas, Escola, Objetos)',
                      prefixIcon: Icon(Icons.label_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: vm.selectedTipoJogo,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Jogo',
                      prefixIcon: Icon(Icons.gamepad_rounded),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'JOGO_ADIVINHACAO', child: Text('Adivinhação (Libras)')),
                      DropdownMenuItem(value: 'JOGO_PALAVRAS', child: Text('Jogo de Palavras (Associação)')),
                    ],
                    onChanged: (val) {
                      if (val != null) vm.setTipoJogo(val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Seletor de Ícone Visual do Tema
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            IconPickerDialogWidget.getIconData(vm.selectedIconKey),
                            size: 30,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ícone Representativo do Tema',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Ícone atual: ${vm.selectedIconKey}',
                                style: TextStyle(fontSize: 12, color: AppColors.textDark.withOpacity(0.7)),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () async {
                            final selected = await showDialog<String>(
                              context: context,
                              builder: (ctx) => IconPickerDialogWidget(initialIconKey: vm.selectedIconKey),
                            );
                            if (selected != null) {
                              vm.setIconKey(selected);
                            }
                          },
                          icon: const Icon(Icons.palette_rounded, size: 18),
                          label: const Text('Escolher Ícone', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Passo 2: Palavras & Imagens
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '2. Palavras e Sinais do Tema',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          final newItem = await showDialog<ItemAtividade>(
                            context: context,
                            builder: (ctx) => ItemAtividadeModalWidget(tipoJogo: vm.selectedTipoJogo),
                          );
                          if (newItem != null) {
                            vm.addItem(newItem);
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                        label: const Text('Adicionar', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (vm.editingItens.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.bgSoft,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.primaryLight),
                          SizedBox(height: 12),
                          Text('Nenhuma palavra adicionada ainda.', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Clique no botão "+ Adicionar" acima para cadastrar as entradas.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vm.editingItens.length,
                      itemBuilder: (context, index) {
                        final item = vm.editingItens[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.bgSoft,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: DynamicImageWidget(imagePath: item.imagem, fit: BoxFit.contain),
                              ),
                            ),
                            title: Text(item.descricao, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: item.opcoes.isNotEmpty
                                  ? Text('Opções: ${item.opcoes.join(", ")}')
                                  : Text('Imagem: ${item.imagem}', maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                                  onPressed: () async {
                                    final updated = await showDialog<ItemAtividade>(
                                      context: context,
                                      builder: (ctx) => ItemAtividadeModalWidget(initialItem: item, tipoJogo: vm.selectedTipoJogo),
                                    );
                                    if (updated != null) {
                                      vm.updateItem(index, updated);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                  onPressed: () => vm.removeItem(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  const Divider(height: 36),

                  // Rodapé de Ações
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: vm.closeCreationForm,
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Voltar'),
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.secondary,
                              side: const BorderSide(color: AppColors.secondary, width: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                            onPressed: () async {
                              await vm.saveDraft(_tituloController.text);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('💾 Progresso salvo!'), backgroundColor: AppColors.secondary),
                                );
                              }
                            },
                            icon: const Icon(Icons.save_rounded),
                            label: const Text('Salvar Progresso', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                            onPressed: () async {
                              if (_tituloController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Informe o tema da atividade.'), backgroundColor: AppColors.error),
                                );
                                return;
                              }
                              if (vm.editingItens.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Adicione ao menos 1 item.'), backgroundColor: AppColors.error),
                                );
                                return;
                              }
                              await vm.publishActivity(_tituloController.text);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('🎉 Atividade publicada com sucesso!'), backgroundColor: AppColors.accent),
                                );
                              }
                            },
                            icon: const Icon(Icons.publish_rounded, color: Colors.white),
                            label: const Text('Publicar Atividade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
