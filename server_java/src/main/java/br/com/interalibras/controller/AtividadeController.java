package br.com.interalibras.controller;

import br.com.interalibras.entity.Atividade;
import br.com.interalibras.repository.AtividadeRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/atividades")
public class AtividadeController {

    private final AtividadeRepository atividadeRepository;

    public AtividadeController(AtividadeRepository atividadeRepository) {
        this.atividadeRepository = atividadeRepository;
    }

    @GetMapping
    public ResponseEntity<List<Atividade>> getAllAtividades(@RequestParam(required = false) Boolean apenasAtivas) {
        if (Boolean.TRUE.equals(apenasAtivas)) {
            return ResponseEntity.ok(atividadeRepository.findByAtivoTrueAndRascunhoFalseOrderByTituloAsc());
        }
        return ResponseEntity.ok(atividadeRepository.findAllByOrderByTituloAsc());
    }

    @PostMapping
    public ResponseEntity<Atividade> createOrUpdateAtividade(@RequestBody Atividade atividade) {
        if (atividade.getItens() != null) {
            atividade.getItens().forEach(item -> item.setAtividade(atividade));
        }

        // Se salvar uma atividade rascunho anterior publicar, apaga rascunhos antigos se for publicar
        if (!atividade.isRascunho()) {
            Optional<Atividade> rascunhoAntigo = atividadeRepository.findByRascunhoTrue();
            rascunhoAntigo.ifPresent(r -> atividadeRepository.deleteById(r.getId()));
        }

        Atividade saved = atividadeRepository.save(atividade);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Atividade> updateAtividade(@PathVariable Long id, @RequestBody Atividade atividade) {
        atividade.setId(id);
        if (atividade.getItens() != null) {
            atividade.getItens().forEach(item -> item.setAtividade(atividade));
        }
        Atividade updated = atividadeRepository.save(atividade);
        return ResponseEntity.ok(updated);
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<Atividade> toggleStatus(@PathVariable Long id) {
        Optional<Atividade> opt = atividadeRepository.findById(id);
        if (opt.isPresent()) {
            Atividade a = opt.get();
            a.setAtivo(!a.isAtivo());
            return ResponseEntity.ok(atividadeRepository.save(a));
        }
        return ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAtividade(@PathVariable Long id) {
        if (atividadeRepository.existsById(id)) {
            atividadeRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping("/rascunho")
    public ResponseEntity<Atividade> getRascunho() {
        Optional<Atividade> opt = atividadeRepository.findByRascunhoTrue();
        return opt.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.noContent().build());
    }
}
