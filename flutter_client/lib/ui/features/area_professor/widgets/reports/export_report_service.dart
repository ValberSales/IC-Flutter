import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/core/constants/app_colors.dart';
import 'package:flutter_client/data/models/relatorio_turma.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;

class ExportReportService {
  static Future<void> exportTurmaCsv(BuildContext context, RelatorioTurma relatorio) async {
    final buffer = StringBuffer();
    // UTF-8 BOM para garantir acentuação correta no Excel
    buffer.write('\uFEFF');

    buffer.writeln('RELATÓRIO PEDAGÓGICO - ALFABETIZA LIBRAS');
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

    final fileName = 'relatorio_turma_${relatorio.turmaCodigo}_${DateTime.now().millisecondsSinceEpoch}.csv';
    final content = buffer.toString();

    if (kIsWeb) {
      final bytes = Uri.encodeComponent(content);
      html.AnchorElement(href: 'data:text/csv;charset=utf-8,$bytes')
        ..setAttribute('download', fileName)
        ..click();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📊 Relatório CSV baixado com sucesso!'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } else {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsString(content);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📊 CSV salvo em: ${file.path}'),
              backgroundColor: AppColors.accent,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar CSV: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  static Future<void> printTurmaReport(BuildContext context, RelatorioTurma relatorio) async {
    final dateStr = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Cabeçalho
            pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.deepPurple, width: 2),
                ),
              ),
              padding: const pw.EdgeInsets.only(bottom: 12),
              margin: const pw.EdgeInsets.only(bottom: 18),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Alfabetiza Libras - Relatório Pedagógico',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.deepPurple,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Turma: ${relatorio.turmaNome} (Código: ${relatorio.turmaCodigo})',
                        style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Emissão: $dateStr',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ],
              ),
            ),

            // Mini KPIs
            pw.Row(
              children: [
                pw.Expanded(
                  child: _buildPdfKpi(
                    'Aproveitamento Geral',
                    '${relatorio.taxaAproveitamentoGeral}%',
                    PdfColors.teal,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: _buildPdfKpi(
                    'Total de Alunos',
                    '${relatorio.totalAlunos}',
                    PdfColors.deepPurple,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: _buildPdfKpi(
                    'Partidas Jogadas',
                    '${relatorio.totalPartidas}',
                    PdfColors.orange800,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: _buildPdfKpi(
                    'Temas Alocados',
                    '${relatorio.temas.length}',
                    PdfColors.purple,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Título da Seção
            pw.Text(
              'Desempenho Consolidado por Aluno',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
            ),
            pw.SizedBox(height: 8),

            // Tabela
            pw.TableHelper.fromTextArray(
              headers: ['Usuário', 'Nome do Aluno', 'Partidas', 'Acertos', 'Erros', 'Aproveitamento', 'Nível'],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 10,
              ),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.deepPurple),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellHeight: 24,
              cellAlignment: pw.Alignment.centerLeft,
              data: relatorio.alunos.map((a) {
                return [
                  '@${a.username}',
                  a.nome,
                  '${a.totalPartidas}',
                  '${a.acertos}',
                  '${a.erros}',
                  '${a.taxaAproveitamento}%',
                  a.dificuldadeCalculada,
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 24),
            pw.Divider(color: PdfColors.grey300),
            pw.Text(
              'Documento gerado automaticamente pelo Sistema Alfabetiza Libras - UTFPR Pato Branco',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
              textAlign: pw.TextAlign.center,
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      name: 'relatorio_turma_${relatorio.turmaCodigo}.pdf',
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  static Future<void> printAlunoReport(BuildContext context, AlunoDesempenho aluno, String turmaNome) async {
    final dateStr = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Cabeçalho
            pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.deepPurple, width: 2),
                ),
              ),
              padding: const pw.EdgeInsets.only(bottom: 12),
              margin: const pw.EdgeInsets.only(bottom: 18),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Alfabetiza Libras - Ficha Individual do Aluno',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.deepPurple,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Aluno(a): ${aluno.nome} (@${aluno.username}) - Turma: $turmaNome',
                        style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Emissão: $dateStr',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ],
              ),
            ),

            // Mini KPIs
            pw.Row(
              children: [
                pw.Expanded(
                  child: _buildPdfKpi(
                    'Aproveitamento',
                    '${aluno.taxaAproveitamento}%',
                    PdfColors.teal,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: _buildPdfKpi(
                    'Total de Partidas',
                    '${aluno.totalPartidas}',
                    PdfColors.deepPurple,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: _buildPdfKpi(
                    'Acertos / Erros',
                    '${aluno.acertos} / ${aluno.erros}',
                    PdfColors.orange800,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: _buildPdfKpi(
                    'Nível Atual',
                    aluno.dificuldadeAtual,
                    PdfColors.purple,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Histórico
            pw.Text(
              'Histórico de Partidas e Atividades',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
            ),
            pw.SizedBox(height: 8),

            if (aluno.historico.isEmpty)
              pw.Text(
                'Nenhuma partida registrada até o momento.',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              )
            else
              pw.TableHelper.fromTextArray(
                headers: ['Jogo', 'Tema / Atividade', 'Nível', 'Acertos', 'Erros', 'Aproveitamento', 'Data/Hora'],
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 10,
                ),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.deepPurple),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellHeight: 24,
                cellAlignment: pw.Alignment.centerLeft,
                data: aluno.historico.map((p) {
                  final pDate = p.createdAt != null
                      ? '${p.createdAt!.day}/${p.createdAt!.month}/${p.createdAt!.year} ${p.createdAt!.hour}:${p.createdAt!.minute.toString().padLeft(2, '0')}'
                      : '-';
                  return [
                    p.atividade,
                    p.tema,
                    p.dificuldade,
                    '${p.acertos}',
                    '${p.erros}',
                    '${p.taxaAproveitamento}%',
                    pDate,
                  ];
                }).toList(),
              ),

            pw.SizedBox(height: 24),
            pw.Divider(color: PdfColors.grey300),
            pw.Text(
              'Documento gerado automaticamente pelo Sistema Alfabetiza Libras - UTFPR Pato Branco',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
              textAlign: pw.TextAlign.center,
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      name: 'ficha_aluno_${aluno.username}.pdf',
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  static pw.Widget _buildPdfKpi(String title, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }
}
