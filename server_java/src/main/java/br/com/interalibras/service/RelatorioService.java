package br.com.interalibras.service;

import br.com.interalibras.entity.Atividade;
import br.com.interalibras.entity.Pontuacao;
import br.com.interalibras.entity.Turma;
import br.com.interalibras.entity.Usuario;
import br.com.interalibras.repository.PontuacaoRepository;
import br.com.interalibras.repository.TurmaRepository;
import br.com.interalibras.repository.UsuarioRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Serviço responsável por analytics pedagógico, cálculos de aproveitamento,
 * evolução de dificuldade calculada e relatórios consolidados de turmas e alunos.
 */
@Service
@Transactional
public class RelatorioService {

    private final TurmaRepository turmaRepository;
    private final UsuarioRepository usuarioRepository;
    private final PontuacaoRepository pontuacaoRepository;

    public RelatorioService(TurmaRepository turmaRepository,
                            UsuarioRepository usuarioRepository,
                            PontuacaoRepository pontuacaoRepository) {
        this.turmaRepository = turmaRepository;
        this.usuarioRepository = usuarioRepository;
        this.pontuacaoRepository = pontuacaoRepository;
    }

    @Transactional(readOnly = true)
    public List<Pontuacao> listarTodasPontuacoes() {
        return pontuacaoRepository.findAll();
    }

    public void limparTodasPontuacoes() {
        pontuacaoRepository.deleteAll();
    }

    public Map<String, Object> deduplicarPontuacoes() {
        List<Pontuacao> all = pontuacaoRepository.findAll();
        Set<String> seen = new HashSet<>();
        List<Pontuacao> toDelete = new ArrayList<>();

        for (Pontuacao p : all) {
            String uid = p.getUsuario() != null ? String.valueOf(p.getUsuario().getId()) : "0";
            String key = uid + "_" + p.getAtividade() + "_" + p.getTema() + "_" + p.getDificuldade() + "_" + p.getAcertos() + "_" + p.getErros();
            if (seen.contains(key)) {
                toDelete.add(p);
            } else {
                seen.add(key);
            }
        }

        if (!toDelete.isEmpty()) {
            pontuacaoRepository.deleteAll(toDelete);
        }

        return Map.of("removidos", toDelete.size(), "restantes", all.size() - toDelete.size());
    }

