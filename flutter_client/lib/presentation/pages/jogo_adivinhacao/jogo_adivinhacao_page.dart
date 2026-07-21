import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/util/responsive_layout.dart';
import '../../../data/models/palavra.dart';
import '../../../data/sources/local_data_source.dart';
import '../../../state/app_state_provider.dart';
import '../../widgets/pontuacao_header_widget.dart';
import '../../widgets/mascote_feedback_widget.dart';
import '../../widgets/tutorial_widget.dart';

import '../../../data/models/atividade.dart';

class JogoAdivinhacaoPage extends StatefulWidget {
  final Atividade? atividadeTema;

  const JogoAdivinhacaoPage({
    super.key,
    this.atividadeTema,
  });

  @override
  State<JogoAdivinhacaoPage> createState() => _JogoAdivinhacaoPageState();
}

class _JogoAdivinhacaoPageState extends State<JogoAdivinhacaoPage> {
  List<Palavra> _palavras = [];
  Palavra? _selectedPalavra;
  List<String> _letrasPalavra = []; // Ex: ['G', 'A', 'T', 'O']
  List<Map<String, String>?> _letrasPreenchidas = []; // Ex: [null, null, null, null]
  int _activeSlotIndex = 0; // Slot ativo que receberá a letra selecionada
  
