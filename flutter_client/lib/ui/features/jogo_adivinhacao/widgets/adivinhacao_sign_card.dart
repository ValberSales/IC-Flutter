import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AdivinhacaoSignCard extends StatelessWidget {
  final Map<String, String> item;
  final bool dicaLetra;
  final VoidCallback onTap;

  const AdivinhacaoSignCard({
    super.key,
    required this.item,
    required this.dicaLetra,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String letra = item['letra']!;
    final String path = item['path']!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 3,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset(
                  path,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Text(
                    letra,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            if (dicaLetra) ...[
              const Divider(height: 1, thickness: 1.5, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(
                  letra,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
