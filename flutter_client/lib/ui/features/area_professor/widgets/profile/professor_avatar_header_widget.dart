import 'package:flutter/material.dart';
import 'package:flutter_client/core/constants/app_colors.dart';
import 'package:flutter_client/ui/core/avatar_selector_dialog.dart';

class ProfessorAvatarHeaderWidget extends StatelessWidget {
  final String currentAvatar;
  final String role;
  final ValueChanged<String> onAvatarSelected;

  const ProfessorAvatarHeaderWidget({
    super.key,
    required this.currentAvatar,
    required this.role,
    required this.onAvatarSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.purple, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(currentAvatar),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: () async {
                  final selected = await AvatarSelectorDialog.show(context, currentAvatar);
                  if (selected != null && selected != currentAvatar) {
                    onAvatarSelected(selected);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () async {
            final selected = await AvatarSelectorDialog.show(context, currentAvatar);
            if (selected != null && selected != currentAvatar) {
              onAvatarSelected(selected);
            }
          },
          icon: const Icon(Icons.palette_rounded, size: 18),
          label: const Text('Alterar Avatar', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purple.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user_rounded, color: Colors.purple, size: 18),
              const SizedBox(width: 6),
              Text(
                'Acesso: $role',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
