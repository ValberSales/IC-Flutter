import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/usuario.dart';
import '../../../../../state/app_state_provider.dart';

class UserCreateDialog extends StatefulWidget {
  final AppStateProvider state;

  const UserCreateDialog({super.key, required this.state});

  static Future<void> show(BuildContext context, AppStateProvider state) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => UserCreateDialog(state: state),
    );
  }

  @override
  State<UserCreateDialog> createState() => _UserCreateDialogState();
}

class _UserCreateDialogState extends State<UserCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(text: '123456');

  String _selectedRole = 'USER';
  String _selectedAvatar = 'assets/avatar/avatar_1.jpg';
  bool _mustChangePassword = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final List<String> _avatares = [
    'assets/avatar/avatar_1.jpg',
    'assets/avatar/avatar_2.jpg',
    'assets/avatar/avatar_3.jpg',
    'assets/avatar/avatar_4.jpg',
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _salvarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final created = await widget.state.createUsuario(
        username: _usernameController.text.trim(),
        nome: _nomeController.text.trim(),
        password: _passwordController.text.trim().isEmpty ? '123456' : _passwordController.text.trim(),
        role: _selectedRole,
        avatar: _selectedAvatar,
        mustChangePassword: _mustChangePassword,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (created != null) {
          Navigator.of(context).pop();
          final prefixDesc = created.role == 'ADMIN' ? 'Professor/Admin' : 'Aluno';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 $prefixDesc "${created.nome}" criado com sucesso! ID: ${created.codigoIdentificador}'),
              backgroundColor: AppColors.accent,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao criar usuário. Verifique se o nome de usuário já existe.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _selectedRole == 'ADMIN';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_add_rounded, color: Colors.purple, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Adicionar Novo Usuário',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Seletor de Avatar
                const Text('Escolha o Avatar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _avatares.map((avatar) {
                    final isSelected = _selectedAvatar == avatar;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatar = avatar),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.purple : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundImage: AssetImage(avatar),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Tipo de Perfil / Acesso
                const Text('Tipo de Perfil / Acesso', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedRole = 'USER'),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                          decoration: BoxDecoration(
                            color: !isAdmin ? AppColors.primary.withOpacity(0.12) : AppColors.bgSoft,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: !isAdmin ? AppColors.primary : AppColors.border,
                              width: !isAdmin ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.school_rounded, color: !isAdmin ? AppColors.primary : AppColors.textDark.withOpacity(0.6), size: 22),
                              const SizedBox(height: 4),
                              Text(
                                'Aluno (USER)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: !isAdmin ? FontWeight.bold : FontWeight.w600,
                                  color: !isAdmin ? AppColors.primary : AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Gera ID: ALU-XXXX',
                                style: TextStyle(fontSize: 11, color: !isAdmin ? AppColors.primaryDark : AppColors.textDark.withOpacity(0.6)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedRole = 'ADMIN'),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                          decoration: BoxDecoration(
                            color: isAdmin ? Colors.purple.withOpacity(0.12) : AppColors.bgSoft,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isAdmin ? Colors.purple : AppColors.border,
                              width: isAdmin ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.admin_panel_settings_rounded, color: isAdmin ? Colors.purple : AppColors.textDark.withOpacity(0.6), size: 22),
                              const SizedBox(height: 4),
                              Text(
                                'Professor (ADMIN)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isAdmin ? FontWeight.bold : FontWeight.w600,
                                  color: isAdmin ? Colors.purple : AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Gera ID: ADM-XXXX',
                                style: TextStyle(fontSize: 11, color: isAdmin ? Colors.purple.shade700 : AppColors.textDark.withOpacity(0.6)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Nome Completo
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo',
                    hintText: 'Ex: Maria Silva ou João Lucas',
                    prefixIcon: Icon(Icons.person_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe o nome completo.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Username / Login
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome de Usuário (Login)',
                    hintText: 'Ex: maria_silva ou joao123',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe um nome de usuário.';
                    }
                    if (value.trim().contains(' ')) {
                      return 'O nome de usuário não pode conter espaços.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Senha Inicial
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Senha Inicial',
                    hintText: 'Padrão: 123456',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),

                // Checkbox: Exigir troca de senha
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Exigir alteração de senha no primeiro login', style: TextStyle(fontSize: 13)),
                  value: _mustChangePassword,
                  activeColor: Colors.purple,
                  onChanged: (val) => setState(() => _mustChangePassword = val ?? true),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 16),

                // Botões de Ação
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAdmin ? Colors.purple : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _isLoading ? null : _salvarUsuario,
                      icon: _isLoading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_rounded),
                      label: Text(_isLoading ? 'Criando...' : 'Criar Usuário', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
