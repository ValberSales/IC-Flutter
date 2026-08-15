import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/core/constants/app_colors.dart';
import 'package:flutter_client/data/models/relatorio_turma.dart';
import 'dart:html' as html;

class ExportReportService {
  static void exportTurmaCsv(BuildContext context, RelatorioTurma relatorio) {
    final buffer = StringBuffer();
    // UTF-8 BOM para garantir acentuação correta no Excel
    buffer.write('\uFEFF');

    buffer.writeln('RELATÓRIO PEDAGÓGICO - INTERALIBRAS');
    buffer.writeln('Turma:;"${relatorio.turmaNome}";Código:;"${relatorio.turmaCodigo}"');
    buffer.writeln('Data de Emissão:;"${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}"');
    buffer.writeln('Total de Alunos:;${relatorio.totalAlunos};Total de Partidas:;${relatorio.totalPartidas}');
    buffer.writeln('Total de Acertos:;${relatorio.totalAcertos};Total de Erros:;${relatorio.totalErros};Aproveitamento Geral:;${relatorio.taxaAproveitamentoGeral}%');
    buffer.writeln('');

    // Cabeçalho da Tabela de Alunos
    buffer.writeln('"Nome";"Usuário";"Total Partidas";"Acertos";"Erros";"Aproveitamento (%)";"Nível"');

    for (final aluno in relatorio.alunos) {
      buffer.writeln(
        '"${aluno.nome}";"@${aluno.username}";${aluno.totalPartidas};${aluno.acertos};${aluno.erros};${aluno.taxaAproveitamento}%;"${aluno.dificuldadeCalculada}"',
      );
    }

    buffer.writeln('');
    buffer.writeln('HISTÓRICO DETALHADO DE PARTIDAS');
    buffer.writeln('"Aluno";"Usuário";"Jogo";"Tema";"Dificuldade";"Acertos";"Erros";"Aproveitamento (%)";"Data"');

    for (final aluno in relatorio.alunos) {
      for (final p in aluno.historico) {
        final dateStr = p.createdAt != null
            ? '${p.createdAt!.day}/${p.createdAt!.month}/${p.createdAt!.year} ${p.createdAt!.hour}:${p.createdAt!.minute.toString().padLeft(2, '0')}'
            : '-';
        buffer.writeln(
          '"${aluno.nome}";"@${aluno.username}";"${p.atividade}";"${p.tema}";"${p.dificuldade}";${p.acertos};${p.erros};${p.taxaAproveitamento}%;"$dateStr"',
        );
      }
    }

    _downloadFile(
      buffer.toString(),
      'relatorio_turma_${relatorio.turmaCodigo}_${DateTime.now().millisecondsSinceEpoch}.csv',
      'text/csv;charset=utf-8',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📊 Relatório CSV exportado com sucesso!'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  static void printTurmaReport(BuildContext context, RelatorioTurma relatorio) {
    if (!kIsWeb) return;

    final dateStr = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    final htmlContent = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>Relatório Pedagógico - ${relatorio.turmaNome}</title>
  <style>
    @media print {
      @page { margin: 15mm; }
      body { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
    }
    body {
      font-family: 'Segoe UI', Arial, sans-serif;
      color: #2D3748;
      margin: 0;
      padding: 24px;
      line-height: 1.5;
    }
    .header {
      border-bottom: 3px solid #6C5CE7;
      padding-bottom: 12px;
      margin-bottom: 20px;
      display: flex;
      justify-content: space-between;
      align-items: flex-end;
    }
    .title { font-size: 24px; font-weight: bold; color: #4834D4; margin: 0; }
    .subtitle { font-size: 14px; color: #718096; margin-top: 4px; }
    .kpi-grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 12px;
      margin-bottom: 24px;
    }
    .kpi-card {
      background: #F7FAFC;
      border: 1px solid #E2E8F0;
      border-radius: 8px;
      padding: 12px;
      text-align: center;
    }
    .kpi-label { font-size: 12px; color: #718096; text-transform: uppercase; font-weight: 600; }
    .kpi-value { font-size: 20px; font-weight: bold; color: #2D3748; margin-top: 4px; }
    .kpi-accent { color: #00B894; }
    table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 24px;
      font-size: 13px;
    }
    th {
      background-color: #6C5CE7;
      color: white;
      text-align: left;
      padding: 8px 10px;
    }
    td {
      padding: 8px 10px;
      border-bottom: 1px solid #E2E8F0;
    }
    tr:nth-child(even) { background-color: #F8FAFC; }
    .badge-apto {
      background: #D4EDDA;
      color: #155724;
      padding: 3px 8px;
      border-radius: 12px;
      font-weight: bold;
      font-size: 11px;
    }
    .section-title {
      font-size: 16px;
      font-weight: bold;
      color: #2D3748;
      margin-bottom: 10px;
      border-left: 4px solid #6C5CE7;
      padding-left: 8px;
    }
    .footer {
      font-size: 11px;
      color: #A0AEC0;
      text-align: center;
      margin-top: 30px;
      border-top: 1px solid #E2E8F0;
      padding-top: 10px;
    }
  </style>
</head>
<body>
  <div class="header">
    <div>
      <h1 class="title">InteraLibras • Relatório Pedagógico</h1>
      <div class="subtitle">Turma: <strong>${relatorio.turmaNome}</strong> (PIN: ${relatorio.turmaCodigo})</div>
    </div>
    <div style="text-align: right; font-size: 12px; color: #718096;">
      Emissão: $dateStr
    </div>
  </div>

  <div class="kpi-grid">
    <div class="kpi-card">
      <div class="kpi-label">Aproveitamento Geral</div>
      <div class="kpi-value kpi-accent">${relatorio.taxaAproveitamentoGeral}%</div>
    </div>
    <div class="kpi-card">
      <div class="kpi-label">Total de Alunos</div>
      <div class="kpi-value">${relatorio.totalAlunos}</div>
    </div>
    <div class="kpi-card">
      <div class="kpi-label">Partidas Jogadas</div>
      <div class="kpi-value">${relatorio.totalPartidas}</div>
    </div>
    <div class="kpi-card">
      <div class="kpi-label">Temas Vinculados</div>
      <div class="kpi-value">${relatorio.temas.length}</div>
    </div>
  </div>

  <div class="section-title">Desempenho Consolidado por Aluno</div>
  <table>
    <thead>
      <tr>
        <th>Usuário</th>
        <th>Nome do Aluno</th>
        <th>Partidas</th>
        <th>Acertos</th>
        <th>Erros</th>
        <th>Aproveitamento</th>
        <th>Nível</th>
      </tr>
    </thead>
    <tbody>
      ${relatorio.alunos.map((a) => '''
      <tr>
        <td><strong>@${a.username}</strong></td>
        <td>${a.nome}</td>
        <td>${a.totalPartidas}</td>
        <td style="color: #00B894; font-weight: bold;">${a.acertos}</td>
        <td style="color: #D63031; font-weight: bold;">${a.erros}</td>
        <td><strong>${a.taxaAproveitamento}%</strong></td>
        <td>${a.dificuldadeCalculada}</td>
      </tr>
      ''').join('')}
    </tbody>
  </table>

  <div class="footer">
    Documento gerado automaticamente pelo Sistema InteraLibras • Plataforma Pedagógica de Alfabetização em Libras
  </div>

  <script>
    window.onload = function() {
      window.print();
    };
  </script>
</body>
</html>
''';

    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
  }

  static void printAlunoReport(BuildContext context, AlunoDesempenho aluno, String turmaNome) {
    if (!kIsWeb) return;

    final dateStr = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    final htmlContent = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>Ficha do Aluno - ${aluno.nome}</title>
  <style>
    @media print {
      @page { margin: 15mm; }
      body { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
    }
    body { font-family: 'Segoe UI', Arial, sans-serif; color: #2D3748; padding: 24px; }
    .header { border-bottom: 3px solid #6C5CE7; padding-bottom: 12px; margin-bottom: 20px; display: flex; justify-content: space-between; }
    .title { font-size: 22px; font-weight: bold; color: #4834D4; margin: 0; }
    .kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin-bottom: 24px; }
    .kpi-card { background: #F7FAFC; border: 1px solid #E2E8F0; border-radius: 8px; padding: 12px; text-align: center; }
    .kpi-label { font-size: 11px; color: #718096; text-transform: uppercase; font-weight: 600; }
    .kpi-value { font-size: 18px; font-weight: bold; color: #2D3748; margin-top: 4px; }
    table { width: 100%; border-collapse: collapse; margin-top: 14px; font-size: 13px; }
    th { background-color: #6C5CE7; color: white; padding: 8px 10px; text-align: left; }
    td { padding: 8px 10px; border-bottom: 1px solid #E2E8F0; }
    tr:nth-child(even) { background-color: #F8FAFC; }
    .section-title { font-size: 15px; font-weight: bold; color: #2D3748; margin-top: 20px; border-left: 4px solid #6C5CE7; padding-left: 8px; }
    .footer { font-size: 11px; color: #A0AEC0; text-align: center; margin-top: 30px; border-top: 1px solid #E2E8F0; padding-top: 10px; }
  </style>
</head>
<body>
  <div class="header">
    <div>
      <h1 class="title">InteraLibras • Ficha Individual de Desempenho</h1>
      <div style="margin-top: 4px;">Aluno(a): <strong>${aluno.nome}</strong> (@${aluno.username} • Turma: $turmaNome)</div>
    </div>
    <div style="font-size: 12px; color: #718096; text-align: right;">
      Emissão: $dateStr
    </div>
  </div>

  <div class="kpi-grid">
    <div class="kpi-card">
      <div class="kpi-label">Aproveitamento Geral</div>
      <div class="kpi-value" style="color: #00B894;">${aluno.taxaAproveitamento}%</div>
    </div>
    <div class="kpi-card">
      <div class="kpi-label">Total de Partidas</div>
      <div class="kpi-value">${aluno.totalPartidas}</div>
    </div>
    <div class="kpi-card">
      <div class="kpi-label">Acertos / Erros</div>
      <div class="kpi-value">${aluno.acertos} / ${aluno.erros}</div>
    </div>
    <div class="kpi-card">
      <div class="kpi-label">Nível Atual</div>
      <div class="kpi-value">${aluno.dificuldadeAtual}</div>
    </div>
  </div>

  <div class="section-title">Histórico de Partidas e Atividades</div>
  ${aluno.historico.isEmpty ? '<p style="color: #718096; margin-top: 10px;">Nenhuma partida registrada até o momento.</p>' : '''
  <table>
    <thead>
      <tr>
        <th>Jogo</th>
        <th>Tema / Atividade</th>
        <th>Nível</th>
        <th>Acertos</th>
        <th>Erros</th>
        <th>Aproveitamento</th>
        <th>Data / Hora</th>
      </tr>
    </thead>
    <tbody>
      ${aluno.historico.map((p) => '''
      <tr>
        <td>${p.atividade}</td>
        <td><strong>${p.tema}</strong></td>
        <td>${p.dificuldade}</td>
        <td style="color: #00B894; font-weight: bold;">${p.acertos}</td>
        <td style="color: #D63031; font-weight: bold;">${p.erros}</td>
        <td><strong>${p.taxaAproveitamento}%</strong></td>
        <td>${p.createdAt != null ? '${p.createdAt!.day}/${p.createdAt!.month}/${p.createdAt!.year} ${p.createdAt!.hour}:${p.createdAt!.minute.toString().padLeft(2, '0')}' : '-'}</td>
      </tr>
      ''').join('')}
    </tbody>
  </table>
  '''}

  <div class="footer">
    Documento gerado automaticamente pelo Sistema InteraLibras • Plataforma Pedagógica de Alfabetização em Libras
  </div>

  <script>
    window.onload = function() {
      window.print();
    };
  </script>
</body>
</html>
''';

    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
  }

  static void _downloadFile(String content, String fileName, String mimeType) {
    if (!kIsWeb) return;
    final bytes = Uri.encodeComponent(content);
    final anchor = html.AnchorElement(href: 'data:$mimeType,$bytes')
      ..setAttribute('download', fileName)
      ..click();
  }
}
