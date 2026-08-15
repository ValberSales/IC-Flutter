package br.com.interalibras.controller;

import br.com.interalibras.entity.Usuario;
import br.com.interalibras.repository.UsuarioRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Random;

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

    @PostMapping
    public ResponseEntity<?> criarUsuario(@RequestBody Map<String, Object> payload) {
        String nome = (String) payload.get("nome");
        String username = (String) payload.get("username");
        String password = (String) payload.get("password");
        String role = (String) payload.get("role");
        String avatar = (String) payload.get("avatar");
        Boolean mustChangePassword = (Boolean) payload.get("mustChangePassword");

        if (username == null || username.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "O nome de usuário é obrigatório."));
        }

        String cleanUsername = username.trim();
        if (usuarioRepository.existsByUsername(cleanUsername)) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("message", "Nome de usuário já está em uso."));
        }

        Usuario usuario = new Usuario();
        usuario.setNome(nome != null && !nome.trim().isEmpty() ? nome.trim() : cleanUsername);
        usuario.setUsername(cleanUsername);
        usuario.setPassword(password != null && !password.trim().isEmpty() 
            ? passwordEncoder.encode(password.trim()) 
            : passwordEncoder.encode("123456"));
        
        String cleanRole = role != null && !role.trim().isEmpty() ? role.trim().toUpperCase() : "USER";
        usuario.setRole(cleanRole);
        usuario.setAvatar(avatar != null && !avatar.trim().isEmpty() ? avatar.trim() : "assets/avatar/avatar_1.jpg");
        usuario.setMustChangePassword(mustChangePassword != null ? mustChangePassword : false);

        // Gerar UUID único interno
        if (usuario.getCodigoIdentificador() == null || usuario.getCodigoIdentificador().trim().isEmpty()) {
            usuario.setCodigoIdentificador(java.util.UUID.randomUUID().toString());
        }

        Usuario saved = usuarioRepository.save(usuario);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    private Optional<Usuario> findUserByIdentifier(String identifier) {
        if (identifier == null || identifier.trim().isEmpty()) return Optional.empty();
        String clean = identifier.trim();
        if (clean.matches("\\d+")) {
            try {
                Optional<Usuario> byId = usuarioRepository.findById(Long.parseLong(clean));
                if (byId.isPresent()) return byId;
            } catch (Exception ignored) {}
        }
        Optional<Usuario> byUsername = usuarioRepository.findByUsername(clean);
        if (byUsername.isPresent()) return byUsername;
        return usuarioRepository.findByCodigoIdentificador(clean);
    }

    @PutMapping("/{identifier}")
    public ResponseEntity<?> atualizarUsuario(@PathVariable String identifier, @RequestBody Usuario dadosAtualizados) {
        Optional<Usuario> opt = findUserByIdentifier(identifier);
        if (opt.isEmpty() && dadosAtualizados.getId() != null) {
            opt = usuarioRepository.findById(dadosAtualizados.getId());
        }
        if (opt.isEmpty() && dadosAtualizados.getUsername() != null) {
            opt = usuarioRepository.findByUsername(dadosAtualizados.getUsername().trim());
        }
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
                return ResponseEntity.badRequest().body(Map.of("message", "Nome de usuário já está em uso"));
            }
            usuario.setUsername(newUsername);
        }
        if (dadosAtualizados.getAvatar() != null && !dadosAtualizados.getAvatar().trim().isEmpty()) {
            usuario.setAvatar(dadosAtualizados.getAvatar().trim());
        }
        if (dadosAtualizados.getRole() != null && !dadosAtualizados.getRole().trim().isEmpty()) {
            String newRole = dadosAtualizados.getRole().trim().toUpperCase();
            usuario.setRole(newRole);
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

    @PostMapping("/change-password")
    public ResponseEntity<?> trocarSenha(@RequestBody Map<String, String> payload, java.security.Principal principal) {
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

        Optional<Usuario> opt = findUserByIdentifier(username);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Usuario usuario = opt.get();
        usuario.setPassword(passwordEncoder.encode(newPassword.trim()));
        usuario.setMustChangePassword(false);
        Usuario saved = usuarioRepository.save(usuario);

        return ResponseEntity.ok(saved);
    }

    @PostMapping("/{identifier}/reset-password")
    public ResponseEntity<?> resetarSenha(@PathVariable String identifier) {
        Optional<Usuario> opt = findUserByIdentifier(identifier);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Usuario usuario = opt.get();
        String chars = "abcdefghijklmnopqrstuvwxyz0123456789";
        StringBuilder sb = new StringBuilder(6);
        Random random = new Random();
        for (int i = 0; i < 6; i++) {
            sb.append(chars.charAt(random.nextInt(chars.length())));
        }
        String tempPassword = sb.toString();

        usuario.setPassword(passwordEncoder.encode(tempPassword));
        usuario.setMustChangePassword(true);
        Usuario saved = usuarioRepository.save(usuario);

        return ResponseEntity.ok(Map.of(
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
