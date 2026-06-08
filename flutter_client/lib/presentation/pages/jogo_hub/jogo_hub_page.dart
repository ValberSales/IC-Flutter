import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/util/responsive_layout.dart';
import '../../../state/app_state_provider.dart';
import '../jogo_alfabeto/jogo_alfabeto_page.dart';
import '../jogo_memoria/jogo_memoria_page.dart';
import '../jogo_adivinhacao/jogo_adivinhacao_page.dart';
import '../jogo_palavras/jogo_palavras_page.dart';

class JogoHubPage extends StatelessWidget {
  const JogoHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final isDesktop = ResponsiveLayout.isWeb(context);
    final double screenHeight = MediaQuery.of(context).size.height;
    
    // In landscape/short screen or mobile, consider it compact for card design
    final bool isCompact = ResponsiveLayout.isMobile(context) || screenHeight < 550;
    
    // Grid columns based on responsiveness
    int crossAxisCount = 1;
    if (isDesktop) {
      crossAxisCount = 4;
    } else if (ResponsiveLayout.isTablet(context)) {
      crossAxisCount = 2;
    }

    // Dynamic aspect ratio based on height and compactness
    final double aspectRatio = isCompact 
        ? (screenHeight < 550 ? 2.0 : 1.4) 
        : 0.85;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Menu de Jogos', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Container(
        color: AppColors.bgSoft,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header amigável
                  if (state.activePersonagem != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
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
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  'Modo de Jogo: ${state.activePersonagem!.dificuldade == 'FACIL' ? 'Fácil 🌟' : state.activePersonagem!.dificuldade == 'MEDIO' ? 'Médio ✨' : 'Difícil 🔥'}',
                                  style: TextStyle(
                                    fontSize: 14,
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

                  // Grid de Jogos (Shrinkwrapped to fit in the SingleChildScrollView)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: aspectRatio,
                    children: [
                      // 1. ALFABETO MANUAL
                      _buildGameCard(
                        context: context,
                        title: 'Alfabeto Manual',
                        description: 'Aprenda os sinais de Libras para cada letra do alfabeto!',
                        color: AppColors.primary,
                        icon: Icons.abc_rounded,
                        page: const JogoAlfabetoPage(),
                        isCompact: isCompact,
                      ),
                      
                      // 2. JOGO DA MEMÓRIA
                      _buildGameCard(
                        context: context,
                        title: 'Jogo da Memória',
                        description: 'Encontre os pares combinando a letra e o sinal em Libras!',
                        color: AppColors.secondary,
                        icon: Icons.grid_view_rounded,
                        page: const JogoMemoriaPage(),
                        isCompact: isCompact,
                      ),
                      
                      // 3. JOGO DE ADIVINHAÇÃO
                      _buildGameCard(
                        context: context,
                        title: 'Adivinhação',
                        description: 'Forme os nomes dos bichinhos arrastando os sinais corretos!',
                        color: AppColors.accent,
                        icon: Icons.drag_indicator_rounded,
                        page: const JogoAdivinhacaoPage(),
                        isCompact: isCompact,
                      ),
                      
                      // 4. JOGO DE PALAVRAS
                      _buildGameCard(
                        context: context,
                        title: 'Jogo de Palavras',
                        description: 'Veja a foto e escolha a palavra escrita que combina com ela!',
                        color: AppColors.info,
                        icon: Icons.collections_rounded,
                        page: const JogoPalavrasPage(),
                        isCompact: isCompact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required String description,
    required Color color,
    required IconData icon,
    required Widget page,
    required bool isCompact,
  }) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final cardPadding = screenHeight < 550 ? 12.0 : 20.0;

    return Card(
      elevation: 6,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: color.withOpacity(0.3), width: 2),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => page),
          );
        },
        borderRadius: BorderRadius.circular(26),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: isCompact
              ? Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(screenHeight < 550 ? 10 : 16),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: screenHeight < 550 ? 32 : 40),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: screenHeight < 550 ? 16 : 18,
                              fontWeight: FontWeight.w900,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: screenHeight < 550 ? 11 : 13,
                              color: AppColors.textDark.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: color, size: 28),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 54),
                    ),
                    Column(
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textDark.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => page),
                        );
                      },
                      child: const Text('Jogar', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
