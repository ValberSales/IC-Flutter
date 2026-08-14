class TextNormalizer {
  /// Remove acentos de vogais para comparacao no alfabeto manual Libras,
  /// preservando estritamente a letra 'Ç' que possui sinal proprio.
  static String removerAcentosPreservandoCedilha(String text) {
    return text.toUpperCase().replaceAllMapped(
      RegExp(r'[ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜ]'),
      (match) {
        final char = match.group(0)!;
        switch (char) {
          case 'Á': case 'À': case 'Â': case 'Ã': case 'Ä': return 'A';
          case 'É': case 'È': case 'Ê': case 'Ë': return 'E';
          case 'Í': case 'Ì': case 'Î': case 'Ï': return 'I';
          case 'Ó': case 'Ò': case 'Ô': case 'Õ': case 'Ö': return 'O';
          case 'Ú': case 'Ù': case 'Û': case 'Ü': return 'U';
          default: return char;
        }
      },
    );
  }
}
