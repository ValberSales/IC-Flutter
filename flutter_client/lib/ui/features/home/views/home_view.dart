import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/util/responsive_layout.dart';
import '../../../../state/app_state_provider.dart';
import '../../../core/app_header_widget.dart';
import '../../../core/avatar_selector_dialog.dart';
import '../../../core/force_change_password_dialog.dart';
import '../../jogo_hub/views/jogo_hub_view.dart';
import '../view_models/home_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late HomeViewModel _viewModel;
  bool _obscurePassword = true;
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
    final isCompact = ResponsiveLayout.isMobile(context);
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
                      ? _buildWelcomeBackView(state, vm, mascotSize, isCompact)
                      : _buildAuthView(state, vm, mascotSize, isCompact),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- 1. TELA DE BOAS-VINDAS (USUÁRIO JÁ LOGADO) ---
  Widget _buildWelcomeBackView(AppStateProvider state, HomeViewModel vm, double mascotSize, bool isCompact) {
    final user = state.currentUser!;
    final avatar = user.avatar ?? 'assets/avatar/avatar_1.jpg';
    final nome = user.nome ?? user.username ?? 'Aluno';
    final idCode = user.codigoIdentificador ?? '#${user.id ?? 1}';

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mascote dançante
          GestureDetector(
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
          ),
          const SizedBox(height: 12),

          // Card Central de Boas-Vindas
          Card(
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.08),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                children: [
                  // Avatar com badge
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.secondary, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.3),
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
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () async {
                            final selected = await AvatarSelectorDialog.show(context, avatar);
                            if (selected != null && selected != avatar) {
                              await state.updateUserProfile(avatar: selected);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'Olá, $nome! 🌟',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '@${user.username}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Que bom ver você de novo! Vamos continuar aprendendo sinais em Libras?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark.withOpacity(0.75),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botão Principal: JOGAR AGORA
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shadowColor: AppColors.secondary.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: _irParaJogos,
                      icon: const Icon(Icons.play_arrow_rounded, size: 34),
                      label: const Text(
                        'JOGAR AGORA',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Botão no Rodapé: Trocar de Conta / Sair
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textDark.withOpacity(0.7),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () async {
              await AppHeaderWidget.executeLogout(context, state);
            },
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text(
              'Trocar de Conta / Sair',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. TELA DE AUTENTICAÇÃO (LOGIN & REGISTRO) ---
  Widget _buildAuthView(AppStateProvider state, HomeViewModel vm, double mascotSize, bool isCompact) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mascote no topo
          GestureDetector(
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
          ),
          const SizedBox(height: 12),

          // Card de Login ou Cadastro
          Card(
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.08),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: vm.isCadastroMode
                  ? _buildCadastroForm(state, vm)
                  : _buildLoginForm(state, vm),
            ),
          ),
          const SizedBox(height: 20),

          // Botão Fora de Foco no Rodapé: JOGAR SEM CADASTRO (Modo Convidado)
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

  // Formulário de Login
  Widget _buildLoginForm(AppStateProvider state, HomeViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Entrar no Jogo 🚀',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Informe seu ID Único ou Usuário e Senha para carregar seu progresso:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textDark.withOpacity(0.7)),
        ),
        const SizedBox(height: 20),

        if (vm.errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vm.errorMessage!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Campo Identificador (ID ou Username)
        TextField(
          onChanged: vm.setLoginIdentifier,
          decoration: InputDecoration(
            labelText: 'Usuário ou ID Único (ex: @pedro ou ALU-1001)',
            prefixIcon: const Icon(Icons.badge_rounded, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.bgSoft,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 14),

        // Campo Senha
        TextField(
          onChanged: vm.setLoginPassword,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Senha',
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: Colors.grey,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: AppColors.bgSoft,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),

        // Botão Entrar
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            onPressed: vm.isLoading
                ? null
                : () async {
                    await vm.executeLogin();
                  },
            child: vm.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    'Entrar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
          ),
        ),
        const SizedBox(height: 12),

        // Botão Criar Cadastro
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          onPressed: () => vm.setCadastroMode(true),
          child: const Text(
            'Novo por aqui? Criar Cadastro ✨',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // Formulário de Cadastro Simplificado Infantil / Docente
  Widget _buildCadastroForm(AppStateProvider state, HomeViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Criar Cadastro 🎉',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Não precisa de e-mail! Escolha seu avatar e crie sua conta:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textDark.withOpacity(0.7)),
        ),
        const SizedBox(height: 16),

        // Seletor de Avatar Interativo
        Center(
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 38,
                  backgroundImage: AssetImage(vm.selectedAvatar),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () async {
                    final selected = await AvatarSelectorDialog.show(context, vm.selectedAvatar);
                    if (selected != null) {
                      vm.setSelectedAvatar(selected);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: TextButton.icon(
            onPressed: () async {
              final selected = await AvatarSelectorDialog.show(context, vm.selectedAvatar);
              if (selected != null) {
                vm.setSelectedAvatar(selected);
              }
            },
            icon: const Icon(Icons.face_retouching_natural_rounded, size: 16),
            label: const Text('Trocar Avatar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 10),

        if (vm.errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vm.errorMessage!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Campo Nome da Criança
        TextField(
          onChanged: vm.setCadastroNome,
          decoration: InputDecoration(
            labelText: 'Nome da Criança ou Professor (ex: Ana Clara)',
            prefixIcon: const Icon(Icons.person_rounded, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.bgSoft,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),

        // Campo Nome de Usuário (@username)
        TextField(
          onChanged: vm.setCadastroUsername,
          decoration: InputDecoration(
            labelText: 'Nome de Usuário (ex: anaclara)',
            prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.bgSoft,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),

        // Campo Senha
        TextField(
          onChanged: vm.setCadastroPassword,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Senha (simples para a criança lembrar)',
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: Colors.grey,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: AppColors.bgSoft,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 18),

        // Botão Cadastrar e Começar a Jogar
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            onPressed: vm.isLoading
                ? null
                : () async {
                    await vm.executeRegister();
                  },
            child: vm.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    'Cadastrar e Começar a Jogar 🚀',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
          ),
        ),
        const SizedBox(height: 10),

        // Botão Voltar ao Login
        TextButton(
          onPressed: () => vm.setCadastroMode(false),
          child: const Text(
            'Já tem cadastro? Voltar ao Login',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
