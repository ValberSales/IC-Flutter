import 'abstract_model.dart';
import 'palavra.dart';
import 'turma.dart';

class Usuario extends AbstractModel {
  String? nome;
  String? username;
  String? codigoIdentificador;
  String? password;
  String? email;
  String? avatar;
  String? role;
  String dificuldade;
  bool mustChangePassword;
  List<Palavra>? palavras;
  List<Turma>? turmas;

  Usuario({
    super.id,
    super.createdAt,
    this.nome,
    this.username,
    this.codigoIdentificador,
    this.password,
    this.email,
    this.avatar,
    this.role,
    this.dificuldade = 'FACIL',
    this.mustChangePassword = false,
    this.palavras,
    this.turmas,
  });

  bool get isAdmin => role?.toUpperCase() == 'ADMIN';

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      nome: json['nome'] as String?,
      username: json['username'] as String?,
      codigoIdentificador: json['codigoIdentificador'] as String?,
      password: json['password'] as String?,
      email: json['email'] as String?,
      avatar: json['avatar'] as String? ?? 'assets/avatar/avatar_1.jpg',
      role: json['role'] as String? ?? 'USER',
      dificuldade: json['dificuldade'] as String? ?? 'FACIL',
      mustChangePassword: json['mustChangePassword'] as bool? ?? false,
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
      'codigoIdentificador': codigoIdentificador,
      'password': password,
      'email': email,
      'avatar': avatar ?? 'assets/avatar/avatar_1.jpg',
      'role': role ?? 'USER',
      'dificuldade': dificuldade,
      'mustChangePassword': mustChangePassword,
      'palavras': palavras?.map((e) => e.toJson()).toList(),
      'turmas': turmas?.map((e) => e.toJson()).toList(),
    };
  }
}
