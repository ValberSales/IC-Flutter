import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class TutorialWidget extends StatelessWidget {
  final String atividade; // 'JOGO_ADIVINHACAO' | 'JOGO_MEMORIA' | 'JOGO_ALFABETO' | 'JOGO_PALAVRAS'
  final bool isIconOnly;

  const TutorialWidget({
    super.key,
    required this.atividade,
    this.isIconOnly = false,
  });

  String get _tutorialAssetPath {
    switch (atividade) {
      case 'JOGO_ADIVINHACAO':
        return 'assets/tutorial/tutorial_jogo_adivinhacao.gif';
      case 'JOGO_MEMORIA':
        return 'assets/tutorial/tutorial_jogo_memoria.gif';
      case 'JOGO_ALFABETO':
        return 'assets/tutorial/tutorial_jogo_letras.gif';
      case 'JOGO_PALAVRAS':
        return 'assets/tutorial/tutorial_jogo_palavras.gif';
      default:
        return '';
    }
  }

  String get _gameName {
    switch (atividade) {
      case 'JOGO_ADIVINHACAO':
        return 'Jogo de Adivinhação';
      case 'JOGO_MEMORIA':
        return 'Jogo da Memória';
      case 'JOGO_ALFABETO':
        return 'Jogo do Alfabeto Manual';
      case 'JOGO_PALAVRAS':
        return 'Jogo de Palavras';
      default:
        return 'Jogo';
    }
  }

  void _showTutorialDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Text(
                  'Como jogar o $_gameName?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Imagem / GIF do tutorial
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: AppColors.bgSoft,
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: Image.asset(
                      _tutorialAssetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.video_collection, size: 60, color: AppColors.primaryLight),
                              SizedBox(height: 8),
                              Text('Animação explicativa do jogo', style: TextStyle(color: AppColors.textDark)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Botão de retornar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.play_arrow_rounded, size: 28),
                    label: const Text('Entendi! Vamos Jogar!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isIconOnly) {
      return IconButton(
        onPressed: () => _showTutorialDialog(context),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.info,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.help_outline_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        tooltip: 'Como Jogar',
      );
    }

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.info,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 3,
        shadowColor: AppColors.info.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () => _showTutorialDialog(context),
      icon: const Icon(Icons.help_outline_rounded, size: 22),
      label: const Text('Como Jogar'),
    );
  }
}
