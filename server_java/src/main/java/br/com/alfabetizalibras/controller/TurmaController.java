package br.com.alfabetizalibras.controller;

import br.com.alfabetizalibras.entity.Turma;
import br.com.alfabetizalibras.service.TurmaService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Endpoints REST para gerenciamento de turmas escolares e direcionamento de atividades.
 */
@RestController
@RequestMapping("/api/turmas")
public class TurmaController {

    private final TurmaService turmaService;

    public TurmaController(TurmaService turmaService) {
        this.turmaService = turmaService;
    }

    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> findAll() {
        return ResponseEntity.ok(turmaService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> findById(@PathVariable Long id) {
        return turmaService.findById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping("/busca/{codigo}")
    public ResponseEntity<?> findByCodigo(@PathVariable String codigo) {
        Optional<Map<String, Object>> opt = turmaService.findByCodigo(codigo);
        if (opt.isPresent()) {
            return ResponseEntity.ok(Map.of(
                    "turma", opt.get(),
                    "message", "Turma encontrada com sucesso!"
            ));
        }
        return ResponseEntity.ok(Map.of(
                "turma", Optional.empty(),
                "message", "Turma não encontrada!"
        ));
    }

    @GetMapping("/aluno/{alunoId}")
    public ResponseEntity<?> findByAluno(@PathVariable Long alunoId) {
        return turmaService.findByAlunoId(alunoId)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.ok(Collections.emptyMap()));
    }

    @PostMapping
    public ResponseEntity<?> create(@RequestBody Map<String, Object> payload) {
        String nome = (String) payload.get("nome");
        String descricao = (String) payload.get("descricao");
        String codigo = (String) payload.get("codigo");

        if (nome == null || nome.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "O nome da turma é obrigatório."));
        }

        Long usuarioId = null;
        if (payload.containsKey("usuarioId") && payload.get("usuarioId") != null) {
            usuarioId = ((Number) payload.get("usuarioId")).longValue();
        }

        try {
            Turma turma = turmaService.create(nome, descricao, codigo, usuarioId);
            return ResponseEntity.ok(turmaService.mapTurmaSummary(turma));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, @RequestBody Map<String, Object> payload) {
        String nome = (String) payload.get("nome");
        String descricao = (String) payload.get("descricao");
        String codigo = (String) payload.get("codigo");

        try {
            Turma turma = turmaService.update(id, nome, descricao, codigo);
            return ResponseEntity.ok(turmaService.mapTurmaSummary(turma));
        } catch (NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        try {
            turmaService.delete(id);
            return ResponseEntity.ok(Map.of("message", "Turma excluída com sucesso."));
        } catch (NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/alunos")
    public ResponseEntity<?> setAlunos(@PathVariable Long id, @RequestBody Map<String, Object> payload) {
        @SuppressWarnings("unchecked")
        List<Number> alunoIds = (List<Number>) payload.get("alunoIds");
        List<Long> ids = alunoIds != null ? alunoIds.stream().map(Number::longValue).collect(Collectors.toList()) : null;

        try {
            Turma turma = turmaService.setAlunos(id, ids);
            return ResponseEntity.ok(turmaService.mapTurmaSummary(turma));
        } catch (NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}/alunos/{alunoId}")
    public ResponseEntity<?> removeAluno(@PathVariable Long id, @PathVariable Long alunoId) {
        try {
            Turma turma = turmaService.removeAluno(id, alunoId);
            return ResponseEntity.ok(turmaService.mapTurmaSummary(turma));
        } catch (NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/atividades")
    public ResponseEntity<?> setAtividades(@PathVariable Long id, @RequestBody Map<String, Object> payload) {
        @SuppressWarnings("unchecked")
        List<Number> atividadeIds = (List<Number>) payload.get("atividadeIds");
        List<Long> ids = atividadeIds != null ? atividadeIds.stream().map(Number::longValue).collect(Collectors.toList()) : null;

        try {
            Turma turma = turmaService.setAtividades(id, ids);
            return ResponseEntity.ok(turmaService.mapTurmaSummary(turma));
        } catch (NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/entrar")
    public ResponseEntity<?> entrarTurma(@RequestBody Map<String, Object> payload) {
        String codigo = (String) payload.get("codigo");
        if (codigo == null || codigo.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Código da turma não informado."));
        }

        Long alunoId = null;
        if (payload.containsKey("alunoId") && payload.get("alunoId") != null) {
            alunoId = ((Number) payload.get("alunoId")).longValue();
        }

        try {
            Turma turma = turmaService.entrarTurma(codigo, alunoId);
            return ResponseEntity.ok(Map.of(
                    "turma", turmaService.mapTurmaSummary(turma),
                    "message", "Vinculado à turma '" + turma.getNome() + "' com sucesso!"
            ));
        } catch (NoSuchElementException e) {
            return ResponseEntity.badRequest().body(Map.of("message", "Turma não encontrada para o código informado."));
        }
    }

    @PostMapping("/sair")
    public ResponseEntity<?> sairTurma(@RequestBody Map<String, Object> payload) {
        if (payload.containsKey("alunoId") && payload.get("alunoId") != null) {
            Long alunoId = ((Number) payload.get("alunoId")).longValue();
            turmaService.sairTurma(alunoId);
        }
        return ResponseEntity.ok(Map.of("message", "Desvinculado da turma com sucesso."));
    }
}
