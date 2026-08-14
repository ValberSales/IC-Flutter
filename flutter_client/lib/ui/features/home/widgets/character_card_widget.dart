import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/personagem.dart';

class CharacterCardWidget extends StatelessWidget {
  final Personagem personagem;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onConsultarPontuacao;
  final VoidCallback onExcluir;

  const CharacterCardWidget({
    super.key,
    required this.personagem,
    required this.isSelected,
    required this.onSelect,
    required this.onConsultarPontuacao,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.secondary : AppColors.border,
          width: isSelected ? 3 : 1.5,
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(personagem.avatar),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 16),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                personagem.nome,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Dificuldade: ${personagem.dificuldade}',
                style: TextStyle(fontSize: 13, color: AppColors.textDark.withOpacity(0.7)),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.analytics_outlined, color: AppColors.primary),
                    tooltip: 'Ver Pontuação',
                    onPressed: onConsultarPontuacao,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    tooltip: 'Excluir Avatar',
                    onPressed: onExcluir,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
