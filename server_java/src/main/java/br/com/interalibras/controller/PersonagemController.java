package br.com.interalibras.controller;

import br.com.interalibras.entity.Personagem;
import br.com.interalibras.repository.PersonagemRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/personagens")
public class PersonagemController {

    private final PersonagemRepository personagemRepository;

    public PersonagemController(PersonagemRepository personagemRepository) {
        this.personagemRepository = personagemRepository;
    }

    @GetMapping
    public ResponseEntity<List<Personagem>> getAll() {
        return ResponseEntity.ok(personagemRepository.findAll());
    }

    @PostMapping
    public ResponseEntity<Personagem> save(@RequestBody Personagem personagem) {
        Personagem saved = personagemRepository.save(personagem);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (personagemRepository.existsById(id)) {
            personagemRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
