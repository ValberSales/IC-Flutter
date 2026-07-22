package br.com.interalibras.controller;

import br.com.interalibras.entity.Pontuacao;
import br.com.interalibras.repository.PontuacaoRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/pontuacoes")
public class PontuacaoController {

    private final PontuacaoRepository pontuacaoRepository;

    public PontuacaoController(PontuacaoRepository pontuacaoRepository) {
        this.pontuacaoRepository = pontuacaoRepository;
    }

    @PostMapping
    public ResponseEntity<Pontuacao> save(@RequestBody Pontuacao pontuacao) {
        Pontuacao saved = pontuacaoRepository.save(pontuacao);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @GetMapping("/personagem/{personagemId}")
    public ResponseEntity<List<Pontuacao>> getByPersonagem(@PathVariable Long personagemId) {
        return ResponseEntity.ok(pontuacaoRepository.findByPersonagemId(personagemId));
    }
}
