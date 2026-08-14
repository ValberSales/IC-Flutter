import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../state/app_state_provider.dart';

class LogoutHelper {
  static Future<void> executeLogout(BuildContext context, AppStateProvider state) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmar Saída'),
        content: Text(
          state.isGuestMode
              ? 'Deseja sair do Modo Convidado e voltar à tela inicial?'
              : 'Deseja desconectar sua conta e voltar à tela de login?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await state.logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    }
  }
}
