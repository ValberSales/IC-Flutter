import 'abstract_model.dart';

class ItemAtividade {
  String descricao;
  String imagem;
  List<String> opcoes;

  ItemAtividade({
    required this.descricao,
    required this.imagem,
    this.opcoes = const [],
  });

  factory ItemAtividade.fromJson(Map<String, dynamic> json) {
    return ItemAtividade(
      descricao: json['descricao'] as String? ?? '',
      imagem: json['imagem'] as String? ?? '',
      opcoes: json['opcoes'] != null ? List<String>.from(json['opcoes']) : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'descricao': descricao,
      'imagem': imagem,
      'opcoes': opcoes,
    };
  }
}

class Atividade extends AbstractModel {
  String titulo; // Tema
  String tipoJogo; // 'JOGO_ADIVINHACAO' | 'JOGO_PALAVRAS'
  bool ativo;
  bool publica; // true = pública (convidados + turmas), false = privada (apenas turmas direcionadas)
  bool rascunho; // Se true, o professor salvou progresso sem publicar
  String dificuldade; // 'FACIL' | 'MEDIO' | 'DIFICIL'
  String? criadoPor;
  String? icone; // Nome do ícone selecionado
  List<ItemAtividade> itens;

  Atividade({
    super.id,
    super.createdAt,
    required this.titulo,
    required this.tipoJogo,
    this.ativo = true,
    this.publica = true,
    this.rascunho = false,
    this.dificuldade = 'FACIL',
    this.criadoPor,
    this.icone,
    this.itens = const [],
  });

  factory Atividade.fromJson(Map<String, dynamic> json) {
    return Atividade(
      id: json['id'] as int?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      titulo: json['titulo'] as String? ?? '',
      tipoJogo: json['tipoJogo'] as String? ?? 'JOGO_ADIVINHACAO',
      ativo: json['ativo'] as bool? ?? true,
      publica: json['publica'] as bool? ?? true,
      rascunho: json['rascunho'] as bool? ?? false,
      dificuldade: json['dificuldade'] as String? ?? 'FACIL',
      criadoPor: json['criadoPor'] as String?,
      icone: json['icone'] as String?,
      itens: json['itens'] != null
          ? (json['itens'] as List).map((i) => ItemAtividade.fromJson(i as Map<String, dynamic>)).toList()
          : const [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'titulo': titulo,
      'tipoJogo': tipoJogo,
      'ativo': ativo,
      'publica': publica,
      'rascunho': rascunho,
      'dificuldade': dificuldade,
      'criadoPor': criadoPor,
      'icone': icone,
      'itens': itens.map((i) => i.toJson()).toList(),
    };
  }

  Atividade copyWith({
    int? id,
    DateTime? createdAt,
    String? titulo,
    String? tipoJogo,
    bool? ativo,
    bool? publica,
    bool? rascunho,
    String? dificuldade,
    String? criadoPor,
    String? icone,
    List<ItemAtividade>? itens,
  }) {
    return Atividade(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      titulo: titulo ?? this.titulo,
      tipoJogo: tipoJogo ?? this.tipoJogo,
      ativo: ativo ?? this.ativo,
      publica: publica ?? this.publica,
      rascunho: rascunho ?? this.rascunho,
      dificuldade: dificuldade ?? this.dificuldade,
      criadoPor: criadoPor ?? this.criadoPor,
      icone: icone ?? this.icone,
      itens: itens ?? this.itens,
    );
  }
}
