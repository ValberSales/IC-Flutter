import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../state/app_state_provider.dart';
import '../view_models/area_professor_view_model.dart';
import 'activities/activity_card_item_widget.dart';
import 'activities/activity_draft_banner_widget.dart';
import 'activities/activity_filter_header_widget.dart';

/// Painel da lista de atividades e jogos cadastrados na Área do Professor.
class ActivityListDashboardWidget extends StatelessWidget {
  final AreaProfessorViewModel viewModel;
  final AppStateProvider state;

  const ActivityListDashboardWidget({
    super.key,
    required this.viewModel,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final rascunho = state.rascunhoAtual;
    final atividades = state.atividades;

    final countTodos = atividades.length;
    final countAdivinhacao = atividades.where((a) => a.tipoJogo == 'JOGO_ADIVINHACAO').length;
    final countPalavras = atividades.where((a) => a.tipoJogo == 'JOGO_PALAVRAS').length;

    final atividadesExibidas = atividades.where((a) {
      if (viewModel.categoriaFiltro == 'JOGO_ADIVINHACAO') return a.tipoJogo == 'JOGO_ADIVINHACAO';
      if (viewModel.categoriaFiltro == 'JOGO_PALAVRAS') return a.tipoJogo == 'JOGO_PALAVRAS';
      return true;
    }).toList()
      ..sort((a, b) => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho e Filtros
              ActivityFilterHeaderWidget(
                viewModel: viewModel,
                countTodos: countTodos,
                countAdivinhacao: countAdivinhacao,
                countPalavras: countPalavras,
              ),
              const SizedBox(height: 20),

              // Card de Rascunho se houver progresso salvo
              if (rascunho != null) ...[
                ActivityDraftBannerWidget(
                  rascunho: rascunho,
                  viewModel: viewModel,
                  state: state,
                ),
                const SizedBox(height: 20),
              ],

              // Estado Vazio ou Lista de Atividades
              if (atividadesExibidas.isEmpty)
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.layers_clear_rounded, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhuma atividade encontrada nesta categoria.',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Clique em "Criar Nova Atividade" para adicionar seu primeiro tema customizado.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: atividadesExibidas.length,
                  itemBuilder: (context, index) {
                    final atv = atividadesExibidas[index];
                    return ActivityCardItemWidget(
                      atv: atv,
                      viewModel: viewModel,
                      state: state,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
