import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/usuario.dart';
import '../../../../../state/app_state_provider.dart';

class UserEditDialog extends StatefulWidget {
  final Usuario user;
  final AppStateProvider state;

  const UserEditDialog({
    super.key,
    required this.user,
    required this.state,
  });

  static Future<void> show(BuildContext context, AppStateProvider state, Usuario user) {
    return showDialog(
      context: context,
      builder: (_) => UserEditDialog(user: user, state: state),
    );
  }

  @override
  State<UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<UserEditDialog> {
  late TextEditingController _nomeController;
  late bool _isAdmin;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.user.nome ?? '');
    _isAdmin = widget.user.isAdmin;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    setState(() => _isSaving = true);
    final novoNome = _nomeController.text.trim();
    final novaRole = _isAdmin ? 'ADMIN' : 'USER';

    widget.user.nome = novoNome;
    widget.user.role = novaRole;
    await widget.state.updateUserRole(widget.user.id!, novaRole);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário atualizado com sucesso!'),
          backgroundColor: AppColors.secondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(widget.user.avatar ?? 'assets/avatar/avatar_1.jpg'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Editar Usuário', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  '@${widget.user.username ?? ''} (${widget.user.codigoIdentificador ?? 'ID #${widget.user.id}'})',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome do Aluno / Professor',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _isAdmin ? Colors.purple.withOpacity(0.08) : AppColors.bgSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isAdmin ? Colors.purple.withOpacity(0.4) : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Acesso de Administrador',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isAdmin ? Colors.purple : AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isAdmin
                                ? 'Perfil com acesso à Área do Professor e criação de temas.'
                                : 'Perfil padrão de aluno (USER).',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textDark.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isAdmin,
                      activeColor: Colors.purple,
                      onChanged: (val) => setState(() => _isAdmin = val),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _isSaving ? null : _salvar,
          child: _isSaving
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Salvar'),
        ),
      ],
    );
  }
}
