import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/util/responsive_layout.dart';
import '../../../state/app_state_provider.dart';
import '../../widgets/pontuacao_header_widget.dart';
import '../../widgets/mascote_feedback_widget.dart';
import '../../widgets/tutorial_widget.dart';
import '../../widgets/jogo_breadcrumb_widget.dart';

class LetraJogo {
  final Map<String, String> letraData;
  bool pendente;

  LetraJogo({required this.letraData, this.pendente = true});
}

class JogoAlfabetoPage extends StatefulWidget {
  const JogoAlfabetoPage({super.key});

  @override
  State<JogoAlfabetoPage> createState() => _JogoAlfabetoPageState();
}

class _JogoAlfabetoPageState extends State<JogoAlfabetoPage> {
  Map<String, String>? _letraSorteada;
  List<LetraJogo> _opcoes = [];
  bool _acerto = false;
  String _feedback = 'VAZIO';
  int _acertosCount = 0;
  int _errosCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _iniciarNovoJogo();
    });
  }

  void _iniciarNovoJogo() {
    final state = context.read<AppStateProvider>();
    final alfabeto = state.currentAlfabeto;
    if (alfabeto.isEmpty) return;

    final random = Random();
    
    // 1. Sortear Letra
    final sorteada = alfabeto[random.nextInt(alfabeto.length)];
    
    // 2. Gerar opções com base na dificuldade
    final dificuldade = state.activePersonagem?.dificuldade ?? 'FACIL';
    int quantidadeOpcoes = 3;
    if (dificuldade == 'MEDIO') {
      quantidadeOpcoes = 5;
    } else if (dificuldade == 'DIFICIL') {
      quantidadeOpcoes = 7;
    }

    // Filtra alfabeto removendo a correta para obter as erradas
    final restantes = alfabeto.where((item) => item['letra'] != sorteada['letra']).toList();
    restantes.shuffle();

    // Monta lista de opções final (letra correta + n letras incorretas)
    final listOpcoes = [sorteada];
    final numAdicionais = min(quantidadeOpcoes - 1, restantes.length);
    for (int i = 0; i < numAdicionais; i++) {
      listOpcoes.add(restantes[i]);
    }

    // Embaralha as opções
    listOpcoes.shuffle();

    setState(() {
      _letraSorteada = sorteada;
      _opcoes = listOpcoes.map((e) => LetraJogo(letraData: e)).toList();
      _acerto = false;
      _feedback = 'VAZIO';
    });
  }

  void _verificarResposta(LetraJogo opcaoSelected) {
    if (_acerto || !opcaoSelected.pendente) return;

    final state = context.read<AppStateProvider>();

    if (opcaoSelected.letraData['letra'] == _letraSorteada?['letra']) {
      setState(() {
        _acerto = true;
        _acertosCount++;
        _feedback = 'ACERTO';
      });
      
      // Salva progresso no estado (e consequentemente no LocalStorage/Backend)
      state.salvaPontuacao(_acertosCount, _errosCount, 'JOGO_ALFABETO');
    } else {
      setState(() {
        opcaoSelected.pendente = false;
        _errosCount++;
        _feedback = 'ERRO';
      });
      state.salvaPontuacao(_acertosCount, _errosCount, 'JOGO_ALFABETO');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.bgSoft,
      body: SafeArea(
        child: Stack(
          children: [
            // Fundo
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header com pontuação
                  JogoBreadcrumbWidget(
                    nomeJogo: 'Alfabeto Manual',
                    dificuldade: context.watch<AppStateProvider>().activePersonagem?.dificuldade ?? 'FACIL',
                  ),
                  PontuacaoHeaderWidget(
                    acertos: _acertosCount,
                    erros: _errosCount,
                    atividade: 'JOGO_ALFABETO',
                  ),
                  const SizedBox(height: 16),

                  // Linha com Tutorial e Mascot
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TutorialWidget(atividade: 'JOGO_ALFABETO'),
                      // Mostramos mascote menor no canto superior
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
                  const SizedBox(height: 20),

                  // Letra sorteada central
                  if (_letraSorteada != null)
                    Center(
                      child: Container(
                        width: isCompact ? 140 : 180,
                        height: isCompact ? 140 : 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 6),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _letraSorteada!['letra']!,
                              style: TextStyle(
                                fontSize: isCompact ? 72 : 96,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Lista/Grid de opções
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isCompact ? 3 : 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: _opcoes.length,
                        itemBuilder: (context, index) {
                          final opcao = _opcoes[index];
                          final isCorrectMatch = opcao.letraData['letra'] == _letraSorteada?['letra'] && _acerto;
                          
                          return GestureDetector(
                            onTap: () => _verificarResposta(opcao),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isCorrectMatch 
                                    ? AppColors.accentLight.withOpacity(0.5) 
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isCorrectMatch 
                                      ? AppColors.accent 
                                      : (!opcao.pendente ? AppColors.error : AppColors.border),
                                  width: isCorrectMatch || !opcao.pendente ? 3.5 : 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Stack(
                                  children: [
                                    // Imagem da mão em Libras
                                    Positioned.fill(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.asset(
                                          opcao.letraData['path']!,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Center(
                                              child: Text(
                                                opcao.letraData['letra']!,
                                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    
                                    // Overlay de Erro (X vermelho)
                                    if (!opcao.pendente)
                                      Container(
                                        color: AppColors.error.withOpacity(0.4),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 48,
                                        ),
                                      ),
                                      
                                    // Overlay de Acerto (Círculo verde)
                                    if (isCorrectMatch)
                                      Container(
                                        color: AppColors.accent.withOpacity(0.3),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: Colors.white,
                                          size: 48,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),

            // Botão "Jogar" (Próxima rodada) flutuante quando acerta
            if (_acerto)
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
                        'Próxima Letra!',
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
}
