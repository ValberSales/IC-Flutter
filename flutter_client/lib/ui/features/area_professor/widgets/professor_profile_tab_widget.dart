import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../state/app_state_provider.dart';
import '../../../core/avatar_selector_dialog.dart';
import '../../../core/logout_helper.dart';
import '../../../core/sobre_projeto_dialog.dart';

class ProfessorProfileTabWidget extends StatefulWidget {
  final AppStateProvider state;

  const ProfessorProfileTabWidget({super.key, required this.state});

  @override
  State<ProfessorProfileTabWidget> createState() => _ProfessorProfileTabWidgetState();
}

class _ProfessorProfileTabWidgetState extends State<ProfessorProfileTabWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  String? _selectedAvatar;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final user = widget.state.currentUser;
    _nomeController = TextEditingController(text: user?.nome ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _selectedAvatar = user?.avatar ?? 'assets/avatar/avatar_1.png';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _salvarAlteracoes() async {
    final nome = _nomeController.text.trim();
    final username = _usernameController.text.trim();
    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (nome.isEmpty) {
      setState(() => _errorMessage = 'O nome de exibição não pode estar vazio.');
      return;
    }

    if (username.isEmpty) {
      setState(() => _errorMessage = 'O nome de usuário não pode estar vazio.');
      return;
    }

    if (newPassword.isNotEmpty) {
      if (newPassword.length < 3) {
        setState(() => _errorMessage = 'A nova senha deve ter no mínimo 3 caracteres.');
        return;
      }
      if (newPassword != confirmPassword) {
        setState(() => _errorMessage = 'As senhas não coincidem.');
        return;
      }
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final res = await widget.state.updateAccountDetails(
      nome: nome,
      username: username,
      newPassword: newPassword.isNotEmpty ? newPassword : null,
      avatar: _selectedAvatar,
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (res['success'] == true) {
      final loginDataChanged = res['loginDataChanged'] == true;
      if (loginDataChanged) {
        // Redireciona para a tela inicial / login após alteração de credenciais
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Credenciais alteradas com sucesso! Faça login novamente.'),
            backgroundColor: AppColors.accent,
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Perfil atualizado com sucesso!'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = res['error'] ?? 'Erro ao atualizar dados.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.state.currentUser;
    final currentAvatar = _selectedAvatar ?? user?.avatar ?? 'assets/avatar/avatar_1.png';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Título e Cabeçalho do Perfil
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.manage_accounts_rounded, color: Colors.purple, size: 28),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Meu Perfil de Professor',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Gerencie seus dados de acesso, nome, avatar e credenciais de segurança.',
                                style: TextStyle(fontSize: 13, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 36),

                    // Seção de Avatar
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.purple, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purple.withOpacity(0.2),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: AssetImage(currentAvatar),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () async {
                                    final selected = await AvatarSelectorDialog.show(context, currentAvatar);
                                    if (selected != null && selected != currentAvatar) {
                                      setState(() => _selectedAvatar = selected);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            onPressed: () async {
                              final selected = await AvatarSelectorDialog.show(context, currentAvatar);
                              if (selected != null && selected != currentAvatar) {
                                setState(() => _selectedAvatar = selected);
                              }
                            },
                            icon: const Icon(Icons.palette_rounded, size: 18),
                            label: const Text('Alterar Avatar', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Badge de Cargo / Role
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.purple.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_user_rounded, color: Colors.purple, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Acesso: ${user?.role ?? "ADMIN (Professor)"}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Mensagem de Erro (se houver)
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Campo Nome de Exibição
                    const Text(
                      'Nome Completo / Exibido',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nomeController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Prof. Valber Sales',
                        prefixIcon: const Icon(Icons.person_rounded, color: AppColors.primary),
                        filled: true,
                        fillColor: AppColors.bgSoft,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo Nome de Usuário (Username)
                    const Text(
                      'Nome de Usuário (@username)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Ex: prof_valber',
                        prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.primary),
                        filled: true,
                        fillColor: AppColors.bgSoft,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Seção de Alteração de Senha
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.bgSoft,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Alteração de Senha',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Deixe os campos abaixo em branco se desejar manter a senha atual.',
                            style: TextStyle(fontSize: 12, color: AppColors.textDark.withOpacity(0.65)),
                          ),
                          const SizedBox(height: 14),

                          // Nova Senha
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Nova Senha',
                              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Confirmar Nova Senha
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirmar Nova Senha',
                              prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Botão Salvar Alterações
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isSaving ? null : _salvarAlteracoes,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.save_rounded, size: 22),
                      label: Text(
                        _isSaving ? 'Salvando...' : 'Salvar Alterações do Perfil',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Divider(),
                    const SizedBox(height: 12),

                    // Ações Secundárias (Sobre o Projeto e Sair da Conta)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => SobreProjetoDialog.show(context),
                            icon: const Icon(Icons.info_outline_rounded, size: 18),
                            label: const Text('Sobre o Projeto', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => LogoutHelper.executeLogout(context, widget.state),
                            icon: const Icon(Icons.logout_rounded, size: 18),
                            label: const Text('Sair da Conta', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
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
