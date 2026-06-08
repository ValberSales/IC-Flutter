import 'abstract_model.dart';
import 'usuario.dart';

class Personagem extends AbstractModel {
  String nome;
  DateTime? dataNascimento;
  String dificuldade; // 'FACIL' | 'MEDIO' | 'DIFICIL'
  String avatar; // Caminho para o asset do avatar
  Usuario? usuario;

  Personagem({
    super.id,
    super.createdAt,
    this.nome = '',
    this.dataNascimento,
    this.dificuldade = 'FACIL',
    this.avatar = 'assets/avatar/avatar_1.jpg',
    this.usuario,
  });

  factory Personagem.fromJson(Map<String, dynamic> json) {
    return Personagem(
      id: json['id'] as int?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      nome: json['nome'] as String? ?? '',
      dataNascimento: json['dataNascimento'] != null ? DateTime.parse(json['dataNascimento']) : null,
      dificuldade: json['dificuldade'] as String? ?? 'FACIL',
      avatar: json['avatar'] as String? ?? 'assets/avatar/avatar_1.jpg',
      usuario: json['usuario'] != null ? Usuario.fromJson(json['usuario']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'nome': nome,
      'dataNascimento': dataNascimento?.toIso8601String(),
      'dificuldade': dificuldade,
      'avatar': avatar,
      'usuario': usuario?.toJson(),
    };
  }

  // Helper method for copying character properties easily
  Personagem copyWith({
    int? id,
    DateTime? createdAt,
    String? nome,
    DateTime? dataNascimento,
    String? dificuldade,
    String? avatar,
    Usuario? usuario,
  }) {
    return Personagem(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      nome: nome ?? this.nome,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      dificuldade: dificuldade ?? this.dificuldade,
      avatar: avatar ?? this.avatar,
      usuario: usuario ?? this.usuario,
    );
  }
}
