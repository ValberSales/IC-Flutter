import 'package:flutter/material.dart';

class AppColors {
  // Cores do Tema Material 3 Expressive
  static const Color primary = Color(0xFF673AB7);      // Roxo vibrante e amigável
  static const Color primaryLight = Color(0xFFD1C4E9); // Roxo claro
  static const Color primaryDark = Color(0xFF512DA8);  // Roxo escuro
  
  static const Color secondary = Color(0xFFFF9800);    // Laranja divertido para botões e destaque
  static const Color secondaryLight = Color(0xFFFFE0B2);
  
  static const Color accent = Color(0xFF4CAF50);       // Verde para acertos
  static const Color accentLight = Color(0xFFC8E6C9);
  
  static const Color error = Color(0xFFF44336);        // Vermelho para erros
  static const Color errorLight = Color(0xFFFFCDD2);
  
  static const Color info = Color(0xFF2196F3);         // Azul informativo
  static const Color infoLight = Color(0xFFBBDEFB);

  static const Color warning = Color(0xFFFFEB3B);      // Amarelo vibrante
  
  // Cores neutras
  static const Color bgSoft = Color(0xFFF7F9FC);       // Fundo claro suave
  static const Color cardBg = Colors.white;            // Fundo de cards
  static const Color textDark = Color(0xFF2D3142);     // Texto escuro suave
  static const Color textLight = Colors.white;         // Texto claro
  static const Color border = Color(0xFFE2E8F0);       // Bordas suaves
  
  // Gradientes divertidos
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8C52FF), Color(0xFF512DA8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient successGradient = LinearGradient(
    colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
