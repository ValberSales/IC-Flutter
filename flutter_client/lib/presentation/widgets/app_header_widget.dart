import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../state/app_state_provider.dart';
import '../../ui/core/sobre_projeto_dialog.dart';
import '../pages/area_professor/area_professor_page.dart';

class AppHeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final isCompact = MediaQuery.of(context).size.width < 600;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          Image.asset(
            'assets/senai_libras.png',
            height: isCompact ? 32 : 40,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.school_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isCompact ? 'Alfabetiza' : 'Alfabetiza Libras',
            style: TextStyle(
              fontSize: isCompact ? 22 : 28,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        // Indicador de Sincronização / Turma
        if (state.activeTurma != null)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent.withOpacity(0.5), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_done_rounded, color: AppColors.accent, size: 18),
                const SizedBox(width: 6),
                if (!isCompact)
                  Text(
                    state.activeTurma!.nome,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
              ],
            ),
          ),

        // Botão Sobre o Projeto
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: IconButton(
            tooltip: 'Sobre o Projeto',
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.textDark, size: 22),
            onPressed: () => SobreProjetoDialog.show(context),
          ),
        ),

        // Botão Área do Professor
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 10 : 16,
                vertical: isCompact ? 8 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AreaProfessorPage(),
                ),
              );
            },
            icon: const Icon(Icons.settings_rounded, size: 18),
            label: Text(isCompact ? 'Painel' : 'Área do Professor'),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.5),
        child: Container(
          color: AppColors.border,
          height: 1.5,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
