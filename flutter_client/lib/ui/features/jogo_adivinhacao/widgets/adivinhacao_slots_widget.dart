import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AdivinhacaoSlotsWidget extends StatelessWidget {
  final List<String> letrasPalavra;
  final List<Map<String, String>?> letrasPreenchidas;
  final List<bool?> slotValidation;
  final int activeIndex;
  final ValueChanged<int> onSlotTapped;
  final double slotWidth;
  final double slotHeight;
  final double fontSize;
  final bool enableHorizontalScroll;

  const AdivinhacaoSlotsWidget({
    super.key,
    required this.letrasPalavra,
    required this.letrasPreenchidas,
    required this.slotValidation,
    required this.activeIndex,
    required this.onSlotTapped,
    this.slotWidth = 52,
    this.slotHeight = 64,
    this.fontSize = 20,
    this.enableHorizontalScroll = true,
  });

  Widget _buildSlotsContent(BuildContext context, double computedWidth, double computedHeight, double computedFontSize) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(letrasPalavra.length, (index) {
        final preenchida = letrasPreenchidas[index];
        final isActive = index == activeIndex;
        final val = index < slotValidation.length ? slotValidation[index] : null;

        Color borderColor = AppColors.border;
        Color bgColor = AppColors.border.withOpacity(0.3);
        double borderWidth = 1.5;

        if (val == true) {
          borderColor = Colors.green;
          bgColor = Colors.green.withOpacity(0.15);
          borderWidth = 3.0;
        } else if (val == false) {
          borderColor = Colors.red;
          bgColor = Colors.red.withOpacity(0.15);
          borderWidth = 3.0;
        } else if (isActive) {
          borderColor = AppColors.secondary;
          bgColor = AppColors.secondaryLight.withOpacity(0.3);
          borderWidth = 2.5;
        } else if (preenchida != null) {
          borderColor = AppColors.primary;
          bgColor = Colors.white;
          borderWidth = 2.5;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3.0),
          child: GestureDetector(
            onTap: () => onSlotTapped(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: computedWidth,
              height: computedHeight,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: borderWidth),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: preenchida != null
                  ? Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Image.asset(
                        preenchida['path']!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Text(
                          preenchida['letra']!,
                          style: TextStyle(
                            fontSize: computedFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      '_',
                      style: TextStyle(
                        fontSize: computedFontSize + 4,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark.withOpacity(0.4),
                      ),
                    ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int count = letrasPalavra.length;
        if (count == 0) return const SizedBox.shrink();

        // Calcula tamanho dinâmico ideal baseado na largura disponível
        final double availableWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 360.0;
        final double spacingTotal = (count + 1) * 6.0;
        const double minSlot = 36.0;
        final double maxSlot = slotWidth < minSlot ? minSlot : slotWidth;
        final double rawCalculated = (availableWidth - spacingTotal) / count;
        final double calculatedSlotWidth = rawCalculated.clamp(minSlot, maxSlot);
        final double calculatedSlotHeight = calculatedSlotWidth * 1.22;
        
        const double minFont = 12.0;
        final double maxFont = fontSize < minFont ? minFont : fontSize;
        final double calculatedFontSize = (calculatedSlotWidth * 0.38).clamp(minFont, maxFont);

        final Widget content = _buildSlotsContent(
          context,
          calculatedSlotWidth,
          calculatedSlotHeight,
          calculatedFontSize,
        );

        if (enableHorizontalScroll) {
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: content,
            ),
          );
        }

        return content;
      },
    );
  }
}
