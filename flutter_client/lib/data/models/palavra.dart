import 'abstract_model.dart';
import 'usuario.dart';

class Palavra extends AbstractModel {
  String tipo; // 'JOGO_ADIVINHACAO' | 'JOGO_PALAVRAS'
  String descricao;
  String imagem; // Caminho para a imagem da palavra
  Usuario? usuario;
  List<String> opcoes;

  Palavra({
    super.id,
    super.createdAt,
    this.tipo = 'JOGO_ADIVINHACAO',
    this.descricao = '',
    this.imagem = '',
    this.usuario,
    this.opcoes = const [],
  });

  factory Palavra.fromJson(Map<String, dynamic> json) {
    return Palavra(
      id: json['id'] as int?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      tipo: json['tipo'] as String? ?? 'JOGO_ADIVINHACAO',
      descricao: json['descricao'] as String? ?? '',
      imagem: json['imagem'] as String? ?? '',
      usuario: json['usuario'] != null ? Usuario.fromJson(json['usuario']) : null,
      opcoes: json['opcoes'] != null ? List<String>.from(json['opcoes']) : const [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'tipo': tipo,
      'descricao': descricao,
      'imagem': imagem,
      'usuario': usuario?.toJson(),
      'opcoes': opcoes,
    };
  }
}
