import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/sources/local_data_source.dart';

class AvatarPickerDialog extends StatelessWidget {
  final String currentAvatar;

  const AvatarPickerDialog({super.key, required this.currentAvatar});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecione um Avatar', textAlign: TextAlign.center),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      content: SizedBox(
        width: 400,
        height: MediaQuery.of(context).size.height * 0.6,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: LocalDataSource.avataresDisponiveis.length,
          itemBuilder: (context, index) {
            final path = LocalDataSource.avataresDisponiveis[index];
            final isSelected = currentAvatar == path;

            return InkWell(
              onTap: () => Navigator.of(context).pop(path),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? AppColors.secondary : Colors.transparent,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.asset(path, fit: BoxFit.cover),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
