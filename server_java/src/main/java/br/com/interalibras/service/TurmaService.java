package br.com.interalibras.service;

import br.com.interalibras.entity.Atividade;
import br.com.interalibras.entity.Turma;
import br.com.interalibras.entity.Usuario;
import br.com.interalibras.repository.AtividadeRepository;
import br.com.interalibras.repository.TurmaRepository;
import br.com.interalibras.repository.UsuarioRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Serviço de domínio responsável pela gestão de turmas, matrículas de alunos e vínculo de atividades pedagógicas.
 */
@Service
@Transactional
public class TurmaService {

    private final TurmaRepository turmaRepository;
    private final UsuarioRepository usuarioRepository;
    private final AtividadeRepository atividadeRepository;
    private final SecureRandom random = new SecureRandom();

    public TurmaService(TurmaRepository turmaRepository,
                        UsuarioRepository usuarioRepository,
                        AtividadeRepository atividadeRepository) {
        this.turmaRepository = turmaRepository;
        this.usuarioRepository = usuarioRepository;
        this.atividadeRepository = atividadeRepository;
    }

    /**
     * Gera um código identificador PIN único e amigável (ex: LBR-4821).
     */
    public String generateUniquePin() {
        String pin;
        do {
            int num = 1000 + random.nextInt(9000);
            pin = "LBR-" + num;
        } while (turmaRepository.existsByCodigo(pin));
        return pin;
    }

    /**
     * Mapeia a entidade Turma para um resumo estruturado em Map JSON-friendly.
     */
    public Map<String, Object> mapTurmaSummary(Turma t) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", t.getId());
        map.put("nome", t.getNome());
        map.put("descricao", t.getDescricao() != null ? t.getDescricao() : "");
        map.put("codigo", t.getCodigo());
        map.put("totalAlunos", t.getAlunos() != null ? t.getAlunos().size() : 0);
        map.put("totalAtividades", t.getAtividades() != null ? t.getAtividades().size() : 0);
        map.put("createdAt", t.getCreatedAt() != null ? t.getCreatedAt().toString() : null);

        if (t.getUsuario() != null) {
            map.put("professorId", t.getUsuario().getId());
            map.put("professorNome", t.getUsuario().getNome());
        }

        // Mapeia alunos associados
        List<Map<String, Object>> alunosList = new ArrayList<>();
        List<Long> alunoIds = new ArrayList<>();
        if (t.getAlunos() != null) {
            for (Usuario u : t.getAlunos()) {
                alunoIds.add(u.getId());
                Map<String, Object> uMap = new HashMap<>();
                uMap.put("id", u.getId());
                uMap.put("nome", u.getNome());
                uMap.put("username", u.getUsername());
                uMap.put("codigoIdentificador", u.getCodigoIdentificador());
                uMap.put("avatar", u.getAvatar());
                uMap.put("role", u.getRole());
                alunosList.add(uMap);
            }
        }
        map.put("alunoIds", alunoIds);
        map.put("alunos", alunosList);

        // Mapeia temas e atividades associadas
        List<Map<String, Object>> atividadesList = new ArrayList<>();
        List<Long> atvIds = new ArrayList<>();
        if (t.getAtividades() != null) {
            for (Atividade a : t.getAtividades()) {
                atvIds.add(a.getId());
                Map<String, Object> aMap = new HashMap<>();
                aMap.put("id", a.getId());
                aMap.put("titulo", a.getTitulo());
                aMap.put("tipoJogo", a.getTipoJogo());
                aMap.put("dificuldade", a.getDificuldade());
                aMap.put("icone", a.getIcone());
                aMap.put("totalItens", a.getItens() != null ? a.getItens().size() : 0);
                atividadesList.add(aMap);
            }
        }
        map.put("atividadesIds", atvIds);
        map.put("atividades", atividadesList);

