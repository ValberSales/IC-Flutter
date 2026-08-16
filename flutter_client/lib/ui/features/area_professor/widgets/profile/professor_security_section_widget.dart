import 'package:flutter/material.dart';
import 'package:flutter_client/core/constants/app_colors.dart';

class ProfessorSecuritySectionWidget extends StatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const ProfessorSecuritySectionWidget({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  State<ProfessorSecuritySectionWidget> createState() => _ProfessorSecuritySectionWidgetState();
}

class _ProfessorSecuritySectionWidgetState extends State<ProfessorSecuritySectionWidget> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              const Text(
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
            style: TextStyle(fontSize: 12, color: AppColors.textDark.withValues(alpha: 0.65)),
          ),
          const SizedBox(height: 14),

          // Nova Senha
          TextField(
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Nova Senha',
              prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.primary),
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
            controller: widget.confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirmar Nova Senha',
              prefixIcon: Icon(Icons.lock_rounded, color: AppColors.primary),
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
    );
  }
}
