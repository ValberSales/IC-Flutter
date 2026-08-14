import 'package:flutter/material.dart';
import '../../../data/models/atividade.dart';
import '../../../ui/features/jogo_adivinhacao/views/jogo_adivinhacao_view.dart';

class JogoAdivinhacaoPage extends StatelessWidget {
  final Atividade? atividadeTema;

  const JogoAdivinhacaoPage({
    super.key,
    this.atividadeTema,
  });

  @override
  Widget build(BuildContext context) {
    return JogoAdivinhacaoView(atividadeTema: atividadeTema);
  }
}
