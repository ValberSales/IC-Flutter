import 'abstract_model.dart';
import 'personagem.dart';
import 'palavra.dart';
import 'turma.dart';

class Usuario extends AbstractModel {
  String? nome;
  String? username;
  String? password;
  String? email;
  List<Personagem>? personagens;
  List<Palavra>? palavras;
  List<Turma>? turmas;

  Usuario({
    super.id,
    super.createdAt,
    this.nome,
    this.username,
    this.password,
    this.email,
    this.personagens,
    this.palavras,
    this.turmas,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      nome: json['nome'] as String?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      email: json['email'] as String?,
      personagens: json['personagens'] != null
          ? (json['personagens'] as List).map((e) => Personagem.fromJson(e)).toList()
          : null,
      palavras: json['palavras'] != null
          ? (json['palavras'] as List).map((e) => Palavra.fromJson(e)).toList()
          : null,
      turmas: json['turmas'] != null
          ? (json['turmas'] as List).map((e) => Turma.fromJson(e)).toList()
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'nome': nome,
      'username': username,
      'password': password,
      'email': email,
      'personagens': personagens?.map((e) => e.toJson()).toList(),
      'palavras': palavras?.map((e) => e.toJson()).toList(),
      'turmas': turmas?.map((e) => e.toJson()).toList(),
    };
  }
}
