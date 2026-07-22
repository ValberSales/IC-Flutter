package br.com.interalibras.controller;

import br.com.interalibras.entity.Turma;
import br.com.interalibras.repository.TurmaRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/turmas")
public class TurmaController {

    private final TurmaRepository turmaRepository;

    public TurmaController(TurmaRepository turmaRepository) {
        this.turmaRepository = turmaRepository;
    }

    @GetMapping("/busca/{codigo}")
    public ResponseEntity<?> findByCodigo(@PathVariable String codigo) {
        Optional<Turma> opt = turmaRepository.findByCodigo(codigo);
        if (opt.isPresent()) {
            return ResponseEntity.ok(Map.of("turma", opt.get(), "message", "Turma encontrada com sucesso!"));
        }
        return ResponseEntity.ok(Map.of("turma", Optional.empty(), "message", "Turma não encontrada!"));
    }

    @PostMapping
    public ResponseEntity<Turma> save(@RequestBody Turma turma) {
        Turma saved = turmaRepository.save(turma);
        return ResponseEntity.ok(saved);
    }
}
