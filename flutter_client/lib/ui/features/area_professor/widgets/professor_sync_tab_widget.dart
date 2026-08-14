import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../state/app_state_provider.dart';
import '../view_models/area_professor_view_model.dart';

class ProfessorSyncTabWidget extends StatefulWidget {
  final AreaProfessorViewModel viewModel;
  final AppStateProvider state;

  const ProfessorSyncTabWidget({
    super.key,
    required this.viewModel,
    required this.state,
  });

  @override
  State<ProfessorSyncTabWidget> createState() => _ProfessorSyncTabWidgetState();
}

class _ProfessorSyncTabWidgetState extends State<ProfessorSyncTabWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.state.activeTurma?.codigo ?? '');
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final res = await widget.viewModel.syncClassroom(_codeController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res),
          backgroundColor: res.startsWith('Sucesso') ? AppColors.accent : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final state = widget.state;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.connect_without_contact_rounded, size: 80, color: AppColors.primary),
                    const SizedBox(height: 16),
                    const Text(
                      'Vincular com o Servidor',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Digite o código fornecido pelo sistema do educador para sincronizar turmas e atividades.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: AppColors.textDark.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Código da Turma',
                        hintText: 'Ex: 12345',
                        prefixIcon: Icon(Icons.vpn_key_rounded),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Por favor, insira o código.' : null,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.infoLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.info.withOpacity(0.5)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.info),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Dica de Teste: Digite o código "12345" para simular a sincronização com sucesso.',
                              style: TextStyle(fontSize: 13, color: AppColors.textDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (vm.syncStatusMessage != null) ...[
                      Text(
                        vm.syncStatusMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: vm.syncStatusMessage!.startsWith('Sucesso') ? AppColors.accent : AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (vm.isSyncLoading)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Vincular Turma'),
                      ),
                      if (state.activeTurma != null) ...[
                        const SizedBox(height: 12),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          onPressed: () async {
                            await vm.unlinkClassroom();
                            _codeController.clear();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Turma desvinculada.'), backgroundColor: AppColors.info),
                              );
                            }
                          },
                          child: const Text('Desvincular Turma', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
