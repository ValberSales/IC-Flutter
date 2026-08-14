import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../view_models/jogo_alfabeto_view_model.dart';

class AlfabetoSignButton extends StatelessWidget {
  final LetraJogo opcao;
  final bool isAcerto;
  final String letraCorreta;
  final VoidCallback onTap;

  const AlfabetoSignButton({
    super.key,
    required this.opcao,
    required this.isAcerto,
    required this.letraCorreta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final letra = opcao.letraData['letra']!;
    final path = opcao.letraData['path']!;
    final bool isCorrect = letra == letraCorreta;
    final bool isErrouEsta = !opcao.pendente;

    Color borderColor = AppColors.border;
    Color bgColor = Colors.white;

    if (isAcerto && isCorrect) {
      borderColor = AppColors.accent;
      bgColor = AppColors.accentLight.withOpacity(0.3);
    } else if (isErrouEsta) {
      borderColor = AppColors.error;
      bgColor = AppColors.errorLight.withOpacity(0.3);
    }

    return InkWell(
      onTap: isErrouEsta || isAcerto ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: isErrouEsta
            ? const Center(child: Icon(Icons.close_rounded, color: AppColors.error, size: 40))
            : Image.asset(path, fit: BoxFit.contain),
      ),
    );
  }
}
