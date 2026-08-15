import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../state/app_state_provider.dart';
import '../features/home/views/home_view.dart';
import 'profile/user_profile_avatar_widget.dart';
import 'profile/user_profile_edit_form_widget.dart';
import 'profile/user_profile_info_section_widget.dart';

/// Modal principal de visualização e edição de perfil de usuário.
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

  @override
  void initState() {
    super.initState();
    final state = context.read<AppStateProvider>();
    final user = state.currentUser;
    _nomeController = TextEditingController(text: user?.nome ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    if (user != null) {
      state.fetchAlunoTurmaOnline();
    }
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
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] as String),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 4),
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeView()),
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
    final avatar = user?.avatar ?? 'assets/avatar/avatar_1.png';

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

              // Avatar Central
              UserProfileAvatarWidget(
                avatar: avatar,
                isGuest: isGuest,
                onAvatarChanged: (newAvatar) async {
                  await state.updateUserProfile(avatar: newAvatar);
                },
              ),
              const SizedBox(height: 12),

              // Alternância entre visualização e formulário de edição
              if (_isEditingAccount && !isGuest)
                UserProfileEditFormWidget(
                  nomeController: _nomeController,
                  usernameController: _usernameController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  isSaving: _isSaving,
                  errorMessage: _errorMessage,
                  onCancel: () => setState(() => _isEditingAccount = false),
                  onSave: () => _salvarAlteracoes(state),
                )
              else
                UserProfileInfoSectionWidget(
                  user: user,
                  isGuest: isGuest,
                  state: state,
                  onEditRequested: () {
                    setState(() {
                      _nomeController.text = user?.nome ?? '';
                      _usernameController.text = user?.username ?? '';
                      _passwordController.clear();
                      _confirmPasswordController.clear();
                      _errorMessage = null;
                      _isEditingAccount = true;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
