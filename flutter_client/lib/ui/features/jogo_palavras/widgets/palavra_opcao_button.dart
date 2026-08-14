import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../view_models/jogo_palavras_view_model.dart';

class PalavraOpcaoButton extends StatelessWidget {
  final OpcaoPalavra opcao;
  final bool isAcerto;
  final String palavraCorreta;
  final VoidCallback onTap;

  const PalavraOpcaoButton({
    super.key,
    required this.opcao,
    required this.isAcerto,
    required this.palavraCorreta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCorrectWord = opcao.palavra.trim().toUpperCase() == palavraCorreta.trim().toUpperCase();
    final bool isErrouEsta = !opcao.pendente;

    Color bgColor = Colors.white;
    Color textColor = AppColors.textDark;
    Color borderColor = AppColors.border;

    if (isAcerto && isCorrectWord) {
      bgColor = AppColors.accent;
      textColor = Colors.white;
      borderColor = AppColors.accent;
    } else if (isErrouEsta) {
      bgColor = AppColors.errorLight.withOpacity(0.5);
      textColor = AppColors.error;
      borderColor = AppColors.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: isErrouEsta ? 0 : 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: borderColor, width: 2),
          ),
        ),
        onPressed: isErrouEsta || isAcerto ? null : onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isAcerto && isCorrectWord)
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
              )
            else if (isErrouEsta)
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.cancel_rounded, color: AppColors.error, size: 24),
              ),
            Flexible(
              child: Text(
                opcao.palavra.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  decoration: isErrouEsta ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
