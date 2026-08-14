import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/personagem.dart';
import '../../../../data/models/pontuacao.dart';

class CharacterScoreDialog extends StatelessWidget {
  final Personagem personagem;
  final List<Pontuacao> history;

  const CharacterScoreDialog({
    super.key,
    required this.personagem,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text('Histórico de Pontos: ${personagem.nome}', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 500,
        height: MediaQuery.of(context).size.height * 0.5,
        child: history.isEmpty
            ? const Center(child: Text('Nenhuma pontuação registrada para este avatar ainda.', style: TextStyle(fontSize: 16)))
            : ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final score = history[index];
                  String title = score.atividade;
                  if (title == 'JOGO_ALFABETO') title = 'Alfabeto Manual';
                  if (title == 'JOGO_MEMORIA') title = 'Jogo da Memória';
                  if (title == 'JOGO_ADIVINHACAO') title = 'Jogo de Adivinhação';
                  if (title == 'JOGO_PALAVRAS') title = 'Jogo de Palavras';

                  return ListTile(
                    leading: const Icon(Icons.stars_rounded, color: AppColors.secondary, size: 28),
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Acertos: ${score.acertos}  •  Erros: ${score.erros}\nDificuldade: ${score.dificuldade}'),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        )
      ],
    );
  }
}
