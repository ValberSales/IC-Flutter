import 'package:flutter/material.dart';
import 'package:flutter_client/core/constants/app_colors.dart';
import 'package:flutter_client/ui/core/avatar_selector_dialog.dart';

class UserProfileAvatarWidget extends StatelessWidget {
  final String avatar;
  final bool isGuest;
  final Future<void> Function(String newAvatar)? onAvatarChanged;

  const UserProfileAvatarWidget({
    super.key,
    required this.avatar,
    required this.isGuest,
    this.onAvatarChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 44,
              backgroundImage: AssetImage(avatar),
            ),
          ),
          if (!isGuest && onAvatarChanged != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: () async {
                  final selected = await AvatarSelectorDialog.show(context, avatar);
                  if (selected != null && selected != avatar) {
                    await onAvatarChanged!(selected);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
