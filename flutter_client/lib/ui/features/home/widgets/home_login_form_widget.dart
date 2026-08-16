import 'package:flutter/material.dart';
import 'package:flutter_client/core/constants/app_colors.dart';
import '../view_models/home_view_model.dart';

class HomeLoginFormWidget extends StatefulWidget {
  final HomeViewModel viewModel;

  const HomeLoginFormWidget({
    super.key,
    required this.viewModel,
  });

  @override
  State<HomeLoginFormWidget> createState() => _HomeLoginFormWidgetState();
}

class _HomeLoginFormWidgetState extends State<HomeLoginFormWidget> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Entrar no Jogo 🚀',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Informe seu Usuário e Senha para carregar seu progresso:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textDark.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 20),

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
          const SizedBox(height: 16),
        ],

        // Campo Usuário
        TextField(
          onChanged: vm.setLoginIdentifier,
          decoration: InputDecoration(
            labelText: 'Nome de usuário (ex: @pedro)',
            prefixIcon: const Icon(Icons.person_rounded, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.bgSoft,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 14),

        // Campo Senha
        TextField(
          onChanged: vm.setLoginPassword,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Senha',
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
        const SizedBox(height: 20),

        // Botão Entrar
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            onPressed: vm.isLoading
                ? null
                : () async {
                    await vm.executeLogin();
                  },
            child: vm.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    'Entrar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
          ),
        ),
        const SizedBox(height: 12),

        // Botão Criar Cadastro
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          onPressed: () => vm.setCadastroMode(true),
          child: const Text(
            'Novo por aqui? Criar Cadastro ✨',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
