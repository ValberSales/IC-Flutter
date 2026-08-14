import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../view_models/home_view_model.dart';
import 'avatar_picker_dialog.dart';

class CharacterFormWidget extends StatefulWidget {
  final HomeViewModel viewModel;

  const CharacterFormWidget({super.key, required this.viewModel});

  @override
  State<CharacterFormWidget> createState() => _CharacterFormWidgetState();
}

class _CharacterFormWidgetState extends State<CharacterFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.viewModel.personagemEdicao.nome);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  void _mudarAvatar() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => AvatarPickerDialog(currentAvatar: widget.viewModel.personagemEdicao.avatar),
    );
    if (selected != null) {
      widget.viewModel.setAvatar(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final p = vm.personagemEdicao;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Criar Novo Avatar',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(p.avatar),
                      ),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white),
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: _mudarAvatar,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Aluno',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Por favor, insira o nome.' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: p.dificuldade,
                    decoration: const InputDecoration(
                      labelText: 'Nível de Dificuldade',
                      prefixIcon: Icon(Icons.tune_rounded),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'FACIL', child: Text('Fácil (com legendas)')),
                      DropdownMenuItem(value: 'MEDIO', child: Text('Médio (desafio balanceado)')),
                      DropdownMenuItem(value: 'DIFICIL', child: Text('Difícil (sem dicas)')),
                    ],
                    onChanged: (val) {
                      if (val != null) vm.setDificuldade(val);
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => vm.setEtapa(ETelaInicial.selecaoPersonagem),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          await vm.savePersonagem(_nomeController.text);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Avatar salvo com sucesso!'), backgroundColor: AppColors.accent),
                            );
                          }
                        },
                        child: const Text('Salvar'),
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
