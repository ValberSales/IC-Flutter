import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/storage/local_storage_service.dart';
import '../../../../state/app_state_provider.dart';

class ProfessorReportsTabWidget extends StatelessWidget {
  final AppStateProvider state;

  const ProfessorReportsTabWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final allScores = LocalStorageService.getPontuacoes();

    if (state.personagens.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline_rounded, size: 64, color: AppColors.primaryLight),
              SizedBox(height: 12),
              Text('Nenhum aluno/avatar cadastrado ainda.', style: TextStyle(fontSize: 18, color: AppColors.textDark)),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Desempenho dos Alunos',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          ...state.personagens.map((p) {
            final pScores = allScores.where((s) => s.personagem?.id == p.id).toList();

            return Card(
              margin: const EdgeInsets.only(bottom: 20),
              child: ExpansionTile(
                leading: CircleAvatar(backgroundImage: AssetImage(p.avatar)),
                title: Text(p.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text('Dificuldade: ${p.dificuldade}  •  ${pScores.length} Partidas jogadas'),
                children: [
                  if (pScores.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Nenhuma partida registrada para este aluno ainda.'),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Table(
                        border: TableBorder.all(color: AppColors.border, width: 1, borderRadius: BorderRadius.circular(8)),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1.5),
                        },
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(color: AppColors.primaryLight),
                            children: [
                              Padding(padding: EdgeInsets.all(10), child: Text('Jogo', style: TextStyle(fontWeight: FontWeight.bold))),
                              Padding(padding: EdgeInsets.all(10), child: Text('Acertos', style: TextStyle(fontWeight: FontWeight.bold))),
                              Padding(padding: EdgeInsets.all(10), child: Text('Erros', style: TextStyle(fontWeight: FontWeight.bold))),
                              Padding(padding: EdgeInsets.all(10), child: Text('Data', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                          ),
                          ...pScores.map((score) {
                            String gameName = score.atividade;
                            if (gameName == 'JOGO_ALFABETO') gameName = 'Alfabeto';
                            if (gameName == 'JOGO_MEMORIA') gameName = 'Memória';
                            if (gameName == 'JOGO_ADIVINHACAO') gameName = 'Adivinhação';
                            if (gameName == 'JOGO_PALAVRAS') gameName = 'Palavras';

                            final dateStr = score.createdAt != null
                                ? "${score.createdAt!.day}/${score.createdAt!.month} ${score.createdAt!.hour}:${score.createdAt!.minute.toString().padLeft(2, '0')}"
                                : '-';

                            return TableRow(
                              children: [
                                Padding(padding: const EdgeInsets.all(10), child: Text(gameName)),
                                Padding(padding: const EdgeInsets.all(10), child: Text('${score.acertos}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold))),
                                Padding(padding: const EdgeInsets.all(10), child: Text('${score.erros}', style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold))),
                                Padding(padding: const EdgeInsets.all(10), child: Text(dateStr)),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
