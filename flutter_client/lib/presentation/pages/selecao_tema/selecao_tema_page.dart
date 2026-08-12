import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/app_state_provider.dart';
import '../../../data/models/atividade.dart';
import '../jogo_adivinhacao/jogo_adivinhacao_page.dart';
import '../jogo_palavras/jogo_palavras_page.dart';

class SelecaoTemaPage extends StatefulWidget {
  final String tipoJogo; // 'JOGO_ADIVINHACAO' | 'JOGO_PALAVRAS'

  const SelecaoTemaPage({
    super.key,
    required this.tipoJogo,
  });

  @override
  State<SelecaoTemaPage> createState() => _SelecaoTemaPageState();
}

class _SelecaoTemaPageState extends State<SelecaoTemaPage> {
  String _currentDifficulty = 'FACIL';

  @override
  void initState() {
    super.initState();
    final p = context.read<AppStateProvider>().activePersonagem;
    if (p != null) {
      _currentDifficulty = p.dificuldade;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final isAdivinhacao = widget.tipoJogo == 'JOGO_ADIVINHACAO';
    final String tituloJogo = isAdivinhacao ? 'Jogo de Adivinhação' : 'Jogo de Palavras';

    // Lista de temas padrão
    final List<Map<String, dynamic>> temasPadrao = isAdivinhacao
        ? [
            {
              'titulo': 'Animais da Natureza',
              'descricao': 'Adivinhe o nome dos animais sinalizados',
              'icone': Icons.pets_rounded,
              'cor': AppColors.accent,
              'atividade': null,
            }
          ]
        : [
            {
              'titulo': 'Membros da Família',
              'descricao': 'Associe as palavras aos membros da família',
              'icone': Icons.diversity_3_rounded,
              'cor': AppColors.info,
              'atividade': null,
            }
          ];

    // Temas criados por professores
    final atividadesCustom = state.atividades.where((a) => a.ativo && a.tipoJogo == widget.tipoJogo).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Escolha o Tema: $tituloJogo',
          style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Fredoka'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _currentDifficulty,
                    dropdownColor: AppColors.primary,
                    icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.white),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    items: const [
                      DropdownMenuItem(value: 'FACIL', child: Text('Fácil 🌟', style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(value: 'MEDIO', child: Text('Médio ✨', style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(value: 'DIFICIL', child: Text('Difícil 🔥', style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _currentDifficulty = val;
                          if (state.activePersonagem != null) {
                            state.activePersonagem!.dificuldade = val;
                          }
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: AppColors.bgSoft,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await state.fetchAtividadesOnline();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Banner Informativo de Escolha de Tema
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
                          border: Border.all(
                            color: isAdivinhacao ? AppColors.accent : AppColors.info,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isAdivinhacao ? Icons.search_rounded : Icons.collections_bookmark_rounded,
                              size: 36,
                              color: isAdivinhacao ? AppColors.accent : AppColors.info,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Selecione o Tema Desejado:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Fredoka',
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Escolha um tema para jogar no Nível selecionado!',
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
                        'Temas Cadastrados:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Fredoka', color: AppColors.textDark),
                      ),
                      const SizedBox(height: 16),

                      // Listagem unificada e dinâmica de temas
                      Builder(
                        builder: (context) {
                          // Se houver atividades vindo do backend/cache para o jogo atual
                          final atividadesFiltradas = state.atividades
                              .where((a) => a.ativo && a.tipoJogo == widget.tipoJogo)
                              .toList();

                          if (atividadesFiltradas.isNotEmpty) {
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 480,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 190,
                              ),
                              itemCount: atividadesFiltradas.length,
                              itemBuilder: (context, index) {
                                final Atividade atv = atividadesFiltradas[index];
                                final int count = atv.itens.length > 0 ? atv.itens.length : 5;
                                final double pctConclusao = state.getTemaCompletionPercentage(
                                  jogo: widget.tipoJogo,
                                  tema: atv,
                                  temaNomePadrao: atv.titulo,
                                  totalItens: count,
                                  dificuldade: _currentDifficulty,
                                );
                                final double? pctAcertos = state.getAccuracyPercentage(widget.tipoJogo, atv.titulo, dificuldade: _currentDifficulty);

                                final bool isDefault = atv.criadoPor == "Sistema InteraLibras" || atv.criadoPor == null;

                                return _buildThemeCard(
                                  context: context,
                                  titulo: atv.titulo,
                                  descricao: '${atv.itens.length} palavras  •  ${isDefault ? "Tema Padrão" : "Criado por ${atv.criadoPor}"}',
                                  icone: isAdivinhacao ? Icons.pets_rounded : Icons.diversity_3_rounded,
                                  cor: isAdivinhacao ? AppColors.accent : AppColors.info,
                                  isTeacherCreated: !isDefault,
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
                              },
                            );
                          }

                          // Fallback se nenhuma atividade online/cache for encontrada
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 480,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              mainAxisExtent: 190,
                            ),
                            itemCount: temasPadrao.length,
                            itemBuilder: (context, index) {
                              final item = temasPadrao[index];
                              final String temaNome = item['titulo'];
                              final int defaultCount = isAdivinhacao ? 5 : 4;
                              final double pctConclusao = state.getTemaCompletionPercentage(
                                jogo: widget.tipoJogo,
                                tema: null,
                                temaNomePadrao: temaNome,
                                totalItens: defaultCount,
                                dificuldade: _currentDifficulty,
                              );
                              final double? pctAcertos = state.getAccuracyPercentage(widget.tipoJogo, temaNome, dificuldade: _currentDifficulty);

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
  }

  Widget _buildThemeCard({
    required BuildContext context,
    required String titulo,
    required String descricao,
    required IconData icone,
    required Color cor,
    required bool isTeacherCreated,
    required double pctConclusao,
    required double? pctAcertos,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icone, size: 32, color: cor),
                  ),
                  const SizedBox(width: 12),
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
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Fredoka',
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
                                  'Turma',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
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
                            fontSize: 12,
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
                padding: const EdgeInsets.all(10),
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
                            const Icon(Icons.task_alt_rounded, size: 16, color: AppColors.accent),
                            const SizedBox(width: 4),
                            Text(
                              'Conclusão: ${pctConclusao.toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(
                              'Acertos: ${pctAcertos != null ? "${pctAcertos.toStringAsFixed(0)}%" : "-"}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (pctConclusao / 100.0).clamp(0.0, 1.0),
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(cor),
                        minHeight: 6,
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
