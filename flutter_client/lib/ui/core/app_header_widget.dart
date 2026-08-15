import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../state/app_state_provider.dart';
import '../features/area_professor/views/area_professor_view.dart';
import 'logout_helper.dart';
import 'sobre_projeto_dialog.dart';
import 'user_profile_dialog.dart';

class AppHeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  final bool isCleanLogin;
  final bool showAdminButton;
  final bool showProfileButton;
  final bool showLogoutButton;

  const AppHeaderWidget({
    super.key,
    this.isCleanLogin = false,
    this.showAdminButton = true,
    this.showProfileButton = true,
    this.showLogoutButton = true,
  });

  static Future<void> executeLogout(BuildContext context, AppStateProvider state) =>
      LogoutHelper.executeLogout(context, state);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final isCompact = MediaQuery.of(context).size.width < 600;
    final user = state.currentUser;
    final isGuest = state.isGuestMode;

    final String avatarPath = user?.avatar ?? 'assets/avatar/avatar_1.jpg';

    // Se for tela de login limpa, não renderiza nenhuma ação
    if (isCleanLogin) {
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
        actions: const [],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(
            color: AppColors.border,
            height: 1.5,
          ),
        ),
      );
    }

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
        // 1. Botão da Área do Professor (Visível SOMENTE quando o usuário logado for ADMIN)
        if (showAdminButton && state.isLoggedIn && user?.isAdmin == true)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 10 : 14,
                  vertical: isCompact ? 8 : 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AreaProfessorView(),
                  ),
                );
              },
              icon: const Icon(Icons.settings_rounded, size: 16),
              label: Text(isCompact ? 'Painel' : 'Painel Admin'),
            ),
          ),

        // 1.5. Botão Sobre o Projeto (Acessível a todos)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: IconButton(
            tooltip: 'Sobre o Projeto',
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.textDark, size: 22),
            onPressed: () => SobreProjetoDialog.show(context),
          ),
        ),

        // 2. Botão da Imagem de Perfil (Avatar clicável que abre o modal de perfil)
        if (showProfileButton && (state.isLoggedIn || isGuest))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Tooltip(
              message: 'Meu Perfil',
              child: InkWell(
                onTap: () => UserProfileDialog.show(context),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                    color: AppColors.bgSoft,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 17,
                    backgroundImage: AssetImage(avatarPath),
                  ),
                ),
              ),
            ),
          ),

        // 3. Botão Sair
        if (showLogoutButton && (state.isLoggedIn || isGuest))
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: IconButton(
              tooltip: 'Sair da Conta',
              icon: const Icon(Icons.logout_rounded, color: AppColors.textDark, size: 24),
              onPressed: () => executeLogout(context, state),
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1.5);
}
