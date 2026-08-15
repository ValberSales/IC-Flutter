import 'abstract_model.dart';
import 'usuario.dart';

class Pontuacao extends AbstractModel {
  int? usuarioId;
  Usuario? usuario;
  String atividade; // 'JOGO_ADIVINHACAO' | 'JOGO_MEMORIA' | 'JOGO_ALFABETO' | 'JOGO_PALAVRAS'
  int acertos;
  int erros;
  String dificuldade; // 'FACIL' | 'MEDIO' | 'DIFICIL'
  bool sincronizado;
  bool concluido;
  String? tema;
  String? progressoItens;

  Pontuacao({
    super.id,
    super.createdAt,
    this.usuarioId,
    this.usuario,
    required this.atividade,
    this.acertos = 0,
    this.erros = 0,
    this.dificuldade = 'FACIL',
    this.sincronizado = false,
    this.concluido = false,
    this.tema,
    this.progressoItens,
  }) {
    if (usuarioId == null && usuario != null) {
      usuarioId = usuario!.id;
    }
  }

  factory Pontuacao.fromJson(Map<String, dynamic> json) {
    Usuario? user;
    if (json['usuario'] != null && json['usuario'] is Map<String, dynamic>) {
      user = Usuario.fromJson(json['usuario']);
    }

    return Pontuacao(
      id: json['id'] as int?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      usuarioId: json['usuarioId'] as int? ?? user?.id ?? json['usuario_id'] as int?,
      usuario: user,
      atividade: json['atividade'] as String? ?? '',
      acertos: json['acertos'] as int? ?? 0,
      erros: json['erros'] as int? ?? 0,
      dificuldade: json['dificuldade'] as String? ?? 'FACIL',
      sincronizado: json['sincronizado'] as bool? ?? (json['id'] != null && (json['id'] as int) > 0),
      concluido: json['concluido'] as bool? ?? false,
      tema: json['tema'] as String?,
      progressoItens: json['progressoItens'] as String? ?? json['progresso_itens'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'usuarioId': usuarioId ?? usuario?.id,
      'usuario': usuario != null ? {'id': usuario!.id, 'username': usuario!.username} : (usuarioId != null ? {'id': usuarioId} : null),
      'atividade': atividade,
      'acertos': acertos,
      'erros': erros,
      'dificuldade': dificuldade,
      'sincronizado': sincronizado,
      'concluido': concluido,
      'tema': tema,
      'progressoItens': progressoItens,
    };
  }
}
