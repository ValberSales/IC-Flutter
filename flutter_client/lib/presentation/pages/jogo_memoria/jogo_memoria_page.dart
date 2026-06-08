import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/util/responsive_layout.dart';
import '../../../state/app_state_provider.dart';
import '../../widgets/pontuacao_header_widget.dart';
import '../../widgets/mascote_feedback_widget.dart';
import '../../widgets/tutorial_widget.dart';

class CartaMemoria {
  final String letra;
  final String path;
  final bool figura; // true = sinal libras, false = letra escrita
  bool revelada;
  final int uniqueId;

  CartaMemoria({
    required this.letra,
    required this.path,
    required this.figura,
    this.revelada = true,
    required this.uniqueId,
  });

  CartaMemoria copy({bool? revelada}) {
    return CartaMemoria(
      letra: letra,
      path: path,
      figura: figura,
      revelada: revelada ?? this.revelada,
      uniqueId: uniqueId,
    );
  }
}

class JogoMemoriaPage extends StatefulWidget {
  const JogoMemoriaPage({super.key});

  @override
  State<JogoMemoriaPage> createState() => _JogoMemoriaPageState();
}

class _JogoMemoriaPageState extends State<JogoMemoriaPage> {
  List<CartaMemoria> _cartas = [];
  CartaMemoria? _primeiraCarta;
  CartaMemoria? _segundaCarta;
  bool _bloqueado = false;
  bool _endGame = false;
  String _feedback = 'VAZIO';
  int _acertosCount = 0;
  int _errosCount = 0;
  Timer? _initialRevealTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _iniciarNovoJogo();
    });
  }

  @override
  void dispose() {
    _initialRevealTimer?.cancel();
    super.dispose();
  }

  void _iniciarNovoJogo() {
    _initialRevealTimer?.cancel();
    final state = context.read<AppStateProvider>();
    final alfabeto = [...state.currentAlfabeto];
    if (alfabeto.isEmpty) return;

    final dificuldade = state.activePersonagem?.dificuldade ?? 'FACIL';
    int quantidadePares = 6; // Fácil: 12 cartas
    if (dificuldade == 'MEDIO') {
      quantidadePares = 8; // Médio: 16 cartas
    } else if (dificuldade == 'DIFICIL') {
      quantidadePares = 10; // Difícil: 20 cartas
    }

    // 1. Sortear as N letras para os pares
    alfabeto.shuffle();
    final letrasSorteadas = alfabeto.take(quantidadePares).toList();

    // 2. Criar cartas (um par por letra: figura e texto)
    final List<CartaMemoria> cartasTemp = [];
    int idCounter = 0;
    
    for (final item in letrasSorteadas) {
      final letra = item['letra']!;
      final path = item['path']!;
      
      // Carta Letra Escrita
      cartasTemp.add(CartaMemoria(
        letra: letra,
        path: path,
        figura: false,
        revelada: true,
        uniqueId: idCounter++,
      ));
      
      // Carta Sinal Libras
      cartasTemp.add(CartaMemoria(
        letra: letra,
        path: path,
        figura: true,
        revelada: true,
        uniqueId: idCounter++,
      ));
    }

    // 3. Embaralhar cartas
    cartasTemp.shuffle();

    setState(() {
      _cartas = cartasTemp;
      _primeiraCarta = null;
      _segundaCarta = null;
      _bloqueado = false;
      _endGame = false;
      _feedback = 'VAZIO';
    });

    // 4. Iniciar timer de 5 segundos para virar as cartas
    _initialRevealTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          for (var c in _cartas) {
            c.revelada = false;
          }
        });
      }
    });
  }

  void _revelarCarta(CartaMemoria carta) {
    if (_bloqueado || carta.revelada || (_primeiraCarta != null && _segundaCarta != null)) {
      return;
    }

    setState(() {
      carta.revelada = true;
    });

    if (_primeiraCarta == null) {
      setState(() {
        _primeiraCarta = carta;
        _feedback = 'VAZIO';
      });
    } else {
      setState(() {
        _segundaCarta = carta;
      });
      _verificarPar();
    }
  }

  void _verificarPar() {
    if (_primeiraCarta == null || _segundaCarta == null) return;
    
    final state = context.read<AppStateProvider>();

    if (_primeiraCarta!.letra == _segundaCarta!.letra) {
      // Acertou par
      setState(() {
        _acertosCount++;
        _feedback = 'ACERTO';
        _primeiraCarta = null;
        _segundaCarta = null;
        
        // Verifica fim do jogo
        if (_cartas.every((c) => c.revelada)) {
          _endGame = true;
        }
      });
      state.salvaPontuacao(_acertosCount, _errosCount, 'JOGO_MEMORIA');
    } else {
      // Errou par
      setState(() {
        _errosCount++;
        _feedback = 'ERRO';
        _bloqueado = true;
      });
      state.salvaPontuacao(_acertosCount, _errosCount, 'JOGO_MEMORIA');
      
      // Aguarda 1 segundo e desvira as duas cartas
      Timer(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _primeiraCarta!.revelada = false;
            _segundaCarta!.revelada = false;
            _primeiraCarta = null;
            _segundaCarta = null;
            _bloqueado = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = ResponsiveLayout.isMobile(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    // Ajusta número de colunas conforme o tamanho da tela e quantidade de cartas
    int columns = 3;
    if (isCompact) {
      columns = _cartas.length >= 20 ? 4 : 3;
    } else if (isTablet) {
      columns = 4;
    } else {
      columns = 5;
    }

    return Scaffold(
      backgroundColor: AppColors.bgSoft,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header de Pontuação
                  PontuacaoHeaderWidget(
                    acertos: _acertosCount,
                    erros: _errosCount,
                    atividade: 'JOGO_MEMORIA',
                  ),
                  const SizedBox(height: 16),

                  // Ações de ajuda / Feedback
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TutorialWidget(atividade: 'JOGO_MEMORIA'),
                      MascoteFeedbackWidget(
                        feedbackType: _feedback,
                        clearFeedback: () {
                          setState(() {
                            _feedback = 'VAZIO';
                          });
                        },
                        scale: 0.65,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tabuleiro do Jogo
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.95,
                        ),
                        itemCount: _cartas.length,
                        itemBuilder: (context, index) {
                          final carta = _cartas[index];
                          return _buildCardItem(carta);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),

            // Botão Novo Jogo quando finaliza
            if (_endGame)
              Positioned(
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
                      onPressed: _iniciarNovoJogo,
                      icon: const Icon(Icons.replay_rounded, size: 28, color: Colors.white),
                      label: const Text(
                        'Jogar Novamente',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem(CartaMemoria carta) {
    // Custom flip animation using AnimatedSwitcher
    return GestureDetector(
      onTap: () => _revelarCarta(carta),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final rotate = Tween(begin: pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, child) {
              final angle = rotate.value;
              final tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
              
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, tilt)
                  ..rotateY(angle),
                alignment: Alignment.center,
                child: child,
              );
            },
          );
        },
        child: carta.revelada
            ? _buildCardFront(carta)
            : _buildCardBack(carta),
      ),
    );
  }

  // Frente da Carta (Revelada)
  Widget _buildCardFront(CartaMemoria carta) {
    return Container(
      key: const ValueKey(true),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 3.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: carta.figura
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  carta.path,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      carta.letra,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    carta.letra,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  // Verso da Carta (Oculta)
  Widget _buildCardBack(CartaMemoria carta) {
    return Container(
      key: const ValueKey(false),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      alignment: Alignment.center,
      child: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Text(
            '?',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
