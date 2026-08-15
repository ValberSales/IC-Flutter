import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/usuario.dart';
import '../../../../state/app_state_provider.dart';
import 'users/user_card_widget.dart';
import 'users/user_create_dialog.dart';
import 'users/user_edit_dialog.dart';
import 'users/reset_password_dialog.dart';

class ProfessorUsersTabWidget extends StatefulWidget {
  final AppStateProvider state;

  const ProfessorUsersTabWidget({super.key, required this.state});

  @override
  State<ProfessorUsersTabWidget> createState() => _ProfessorUsersTabWidgetState();
}

class _ProfessorUsersTabWidgetState extends State<ProfessorUsersTabWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    widget.state.loadUsuarios();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmarExclusao(Usuario user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Excluir Usuário', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Tem certeza que deseja excluir o usuário "${user.nome ?? user.username}"?\n\n'
          'Esta ação removerá a conta e todo o histórico associado permanentemente.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.state.deleteUser(user.id!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Usuário excluído com sucesso.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuarios = widget.state.usuarios.where((u) {
      if (_filtro.isEmpty) return true;
      final q = _filtro.toLowerCase();
      final nome = (u.nome ?? '').toLowerCase();
      final username = (u.username ?? '').toLowerCase();
      final codigo = (u.codigoIdentificador ?? '').toLowerCase();
      return nome.contains(q) || username.contains(q) || codigo.contains(q);
    }).toList();

    final currentUserId = widget.state.currentUser?.id;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho da Aba de Usuários
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.people_alt_rounded, color: Colors.purple, size: 30),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gestão de Contas e Acessos',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Visualize todos os alunos e professores cadastrados, crie novos acessos, resete senhas e gerencie permissões.',
                              style: TextStyle(fontSize: 13, color: AppColors.textDark),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        onPressed: () => UserCreateDialog.show(context, widget.state),
                        icon: const Icon(Icons.person_add_rounded, size: 20),
                        label: const Text('Novo Usuário', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Barra de Pesquisa
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _filtro = val),
                decoration: InputDecoration(
                  hintText: 'Pesquisar usuário por nome ou @username...',
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

              // Lista de Usuários
              if (usuarios.isEmpty)
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(Icons.person_search_rounded, size: 64, color: Colors.purple.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        Text(
                          _filtro.isEmpty ? 'Nenhum usuário cadastrado.' : 'Nenhum usuário encontrado.',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    final user = usuarios[index];
                    final isMe = user.id == currentUserId;

                    return UserCardWidget(
                      user: user,
                      isMe: isMe,
                      onEdit: () => UserEditDialog.show(context, widget.state, user),
                      onResetPassword: () => ResetPasswordDialog.confirmAndReset(context, widget.state, user),
                      onDelete: () => _confirmarExclusao(user),
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