        return map;
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> findAll() {
        return turmaRepository.findAll().stream()
                .map(this::mapTurmaSummary)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Optional<Map<String, Object>> findById(Long id) {
        return turmaRepository.findById(id).map(this::mapTurmaSummary);
    }

    @Transactional(readOnly = true)
    public Optional<Map<String, Object>> findByCodigo(String codigo) {
        return turmaRepository.findByCodigo(codigo.trim().toUpperCase()).map(this::mapTurmaSummary);
    }

    @Transactional(readOnly = true)
    public Optional<Map<String, Object>> findByAlunoId(Long alunoId) {
        List<Turma> list = turmaRepository.findByAlunoId(alunoId);
        if (!list.isEmpty()) {
            return Optional.of(mapTurmaSummary(list.get(0)));
        }
        return Optional.empty();
    }

    public Turma create(String nome, String descricao, String codigo, Long usuarioId) {
        if (codigo == null || codigo.trim().isEmpty()) {
            codigo = generateUniquePin();
        } else {
            codigo = codigo.trim().toUpperCase();
            if (turmaRepository.existsByCodigo(codigo)) {
                throw new IllegalArgumentException("Este código de turma já está em uso.");
            }
        }

        Turma turma = new Turma();
        turma.setNome(nome.trim());
        turma.setDescricao(descricao != null ? descricao.trim() : "");
        turma.setCodigo(codigo);

        if (usuarioId != null) {
            usuarioRepository.findById(usuarioId).ifPresent(turma::setUsuario);
        } else {
            usuarioRepository.findByUsername("admin").ifPresent(turma::setUsuario);
        }

        return turmaRepository.save(turma);
    }

    public Turma update(Long id, String nome, String descricao, String codigo) {
        Turma turma = turmaRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Turma não encontrada com ID " + id));

        if (nome != null && !nome.trim().isEmpty()) {
            turma.setNome(nome.trim());
        }
        if (descricao != null) {
            turma.setDescricao(descricao.trim());
        }
        if (codigo != null && !codigo.trim().isEmpty()) {
            String newCode = codigo.trim().toUpperCase();
            if (!newCode.equals(turma.getCodigo())) {
                if (turmaRepository.existsByCodigo(newCode)) {
                    throw new IllegalArgumentException("Este código de turma já está em uso.");
                }
                turma.setCodigo(newCode);
            }
        }

        return turmaRepository.save(turma);
    }

    public void delete(Long id) {
        if (!turmaRepository.existsById(id)) {
            throw new NoSuchElementException("Turma não encontrada com ID " + id);
        }
        turmaRepository.deleteById(id);
    }

    public Turma setAlunos(Long id, List<Long> alunoIds) {
        Turma turma = turmaRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Turma não encontrada com ID " + id));

        if (turma.getAlunos() == null) {
            turma.setAlunos(new HashSet<>());
        }
        turma.getAlunos().clear();

        if (alunoIds != null) {
            for (Long aId : alunoIds) {
                usuarioRepository.findById(aId).ifPresent(turma.getAlunos()::add);
            }
        }

        return turmaRepository.save(turma);
    }

    public Turma removeAluno(Long id, Long alunoId) {
        Turma turma = turmaRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Turma não encontrada com ID " + id));

        usuarioRepository.findById(alunoId).ifPresent(turma::removeAluno);
        return turmaRepository.save(turma);
    }

    public Turma setAtividades(Long id, List<Long> atividadeIds) {
        Turma turma = turmaRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Turma não encontrada com ID " + id));

        if (turma.getAtividades() == null) {
            turma.setAtividades(new HashSet<>());
        }
        turma.getAtividades().clear();

        if (atividadeIds != null) {
            for (Long atvId : atividadeIds) {
                atividadeRepository.findById(atvId).ifPresent(turma.getAtividades()::add);
            }
        }

        return turmaRepository.save(turma);
    }

    public Turma entrarTurma(String codigo, Long alunoId) {
        Turma turma = turmaRepository.findByCodigo(codigo.trim().toUpperCase())
                .orElseThrow(() -> new NoSuchElementException("Turma não encontrada para o código " + codigo));

        if (alunoId != null) {
            usuarioRepository.findById(alunoId).ifPresent(turma::addAluno);
            turmaRepository.save(turma);
        }

        return turma;
    }

    public void sairTurma(Long alunoId) {
        if (alunoId != null) {
            List<Turma> turmas = turmaRepository.findByAlunoId(alunoId);
            for (Turma t : turmas) {
                usuarioRepository.findById(alunoId).ifPresent(t::removeAluno);
                turmaRepository.save(t);
            }
        }
    }
}
