package br.com.alfabetizalibras.controller;

import br.com.alfabetizalibras.entity.Usuario;
import br.com.alfabetizalibras.service.UsuarioService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

/**
 * Endpoints REST para gerenciamento de contas, perfis e credenciais de usuários.
 */
@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {

    private final UsuarioService usuarioService;

    public UsuarioController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @GetMapping
    public ResponseEntity<List<Usuario>> listarUsuarios(@RequestParam(value = "busca", required = false) String busca) {
        return ResponseEntity.ok(usuarioService.listarUsuarios(busca));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> buscarPorId(@PathVariable Long id) {
        return usuarioService.buscarPorId(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<?> criarUsuario(@RequestBody Map<String, Object> payload) {
        String nome = (String) payload.get("nome");
        String username = (String) payload.get("username");
        String password = (String) payload.get("password");
        String role = (String) payload.get("role");
        String avatar = (String) payload.get("avatar");
        Boolean mustChangePassword = (Boolean) payload.get("mustChangePassword");

        try {
            Usuario saved = usuarioService.criarUsuario(nome, username, password, role, avatar, mustChangePassword);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("message", e.getMessage()));
        }
    }

    @PutMapping("/{identifier}")
    public ResponseEntity<?> atualizarUsuario(@PathVariable String identifier, @RequestBody Usuario dadosAtualizados) {
        try {
            Usuario saved = usuarioService.atualizarUsuario(identifier, dadosAtualizados);
            return ResponseEntity.ok(saved);
        } catch (NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @PostMapping("/change-password")
    public ResponseEntity<?> trocarSenha(@RequestBody Map<String, String> payload, Principal principal) {
        String username = payload.get("username");
        if ((username == null || username.trim().isEmpty()) && principal != null) {
            username = principal.getName();
        }
        String newPassword = payload.get("newPassword");
        if (newPassword == null || newPassword.trim().isEmpty()) {
            newPassword = payload.get("password");
        }
        if (username == null || newPassword == null || newPassword.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Usuário e nova senha são obrigatórios."));
        }

        try {
            Usuario saved = usuarioService.trocarSenha(username, newPassword);
            return ResponseEntity.ok(saved);
        } catch (NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{identifier}/reset-password")
    public ResponseEntity<?> resetarSenha(@PathVariable String identifier) {
        try {
            Map<String, Object> result = usuarioService.resetarSenha(identifier);
            return ResponseEntity.ok(result);
        } catch (NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> excluirUsuario(@PathVariable Long id) {
        try {
            usuarioService.excluirUsuario(id);
            return ResponseEntity.noContent().build();
        } catch (NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
