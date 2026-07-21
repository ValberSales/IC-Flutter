import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/app_state_provider.dart';
import '../../../data/models/atividade.dart';
import '../jogo_adivinhacao/jogo_adivinhacao_page.dart';
import '../jogo_palavras/jogo_palavras_page.dart';

class SelecaoTemaPage extends StatelessWidget {
  final String tipoJogo; // 'JOGO_ADIVINHACAO' | 'JOGO_PALAVRAS'

  const SelecaoTemaPage({
    super.key,
    required this.tipoJogo,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final isAdivinhacao = tipoJogo == 'JOGO_ADIVINHACAO';
    final String tituloJogo = isAdivinhacao ? 'Jogo de Adivinhação' : 'Jogo de Palavras';

    // Lista de temas padrão
    final List<Map<String, dynamic>> temasPadrao = isAdivinhacao
        ? [
            {
              'titulo': 'Animais da Natureza',
              'descricao': 'Adivinhe o nome dos animais sinalizados',
              'icone': Icons.pets_rounded,
              'cor': AppColors.accent,
              'atividade': null, // Usa o padrão
            }
          ]
        : [
            {
              'titulo': 'Membros da Família',
              'descricao': 'Associe as palavras aos membros da família',
              'icone': Icons.diversity_3_rounded,
              'cor': AppColors.info,
              'atividade': null, // Usa o padrão
            }
          ];

    // Temas criados por professores
    final atividadesCustom = state.atividades.where((a) => a.ativo && a.tipoJogo == tipoJogo).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Escolha o Tema: $tituloJogo',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: AppColors.bgSoft,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner Informativo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: (isAdivinhacao ? AppColors.accent : AppColors.info).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isAdivinhacao ? AppColors.accent : AppColors.info,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isAdivinhacao ? Icons.search_rounded : Icons.collections_bookmark_rounded,
                        size: 40,
                        color: isAdivinhacao ? AppColors.accent : AppColors.info,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selecione um nível ou tema:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Escolha uma das atividades abaixo para começar a jogar e ver seu progresso!',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textDark.withOpacity(0.8),
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
                  'Temas Disponíveis:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark),
                ),
                const SizedBox(height: 16),

                // Grid de Cartões de Tema
                LayoutBuilder(
                  builder: (context, constraints) {
                    final int columns = constraints.maxWidth > 800 ? 2 : 1;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: columns == 2 ? 1.8 : 1.5,
                      ),
                      itemCount: temasPadrao.length + atividadesCustom.length,
                      itemBuilder: (context, index) {
                        if (index < temasPadrao.length) {
                          // Cartão Padrão
                          final item = temasPadrao[index];
                          final String temaNome = item['titulo'];
                          final double pctConclusao = state.getCompletionPercentage(tipoJogo, temaNome);
                          final double pctAcertos = state.getAccuracyPercentage(tipoJogo, temaNome);

                          return _buildThemeCard(
                            context: context,
                            titulo: temaNome,
                            descricao: item['descricao'],
                            icone: item['icone'],
                            cor: item['cor'],
                            isTeacherCreated: false,
                            pctConclusao: pctConclusao,
                            pctAcertos: pctAcertos,
                            onTap: () {
                              if (isAdivinhacao) {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const JogoAdivinhacaoPage()));
                              } else {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const JogoPalavrasPage()));
                              }
                            },
                          );
                        } else {
                          // Cartão Criado pelo Professor
                          final Atividade atv = atividadesCustom[index - temasPadrao.length];
                          final double pctConclusao = state.getCompletionPercentage(tipoJogo, atv.titulo);
                          final double pctAcertos = state.getAccuracyPercentage(tipoJogo, atv.titulo);

                          return _buildThemeCard(
                            context: context,
                            titulo: atv.titulo,
                            descricao: '${atv.itens.length} palavras  •  Criado por ${atv.criadoPor ?? "Professor"}',
                            icone: Icons.school_rounded,
                            cor: AppColors.primary,
                            isTeacherCreated: true,
                            pctConclusao: pctConclusao,
                            pctAcertos: pctAcertos,
                            onTap: () {
                              if (isAdivinhacao) {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => JogoAdivinhacaoPage(atividadeTema: atv)));
                              } else {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => JogoPalavrasPage(atividadeTema: atv)));
                              }
                            },
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard({
    required BuildContext context,
    required String titulo,
    required String descricao,
    required IconData icone,
    required Color cor,
    required bool isTeacherCreated,
    required double pctConclusao,
    required double pctAcertos,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(icone, size: 36, color: cor),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                titulo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            if (isTeacherCreated)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Professor',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          descricao,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
              const SizedBox(height: 12),

              // Indicadores de Desempenho (Conclusão e Acertos)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.task_alt_rounded, size: 18, color: AppColors.accent),
                            const SizedBox(width: 6),
                            Text(
                              'Conclusão: ${pctConclusao.toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 18, color: AppColors.secondary),
                            const SizedBox(width: 6),
                            Text(
                              'Acertos: ${pctAcertos.toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (pctConclusao / 100.0).clamp(0.0, 1.0),
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(cor),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
