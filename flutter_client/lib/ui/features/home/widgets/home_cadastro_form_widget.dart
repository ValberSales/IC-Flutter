import 'package:flutter/material.dart';
import 'package:flutter_client/core/constants/app_colors.dart';
import 'package:flutter_client/ui/core/avatar_selector_dialog.dart';
import '../view_models/home_view_model.dart';

class HomeCadastroFormWidget extends StatefulWidget {
  final HomeViewModel viewModel;

  const HomeCadastroFormWidget({
    super.key,
    required this.viewModel,
  });

  @override
  State<HomeCadastroFormWidget> createState() => _HomeCadastroFormWidgetState();
}

class _HomeCadastroFormWidgetState extends State<HomeCadastroFormWidget> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Criar Cadastro 🎉',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Não precisa de e-mail! Escolha seu avatar e crie sua conta:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textDark.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 16),

        // Seletor de Avatar Interativo
        Center(
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 38,
                  backgroundImage: AssetImage(vm.selectedAvatar),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () async {
                    final selected = await AvatarSelectorDialog.show(context, vm.selectedAvatar);
                    if (selected != null) {
                      vm.setSelectedAvatar(selected);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: TextButton.icon(
            onPressed: () async {
              final selected = await AvatarSelectorDialog.show(context, vm.selectedAvatar);
              if (selected != null) {
                vm.setSelectedAvatar(selected);
              }
            },
            icon: const Icon(Icons.face_retouching_natural_rounded, size: 16),
            label: const Text('Trocar Avatar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 10),

        if (vm.errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vm.errorMessage!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Campo Nome da Criança
        TextField(
          onChanged: vm.setCadastroNome,
          decoration: InputDecoration(
            labelText: 'Nome da Criança ou Professor (ex: Ana Clara)',
            prefixIcon: const Icon(Icons.person_rounded, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.bgSoft,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),

        // Campo Nome de Usuário (@username)
        TextField(
          onChanged: vm.setCadastroUsername,
          decoration: InputDecoration(
            labelText: 'Nome de Usuário (ex: anaclara)',
            prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.bgSoft,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),

        // Campo Senha
        TextField(
          onChanged: vm.setCadastroPassword,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Senha (simples para a criança lembrar)',
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 18),

        // Botão Cadastrar e Começar a Jogar
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            onPressed: vm.isLoading
                ? null
                : () async {
                    await vm.executeRegister();
                  },
            child: vm.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    'Cadastrar e Começar a Jogar 🚀',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
          ),
        ),
        const SizedBox(height: 10),

        // Botão Voltar ao Login
        TextButton(
          onPressed: () => vm.setCadastroMode(false),
          child: const Text(
            'Já tem cadastro? Voltar ao Login',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
