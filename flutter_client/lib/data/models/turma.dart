import 'abstract_model.dart';
import 'usuario.dart';

class Turma extends AbstractModel {
  String nome;
  String descricao;
  String codigo;
  int? professorId;
  String? professorNome;
  int totalAlunos;
  int totalAtividades;
  List<Usuario> alunos;
  List<int> atividadesIds;
  Usuario? usuario;

  List<int> get alunoIds => alunos.map((a) => a.id).whereType<int>().toList();

  Turma({
    super.id,
    super.createdAt,
    this.nome = '',
    this.descricao = '',
    this.codigo = '',
    this.professorId,
    this.professorNome,
    this.totalAlunos = 0,
    this.totalAtividades = 0,
    this.alunos = const [],
    this.atividadesIds = const [],
    this.usuario,
  });

  factory Turma.fromJson(Map<String, dynamic> json) {
    List<Usuario> alunosList = [];
    if (json['alunos'] != null && json['alunos'] is List) {
      alunosList = (json['alunos'] as List)
          .map((e) => Usuario.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    List<int> atvIds = [];
    if (json['atividadesIds'] != null && json['atividadesIds'] is List) {
      atvIds = (json['atividadesIds'] as List).map((e) => (e as num).toInt()).toList();
    } else if (json['atividades'] != null && json['atividades'] is List) {
      atvIds = (json['atividades'] as List)
          .where((e) => e != null && e['id'] != null)
          .map((e) => (e['id'] as num).toInt())
          .toList();
    }

    return Turma(
      id: json['id'] as int?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      nome: json['nome'] as String? ?? '',
      descricao: json['descricao'] as String? ?? '',
      codigo: json['codigo'] as String? ?? '',
      professorId: json['professorId'] as int?,
      professorNome: json['professorNome'] as String?,
      totalAlunos: json['totalAlunos'] as int? ?? alunosList.length,
      totalAtividades: json['totalAtividades'] as int? ?? atvIds.length,
      alunos: alunosList,
      atividadesIds: atvIds,
      usuario: json['usuario'] != null ? Usuario.fromJson(Map<String, dynamic>.from(json['usuario'] as Map)) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'nome': nome,
      'descricao': descricao,
      'codigo': codigo,
      'professorId': professorId,
      'professorNome': professorNome,
      'totalAlunos': totalAlunos,
      'totalAtividades': totalAtividades,
      'alunos': alunos.map((a) => a.toJson()).toList(),
      'atividadesIds': atividadesIds,
      'usuario': usuario?.toJson(),
    };
  }

  Turma copyWith({
    int? id,
    DateTime? createdAt,
    String? nome,
    String? descricao,
    String? codigo,
    int? professorId,
    String? professorNome,
    int? totalAlunos,
    int? totalAtividades,
    List<Usuario>? alunos,
    List<int>? atividadesIds,
    Usuario? usuario,
  }) {
    return Turma(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      codigo: codigo ?? this.codigo,
      professorId: professorId ?? this.professorId,
      professorNome: professorNome ?? this.professorNome,
      totalAlunos: totalAlunos ?? this.totalAlunos,
      totalAtividades: totalAtividades ?? this.totalAtividades,
      alunos: alunos ?? this.alunos,
      atividadesIds: atividadesIds ?? this.atividadesIds,
      usuario: usuario ?? this.usuario,
    );
  }
}
