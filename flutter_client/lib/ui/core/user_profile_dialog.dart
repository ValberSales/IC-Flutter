import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../state/app_state_provider.dart';
import 'avatar_selector_dialog.dart';
import 'logout_helper.dart';

class UserProfileDialog extends StatefulWidget {
  const UserProfileDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const UserProfileDialog(),
    );
  }

  @override
  State<UserProfileDialog> createState() => _UserProfileDialogState();
}

class _UserProfileDialogState extends State<UserProfileDialog> {
  bool _isEditingAccount = false;
  bool _isSaving = false;
  String? _errorMessage;

  late TextEditingController _nomeController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppStateProvider>();
    final user = state.currentUser;
    _nomeController = TextEditingController(text: user?.nome ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _salvarAlteracoes(AppStateProvider state) async {
    final nome = _nomeController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty) {
      setState(() => _errorMessage = 'O nome de usuário não pode ficar em branco.');
      return;
    }

    if (password.isNotEmpty && password != confirmPassword) {
      setState(() => _errorMessage = 'A confirmação de senha não confere com a nova senha.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final result = await state.updateAccountDetails(
      nome: nome,
      username: username,
      newPassword: password.isNotEmpty ? password : null,
    );

    setState(() => _isSaving = false);

    if (result['success'] == true) {
      if (result['loginDataChanged'] == true) {
        if (mounted) {
          Navigator.of(context).pop(); // Fecha o diálogo
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] as String),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 4),
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] as String),
              backgroundColor: AppColors.secondary,
            ),
          );
          setState(() {
            _isEditingAccount = false;
            _passwordController.clear();
            _confirmPasswordController.clear();
          });
        }
      }
    } else {
      setState(() {
        _errorMessage = result['error'] as String? ?? 'Erro ao salvar alterações.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final user = state.currentUser;
    final isGuest = state.isGuestMode || user == null;
    final avatar = isGuest
        ? (state.activePersonagem?.avatar ?? 'assets/avatar/avatar_1.jpg')
        : (user.avatar ?? 'assets/avatar/avatar_1.jpg');
    final nome = isGuest
        ? (state.activePersonagem?.nome ?? 'Pequeno Aprendiz')
        : (user.nome ?? user.username ?? 'Aluno');
    final username = isGuest ? 'Convidado' : (user.username ?? '');
    final idCode = isGuest ? 'Modo Convidado' : (user.codigoIdentificador ?? 'ID #${user.id ?? 1}');
    final role = isGuest ? 'VISITANTE' : (user.role ?? 'USER');

    // Estatísticas de pontuação
    final history = state.getPontuacaoHistoryForActivePersonagem();
    int totalAcertos = 0;
    int totalErros = 0;
    for (final p in history) {
      totalAcertos += p.acertos;
      totalErros += p.erros;
    }
    final int totalJogadas = totalAcertos + totalErros;
    final double taxaAcerto = totalJogadas > 0 ? (totalAcertos / totalJogadas) * 100 : 0.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header do Dialog
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_pin_rounded, color: AppColors.primary, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        isGuest ? 'Perfil do Visitante' : (_isEditingAccount ? 'Editar Conta' : 'Meu Perfil'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Avatar Central com botão de troca
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 44,
                        backgroundImage: AssetImage(avatar),
                      ),
                    ),
                    if (!isGuest)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () async {
                            final selected = await AvatarSelectorDialog.show(context, avatar);
                            if (selected != null && selected != avatar) {
                              await state.updateUserProfile(avatar: selected);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Se estiver no modo de edição de dados/senha
              if (_isEditingAccount && !isGuest) ...[
                _buildEditAccountForm(state),
              ] else ...[
                // Exibição normal do perfil
                Center(
                  child: Column(
                    children: [
                      Text(
                        nome,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '@$username',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: role == 'ADMIN'
                                  ? Colors.purple.withOpacity(0.15)
                                  : AppColors.secondary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              role == 'ADMIN' ? '👑 Professor / Admin' : '⭐ Aluno',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: role == 'ADMIN' ? Colors.purple : AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ID Único: $idCode',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Card de Estatísticas de Jogadas
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgSoft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Partidas', '${history.length}', Icons.sports_esports_rounded, AppColors.primary),
                      _buildStatItem('Acertos', '$totalAcertos', Icons.check_circle_rounded, AppColors.secondary),
                      _buildStatItem('Aproveitamento', '${taxaAcerto.toStringAsFixed(0)}%', Icons.stars_rounded, AppColors.accent),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Botão para abrir formulário de edição de nome, usuário e senha
                if (!isGuest) ...[
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.secondary, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      setState(() {
                        _nomeController.text = user.nome ?? '';
                        _usernameController.text = user.username ?? '';
                        _passwordController.clear();
                        _confirmPasswordController.clear();
                        _errorMessage = null;
                        _isEditingAccount = true;
                      });
                    },
                    icon: const Icon(Icons.manage_accounts_rounded),
                    label: const Text('Editar Nome, Usuário ou Senha', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                ],

                // Botão de Sair / Logout
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error.withOpacity(0.12),
                    foregroundColor: AppColors.error,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await LogoutHelper.executeLogout(context, state);
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(
                    isGuest ? 'Sair do Modo Convidado' : 'Sair da Conta',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Formulário de Edição de Conta e Senha
  Widget _buildEditAccountForm(AppStateProvider state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Campo Nome Exibido
        TextField(
          controller: _nomeController,
          decoration: InputDecoration(
            labelText: 'Nome do Aluno / Professor',
            prefixIcon: const Icon(Icons.person_rounded, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.bgSoft,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),

        // Campo Nome de Usuário
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: 'Nome de Usuário (@username)',
            prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.bgSoft,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),

        // Campo Nova Senha
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Nova Senha (deixe vazio para manter a atual)',
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: Colors.grey,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: AppColors.bgSoft,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),

        // Campo Confirmar Nova Senha
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
            fillColor: AppColors.bgSoft,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 18),

        // Botões Salvar e Cancelar
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _isSaving ? null : () => setState(() => _isEditingAccount = false),
                child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isSaving ? null : () => _salvarAlteracoes(state),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Salvar Dados',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textDark, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
