import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/app_state_provider.dart';
import '../jogo_alfabeto/jogo_alfabeto_page.dart';
import '../jogo_memoria/jogo_memoria_page.dart';
import '../selecao_tema/selecao_tema_page.dart';

class JogoHubPage extends StatefulWidget {
  const JogoHubPage({super.key});

  @override
  State<JogoHubPage> createState() => _JogoHubPageState();
}

class _JogoHubPageState extends State<JogoHubPage> {
  // Individual difficulty levels for each category card
  String _diffAlfabeto = 'FACIL';
  String _diffMemoria = 'FACIL';
  String _diffAdivinhacao = 'FACIL';
  String _diffPalavras = 'FACIL';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Menu de Jogos',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Fredoka'),
        ),
      ),
      body: Container(
        color: AppColors.bgSoft,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header amigável com perfil do aluno
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
                                        fontFamily: 'Fredoka',
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
                          fontFamily: 'Fredoka',
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Grid de Jogos com Colunas Dinâmicas e Max Width nos Cards
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 480,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          mainAxisExtent: 295,
                        ),
                        children: [
                          // 1. ALFABETO MANUAL
                          _buildGameCategoryCard(
                            context: context,
                            title: 'Alfabeto Manual',
                            description: 'Aprenda os sinais de Libras para cada letra do alfabeto!',
                            color: AppColors.primary,
                            icon: Icons.abc_rounded,
                            currentDiff: _diffAlfabeto,
                            onDiffChanged: (newDiff) {
                              setState(() {
                                _diffAlfabeto = newDiff;
                              });
                            },
                            pctConclusao: state.getCompletionPercentage('JOGO_ALFABETO', 'Alfabeto'),
                            pctAcertos: state.getAccuracyPercentage('JOGO_ALFABETO', 'Alfabeto'),
                            onPlay: () {
                              if (state.activePersonagem != null) {
                                state.activePersonagem!.dificuldade = _diffAlfabeto;
                              }
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const JogoAlfabetoPage()),
                              );
                            },
                          ),
                          
                          // 2. JOGO DA MEMÓRIA
                          _buildGameCategoryCard(
                            context: context,
                            title: 'Jogo da Memória',
                            description: 'Encontre os pares combinando a letra e o sinal em Libras!',
                            color: AppColors.secondary,
                            icon: Icons.grid_view_rounded,
                            currentDiff: _diffMemoria,
                            onDiffChanged: (newDiff) {
                              setState(() {
                                _diffMemoria = newDiff;
                              });
                            },
                            pctConclusao: state.getCompletionPercentage('JOGO_MEMORIA', 'Memoria'),
                            pctAcertos: state.getAccuracyPercentage('JOGO_MEMORIA', 'Memoria'),
                            onPlay: () {
                              if (state.activePersonagem != null) {
                                state.activePersonagem!.dificuldade = _diffMemoria;
                              }
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const JogoMemoriaPage()),
                              );
                            },
                          ),
                          
                          // 3. JOGO DE ADIVINHAÇÃO
                          _buildGameCategoryCard(
                            context: context,
                            title: 'Adivinhação',
                            description: 'Escolha o tema e forme as palavras selecionando os sinais corretos!',
                            color: AppColors.accent,
                            icon: Icons.search_rounded,
                            currentDiff: _diffAdivinhacao,
                            onDiffChanged: (newDiff) {
                              setState(() {
                                _diffAdivinhacao = newDiff;
                              });
                            },
                            pctConclusao: state.getCompletionPercentage('JOGO_ADIVINHACAO', 'Adivinhacao'),
                            pctAcertos: state.getAccuracyPercentage('JOGO_ADIVINHACAO', 'Adivinhacao'),
                            onPlay: () {
                              if (state.activePersonagem != null) {
                                state.activePersonagem!.dificuldade = _diffAdivinhacao;
                              }
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SelecaoTemaPage(tipoJogo: 'JOGO_ADIVINHACAO')),
                              );
                            },
                          ),
                          
                          // 4. JOGO DE PALAVRAS
                          _buildGameCategoryCard(
                            context: context,
                            title: 'Jogo de Palavras',
                            description: 'Escolha o tema, veja a foto e selecione a palavra correta!',
                            color: AppColors.info,
                            icon: Icons.collections_rounded,
                            currentDiff: _diffPalavras,
                            onDiffChanged: (newDiff) {
                              setState(() {
                                _diffPalavras = newDiff;
                              });
                            },
                            pctConclusao: state.getCompletionPercentage('JOGO_PALAVRAS', 'Palavras'),
                            pctAcertos: state.getAccuracyPercentage('JOGO_PALAVRAS', 'Palavras'),
                            onPlay: () {
                              if (state.activePersonagem != null) {
                                state.activePersonagem!.dificuldade = _diffPalavras;
                              }
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SelecaoTemaPage(tipoJogo: 'JOGO_PALAVRAS')),
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
    );
  }

  Widget _buildGameCategoryCard({
    required BuildContext context,
    required String title,
    required String description,
    required Color color,
    required IconData icon,
    required String currentDiff,
    required ValueChanged<String> onDiffChanged,
    required double pctConclusao,
    required double pctAcertos,
    required VoidCallback onPlay,
  }) {
    return Card(
      elevation: 6,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: color.withOpacity(0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Header (Icon + Title + Description)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: color, size: 36),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Fredoka',
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
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

            // Seletor de Dificuldade Individual para este Card
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nível de Dificuldade:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    Text(
                      currentDiff == 'FACIL' ? 'Fácil 🌟' : currentDiff == 'MEDIO' ? 'Médio ✨' : 'Difícil 🔥',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildDiffChip('FACIL', 'Fácil 🌟', currentDiff, onDiffChanged, color),
                    const SizedBox(width: 6),
                    _buildDiffChip('MEDIO', 'Médio ✨', currentDiff, onDiffChanged, color),
                    const SizedBox(width: 6),
                    _buildDiffChip('DIFICIL', 'Difícil 🔥', currentDiff, onDiffChanged, color),
                  ],
                ),
              ],
            ),

            // Indicadores de Desempenho
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
                      Text(
                        'Conclusão: ${pctConclusao.toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      Text(
                        'Acertos: ${pctAcertos.toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (pctConclusao / 100.0).clamp(0.0, 1.0),
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            // Botão Jogar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: onPlay,
              child: const Text(
                'Jogar Agora 🚀',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Fredoka'),
              ),
            ),
          ],
        ),
      ),
    );
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
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : activeColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: activeColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'Fredoka',
              color: isSelected ? Colors.white : activeColor,
            ),
          ),
        ),
      ),
    );
  }
}
