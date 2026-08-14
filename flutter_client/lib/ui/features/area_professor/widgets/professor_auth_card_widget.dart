import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/usuario.dart';
import '../view_models/area_professor_view_model.dart';

class ProfessorAuthCardWidget extends StatefulWidget {
  final AreaProfessorViewModel viewModel;

  const ProfessorAuthCardWidget({super.key, required this.viewModel});

  @override
  State<ProfessorAuthCardWidget> createState() => _ProfessorAuthCardWidgetState();
}

class _ProfessorAuthCardWidgetState extends State<ProfessorAuthCardWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = widget.viewModel;
    if (vm.isLoginMode) {
      await vm.login(_usernameController.text.trim(), _passwordController.text);
    } else {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('As senhas não coincidem.'), backgroundColor: AppColors.error),
        );
        return;
      }
      final user = Usuario(
        nome: _nameController.text.trim(),
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      await vm.register(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;

    return Center(
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
                  Icon(
                    vm.isLoginMode ? Icons.lock_person_rounded : Icons.person_add_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    vm.isLoginMode ? 'Área do Professor' : 'Crie sua Conta',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vm.isLoginMode
                        ? 'Faça login para acompanhar o progresso dos seus alunos e gerenciar turmas.'
                        : 'Cadastre-se para sincronizar salas de aula e criar atividades personalizadas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: AppColors.textDark.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 24),
                  if (!vm.isLoginMode) ...[
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Nome Completo', prefixIcon: Icon(Icons.person_outline)),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Por favor, insira seu nome.' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.email_outlined)),
                      validator: (v) => (v == null || !v.contains('@')) ? 'Por favor, insira um e-mail válido.' : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Usuário (username)', prefixIcon: Icon(Icons.alternate_email_rounded)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Por favor, insira um usuário.' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: vm.obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(vm.obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: vm.togglePasswordVisibility,
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6) ? 'A senha deve ter ao menos 6 caracteres.' : null,
                  ),
                  if (!vm.isLoginMode) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: vm.obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Senha',
                        prefixIcon: const Icon(Icons.lock_reset_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(vm.obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: vm.toggleConfirmPasswordVisibility,
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Confirme sua senha.' : null,
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (vm.authError != null) ...[
                    Text(vm.authError!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                  ],
                  if (vm.isAuthLoading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(vm.isLoginMode ? 'Entrar' : 'Cadastrar'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: vm.toggleLoginMode,
                      child: Text(
                        vm.isLoginMode ? 'Não tem uma conta? Cadastre-se' : 'Já tem uma conta? Faça Login',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
