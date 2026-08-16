package br.com.alfabetizalibras.controller;

import br.com.alfabetizalibras.entity.Atividade;
import br.com.alfabetizalibras.service.AtividadeService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.NoSuchElementException;

/**
 * Endpoints REST para criação, consulta, edição e publicação de atividades e temas de Libras.
 */
@RestController
@RequestMapping("/api/atividades")
public class AtividadeController {

    private final AtividadeService atividadeService;

    public AtividadeController(AtividadeService atividadeService) {
        this.atividadeService = atividadeService;
    }

    @GetMapping
    public ResponseEntity<List<Atividade>> getAllAtividades(@RequestParam(required = false) Boolean apenasAtivas) {
        return ResponseEntity.ok(atividadeService.findAll(apenasAtivas));
    }

    @PostMapping
    public ResponseEntity<Atividade> createOrUpdateAtividade(@RequestBody Atividade atividade) {
        Atividade saved = atividadeService.createOrUpdate(atividade);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Atividade> updateAtividade(@PathVariable Long id, @RequestBody Atividade atividade) {
        Atividade updated = atividadeService.update(id, atividade);
        return ResponseEntity.ok(updated);
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<Atividade> toggleStatus(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(atividadeService.toggleStatus(id));
        } catch (NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/publica")
    public ResponseEntity<Atividade> togglePublica(@PathVariable Long id, @RequestParam(required = false) Boolean publica) {
        try {
            return ResponseEntity.ok(atividadeService.togglePublica(id, publica));
        } catch (NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAtividade(@PathVariable Long id) {
        try {
            atividadeService.delete(id);
            return ResponseEntity.noContent().build();
        } catch (NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/rascunho")
    public ResponseEntity<Atividade> getRascunho() {
        return atividadeService.getRascunho()
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.noContent().build());
    }
}
