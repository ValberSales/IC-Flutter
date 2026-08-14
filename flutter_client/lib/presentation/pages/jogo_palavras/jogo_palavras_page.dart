import 'package:flutter/material.dart';
import '../../../data/models/atividade.dart';
import '../../../ui/features/jogo_palavras/views/jogo_palavras_view.dart';

class JogoPalavrasPage extends StatelessWidget {
  final Atividade? atividadeTema;

  const JogoPalavrasPage({
    super.key,
    this.atividadeTema,
  });

  @override
  Widget build(BuildContext context) {
    return JogoPalavrasView(atividadeTema: atividadeTema);
  }
}
