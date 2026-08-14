import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/usuario.dart';
import '../../../../state/app_state_provider.dart';

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _abrirModalEdicao(Usuario user) {
    bool isAdmin = user.isAdmin;
    final nomeController = TextEditingController(text: user.nome ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(user.avatar ?? 'assets/avatar/avatar_1.jpg'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Editar Usuário', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        '@${user.username ?? ''} (${user.codigoIdentificador ?? 'ID #${user.id}'})',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nomeController,
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
                      color: isAdmin ? Colors.purple.withOpacity(0.08) : AppColors.bgSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isAdmin ? Colors.purple.withOpacity(0.4) : AppColors.border,
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
                                  color: isAdmin ? Colors.purple : AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isAdmin
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
                          value: isAdmin,
                          activeColor: Colors.purple,
                          onChanged: (val) {
                            setModalState(() {
                              isAdmin = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  user.nome = nomeController.text.trim();
                  user.role = isAdmin ? 'ADMIN' : 'USER';
                  await widget.state.updateUserRole(user.id!, user.role!);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Usuário atualizado com sucesso!'),
                        backgroundColor: AppColors.secondary,
                      ),
                    );
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmarResetSenha(Usuario user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_reset_rounded, color: AppColors.accent, size: 24),
            ),
            const SizedBox(width: 10),
            const Text('Resetar Senha', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          'Deseja resetar a senha de "${user.nome ?? user.username}"?\n\n'
          'Será gerada uma senha temporária de 6 dígitos. Ao fazer login com essa senha, o usuário terá que cadastrar uma nova senha imediatamente.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final tempPassword = await widget.state.resetUserPassword(user.id!);
              if (tempPassword != null && mounted) {
                _mostrarSenhaTemporariaGerada(user, tempPassword);
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erro ao resetar senha. Verifique a conexão.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            icon: const Icon(Icons.key_rounded, size: 18),
            label: const Text('Gerar Senha Temporária', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _mostrarSenhaTemporariaGerada(Usuario user, String tempPassword) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Center(
          child: Text('🔑 Senha Temporária Gerada', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'A senha de "${user.nome ?? user.username}" foi redefinida com sucesso. Repasse a senha temporária abaixo para o usuário:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textDark.withOpacity(0.8)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.bgSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: SelectableText(
                tempPassword,
                style: const TextStyle(
                  fontSize: 32,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '⚠️ Ao logar com esta senha, o sistema exigirá a troca imediata.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.check_rounded),
              label: const Text('Concluído', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarExclusao(Usuario user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o usuário "${user.nome ?? user.username}"? Esta ação removerá os dados de acesso.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Não'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.state.deleteUser(user.id!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Usuário removido com sucesso.'),
                    backgroundColor: AppColors.info,
                  ),
                );
              }
            },
            child: const Text('Sim, Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todosUsuarios = widget.state.usuarios;
    final usuariosFiltrados = todosUsuarios.where((u) {
      if (_filtro.trim().isEmpty) return true;
      final term = _filtro.trim().toLowerCase();
      final nome = (u.nome ?? '').toLowerCase();
      final username = (u.username ?? '').toLowerCase();
      final codigo = (u.codigoIdentificador ?? '').toLowerCase();
      return nome.contains(term) || username.contains(term) || codigo.contains(term);
    }).toList();

    return RefreshIndicator(
      onRefresh: () => widget.state.fetchUsuariosOnline(busca: _filtro.isNotEmpty ? _filtro : null),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header informativo
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.people_alt_rounded, color: AppColors.primary, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gestão de Usuários & Alunos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gerencie os perfis cadastrados, visualize o ID das crianças ou promova professores para Administrador.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textDark.withOpacity(0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Barra de Busca
            TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _filtro = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar por nome, @username ou ID único...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                suffixIcon: _filtro.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _filtro = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Contagem de resultados
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${usuariosFiltrados.length} usuário(s) encontrado(s)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                IconButton(
                  tooltip: 'Atualizar Lista',
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                  onPressed: () => widget.state.fetchUsuariosOnline(busca: _filtro.isNotEmpty ? _filtro : null),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista de Usuários
            if (usuariosFiltrados.isEmpty)
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      Icon(Icons.person_search_rounded, size: 56, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'Nenhum usuário encontrado',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tente buscar por outro termo ou cadastre novas crianças.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: usuariosFiltrados.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = usuariosFiltrados[index];
                  final isAdmin = user.isAdmin;

                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: isAdmin ? Colors.purple.withOpacity(0.3) : AppColors.border,
                        width: isAdmin ? 1.5 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundImage: AssetImage(user.avatar ?? 'assets/avatar/avatar_1.jpg'),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        user.nome ?? user.username ?? 'Sem nome',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isAdmin
                                            ? Colors.purple.withOpacity(0.12)
                                            : AppColors.secondary.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        isAdmin ? '👑 ADMIN' : '⭐ ALUNO',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: isAdmin ? Colors.purple : AppColors.secondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '@${user.username ?? ''}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('•', style: TextStyle(color: Colors.grey.shade400)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'ID: ${user.codigoIdentificador ?? '#${user.id}'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Resetar Senha (Gerar Senha Temporária)',
                            icon: const Icon(Icons.lock_reset_rounded, color: AppColors.accent),
                            onPressed: () => _confirmarResetSenha(user),
                          ),
                          IconButton(
                            tooltip: 'Editar Perfil & Privilégios',
                            icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                            onPressed: () => _abrirModalEdicao(user),
                          ),
                          IconButton(
                            tooltip: 'Excluir Usuário',
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                            onPressed: () => _confirmarExclusao(user),
                          ),
                        ],
                      ),
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
