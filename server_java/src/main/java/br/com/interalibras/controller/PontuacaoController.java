package br.com.interalibras.controller;

import br.com.interalibras.entity.Pontuacao;
import br.com.interalibras.service.PontuacaoService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

/**
 * Endpoints REST para registro e consulta de pontuações de partidas.
 */
@RestController
@RequestMapping("/api/pontuacoes")
public class PontuacaoController {

    private final PontuacaoService pontuacaoService;

    public PontuacaoController(PontuacaoService pontuacaoService) {
        this.pontuacaoService = pontuacaoService;
    }

    @PostMapping
    public ResponseEntity<Pontuacao> save(@RequestBody Pontuacao pontuacao, Principal principal) {
        Pontuacao saved = pontuacaoService.salvarPontuacao(pontuacao, principal);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @GetMapping
    public ResponseEntity<List<Pontuacao>> getAll() {
        return ResponseEntity.ok(pontuacaoService.findAll());
    }

    @GetMapping("/usuario/{usuarioId}")
    public ResponseEntity<List<Pontuacao>> getByUsuario(@PathVariable Long usuarioId) {
        return ResponseEntity.ok(pontuacaoService.findByUsuarioId(usuarioId));
    }
}
