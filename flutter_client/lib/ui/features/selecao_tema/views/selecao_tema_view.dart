import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../state/app_state_provider.dart';
import '../../../core/app_header_widget.dart';
import '../../../core/icon_picker_dialog.dart';
import '../../../core/user_profile_dialog.dart';
import '../../jogo_adivinhacao/views/jogo_adivinhacao_view.dart';
import '../../jogo_palavras/views/jogo_palavras_view.dart';
import '../view_models/selecao_tema_view_model.dart';
import '../widgets/tema_card_widget.dart';

class SelecaoTemaView extends StatefulWidget {
  final String tipoJogo;
  final String? initialDifficulty;

  const SelecaoTemaView({
    super.key,
    required this.tipoJogo,
    this.initialDifficulty,
  });

  @override
  State<SelecaoTemaView> createState() => _SelecaoTemaViewState();
}

class _SelecaoTemaViewState extends State<SelecaoTemaView> {
  late SelecaoTemaViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppStateProvider>();
    _viewModel = SelecaoTemaViewModel(
      appState: appState,
      tipoJogo: widget.tipoJogo,
      initialDifficulty: widget.initialDifficulty,
    );
    // Atualização imediata ao abrir a tela
    appState.fetchAtividadesOnline();
    if (appState.currentUser != null) {
      appState.fetchAlunoTurmaOnline();
    }
  }

  Widget _buildDiffChip(
    String code,
    String label,
    String currentDiff,
    ValueChanged<String> onChanged,
    Color activeColor,
  ) {
    final isSelected = currentDiff == code;

    return Expanded(
      child: InkWell(
        onTap: () => onChanged(code),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? activeColor : activeColor.withValues(alpha: 0.35),
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                color: isSelected ? Colors.white : activeColor,
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
    final isAdivinhacao = widget.tipoJogo == 'JOGO_ADIVINHACAO';
    final String tituloJogo = isAdivinhacao ? 'Jogo de Adivinhação' : 'Jogo de Palavras';
    final Color themeColor = isAdivinhacao ? AppColors.accent : AppColors.info;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<SelecaoTemaViewModel>(
        builder: (context, vm, _) {
          final diff = vm.currentDifficulty;

          // Filtra os temas disponíveis conforme o status global e a visibilidade (Pública vs Turma)
          final atividadesDisponiveis = state.atividades.where((a) {
            // Regra 1: Deve estar ativo globalmente
            if (!a.ativo) return false;
            // Regra 2: Tipo de jogo correspondente
            if (a.tipoJogo != widget.tipoJogo) return false;

            // Se for Professor/Admin, pode visualizar todos os temas ativos para teste
            if (state.currentUser?.role == 'ADMIN') return true;

            final isAlocadaNaTurma = state.isTemaDaTurma(a.titulo, a.id);

            // Regra 3: Convidado / Não logado só visualiza atividades públicas
            if (state.isGuestMode || !state.isLoggedIn) {
              return a.publica;
            }

            // Regra 4: Aluno logado visualiza se for pública OU se for direcionada à sua turma ativa
            return a.publica || isAlocadaNaTurma;
          }).toList()
            ..sort((a, b) {
              final aTurma = state.isTemaDaTurma(a.titulo, a.id);
              final bTurma = state.isTemaDaTurma(b.titulo, b.id);
              if (aTurma && !bTurma) return -1;
              if (!aTurma && bTurma) return 1;
              return a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase());
            });
          final avatarPath = state.currentUser?.avatar ?? 'assets/avatar/avatar_1.jpg';

          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              title: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  tituloJogo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              actions: [
                if (state.isLoggedIn || state.isGuestMode)
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
                if (state.isLoggedIn || state.isGuestMode)
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
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Card Informativo com Seletor de Dificuldade Integrado
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: themeColor.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: themeColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Icon(
                                          isAdivinhacao ? Icons.pets_rounded : Icons.diversity_3_rounded,
                                          size: 32,
                                          color: themeColor,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isAdivinhacao
                                                  ? 'Adivinhe os sinais soletrando em Libras!'
                                                  : 'Associe o sinal em Libras com a palavra correta!',
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.textDark,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              'Escolha o nível de dificuldade e selecione um tema abaixo para jogar:',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: AppColors.textDark.withValues(alpha: 0.75),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(height: 1, color: AppColors.border),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      _buildDiffChip('FACIL', 'Fácil 🌟', diff, vm.setDifficulty, themeColor),
                                      const SizedBox(width: 8),
                                      _buildDiffChip('MEDIO', 'Médio ✨', diff, vm.setDifficulty, themeColor),
                                      const SizedBox(width: 8),
                                      _buildDiffChip('DIFICIL', 'Difícil 🔥', diff, vm.setDifficulty, themeColor),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (state.activeTurma != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.school_rounded, color: AppColors.accent, size: 22),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Turma Ativa: ${state.activeTurma!.nome} (PIN: ${state.activeTurma!.codigo}) — Atividades direcionadas pelo seu professor estão destacadas com 🎯',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),

                            if (atividadesDisponiveis.isEmpty)
                              Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                child: Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        isAdivinhacao ? Icons.pets_rounded : Icons.collections_rounded,
                                        size: 64,
                                        color: AppColors.primaryLight,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Nenhum tema encontrado para este jogo',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Peça para o professor cadastrar novos temas no Painel do Professor.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: AppColors.textDark),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 480,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  mainAxisExtent: 220,
                                ),
                                itemCount: atividadesDisponiveis.length,
                                itemBuilder: (context, index) {
                                  final atv = atividadesDisponiveis[index];
                                  final int totalItens = atv.itens.isNotEmpty ? atv.itens.length : 5;

                                  final double pctConclusao = state.getTemaCompletionPercentage(
                                    jogo: widget.tipoJogo,
                                    tema: atv,
                                    temaNomePadrao: atv.titulo,
                                    totalItens: totalItens,
                                    dificuldade: diff,
                                  );

                                  final double? pctAcertos = state.getAccuracyPercentage(
                                    widget.tipoJogo,
                                    atv.titulo,
                                    dificuldade: diff,
                                  );

                                  final bool isAssigned = state.isTemaDaTurma(atv.titulo, atv.id);

                                  return TemaCardWidget(
                                    titulo: atv.titulo,
                                    descricao: 'Tema com ${atv.itens.length} palavras cadastradas',
                                    icone: atv.icone != null && atv.icone!.isNotEmpty
                                        ? IconPickerDialogWidget.getIconData(atv.icone)
                                        : (isAdivinhacao ? Icons.pets_rounded : Icons.diversity_3_rounded),
                                    cor: themeColor,
                                    isTeacherCreated: true,
                                    isTurmaAssigned: isAssigned,
                                    pctConclusao: pctConclusao,
                                    pctAcertos: pctAcertos,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => isAdivinhacao
                                              ? JogoAdivinhacaoView(
                                                  atividadeTema: atv,
                                                  dificuldade: vm.currentDifficulty,
                                                )
                                              : JogoPalavrasView(
                                                  atividadeTema: atv,
                                                  dificuldade: vm.currentDifficulty,
                                                ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                          ],
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
