import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/util/responsive_layout.dart';
import '../../../../state/app_state_provider.dart';
import '../../../core/app_header_widget.dart';
import '../../../core/force_change_password_dialog.dart';
import '../../jogo_hub/views/jogo_hub_view.dart';
import '../view_models/home_view_model.dart';
import '../widgets/home_cadastro_form_widget.dart';
import '../widgets/home_login_form_widget.dart';
import '../widgets/home_welcome_card_widget.dart';

/// Tela inicial do aplicativo Alfabetiza Libras.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late HomeViewModel _viewModel;
  bool _isForceDialogOpen = false;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppStateProvider>();
    _viewModel = HomeViewModel(appState: appState);
  }

  void _verificarTrocaSenhaObrigatoria(AppStateProvider state) {
    if (state.isLoggedIn && state.currentUser?.mustChangePassword == true && !_isForceDialogOpen) {
      _isForceDialogOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted && state.isLoggedIn && state.currentUser?.mustChangePassword == true) {
          await ForceChangePasswordDialog.show(context);
        }
        _isForceDialogOpen = false;
      });
    }
  }

  void _irParaJogos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const JogoHubView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    _verificarTrocaSenhaObrigatoria(state);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double mascotSize = screenHeight < 600 ? 110.0 : 180.0;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<HomeViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: AppColors.bgSoft,
            appBar: AppHeaderWidget(
              isCleanLogin: !state.isLoggedIn,
              showAdminButton: true,
              showProfileButton: true,
              showLogoutButton: true,
            ),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: state.isLoggedIn
                      ? _buildWelcomeBackSection(state, vm, mascotSize)
                      : _buildAuthSection(state, vm, mascotSize),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Exibição quando o usuário já está logado
  Widget _buildWelcomeBackSection(AppStateProvider state, HomeViewModel vm, double mascotSize) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMascot(vm, mascotSize),
          const SizedBox(height: 12),
          HomeWelcomeCardWidget(
            user: state.currentUser!,
            onJogarTap: _irParaJogos,
            onAvatarChange: (newAvatar) async {
              await state.updateUserProfile(avatar: newAvatar);
            },
          ),
        ],
      ),
    );
  }

  /// Exibição de Login / Cadastro / Modo Convidado
  Widget _buildAuthSection(AppStateProvider state, HomeViewModel vm, double mascotSize) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMascot(vm, mascotSize),
          const SizedBox(height: 12),
          Card(
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.08),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: vm.isCadastroMode
                  ? HomeCadastroFormWidget(viewModel: vm)
                  : HomeLoginFormWidget(viewModel: vm),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textDark.withOpacity(0.8),
              side: BorderSide(color: AppColors.textDark.withOpacity(0.25)),
              backgroundColor: Colors.white.withOpacity(0.6),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () async {
              await vm.playAsGuest();
              _irParaJogos();
            },
            icon: const Icon(Icons.sports_esports_rounded, size: 20, color: AppColors.primary),
            label: const Text(
              '🎮 Jogar sem cadastro (Modo Convidado)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMascot(HomeViewModel vm, double mascotSize) {
    return GestureDetector(
      onTap: vm.triggerMascotDance,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        transform: Matrix4.rotationZ(vm.isMoving ? 0.08 : 0.0),
        child: Image.asset(
          vm.isMoving
              ? 'assets/raccoon/gif/victory-dance.gif'
              : 'assets/raccoon/raccoon.png',
          height: mascotSize,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
