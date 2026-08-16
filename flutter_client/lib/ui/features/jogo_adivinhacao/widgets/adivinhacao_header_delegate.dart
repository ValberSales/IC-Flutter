import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/palavra.dart';
import '../../../core/dynamic_image_widget.dart';
import 'adivinhacao_slots_widget.dart';

class AdivinhacaoHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Palavra palavra;
  final List<String> letrasPalavra;
  final List<Map<String, String>?> letrasPreenchidas;
  final List<bool?> slotValidation;
  final int activeIndex;
  final ValueChanged<int> onSlotTapped;
  final VoidCallback onClearTapped;
  final String feedback;
  final bool isCompact;
  final String difficulty;

  AdivinhacaoHeaderDelegate({
    required this.palavra,
    required this.letrasPalavra,
    required this.letrasPreenchidas,
    required this.slotValidation,
    required this.activeIndex,
    required this.onSlotTapped,
    required this.onClearTapped,
    required this.feedback,
    required this.isCompact,
    required this.difficulty,
  });

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  double get maxExtent => 285.0;

  @override
  double get minExtent => 110.0;

  @override
  bool shouldRebuild(covariant AdivinhacaoHeaderDelegate oldDelegate) => true;

  Widget _buildClearButton({bool isCompact = false, bool isMinimal = false}) {
    final bool isError = feedback == 'ERRO';
    final Color btnColor = isError ? AppColors.error : AppColors.secondary;

    return Center(
      child: InkWell(
        onTap: onClearTapped,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMinimal ? 12 : (isCompact ? 16 : 22),
            vertical: isMinimal ? 4 : 7,
          ),
          decoration: BoxDecoration(
            color: isError ? AppColors.error.withValues(alpha: 0.12) : AppColors.bgSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: btnColor.withValues(alpha: 0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cleaning_services_rounded,
                size: isMinimal ? 15 : 18,
                color: btnColor,
              ),
              const SizedBox(width: 6),
              Text(
                isError ? 'Tentar Novamente' : 'Limpar Palavra',
                style: TextStyle(
                  fontSize: isMinimal ? 11 : (isCompact ? 12 : 13),
                  fontWeight: FontWeight.bold,
                  color: btnColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double percent = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final double slotSize = _lerp(50.0, 36.0, percent);
    final double fontSize = _lerp(20.0, 14.0, percent);
    final bool dicaPalavra = difficulty == 'FACIL' || difficulty == 'MEDIO';

    return Container(
      color: AppColors.bgSoft,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 840),
        child: Card(
          elevation: _lerp(4.0, 1.0, percent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_lerp(24.0, 16.0, percent)),
            side: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isWide = constraints.maxWidth >= 540;

                // Modo Recolhido durante o Scroll Vertical
                if (percent >= 0.70) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.bgSoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: DynamicImageWidget(
                              imagePath: palavra.imagem,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AdivinhacaoSlotsWidget(
                              letrasPalavra: letrasPalavra,
                              letrasPreenchidas: letrasPreenchidas,
                              slotValidation: slotValidation,
                              activeIndex: activeIndex,
                              onSlotTapped: onSlotTapped,
                              slotWidth: slotSize * 0.85,
                              slotHeight: slotSize * 1.05,
                              fontSize: fontSize * 0.85,
                              enableHorizontalScroll: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _buildClearButton(isCompact: true, isMinimal: true),
                    ],
                  );
                }

                // Modo Expandido Amplo (Desktop / Tablet / Telas Maiores):
                // Imagem à esquerda, placeholders à direita, alinhados com spaceBetween, botão de limpar na linha de baixo centralizado
                if (isWide) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 1. Imagem e Nome alinhados à ESQUERDA
                            Flexible(
                              flex: 3,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxHeight: (constraints.maxHeight * 0.55).clamp(40.0, 110.0),
                                        maxWidth: 140,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.bgSoft,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(color: AppColors.secondary, width: 2.5),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: DynamicImageWidget(
                                        imagePath: palavra.imagem,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  if (dicaPalavra) ...[
                                    const SizedBox(height: 4),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        palavra.descricao.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: (fontSize * 0.85).clamp(12.0, 15.0),
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.secondary,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            // 2. Placeholders alinhados à DIREITA
                            Expanded(
                              flex: 5,
                              child: Center(
                                child: AdivinhacaoSlotsWidget(
                                  letrasPalavra: letrasPalavra,
                                  letrasPreenchidas: letrasPreenchidas,
                                  slotValidation: slotValidation,
                                  activeIndex: activeIndex,
                                  onSlotTapped: onSlotTapped,
                                  slotWidth: slotSize,
                                  slotHeight: slotSize * 1.22,
                                  fontSize: fontSize,
                                  enableHorizontalScroll: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Botão de Limpar na linha de baixo centralizado
                      _buildClearButton(isCompact: false),
                    ],
                  );
                }

                // Modo Estreito (ao quebrar a linha / diminuir a largura):
                // 1. Título no topo, 2. Imagem logo abaixo, 3. Placeholders, 4. Botão de limpar. Tudo centralizado!
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1. Título no TOPO centralizado
                    if (dicaPalavra) ...[
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          palavra.descricao.toUpperCase(),
                          style: TextStyle(
                            fontSize: (fontSize * 0.9).clamp(13.0, 16.0),
                            fontWeight: FontWeight.w900,
                            color: AppColors.secondary,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    // 2. Imagem logo ABAIXO centralizada
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: (constraints.maxHeight * 0.40).clamp(36.0, 95.0),
                          maxWidth: 120,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bgSoft,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.secondary, width: 2),
                        ),
                        padding: const EdgeInsets.all(3),
                        child: DynamicImageWidget(
                          imagePath: palavra.imagem,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // 3. Placeholders centralizados com rolagem horizontal
                    AdivinhacaoSlotsWidget(
                      letrasPalavra: letrasPalavra,
                      letrasPreenchidas: letrasPreenchidas,
                      slotValidation: slotValidation,
                      activeIndex: activeIndex,
                      onSlotTapped: onSlotTapped,
                      slotWidth: slotSize,
                      slotHeight: slotSize * 1.22,
                      fontSize: fontSize,
                      enableHorizontalScroll: true,
                    ),
                    const SizedBox(height: 6),
                    // 4. Botão de Limpar na linha de baixo centralizado
                    _buildClearButton(isCompact: true),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
