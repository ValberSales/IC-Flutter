package br.com.interalibras.service;

import br.com.interalibras.entity.Pontuacao;
import br.com.interalibras.entity.Usuario;
import br.com.interalibras.repository.PontuacaoRepository;
import br.com.interalibras.repository.UsuarioRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.Principal;
import java.time.LocalDateTime;
import java.util.*;

/**
 * Serviço responsável pela persistência, mesclagem e consulta de histórico de pontuações de partidas.
 */
@Service
@Transactional
public class PontuacaoService {

    private final PontuacaoRepository pontuacaoRepository;
    private final UsuarioRepository usuarioRepository;

    public PontuacaoService(PontuacaoRepository pontuacaoRepository, UsuarioRepository usuarioRepository) {
        this.pontuacaoRepository = pontuacaoRepository;
        this.usuarioRepository = usuarioRepository;
    }

    public Pontuacao salvarPontuacao(Pontuacao pontuacao, Principal principal) {
        Usuario targetUser = null;
        if (pontuacao.getUsuario() != null && pontuacao.getUsuario().getId() != null) {
            targetUser = usuarioRepository.findById(pontuacao.getUsuario().getId()).orElse(null);
        }
        if (targetUser == null && pontuacao.getUsuario() != null && pontuacao.getUsuario().getUsername() != null) {
            targetUser = usuarioRepository.findByUsername(pontuacao.getUsuario().getUsername().trim()).orElse(null);
        }
        if (targetUser == null && principal != null) {
            targetUser = usuarioRepository.findByUsername(principal.getName()).orElse(null);
        }

        pontuacao.setUsuario(targetUser);

        String atividade = pontuacao.getAtividade() != null ? pontuacao.getAtividade() : "";
        String tema = pontuacao.getTema() != null ? pontuacao.getTema() : atividade;
        String diff = pontuacao.getDificuldade() != null ? pontuacao.getDificuldade() : "FACIL";

        int newTotal = pontuacao.getAcertos() + pontuacao.getErros();
        double newTaxa = "JOGO_MEMORIA".equalsIgnoreCase(atividade)
                ? (pontuacao.isConcluido() ? 100.0 : 0.0)
                : (newTotal > 0 ? ((double) pontuacao.getAcertos() / newTotal) * 100.0 : 0.0);

        final Usuario resolvedUser = targetUser;
        List<Pontuacao> allScores = resolvedUser != null
                ? pontuacaoRepository.findByUsuarioId(resolvedUser.getId())
                : pontuacaoRepository.findAll();

        Optional<Pontuacao> optExisting = allScores.stream().filter(p -> {
            boolean userMatch = (resolvedUser == null && p.getUsuario() == null) ||
                    (resolvedUser != null && p.getUsuario() != null && Objects.equals(resolvedUser.getId(), p.getUsuario().getId()));
            if (!userMatch) return false;

            boolean atvMatch = atividade.equalsIgnoreCase(p.getAtividade());
            String pTema = p.getTema() != null ? p.getTema() : (p.getAtividade() != null ? p.getAtividade() : "");
            boolean temaMatch = tema.equalsIgnoreCase(pTema);
            String pDiff = p.getDificuldade() != null ? p.getDificuldade() : "FACIL";
            boolean diffMatch = diff.equalsIgnoreCase(pDiff);

            return atvMatch && temaMatch && diffMatch;
        }).findFirst();

        if (optExisting.isPresent()) {
            Pontuacao existing = optExisting.get();
            int oldTotal = existing.getAcertos() + existing.getErros();
            double oldTaxa = "JOGO_MEMORIA".equalsIgnoreCase(existing.getAtividade())
                    ? (existing.isConcluido() ? 100.0 : 0.0)
                    : (oldTotal > 0 ? ((double) existing.getAcertos() / oldTotal) * 100.0 : 0.0);

            // Mescla progresso de itens
            if (pontuacao.getProgressoItens() != null && !pontuacao.getProgressoItens().trim().isEmpty()) {
                Set<String> mergedItems = new LinkedHashSet<>();
                if (existing.getProgressoItens() != null) {
                    mergedItems.addAll(Arrays.asList(existing.getProgressoItens().split(",")));
                }
                mergedItems.addAll(Arrays.asList(pontuacao.getProgressoItens().split(",")));
                existing.setProgressoItens(String.join(",", mergedItems));
            }

            if (newTaxa >= oldTaxa) {
                existing.setAcertos(pontuacao.getAcertos());
                existing.setErros(pontuacao.getErros());
                existing.setConcluido(pontuacao.isConcluido());
                existing.setCreatedAt(LocalDateTime.now());
                if (targetUser != null) existing.setUsuario(targetUser);

                return pontuacaoRepository.save(existing);
            } else {
                if (targetUser != null && existing.getUsuario() == null) existing.setUsuario(targetUser);
                return pontuacaoRepository.save(existing);
            }
        }

        pontuacao.setCreatedAt(LocalDateTime.now());
        return pontuacaoRepository.save(pontuacao);
    }

    @Transactional(readOnly = true)
    public List<Pontuacao> findAll() {
        return pontuacaoRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<Pontuacao> findByUsuarioId(Long usuarioId) {
        return pontuacaoRepository.findByUsuarioIdOrderByCreatedAtDesc(usuarioId);
    }
}
