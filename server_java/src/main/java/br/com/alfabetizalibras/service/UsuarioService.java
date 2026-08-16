package br.com.alfabetizalibras.service;

import br.com.alfabetizalibras.entity.Usuario;
import br.com.alfabetizalibras.repository.UsuarioRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.util.*;

/**
 * Serviço responsável pelo gerenciamento de contas, perfis e credenciais de usuários (alunos e professores).
 */
@Service
@Transactional
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;
    private final SecureRandom random = new SecureRandom();

    public UsuarioService(UsuarioRepository usuarioRepository, PasswordEncoder passwordEncoder) {
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional(readOnly = true)
    public List<Usuario> listarUsuarios(String busca) {
        if (busca != null && !busca.trim().isEmpty()) {
            return usuarioRepository.buscarPorTermo(busca.trim());
        }
        return usuarioRepository.findAll();
    }

    @Transactional(readOnly = true)
    public Optional<Usuario> buscarPorId(Long id) {
        return usuarioRepository.findById(id);
    }

    @Transactional(readOnly = true)
    public Optional<Usuario> findUserByIdentifier(String identifier) {
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

    public Usuario criarUsuario(String nome, String username, String password, String role, String avatar, Boolean mustChangePassword) {
        if (username == null || username.trim().isEmpty()) {
            throw new IllegalArgumentException("O nome de usuário é obrigatório.");
        }

        String cleanUsername = username.trim();
        if (usuarioRepository.existsByUsername(cleanUsername)) {
            throw new IllegalStateException("Nome de usuário já está em uso.");
        }

        Usuario usuario = new Usuario();
        usuario.setNome(nome != null && !nome.trim().isEmpty() ? nome.trim() : cleanUsername);
        usuario.setUsername(cleanUsername);
        usuario.setPassword(password != null && !password.trim().isEmpty()
                ? passwordEncoder.encode(password.trim())
                : passwordEncoder.encode("123456"));

        String cleanRole = role != null && !role.trim().isEmpty() ? role.trim().toUpperCase() : "USER";
        usuario.setRole(cleanRole);
        usuario.setAvatar(avatar != null && !avatar.trim().isEmpty() ? avatar.trim() : "assets/avatar/avatar_1.png");
        usuario.setMustChangePassword(mustChangePassword != null ? mustChangePassword : false);

        if (usuario.getCodigoIdentificador() == null || usuario.getCodigoIdentificador().trim().isEmpty()) {
            usuario.setCodigoIdentificador(UUID.randomUUID().toString());
        }

        return usuarioRepository.save(usuario);
    }

    public Usuario atualizarUsuario(String identifier, Usuario dadosAtualizados) {
        Optional<Usuario> opt = findUserByIdentifier(identifier);
        if (opt.isEmpty() && dadosAtualizados.getId() != null) {
            opt = usuarioRepository.findById(dadosAtualizados.getId());
        }
        if (opt.isEmpty() && dadosAtualizados.getUsername() != null) {
            opt = usuarioRepository.findByUsername(dadosAtualizados.getUsername().trim());
        }
        if (opt.isEmpty()) {
            throw new NoSuchElementException("Usuário não encontrado.");
        }

        Usuario usuario = opt.get();
        if (dadosAtualizados.getNome() != null && !dadosAtualizados.getNome().trim().isEmpty()) {
            usuario.setNome(dadosAtualizados.getNome().trim());
        }
        if (dadosAtualizados.getUsername() != null && !dadosAtualizados.getUsername().trim().isEmpty()) {
            String newUsername = dadosAtualizados.getUsername().trim();
            if (!newUsername.equalsIgnoreCase(usuario.getUsername()) && usuarioRepository.existsByUsername(newUsername)) {
                throw new IllegalArgumentException("Nome de usuário já está em uso");
            }
            usuario.setUsername(newUsername);
        }
        if (dadosAtualizados.getEmail() != null && !dadosAtualizados.getEmail().trim().isEmpty()) {
            usuario.setEmail(dadosAtualizados.getEmail().trim());
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

        return usuarioRepository.save(usuario);
    }

    public Usuario trocarSenha(String username, String newPassword) {
        Usuario usuario = findUserByIdentifier(username)
                .orElseThrow(() -> new NoSuchElementException("Usuário não encontrado."));

        usuario.setPassword(passwordEncoder.encode(newPassword.trim()));
        usuario.setMustChangePassword(false);
        return usuarioRepository.save(usuario);
    }

    public Map<String, Object> resetarSenha(String identifier) {
        Usuario usuario = findUserByIdentifier(identifier)
                .orElseThrow(() -> new NoSuchElementException("Usuário não encontrado."));

        String chars = "abcdefghijklmnopqrstuvwxyz0123456789";
        StringBuilder sb = new StringBuilder(6);
        for (int i = 0; i < 6; i++) {
            sb.append(chars.charAt(random.nextInt(chars.length())));
        }
        String tempPassword = sb.toString();

        usuario.setPassword(passwordEncoder.encode(tempPassword));
        usuario.setMustChangePassword(true);
        Usuario saved = usuarioRepository.save(usuario);

        return Map.of(
                "tempPassword", tempPassword,
                "message", "Senha temporária gerada com sucesso",
                "user", saved
        );
    }

    public void excluirUsuario(Long id) {
        if (!usuarioRepository.existsById(id)) {
            throw new NoSuchElementException("Usuário não encontrado com ID " + id);
        }
        usuarioRepository.deleteById(id);
    }
}
