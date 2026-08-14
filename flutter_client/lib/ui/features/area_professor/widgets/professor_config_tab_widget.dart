import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/services/api_service.dart';
import '../../../../state/app_state_provider.dart';

class ProfessorConfigTabWidget extends StatefulWidget {
  final AppStateProvider state;

  const ProfessorConfigTabWidget({super.key, required this.state});

  @override
  State<ProfessorConfigTabWidget> createState() => _ProfessorConfigTabWidgetState();
}

class _ProfessorConfigTabWidgetState extends State<ProfessorConfigTabWidget> {
  void _showSobreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sobre o Projeto', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Este projeto foi desenvolvido como parte do Trabalho de Conclusão de Curso (TCC) no curso de Análise e Desenvolvimento de Sistemas da UTFPR.\n\nA aplicação tem como objetivo apoiar a alfabetização bilíngue de crianças surdas entre 4 e 5 anos, com foco na Língua Brasileira de Sinais (Libras) e no alfabeto manual.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(height: 20),
                Divider(),
                SizedBox(height: 10),
                Text('Desenvolvedor:\nLuan Filipe Finatto', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(height: 12),
                Text('Orientadora:\nProfª. Drª. Rúbia Eliza de Oliveira Schultz Ascari', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
                SizedBox(height: 12),
                Text('Coorientadoras:\nProfª. Me. Mirelia Flausino Vogel\nProfª. Me. Aline Brancalione', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
                SizedBox(height: 20),
                Text('© 2025 - Luan Finatto.\nTodos os direitos reservados.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary, textStyle: const TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24.0),
        child: Card(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.settings_suggest_rounded, color: AppColors.secondary, size: 36),
                      SizedBox(width: 12),
                      Text('Configurações Básicas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 32),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Utilizar Alfabeto Original', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: const Text('Usa as ilustrações originais vetorizadas para Libras ao invés das fotos reais das professoras.', style: TextStyle(fontSize: 14)),
                    trailing: Switch(
                      value: state.useLegacyLetters,
                      activeColor: AppColors.primary,
                      onChanged: (val) => state.setUseLegacyLetters(val),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text('Modo de Backend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Conectar o aplicativo ao backend Spring Boot em http://localhost:8081/api.',
                          style: TextStyle(color: AppColors.textDark.withOpacity(0.7), fontSize: 14),
                        ),
                      ),
                      Switch(
                        value: ApiService.useBackend,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() {
                            ApiService.useBackend = val;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(val ? 'Conectado ao backend local' : 'Retornado ao modo estático (Offline Mock)'),
                              backgroundColor: AppColors.info,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => _showSobreDialog(context),
                    icon: const Icon(Icons.info_outline_rounded),
                    label: const Text('Sobre o Projeto'),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error, width: 2),
                      foregroundColor: AppColors.error,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      await state.logout();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Conta encerrada com sucesso.'), backgroundColor: AppColors.info),
                        );
                      }
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sair da Conta', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
