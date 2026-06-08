import 'abstract_model.dart';
import 'personagem.dart';

class Pontuacao extends AbstractModel {
  String atividade; // 'JOGO_ADIVINHACAO' | 'JOGO_MEMORIA' | 'JOGO_ALFABETO' | 'JOGO_PALAVRAS'
  int acertos;
  int erros;
  String dificuldade; // 'FACIL' | 'MEDIO' | 'DIFICIL'
  Personagem? personagem;

  Pontuacao({
    super.id,
    super.createdAt,
    required this.atividade,
    this.acertos = 0,
    this.erros = 0,
    this.dificuldade = 'FACIL',
    this.personagem,
  });

  factory Pontuacao.fromJson(Map<String, dynamic> json) {
    return Pontuacao(
      id: json['id'] as int?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      atividade: json['atividade'] as String,
      acertos: json['acertos'] as int? ?? 0,
      erros: json['erros'] as int? ?? 0,
      dificuldade: json['dificuldade'] as String? ?? 'FACIL',
      personagem: json['personagem'] != null ? Personagem.fromJson(json['personagem']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'atividade': atividade,
      'acertos': acertos,
      'erros': erros,
      'dificuldade': dificuldade,
      'personagem': personagem?.toJson(),
    };
  }
}
