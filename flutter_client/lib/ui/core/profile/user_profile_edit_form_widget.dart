import 'package:flutter/material.dart';
import 'package:flutter_client/core/constants/app_colors.dart';

class UserProfileEditFormWidget extends StatefulWidget {
  final TextEditingController nomeController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isSaving;
  final String? errorMessage;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const UserProfileEditFormWidget({
    super.key,
    required this.nomeController,
    required this.usernameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isSaving,
    this.errorMessage,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<UserProfileEditFormWidget> createState() => _UserProfileEditFormWidgetState();
}

class _UserProfileEditFormWidgetState extends State<UserProfileEditFormWidget> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.errorMessage != null) ...[
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
                    widget.errorMessage!,
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
          controller: widget.nomeController,
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
          controller: widget.usernameController,
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
          controller: widget.passwordController,
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
          controller: widget.confirmPasswordController,
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
                onPressed: widget.isSaving ? null : widget.onCancel,
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
                onPressed: widget.isSaving ? null : widget.onSave,
                child: widget.isSaving
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
}
