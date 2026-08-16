import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../view_models/jogo_memoria_view_model.dart';

class MemoriaCardWidget extends StatelessWidget {
  final CartaMemoria carta;
  final VoidCallback onTap;

  const MemoriaCardWidget({
    super.key,
    required this.carta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: carta.revelada ? Colors.white : AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: carta.revelada ? AppColors.secondary : AppColors.primaryLight,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        alignment: Alignment.center,
        child: carta.revelada
            ? (carta.figura
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(carta.path, fit: BoxFit.contain),
                  )
                : Text(
                    carta.letra,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ))
            : const Icon(
                Icons.help_outline_rounded,
                color: Colors.white,
                size: 32,
              ),
      ),
    );
  }
}
