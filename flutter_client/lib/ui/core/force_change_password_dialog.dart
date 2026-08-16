import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../state/app_state_provider.dart';

class ForceChangePasswordDialog extends StatefulWidget {
  const ForceChangePasswordDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const PopScope(
        canPop: false,
        child: ForceChangePasswordDialog(),
      ),
    );
  }

  @override
  State<ForceChangePasswordDialog> createState() => _ForceChangePasswordDialogState();
}

class _ForceChangePasswordDialogState extends State<ForceChangePasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _salvarNovaSenha(AppStateProvider state) async {
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (password.isEmpty) {
      setState(() => _errorMessage = 'Por favor, digite sua nova senha.');
      return;
    }

    if (password.length < 3) {
      setState(() => _errorMessage = 'A senha deve ter pelo menos 3 caracteres.');
      return;
    }

    if (password != confirm) {
      setState(() => _errorMessage = 'A confirmação de senha não confere com a nova senha.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final success = await state.changePasswordAfterReset(password);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Nova senha cadastrada com sucesso! Bom jogo!'),
            backgroundColor: AppColors.secondary,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        setState(() => _errorMessage = 'Erro ao salvar a nova senha no servidor. Tente novamente.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 12,
      child: Container(
        padding: const EdgeInsets.all(28),
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ícone e Título
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: AppColors.accent,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Center(
                child: Text(
                  'Troca de Senha Obrigatória',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Você entrou usando uma senha temporária. Para sua segurança, defina uma nova senha definitiva para continuar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
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
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Campo Nova Senha
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Sua Nova Senha',
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

              // Campo Confirmar Senha
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
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                ),
                onPressed: _isSaving ? null : () => _salvarNovaSenha(state),
                child: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'Salvar Nova Senha e Continuar 🚀',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
