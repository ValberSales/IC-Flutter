import 'abstract_model.dart';
import 'usuario.dart';

class Turma extends AbstractModel {
  String nome;
  String codigo;
  DateTime? dataGeracaoCodigo;
  List<int> palavras; // IDs das palavras associadas
  Usuario? usuario;

  Turma({
    super.id,
    super.createdAt,
    this.nome = '',
    this.codigo = '',
    this.dataGeracaoCodigo,
    this.palavras = const [],
    this.usuario,
  });

  factory Turma.fromJson(Map<String, dynamic> json) {
    return Turma(
      id: json['id'] as int?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      nome: json['nome'] as String? ?? '',
      codigo: json['codigo'] as String? ?? '',
      dataGeracaoCodigo: json['dataGeracaoCodigo'] != null ? DateTime.parse(json['dataGeracaoCodigo']) : null,
      palavras: json['palavras'] != null ? List<int>.from(json['palavras']) : const [],
      usuario: json['usuario'] != null ? Usuario.fromJson(json['usuario']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'nome': nome,
      'codigo': codigo,
      'dataGeracaoCodigo': dataGeracaoCodigo?.toIso8601String(),
      'palavras': palavras,
      'usuario': usuario?.toJson(),
    };
  }
}
