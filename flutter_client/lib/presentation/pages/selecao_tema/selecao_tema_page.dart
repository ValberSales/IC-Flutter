import 'package:flutter/material.dart';
import '../../../ui/features/selecao_tema/views/selecao_tema_view.dart';

class SelecaoTemaPage extends StatelessWidget {
  final String tipoJogo;

  const SelecaoTemaPage({super.key, required this.tipoJogo});

  @override
  Widget build(BuildContext context) {
    return SelecaoTemaView(tipoJogo: tipoJogo);
  }
}
