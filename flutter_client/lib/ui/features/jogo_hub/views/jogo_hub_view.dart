import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../state/app_state_provider.dart';
import '../../../core/app_header_widget.dart';
import '../../../core/user_profile_dialog.dart';
import '../../jogo_alfabeto/views/jogo_alfabeto_view.dart';
import '../../jogo_memoria/views/jogo_memoria_view.dart';
import '../../selecao_tema/views/selecao_tema_view.dart';
import '../view_models/jogo_hub_view_model.dart';
import '../widgets/game_category_card_widget.dart';

class JogoHubView extends StatefulWidget {
  const JogoHubView({super.key});

  @override
  State<JogoHubView> createState() => _JogoHubViewState();
}

class _JogoHubViewState extends State<JogoHubView> {
  late JogoHubViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppStateProvider>();
    _viewModel = JogoHubViewModel(appState: appState);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final user = state.currentUser;
    final isGuest = state.isGuestMode;
    final avatarPath = user?.avatar ?? state.activePersonagem?.avatar ?? 'assets/avatar/avatar_1.jpg';

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<JogoHubViewModel>(
        builder: (context, vm, _) {
          final totalAdivinhacao = state.atividades.where((a) => a.ativo && a.tipoJogo == 'JOGO_ADIVINHACAO').length;
          final totalPalavras = state.atividades.where((a) => a.ativo && a.tipoJogo == 'JOGO_PALAVRAS').length;

          // Indicadores de Desempenho Globais por Categoria
          final double progressoAlfabeto = state.getOverallGameProgress('JOGO_ALFABETO');
          final double? acertosAlfabeto = state.getOverallGameAccuracy('JOGO_ALFABETO');

          final double progressoMemoria = state.getOverallGameProgress('JOGO_MEMORIA');
          final double? acertosMemoria = state.getOverallGameAccuracy('JOGO_MEMORIA');

          final double progressoAdivinhacao = state.getOverallGameProgress('JOGO_ADIVINHACAO');
          final double? acertosAdivinhacao = state.getOverallGameAccuracy('JOGO_ADIVINHACAO');

          final double progressoPalavras = state.getOverallGameProgress('JOGO_PALAVRAS');
          final double? acertosPalavras = state.getOverallGameAccuracy('JOGO_PALAVRAS');

          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              title: const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text('Menu de Jogos', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              actions: [
                // Imagem de perfil que é um botão
                if (state.isLoggedIn || isGuest || state.activePersonagem != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Tooltip(
                      message: 'Meu Perfil',
                      child: InkWell(
                        onTap: () => UserProfileDialog.show(context),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 17,
                            backgroundImage: AssetImage(avatarPath),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Botão Sair
                if (state.isLoggedIn || isGuest)
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: IconButton(
                      tooltip: 'Sair da Conta',
                      icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 24),
                      onPressed: () => AppHeaderWidget.executeLogout(context, state),
                    ),
                  ),
              ],
            ),
            body: Container(
              color: AppColors.bgSoft,
              child: SafeArea(
                child: RefreshIndicator(
                  onRefresh: vm.refreshAtividades,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (state.activePersonagem != null)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: AssetImage(state.activePersonagem!.avatar),
                                        radius: 28,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Olá, ${state.activePersonagem!.nome}!',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Escolha o nível de cada jogo no card correspondente abaixo:',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: AppColors.textDark.withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 24),
                              const Text(
                                'Escolha um jogo divertido:',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 16),
                              GridView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 480,
                                  mainAxisSpacing: 20,
                                  crossAxisSpacing: 20,
                                  mainAxisExtent: 335,
                                ),
                                children: [
                                  // 1. ALFABETO MANUAL
                                  GameCategoryCardWidget(
                                    title: 'Alfabeto Manual',
                                    description: 'Aprenda os sinais de Libras para cada letra do alfabeto!',
                                    color: AppColors.primary,
                                    icon: Icons.abc_rounded,
                                    badgeText: 'Módulo Fixo',
                                    currentDiff: vm.diffAlfabeto,
                                    onDiffChanged: vm.setDiffAlfabeto,
                                    pctConclusao: progressoAlfabeto,
                                    pctAcertos: acertosAlfabeto,
                                    onPlay: () {
                                      state.updatePersonagemDificuldade(vm.diffAlfabeto);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => JogoAlfabetoView(dificuldade: vm.diffAlfabeto),
                                        ),
                                      );
                                    },
                                  ),

                                  // 2. JOGO DA MEMÓRIA
                                  GameCategoryCardWidget(
                                    title: 'Jogo da Memória',
                                    description: 'Encontre os pares entre sinais em Libras e as letras correspondentes!',
                                    color: AppColors.secondary,
                                    icon: Icons.grid_view_rounded,
                                    badgeText: 'Módulo Fixo',
                                    currentDiff: vm.diffMemoria,
                                    onDiffChanged: vm.setDiffMemoria,
                                    pctConclusao: progressoMemoria,
                                    pctAcertos: acertosMemoria,
                                    onPlay: () {
                                      state.updatePersonagemDificuldade(vm.diffMemoria);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => JogoMemoriaView(dificuldade: vm.diffMemoria),
                                        ),
                                      );
                                    },
                                  ),

                                  // 3. JOGO DE ADIVINHAÇÃO
                                  GameCategoryCardWidget(
                                    title: 'Jogo de Adivinhação',
                                    description: 'Descubra a palavra secreta soletrando os sinais corretos!',
                                    color: AppColors.accent,
                                    icon: Icons.help_outline_rounded,
                                    badgeText: totalAdivinhacao > 0 ? '$totalAdivinhacao Temas Disponíveis' : null,
                                    currentDiff: vm.diffAdivinhacao,
                                    onDiffChanged: vm.setDiffAdivinhacao,
                                    pctConclusao: progressoAdivinhacao,
                                    pctAcertos: acertosAdivinhacao,
                                    onPlay: () {
                                      state.updatePersonagemDificuldade(vm.diffAdivinhacao);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SelecaoTemaView(
                                            tipoJogo: 'JOGO_ADIVINHACAO',
                                            initialDifficulty: vm.diffAdivinhacao,
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  // 4. JOGO DE PALAVRAS
                                  GameCategoryCardWidget(
                                    title: 'Jogo de Palavras',
                                    description: 'Veja o sinal em Libras e selecione a palavra escrita correspondente!',
                                    color: AppColors.info,
                                    icon: Icons.spellcheck_rounded,
                                    badgeText: totalPalavras > 0 ? '$totalPalavras Temas Disponíveis' : null,
                                    currentDiff: vm.diffPalavras,
                                    onDiffChanged: vm.setDiffPalavras,
                                    pctConclusao: progressoPalavras,
                                    pctAcertos: acertosPalavras,
                                    onPlay: () {
                                      state.updatePersonagemDificuldade(vm.diffPalavras);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SelecaoTemaView(
                                            tipoJogo: 'JOGO_PALAVRAS',
                                            initialDifficulty: vm.diffPalavras,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