  bool _endGame = false;
  String _feedback = 'VAZIO';
  int _acertosCount = 0;
  int _errosCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarPalavras();
    });
  }

  void _carregarPalavras() {
    final state = context.read<AppStateProvider>();
    
    if (widget.atividadeTema != null && widget.atividadeTema!.itens.isNotEmpty) {
      _palavras = widget.atividadeTema!.itens.map((item) {
        return Palavra(
          tipo: 'JOGO_ADIVINHACAO',
          descricao: item.descricao,
          imagem: item.imagem,
        );
      }).toList();
    } else if (state.customPalavras.isNotEmpty) {
      _palavras = state.customPalavras.where((p) => p.tipo == 'JOGO_ADIVINHACAO').toList();
    }
    
    if (_palavras.isEmpty) {
      _palavras = LocalDataSource.animaisPadrao.map((item) {
        return Palavra(
          tipo: 'JOGO_ADIVINHACAO',
          descricao: item['descricao']!,
          imagem: item['imagem']!,
        );
      }).toList();
    }

    _iniciarRodada();
  }


  void _iniciarRodada() {
    if (_palavras.isEmpty) return;

    final random = Random();
    final palavraSorteada = _palavras[random.nextInt(_palavras.length)];
    final palavraTexto = palavraSorteada.descricao.toUpperCase();
    
    setState(() {
      _selectedPalavra = palavraSorteada;
      _letrasPalavra = palavraTexto.split('');
      _letrasPreenchidas = List.generate(palavraTexto.length, (_) => null);
      _activeSlotIndex = 0;
      _endGame = false;
      _feedback = 'VAZIO';
    });
  }

  void _setActiveSlot(int index) {
    setState(() {
      if (_letrasPreenchidas[index] != null) {
        _letrasPreenchidas[index] = null;
        _endGame = false;
      }
      _activeSlotIndex = index;
    });
  }

  void _selectLetra(Map<String, String> letraData) {
    if (_endGame) return;
    if (_activeSlotIndex < 0 || _activeSlotIndex >= _letrasPalavra.length) return;

    final letraCorreta = _letrasPalavra[_activeSlotIndex];
    final letraClicada = letraData['letra']!;
    
    final state = context.read<AppStateProvider>();

    if (letraClicada == letraCorreta) {
      setState(() {
        _letrasPreenchidas[_activeSlotIndex] = letraData;
        _acertosCount++;
        _feedback = 'ACERTO';
        
        // Encontra o próximo slot vazio
        _activeSlotIndex = _letrasPreenchidas.indexOf(null);
        
        // Verifica se completou a palavra
        if (_activeSlotIndex == -1) {
          _endGame = true;
        }
      });
      state.salvaPontuacao(_acertosCount, _errosCount, 'JOGO_ADIVINHACAO');
    } else {
      setState(() {
        _errosCount++;
        _feedback = 'ERRO';
      });
      state.salvaPontuacao(_acertosCount, _errosCount, 'JOGO_ADIVINHACAO');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final isCompact = ResponsiveLayout.isMobile(context);
    final dificuldade = state.activePersonagem?.dificuldade ?? 'FACIL';
    
    final bool dicaLetra = dificuldade == 'FACIL';

    if (_selectedPalavra == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (isCompact) {
      // MOBILE / TABLET COLLAPSIBLE LAYOUT
      return Scaffold(
        backgroundColor: AppColors.bgSoft,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Fixed Area: Score Header + Mascot/Tutorial
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Column(
                      children: [
                        PontuacaoHeaderWidget(
                          acertos: _acertosCount,
                          erros: _errosCount,
                          atividade: 'JOGO_ADIVINHACAO',
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const TutorialWidget(atividade: 'JOGO_ADIVINHACAO'),
                            MascoteFeedbackWidget(
                              feedbackType: _feedback,
                              clearFeedback: () {
                                setState(() {
                                  _feedback = 'VAZIO';
                                });
                              },
                              scale: 0.60,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Collapsible Area + Option grid
                  Expanded(
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: JogoAdivinhacaoHeaderDelegate(
                            palavra: _selectedPalavra!,
                            letrasPalavra: _letrasPalavra,
                            letrasPreenchidas: _letrasPreenchidas,
                            activeIndex: _activeSlotIndex,
                            onSlotTapped: _setActiveSlot,
                            isCompact: true,
                            difficulty: dificuldade,
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.all(16.0),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.82,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = state.currentAlfabeto[index];
                                return _buildSignCard(item, dicaLetra);
                              },
                              childCount: state.currentAlfabeto.length,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 80), // Padding to allow scrolling past bottom buttons
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_endGame) _buildNextButton(),
            ],
          ),
        ),
      );
    } else {
      // WEB / DESKTOP SIDE-BY-SIDE LAYOUT
      final bool dicaPalavra = dificuldade == 'FACIL' || dificuldade == 'MEDIO';
      
      return Scaffold(
        backgroundColor: AppColors.bgSoft,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Coluna da Esquerda (Desafio)
                    Expanded(
                      flex: 2,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                          side: const BorderSide(color: AppColors.border, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              PontuacaoHeaderWidget(
                                acertos: _acertosCount,
                                erros: _errosCount,
                                atividade: 'JOGO_ADIVINHACAO',
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const TutorialWidget(atividade: 'JOGO_ADIVINHACAO'),
                                  MascoteFeedbackWidget(
                                    feedbackType: _feedback,
                                    clearFeedback: () {
                                      setState(() {
                                        _feedback = 'VAZIO';
                                      });
                                    },
                                    scale: 0.70,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Center(
                                child: Container(
                                  constraints: const BoxConstraints(maxWidth: 320, maxHeight: 220),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgSoft,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: AppColors.secondary, width: 3.5),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Image.asset(
                                    _selectedPalavra!.imagem,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.image,
                                      size: 100,
                                      color: AppColors.primaryLight,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (dicaPalavra)
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryLight.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      _selectedPalavra!.descricao.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              Center(
                                child: _buildWebSlots(),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Coluna da Direita (Grid de Letras)
                    Expanded(
                      flex: 3,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                          side: const BorderSide(color: AppColors.border, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Selecione o sinal correto:',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 6,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.85,
                                  ),
                                  itemCount: state.currentAlfabeto.length,
                                  itemBuilder: (context, index) {
                                    final item = state.currentAlfabeto[index];
                                    return _buildSignCard(item, dicaLetra);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_endGame) _buildNextButton(),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildSignCard(Map<String, String> item, bool dicaLetra) {
    final String letra = item['letra']!;
    final String path = item['path']!;

    return InkWell(
      onTap: () => _selectLetra(item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 3,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset(
                  path,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Text(
                    letra,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            if (dicaLetra) ...[
              const Divider(height: 1, thickness: 1.5, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(
                  letra,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWebSlots() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(_letrasPalavra.length, (index) {
        final preenchida = _letrasPreenchidas[index];
        final isActive = index == _activeSlotIndex;

        return GestureDetector(
          onTap: () => _setActiveSlot(index),
          child: Container(
            width: 65,
            height: 78,
            decoration: BoxDecoration(
              color: preenchida != null
                  ? Colors.white
                  : (isActive ? AppColors.secondaryLight.withOpacity(0.3) : AppColors.border.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? AppColors.secondary
                    : (preenchida != null ? AppColors.primary : AppColors.border),
                width: isActive || preenchida != null ? 3.0 : 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: preenchida != null
                ? Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(
                      preenchida['path']!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Text(
                        preenchida['letra']!,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : Text(
                    '_',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark.withOpacity(0.5),
                    ),
                  ),
          ),
        );
      }),
    );
  }

  Widget _buildNextButton() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              elevation: 8,
              shadowColor: AppColors.secondary.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: _iniciarRodada,
            icon: const Icon(Icons.replay_rounded, size: 28, color: Colors.white),
            label: const Text(
              'Próxima Palavra!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- COLLAPSIBLE SLIVER HEADER DELEGATE ----------------

class JogoAdivinhacaoHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Palavra palavra;
  final List<String> letrasPalavra;
  final List<Map<String, String>?> letrasPreenchidas;
  final int activeIndex;
  final ValueChanged<int> onSlotTapped;
  final bool isCompact;
  final String difficulty;

  JogoAdivinhacaoHeaderDelegate({
    required this.palavra,
    required this.letrasPalavra,
    required this.letrasPreenchidas,
    required this.activeIndex,
    required this.onSlotTapped,
    required this.isCompact,
    required this.difficulty,
  });

  double _lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  @override
  double get maxExtent => 260.0;

  @override
  double get minExtent => 96.0;

  @override
  bool shouldRebuild(covariant JogoAdivinhacaoHeaderDelegate oldDelegate) {
    return true; // Rebuild to ensure updates propagate immediately
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Calcula a porcentagem de colapso baseada no scroll real do sliver
    final double percent = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    final double imageSize = _lerp(120.0, 52.0, percent);
    final double slotSize = _lerp(54.0, 42.0, percent);
    final double fontSize = _lerp(24.0, 18.0, percent);

    final bool dicaPalavra = difficulty == 'FACIL' || difficulty == 'MEDIO';

    return Container(
      color: AppColors.bgSoft,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: _lerp(4.0, 1.0, percent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_lerp(24.0, 16.0, percent)),
          side: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: percent < 0.65
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Modo Expandido: Imagem + dica opcional + slots embaixo
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          palavra.imagem,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.image,
                            size: 60,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (dicaPalavra)
                      Text(
                        palavra.descricao.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.secondary,
                        ),
                      ),
                    const SizedBox(height: 8),
                    _buildSlotsRow(slotSize, fontSize),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Modo Colapsado: Slots na esquerda (com scroll se palavra for grande), Imagem pequena na direita
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildSlotsRow(slotSize, fontSize),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: imageSize,
                      height: imageSize,
                      decoration: BoxDecoration(
                        color: AppColors.bgSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        palavra.imagem,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.image,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSlotsRow(double slotSize, double fontSize) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: List.generate(letrasPalavra.length, (index) {
        final preenchida = letrasPreenchidas[index];
        final isActive = index == activeIndex;

        return GestureDetector(
          onTap: () => onSlotTapped(index),
          child: Container(
            width: slotSize,
            height: slotSize * 1.2,
            decoration: BoxDecoration(
              color: preenchida != null
                  ? Colors.white
                  : (isActive ? AppColors.secondaryLight.withOpacity(0.3) : AppColors.border.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? AppColors.secondary
                    : (preenchida != null ? AppColors.primary : AppColors.border),
                width: isActive || preenchida != null ? 3.0 : 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: preenchida != null
                ? Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Image.asset(
                      preenchida['path']!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Text(
                        preenchida['letra']!,
                        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : Text(
                    '_',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark.withOpacity(0.5),
                    ),
                  ),
          ),
        );
      }),
    );
  }
}