    @Transactional(readOnly = true)
    public Map<String, Object> gerarRelatorioTurma(Long turmaId) {
        Turma turma = turmaRepository.findById(turmaId)
                .orElseThrow(() -> new NoSuchElementException("Turma não encontrada com ID " + turmaId));

        Set<Usuario> alunosSet = turma.getAlunos() != null ? turma.getAlunos() : Collections.emptySet();
        List<Usuario> alunos = new ArrayList<>(alunosSet);
        List<Long> alunoIds = alunos.stream().map(Usuario::getId).filter(Objects::nonNull).collect(Collectors.toList());

        List<Pontuacao> scores = alunoIds.isEmpty() ? Collections.emptyList() : pontuacaoRepository.findByAlunoIds(alunoIds);

        int totalPartidas = scores.size();
        int totalAcertos = scores.stream().mapToInt(Pontuacao::getAcertos).sum();
        int totalErros = scores.stream().mapToInt(Pontuacao::getErros).sum();
        double taxaAproveitamento = (totalAcertos + totalErros > 0)
                ? ((double) totalAcertos / (totalAcertos + totalErros)) * 100.0
                : 0.0;

        Set<Atividade> atividadesSet = turma.getAtividades() != null ? turma.getAtividades() : Collections.emptySet();
        Set<String> turmaThemeNames = atividadesSet.stream()
                .map(Atividade::getTitulo)
                .filter(Objects::nonNull)
                .map(String::trim)
                .map(String::toUpperCase)
                .collect(Collectors.toSet());

        List<Map<String, Object>> temasList = new ArrayList<>();
        for (Atividade atv : atividadesSet) {
            Map<String, Object> tMap = new HashMap<>();
            tMap.put("id", atv.getId());
            tMap.put("titulo", atv.getTitulo());
            tMap.put("tipoJogo", atv.getTipoJogo());
            tMap.put("totalItens", atv.getItens() != null ? atv.getItens().size() : 0);

            List<Pontuacao> temaScores = scores.stream()
                    .filter(s -> atv.getTitulo().equalsIgnoreCase(s.getTema()) || atv.getTitulo().equalsIgnoreCase(s.getAtividade()))
                    .collect(Collectors.toList());
            int tAcertos = temaScores.stream().mapToInt(Pontuacao::getAcertos).sum();
            int tErros = temaScores.stream().mapToInt(Pontuacao::getErros).sum();
            double tTaxa = (tAcertos + tErros > 0) ? ((double) tAcertos / (tAcertos + tErros)) * 100.0 : 0.0;

            tMap.put("totalPartidas", temaScores.size());
            tMap.put("taxaAproveitamento", Math.round(tTaxa * 10.0) / 10.0);
            temasList.add(tMap);
        }

        List<Map<String, Object>> alunosList = new ArrayList<>();
        int countFacil = 0;
        int countMedio = 0;
        int countDificil = 0;

        for (Usuario aluno : alunos) {
            List<Pontuacao> pScores = scores.stream()
                    .filter(s -> s.getUsuario() != null && Objects.equals(s.getUsuario().getId(), aluno.getId()))
                    .collect(Collectors.toList());

            int pPartidas = pScores.size();
            int pAcertos = pScores.stream().mapToInt(Pontuacao::getAcertos).sum();
            int pErros = pScores.stream().mapToInt(Pontuacao::getErros).sum();
            double pTaxa = (pAcertos + pErros > 0) ? ((double) pAcertos / (pAcertos + pErros)) * 100.0 : 0.0;

            List<Pontuacao> turmaScores = pScores.stream().filter(s -> {
                String sTema = (s.getTema() != null ? s.getTema() : (s.getAtividade() != null ? s.getAtividade() : "")).trim().toUpperCase();
                return turmaThemeNames.contains(sTema);
            }).collect(Collectors.toList());

            String calculatedLevel = "FACIL";
            boolean hasDificilDominado = turmaScores.stream().anyMatch(s -> "DIFICIL".equalsIgnoreCase(s.getDificuldade()) &&
                    ("JOGO_MEMORIA".equalsIgnoreCase(s.getAtividade()) ? s.isConcluido() : (s.getAcertos() + s.getErros() > 0 && ((double) s.getAcertos() / (s.getAcertos() + s.getErros())) >= 0.70)));

            boolean hasMedioDominado = turmaScores.stream().anyMatch(s -> ("MEDIO".equalsIgnoreCase(s.getDificuldade()) || "FACIL".equalsIgnoreCase(s.getDificuldade())) &&
                    ("JOGO_MEMORIA".equalsIgnoreCase(s.getAtividade()) ? s.isConcluido() : (s.getAcertos() + s.getErros() > 0 && ((double) s.getAcertos() / (s.getAcertos() + s.getErros())) >= 0.70)));

            if (hasDificilDominado) {
                calculatedLevel = "DIFICIL";
                countDificil++;
            } else if (hasMedioDominado) {
                calculatedLevel = "MEDIO";
                countMedio++;
            } else {
                calculatedLevel = "FACIL";
                countFacil++;
            }

            Map<String, Object> aMap = new HashMap<>();
            aMap.put("id", aluno.getId());
            aMap.put("nome", aluno.getNome() != null ? aluno.getNome() : aluno.getUsername());
            aMap.put("username", aluno.getUsername());
            aMap.put("codigoIdentificador", aluno.getCodigoIdentificador() != null ? aluno.getCodigoIdentificador() : UUID.randomUUID().toString());
            aMap.put("avatar", aluno.getAvatar() != null ? aluno.getAvatar() : "assets/avatar/avatar_1.png");
            aMap.put("totalPartidas", pPartidas);
            aMap.put("acertos", pAcertos);
            aMap.put("erros", pErros);
            aMap.put("taxaAproveitamento", Math.round(pTaxa * 10.0) / 10.0);
            aMap.put("dificuldadeAtual", "FACIL");
            aMap.put("dificuldadeCalculada", calculatedLevel);

            List<Map<String, Object>> historicoList = pScores.stream().map(this::mapPontuacaoItem).collect(Collectors.toList());
            aMap.put("historico", historicoList);

            alunosList.add(aMap);
        }

        Map<String, Object> evolucaoDificuldade = new HashMap<>();
        evolucaoDificuldade.put("facil", countFacil);
        evolucaoDificuldade.put("medio", countMedio);
        evolucaoDificuldade.put("dificil", countDificil);

        Map<String, Object> response = new HashMap<>();
        response.put("turmaId", turma.getId());
        response.put("turmaNome", turma.getNome());
        response.put("turmaCodigo", turma.getCodigo());
        response.put("totalAlunos", alunos.size());
        response.put("totalPartidas", totalPartidas);
        response.put("totalAcertos", totalAcertos);
        response.put("totalErros", totalErros);
        response.put("taxaAproveitamentoGeral", Math.round(taxaAproveitamento * 10.0) / 10.0);
        response.put("temas", temasList);
        response.put("alunos", alunosList);
        response.put("evolucaoDificuldade", evolucaoDificuldade);

        return response;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> gerarRelatorioAluno(Long alunoId) {
        Usuario aluno = usuarioRepository.findById(alunoId)
                .orElseThrow(() -> new NoSuchElementException("Aluno não encontrado com ID " + alunoId));

        List<Pontuacao> scores = pontuacaoRepository.findByUsuarioIdOrderByCreatedAtDesc(aluno.getId());

        int totalPartidas = scores.size();
        int totalAcertos = scores.stream().mapToInt(Pontuacao::getAcertos).sum();
        int totalErros = scores.stream().mapToInt(Pontuacao::getErros).sum();
        double taxaAproveitamento = (totalAcertos + totalErros > 0)
                ? ((double) totalAcertos / (totalAcertos + totalErros)) * 100.0
                : 0.0;

        String diff = "FACIL";
        if (!scores.isEmpty() && scores.get(0).getDificuldade() != null) {
            diff = scores.get(0).getDificuldade();
        }

        Map<String, Object> result = new HashMap<>();
        result.put("id", aluno.getId());
        result.put("nome", aluno.getNome() != null ? aluno.getNome() : aluno.getUsername());
        result.put("username", aluno.getUsername());
        result.put("codigoIdentificador", aluno.getCodigoIdentificador() != null ? aluno.getCodigoIdentificador() : UUID.randomUUID().toString());
        result.put("avatar", aluno.getAvatar() != null ? aluno.getAvatar() : "assets/avatar/avatar_1.png");
        result.put("totalPartidas", totalPartidas);
        result.put("totalAcertos", totalAcertos);
        result.put("totalErros", totalErros);
        result.put("taxaAproveitamento", Math.round(taxaAproveitamento * 10.0) / 10.0);
        result.put("dificuldadeAtual", diff);
        result.put("historico", scores.stream().map(this::mapPontuacaoItem).collect(Collectors.toList()));

        return result;
    }

    public Map<String, Object> mapPontuacaoItem(Pontuacao p) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", p.getId());
        map.put("atividade", p.getAtividade());
        map.put("tema", p.getTema() != null ? p.getTema() : p.getAtividade());
        map.put("acertos", p.getAcertos());
        map.put("erros", p.getErros());
        map.put("dificuldade", p.getDificuldade() != null ? p.getDificuldade() : "FACIL");
        map.put("concluido", p.isConcluido());
        map.put("createdAt", p.getCreatedAt() != null ? p.getCreatedAt().toString() : null);

        int total = p.getAcertos() + p.getErros();
        double taxa = 0.0;
        if ("JOGO_MEMORIA".equalsIgnoreCase(p.getAtividade())) {
            taxa = p.isConcluido() ? 100.0 : 0.0;
        } else if (total > 0) {
            taxa = ((double) p.getAcertos() / total) * 100.0;
        }
        map.put("taxaAproveitamento", Math.round(taxa * 10.0) / 10.0);
        return map;
    }
}
