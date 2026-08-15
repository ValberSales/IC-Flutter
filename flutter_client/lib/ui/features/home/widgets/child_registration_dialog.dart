import 'package:flutter/material.dart';
import 'package:flutter_client/core/constants/app_colors.dart';
import 'package:flutter_client/ui/core/avatar_selector_dialog.dart';
import '../view_models/home_view_model.dart';

class ChildRegistrationDialog extends StatefulWidget {
  final HomeViewModel viewModel;
  final VoidCallback onRegistrationSuccess;

  const ChildRegistrationDialog({
    super.key,
    required this.viewModel,
    required this.onRegistrationSuccess,
  });

  static Future<void> show(BuildContext context, HomeViewModel viewModel, VoidCallback onRegistrationSuccess) {
    return showDialog(
      context: context,
      builder: (ctx) => ChildRegistrationDialog(
        viewModel: viewModel,
        onRegistrationSuccess: onRegistrationSuccess,
      ),
    );
  }

  @override
  State<ChildRegistrationDialog> createState() => _ChildRegistrationDialogState();
}

class _ChildRegistrationDialogState extends State<ChildRegistrationDialog> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedAvatar = 'assets/avatar/avatar_1.png';
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nomeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nome = _nomeController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (nome.isEmpty || username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Por favor, preencha todos os campos.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await widget.viewModel.cadastrarAluno(
      nome: nome,
      username: username,
      password: password,
      avatar: _selectedAvatar,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop();
      widget.onRegistrationSuccess();
    } else {
      setState(() {
        _errorMessage = widget.viewModel.errorMessage ?? 'Erro ao realizar cadastro.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.stars_rounded, color: AppColors.secondary, size: 26),
                      SizedBox(width: 8),
                      Text(
                        'Criar Meu Perfil',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 20),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Seletor de Avatar
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.secondary, width: 3),
                          ),
                          child: CircleAvatar(
                            radius: 38,
                            backgroundImage: AssetImage(_selectedAvatar),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () async {
                              final avatar = await AvatarSelectorDialog.show(context, _selectedAvatar);
                              if (avatar != null) {
                                setState(() => _selectedAvatar = avatar);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.palette_rounded, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () async {
                        final avatar = await AvatarSelectorDialog.show(context, _selectedAvatar);
                        if (avatar != null) {
                          setState(() => _selectedAvatar = avatar);
                        }
                      },
                      child: const Text('Escolher Personagem', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Como você se chama?',
                  hintText: 'Ex: Lucas',
                  prefixIcon: const Icon(Icons.face_rounded, color: AppColors.secondary),
                  filled: true,
                  fillColor: AppColors.bgSoft,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nome de Usuário (@usuario)',
                  hintText: 'Ex: lucas123',
                  prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.secondary),
                  filled: true,
                  fillColor: AppColors.bgSoft,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Crie uma Senha',
                  prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.secondary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: AppColors.bgSoft,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Criar e Começar a Jogar! 🚀',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
