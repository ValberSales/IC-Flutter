import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/sources/local_data_source.dart';

class AvatarSelectorDialog extends StatefulWidget {
  final String currentAvatar;
  final ValueChanged<String> onAvatarSelected;

  const AvatarSelectorDialog({
    super.key,
    required this.currentAvatar,
    required this.onAvatarSelected,
  });

  static Future<String?> show(BuildContext context, String currentAvatar) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => AvatarSelectorDialog(
        currentAvatar: currentAvatar,
        onAvatarSelected: (selected) => Navigator.of(ctx).pop(selected),
      ),
    );
  }

  @override
  State<AvatarSelectorDialog> createState() => _AvatarSelectorDialogState();
}

class _AvatarSelectorDialogState extends State<AvatarSelectorDialog> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentAvatar;
  }

  @override
  Widget build(BuildContext context) {
    final avatars = LocalDataSource.avataresDisponiveis;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 12,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.face_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Escolha seu Avatar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Selecione a figurinha que mais combina com você:',
                        style: TextStyle(fontSize: 13, color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.0,
                ),
                itemCount: avatars.length,
                itemBuilder: (context, index) {
                  final path = avatars[index];
                  final isSelected = _selected == path;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selected = path;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.secondary.withOpacity(0.15) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.secondary : Colors.grey.withOpacity(0.25),
                          width: isSelected ? 3.5 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.secondary.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              path,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 14),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              onPressed: () {
                widget.onAvatarSelected(_selected);
              },
              child: const Text(
                'Confirmar Avatar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
