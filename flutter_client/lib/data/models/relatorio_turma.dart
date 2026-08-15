class RelatorioTurma {
  final int turmaId;
  final String turmaNome;
  final String turmaCodigo;
  final int totalAlunos;
  final int totalPartidas;
  final int totalAcertos;
  final int totalErros;
  final double taxaAproveitamentoGeral;
  final List<AlunoDesempenho> alunos;
  final List<TemaRelatorio> temas;
  final EvolucaoDificuldade evolucaoDificuldade;

  RelatorioTurma({
    this.turmaId = 0,
    this.turmaNome = '',
    this.turmaCodigo = '',
    this.totalAlunos = 0,
    this.totalPartidas = 0,
    this.totalAcertos = 0,
    this.totalErros = 0,
    this.taxaAproveitamentoGeral = 0.0,
    this.alunos = const [],
    this.temas = const [],
    EvolucaoDificuldade? evolucaoDificuldade,
  }) : evolucaoDificuldade = evolucaoDificuldade ?? EvolucaoDificuldade();

  factory RelatorioTurma.fromJson(Map<String, dynamic> json) {
    return RelatorioTurma(
      turmaId: (json['turmaId'] as num?)?.toInt() ?? 0,
      turmaNome: json['turmaNome'] as String? ?? '',
      turmaCodigo: json['turmaCodigo'] as String? ?? '',
      totalAlunos: (json['totalAlunos'] as num?)?.toInt() ?? 0,
      totalPartidas: (json['totalPartidas'] as num?)?.toInt() ?? 0,
      totalAcertos: (json['totalAcertos'] as num?)?.toInt() ?? 0,
      totalErros: (json['totalErros'] as num?)?.toInt() ?? 0,
      taxaAproveitamentoGeral: (json['taxaAproveitamentoGeral'] as num?)?.toDouble() ?? 0.0,
      alunos: json['alunos'] != null && json['alunos'] is List
          ? (json['alunos'] as List).map((e) => AlunoDesempenho.fromJson(Map<String, dynamic>.from(e as Map))).toList()
          : [],
      temas: json['temas'] != null && json['temas'] is List
          ? (json['temas'] as List).map((e) => TemaRelatorio.fromJson(Map<String, dynamic>.from(e as Map))).toList()
          : [],
      evolucaoDificuldade: json['evolucaoDificuldade'] != null
          ? EvolucaoDificuldade.fromJson(Map<String, dynamic>.from(json['evolucaoDificuldade'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'turmaId': turmaId,
        'turmaNome': turmaNome,
        'turmaCodigo': turmaCodigo,
        'totalAlunos': totalAlunos,
        'totalPartidas': totalPartidas,
        'totalAcertos': totalAcertos,
        'totalErros': totalErros,
        'taxaAproveitamentoGeral': taxaAproveitamentoGeral,
        'alunos': alunos.map((a) => a.toJson()).toList(),
        'temas': temas.map((t) => t.toJson()).toList(),
        'evolucaoDificuldade': evolucaoDificuldade.toJson(),
      };
}

class AlunoDesempenho {
  final int id;
  final String nome;
  final String username;
  final String codigoIdentificador;
  final String avatar;
  final int totalPartidas;
  final int acertos;
  final int erros;
  final double taxaAproveitamento;
  final String dificuldadeAtual;
  final String dificuldadeCalculada;
  final List<PartidaHistorico> historico;

  AlunoDesempenho({
    this.id = 0,
    this.nome = '',
    this.username = '',
    this.codigoIdentificador = '',
    this.avatar = 'assets/avatar/avatar_1.jpg',
    this.totalPartidas = 0,
    this.acertos = 0,
    this.erros = 0,
    this.taxaAproveitamento = 0.0,
    this.dificuldadeAtual = 'FACIL',
    String? dificuldadeCalculada,
    this.historico = const [],
  }) : dificuldadeCalculada = dificuldadeCalculada ?? dificuldadeAtual;

  factory AlunoDesempenho.fromJson(Map<String, dynamic> json) {
    final diff = json['dificuldadeCalculada'] as String? ?? json['dificuldadeAtual'] as String? ?? 'FACIL';
    return AlunoDesempenho(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nome: json['nome'] as String? ?? '',
      username: json['username'] as String? ?? '',
      codigoIdentificador: json['codigoIdentificador'] as String? ?? '',
      avatar: json['avatar'] as String? ?? 'assets/avatar/avatar_1.jpg',
      totalPartidas: (json['totalPartidas'] as num?)?.toInt() ?? 0,
      acertos: (json['acertos'] as num?)?.toInt() ?? 0,
      erros: (json['erros'] as num?)?.toInt() ?? 0,
      taxaAproveitamento: (json['taxaAproveitamento'] as num?)?.toDouble() ?? 0.0,
      dificuldadeAtual: diff,
      dificuldadeCalculada: diff,
      historico: json['historico'] != null && json['historico'] is List
          ? (json['historico'] as List).map((e) => PartidaHistorico.fromJson(Map<String, dynamic>.from(e as Map))).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'username': username,
        'codigoIdentificador': codigoIdentificador,
        'avatar': avatar,
        'totalPartidas': totalPartidas,
        'acertos': acertos,
        'erros': erros,
        'taxaAproveitamento': taxaAproveitamento,
        'dificuldadeAtual': dificuldadeAtual,
        'dificuldadeCalculada': dificuldadeCalculada,
        'historico': historico.map((h) => h.toJson()).toList(),
      };
}

class TemaRelatorio {
  final int id;
  final String titulo;
  final String tipoJogo;
  final int totalItens;
  final int totalPartidas;
  final double taxaAproveitamento;

  TemaRelatorio({
    this.id = 0,
    this.titulo = '',
    this.tipoJogo = 'JOGO_ADIVINHACAO',
    this.totalItens = 0,
    this.totalPartidas = 0,
    this.taxaAproveitamento = 0.0,
  });

  factory TemaRelatorio.fromJson(Map<String, dynamic> json) {
    return TemaRelatorio(
      id: (json['id'] as num?)?.toInt() ?? 0,
      titulo: json['titulo'] as String? ?? '',
      tipoJogo: json['tipoJogo'] as String? ?? 'JOGO_ADIVINHACAO',
      totalItens: (json['totalItens'] as num?)?.toInt() ?? 0,
      totalPartidas: (json['totalPartidas'] as num?)?.toInt() ?? 0,
      taxaAproveitamento: (json['taxaAproveitamento'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'tipoJogo': tipoJogo,
        'totalItens': totalItens,
        'totalPartidas': totalPartidas,
        'taxaAproveitamento': taxaAproveitamento,
      };
}

class EvolucaoDificuldade {
  final int facil;
  final int medio;
  final int dificil;

  EvolucaoDificuldade({
    this.facil = 0,
    this.medio = 0,
    this.dificil = 0,
  });

  factory EvolucaoDificuldade.fromJson(Map<String, dynamic> json) {
    return EvolucaoDificuldade(
      facil: (json['facil'] as num?)?.toInt() ?? 0,
      medio: (json['medio'] as num?)?.toInt() ?? 0,
      dificil: (json['dificil'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'facil': facil,
        'medio': medio,
        'dificil': dificil,
      };
}

class PartidaHistorico {
  final int? id;
  final String atividade;
  final String tema;
  final int acertos;
  final int erros;
  final String dificuldade;
  final bool concluido;
  final DateTime? createdAt;
  final double taxaAproveitamento;

  PartidaHistorico({
    this.id,
    this.atividade = '',
    this.tema = '',
    this.acertos = 0,
    this.erros = 0,
    this.dificuldade = 'FACIL',
    this.concluido = false,
    this.createdAt,
    this.taxaAproveitamento = 0.0,
  });

  factory PartidaHistorico.fromJson(Map<String, dynamic> json) {
    return PartidaHistorico(
      id: (json['id'] as num?)?.toInt(),
      atividade: json['atividade'] as String? ?? '',
      tema: json['tema'] as String? ?? json['atividade'] as String? ?? '',
      acertos: (json['acertos'] as num?)?.toInt() ?? 0,
      erros: (json['erros'] as num?)?.toInt() ?? 0,
      dificuldade: json['dificuldade'] as String? ?? 'FACIL',
      concluido: json['concluido'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      taxaAproveitamento: (json['taxaAproveitamento'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'atividade': atividade,
        'tema': tema,
        'acertos': acertos,
        'erros': erros,
        'dificuldade': dificuldade,
        'concluido': concluido,
        'createdAt': createdAt?.toIso8601String(),
        'taxaAproveitamento': taxaAproveitamento,
      };
}
