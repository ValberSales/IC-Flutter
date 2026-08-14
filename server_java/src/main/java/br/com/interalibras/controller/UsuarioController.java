package br.com.interalibras.controller;

import br.com.interalibras.entity.Usuario;
import br.com.interalibras.repository.UsuarioRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;

    public UsuarioController(UsuarioRepository usuarioRepository, PasswordEncoder passwordEncoder) {
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @GetMapping
    public ResponseEntity<List<Usuario>> listarUsuarios(@RequestParam(value = "busca", required = false) String busca) {
        if (busca != null && !busca.trim().isEmpty()) {
            return ResponseEntity.ok(usuarioRepository.buscarPorTermo(busca.trim()));
        }
        return ResponseEntity.ok(usuarioRepository.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> buscarPorId(@PathVariable Long id) {
        Optional<Usuario> usuario = usuarioRepository.findById(id);
        if (usuario.isPresent()) {
            return ResponseEntity.ok(usuario.get());
        }
        return ResponseEntity.notFound().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> atualizarUsuario(@PathVariable Long id, @RequestBody Usuario dadosAtualizados) {
        Optional<Usuario> opt = usuarioRepository.findById(id);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Usuario usuario = opt.get();
        if (dadosAtualizados.getNome() != null && !dadosAtualizados.getNome().trim().isEmpty()) {
            usuario.setNome(dadosAtualizados.getNome().trim());
        }
        if (dadosAtualizados.getUsername() != null && !dadosAtualizados.getUsername().trim().isEmpty()) {
            String newUsername = dadosAtualizados.getUsername().trim();
            if (!newUsername.equalsIgnoreCase(usuario.getUsername()) && usuarioRepository.existsByUsername(newUsername)) {
                return ResponseEntity.badRequest().body(java.util.Map.of("message", "Nome de usuário já está em uso"));
            }
            usuario.setUsername(newUsername);
        }
        if (dadosAtualizados.getAvatar() != null && !dadosAtualizados.getAvatar().trim().isEmpty()) {
            usuario.setAvatar(dadosAtualizados.getAvatar().trim());
        }
        if (dadosAtualizados.getRole() != null && !dadosAtualizados.getRole().trim().isEmpty()) {
            usuario.setRole(dadosAtualizados.getRole().trim());
        }
        if (dadosAtualizados.getMustChangePassword() != null) {
            usuario.setMustChangePassword(dadosAtualizados.getMustChangePassword());
        }
        if (dadosAtualizados.getPassword() != null && !dadosAtualizados.getPassword().trim().isEmpty()) {
            usuario.setPassword(passwordEncoder.encode(dadosAtualizados.getPassword().trim()));
            if (dadosAtualizados.getMustChangePassword() == null) {
                usuario.setMustChangePassword(false);
            }
        }

        Usuario saved = usuarioRepository.save(usuario);
        return ResponseEntity.ok(saved);
    }

    @PostMapping("/{id}/reset-password")
    public ResponseEntity<?> resetarSenha(@PathVariable Long id) {
        Optional<Usuario> opt = usuarioRepository.findById(id);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Usuario usuario = opt.get();
        String chars = "abcdefghijklmnopqrstuvwxyz0123456789";
        StringBuilder sb = new StringBuilder(6);
        java.util.Random random = new java.util.Random();
        for (int i = 0; i < 6; i++) {
            sb.append(chars.charAt(random.nextInt(chars.length())));
        }
        String tempPassword = sb.toString();

        usuario.setPassword(passwordEncoder.encode(tempPassword));
        usuario.setMustChangePassword(true);
        Usuario saved = usuarioRepository.save(usuario);

        return ResponseEntity.ok(java.util.Map.of(
            "tempPassword", tempPassword,
            "message", "Senha temporária gerada com sucesso",
            "user", saved
        ));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> excluirUsuario(@PathVariable Long id) {
        if (usuarioRepository.existsById(id)) {
            usuarioRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
