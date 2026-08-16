import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../state/app_state_provider.dart';
import '../view_models/area_professor_view_model.dart';
import '../widgets/activity_list_dashboard_widget.dart';
import '../widgets/activity_wizard_widget.dart';
import '../widgets/professor_auth_card_widget.dart';
import '../widgets/professor_classes_tab_widget.dart';
import '../widgets/professor_profile_tab_widget.dart';
import '../widgets/professor_reports_tab_widget.dart';
import '../widgets/professor_users_tab_widget.dart';

class AreaProfessorView extends StatefulWidget {
  const AreaProfessorView({super.key});

  @override
  State<AreaProfessorView> createState() => _AreaProfessorViewState();
}

class _AreaProfessorViewState extends State<AreaProfessorView> {
  late AreaProfessorViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppStateProvider>();
    _viewModel = AreaProfessorViewModel(appState: appState);
  }

  Widget _buildScreenTooSmallView(BuildContext context, double currentWidth) {
    return Scaffold(
      backgroundColor: AppColors.bgSoft,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Painel Administrativo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.devices_rounded,
                        size: 54,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Tamanho de Tela Incompatível',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'O Painel Administrativo e Área do Professor foram projetados exclusivamente para visualização em telas a partir de 720px de largura (Computadores e Tablets).',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark.withValues(alpha: 0.75),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.bgSoft,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.aspect_ratio_rounded, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Largura atual: ${currentWidth.toInt()}px\n(Mínimo necessário: 720px)',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text(
                        'Voltar aos Jogos',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final double screenWidth = MediaQuery.of(context).size.width;

    // Bloqueia e intercepta telas com largura menor que 720px
    if (screenWidth < 720.0) {
      return _buildScreenTooSmallView(context, screenWidth);
    }

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<AreaProfessorViewModel>(
        builder: (context, vm, _) {
          if (!state.isLoggedIn) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                title: Text(
                  vm.isLoginMode ? 'Entrar na Área do Professor' : 'Cadastro de Professor',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              body: Container(
                color: AppColors.bgSoft,
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: ProfessorAuthCardWidget(viewModel: vm),
                ),
              ),
            );
          }

          return DefaultTabController(
            length: 5,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                centerTitle: true,
                title: const Text(
                  'Área do Professor',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                bottom: const TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.primaryLight,
                  indicatorColor: AppColors.secondary,
                  indicatorWeight: 4,
                  tabs: [
                    Tab(icon: Icon(Icons.add_task_rounded), text: 'Atividades'),
                    Tab(icon: Icon(Icons.people_alt_rounded), text: 'Usuários'),
                    Tab(icon: Icon(Icons.school_rounded), text: 'Turmas'),
                    Tab(icon: Icon(Icons.analytics_rounded), text: 'Relatórios'),
                    Tab(icon: Icon(Icons.account_circle_rounded), text: 'Meu Perfil'),
                  ],
                ),
              ),
              body: Container(
                color: AppColors.bgSoft,
                child: TabBarView(
                  children: [
                    vm.isCreatingActivity
                        ? ActivityWizardWidget(viewModel: vm, state: state)
                        : ActivityListDashboardWidget(viewModel: vm, state: state),
                    ProfessorUsersTabWidget(state: state),
                    ProfessorClassesTabWidget(viewModel: vm, state: state),
                    ProfessorReportsTabWidget(state: state),
                    ProfessorProfileTabWidget(state: state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
