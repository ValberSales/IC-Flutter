package br.com.alfabetizalibras.controller;

import br.com.alfabetizalibras.entity.Pontuacao;
import br.com.alfabetizalibras.service.RelatorioService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * Endpoints REST para emissão de relatórios pedagógicos, histórico de partidas e analytics de turmas.
 */
@RestController
@RequestMapping("/api/relatorios")
public class RelatorioController {

    private final RelatorioService relatorioService;

    public RelatorioController(RelatorioService relatorioService) {
        this.relatorioService = relatorioService;
    }

    @GetMapping("/pontuacoes")
    public ResponseEntity<List<Pontuacao>> listarTodasPontuacoes() {
        return ResponseEntity.ok(relatorioService.listarTodasPontuacoes());
    }

    @DeleteMapping("/pontuacoes/limpar")
    public ResponseEntity<?> limparTodasPontuacoes() {
        relatorioService.limparTodasPontuacoes();
        return ResponseEntity.ok(Map.of("message", "Todas as pontuações foram resetadas com sucesso."));
    }

    @PostMapping("/pontuacoes/deduplicar")
    public ResponseEntity<?> deduplicarPontuacoes() {
        Map<String, Object> result = relatorioService.deduplicarPontuacoes();
        return ResponseEntity.ok(result);
    }

    @GetMapping("/turma/{turmaId}")
    public ResponseEntity<?> relatorioTurma(@PathVariable Long turmaId) {
        try {
            Map<String, Object> relatorio = relatorioService.gerarRelatorioTurma(turmaId);
            return ResponseEntity.ok(relatorio);
        } catch (NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/aluno/{alunoId}")
    public ResponseEntity<?> relatorioAluno(@PathVariable Long alunoId) {
        try {
            Map<String, Object> relatorio = relatorioService.gerarRelatorioAluno(alunoId);
            return ResponseEntity.ok(relatorio);
        } catch (NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
