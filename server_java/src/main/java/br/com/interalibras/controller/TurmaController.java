package br.com.interalibras.controller;

import br.com.interalibras.entity.Atividade;
import br.com.interalibras.entity.Turma;
import br.com.interalibras.entity.Usuario;
import br.com.interalibras.repository.AtividadeRepository;
import br.com.interalibras.repository.TurmaRepository;
import br.com.interalibras.repository.UsuarioRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.security.SecureRandom;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/turmas")
@Transactional
public class TurmaController {

    private final TurmaRepository turmaRepository;
    private final UsuarioRepository usuarioRepository;
    private final AtividadeRepository atividadeRepository;
    private final SecureRandom random = new SecureRandom();

    public TurmaController(TurmaRepository turmaRepository,
                           UsuarioRepository usuarioRepository,
                           AtividadeRepository atividadeRepository) {
        this.turmaRepository = turmaRepository;
        this.usuarioRepository = usuarioRepository;
        this.atividadeRepository = atividadeRepository;
    }

    private String generateUniquePin() {
        String pin;
        do {
            int num = 1000 + random.nextInt(9000);
            pin = "LBR-" + num;
        } while (turmaRepository.existsByCodigo(pin));
        return pin;
    }

    private Map<String, Object> mapTurmaSummary(Turma t) {
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

    private Map<String, Object> mapTurmaDetail(Turma t) {
        return mapTurmaSummary(t);
    }

    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> findAll() {
        List<Turma> list = turmaRepository.findAll();
        List<Map<String, Object>> res = list.stream().map(this::mapTurmaSummary).collect(Collectors.toList());
        return ResponseEntity.ok(res);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> findById(@PathVariable Long id) {
        Optional<Turma> opt = turmaRepository.findById(id);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(mapTurmaDetail(opt.get()));
    }

    @GetMapping("/busca/{codigo}")
    public ResponseEntity<?> findByCodigo(@PathVariable String codigo) {
        Optional<Turma> opt = turmaRepository.findByCodigo(codigo.trim().toUpperCase());
        if (opt.isPresent()) {
            return ResponseEntity.ok(Map.of(
                "turma", mapTurmaDetail(opt.get()),
                "message", "Turma encontrada com sucesso!"
            ));
        }
        return ResponseEntity.ok(Map.of(
            "turma", Optional.empty(),
            "message", "Turma não encontrada!"
        ));
    }

    @GetMapping("/aluno/{alunoId}")
    public ResponseEntity<?> findByAluno(@PathVariable Long alunoId) {
        List<Turma> list = turmaRepository.findByAlunoId(alunoId);
        if (!list.isEmpty()) {
            return ResponseEntity.ok(mapTurmaDetail(list.get(0)));
        }
        return ResponseEntity.ok(Collections.emptyMap());
    }

    @PostMapping
    public ResponseEntity<?> create(@RequestBody Map<String, Object> payload) {
        String nome = (String) payload.get("nome");
        String descricao = (String) payload.get("descricao");
        String codigo = (String) payload.get("codigo");

        if (nome == null || nome.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "O nome da turma é obrigatório."));
        }

        if (codigo == null || codigo.trim().isEmpty()) {
            codigo = generateUniquePin();
        } else {
            codigo = codigo.trim().toUpperCase();
            if (turmaRepository.existsByCodigo(codigo)) {
                return ResponseEntity.badRequest().body(Map.of("message", "Este código de turma já está em uso."));
            }
        }

        Turma turma = new Turma();
        turma.setNome(nome.trim());
        turma.setDescricao(descricao != null ? descricao.trim() : "");
        turma.setCodigo(codigo);

        if (payload.containsKey("usuarioId") && payload.get("usuarioId") != null) {
            Long usuarioId = ((Number) payload.get("usuarioId")).longValue();
            usuarioRepository.findById(usuarioId).ifPresent(turma::setUsuario);
        } else {
            usuarioRepository.findByUsername("admin").ifPresent(turma::setUsuario);
        }

        Turma saved = turmaRepository.save(turma);
        return ResponseEntity.ok(mapTurmaDetail(saved));
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, @RequestBody Map<String, Object> payload) {
        Optional<Turma> opt = turmaRepository.findById(id);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Turma turma = opt.get();
        if (payload.containsKey("nome")) {
            turma.setNome(((String) payload.get("nome")).trim());
        }
        if (payload.containsKey("descricao")) {
            turma.setDescricao((String) payload.get("descricao"));
        }
        if (payload.containsKey("codigo")) {
            String newCode = ((String) payload.get("codigo")).trim().toUpperCase();
            if (!newCode.equals(turma.getCodigo())) {
                if (turmaRepository.existsByCodigo(newCode)) {
                    return ResponseEntity.badRequest().body(Map.of("message", "Este código de turma já está em uso."));
                }
                turma.setCodigo(newCode);
            }
        }

        Turma saved = turmaRepository.save(turma);
        return ResponseEntity.ok(mapTurmaDetail(saved));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        if (!turmaRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        turmaRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("message", "Turma excluída com sucesso."));
    }

    @PostMapping("/{id}/alunos")
    public ResponseEntity<?> setAlunos(@PathVariable Long id, @RequestBody Map<String, Object> payload) {
        Optional<Turma> opt = turmaRepository.findById(id);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Turma turma = opt.get();
        @SuppressWarnings("unchecked")
        List<Number> alunoIds = (List<Number>) payload.get("alunoIds");

        if (turma.getAlunos() == null) {
            turma.setAlunos(new HashSet<>());
        }
        turma.getAlunos().clear();

        if (alunoIds != null) {
            for (Number aId : alunoIds) {
                usuarioRepository.findById(aId.longValue()).ifPresent(turma.getAlunos()::add);
            }
        }

        Turma saved = turmaRepository.save(turma);
        return ResponseEntity.ok(mapTurmaDetail(saved));
    }

    @DeleteMapping("/{id}/alunos/{alunoId}")
    public ResponseEntity<?> removeAluno(@PathVariable Long id, @PathVariable Long alunoId) {
        Optional<Turma> opt = turmaRepository.findById(id);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Turma turma = opt.get();
        usuarioRepository.findById(alunoId).ifPresent(turma::removeAluno);
        Turma saved = turmaRepository.save(turma);
        return ResponseEntity.ok(mapTurmaDetail(saved));
    }

    @PostMapping("/{id}/atividades")
    public ResponseEntity<?> setAtividades(@PathVariable Long id, @RequestBody Map<String, Object> payload) {
        Optional<Turma> opt = turmaRepository.findById(id);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Turma turma = opt.get();
        @SuppressWarnings("unchecked")
        List<Number> atividadeIds = (List<Number>) payload.get("atividadeIds");

        if (turma.getAtividades() == null) {
            turma.setAtividades(new HashSet<>());
        }
        turma.getAtividades().clear();

        if (atividadeIds != null) {
            for (Number atvId : atividadeIds) {
                atividadeRepository.findById(atvId.longValue()).ifPresent(turma.getAtividades()::add);
            }
        }

        Turma saved = turmaRepository.save(turma);
        return ResponseEntity.ok(mapTurmaDetail(saved));
    }

    @PostMapping("/entrar")
    public ResponseEntity<?> entrarTurma(@RequestBody Map<String, Object> payload) {
        String codigo = (String) payload.get("codigo");
        if (codigo == null || codigo.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Código da turma não informado."));
        }

        Optional<Turma> opt = turmaRepository.findByCodigo(codigo.trim().toUpperCase());
        if (opt.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Turma não encontrada para o código informado."));
        }

        Turma turma = opt.get();
        if (payload.containsKey("alunoId") && payload.get("alunoId") != null) {
            Long alunoId = ((Number) payload.get("alunoId")).longValue();
            usuarioRepository.findById(alunoId).ifPresent(turma::addAluno);
            turmaRepository.save(turma);
        }

        return ResponseEntity.ok(Map.of(
            "turma", mapTurmaDetail(turma),
            "message", "Vinculado à turma '" + turma.getNome() + "' com sucesso!"
        ));
    }

    @PostMapping("/sair")
    public ResponseEntity<?> sairTurma(@RequestBody Map<String, Object> payload) {
        if (payload.containsKey("alunoId") && payload.get("alunoId") != null) {
            Long alunoId = ((Number) payload.get("alunoId")).longValue();
            List<Turma> turmas = turmaRepository.findByAlunoId(alunoId);
            for (Turma t : turmas) {
                usuarioRepository.findById(alunoId).ifPresent(t::removeAluno);
                turmaRepository.save(t);
            }
        }
        return ResponseEntity.ok(Map.of("message", "Desvinculado da turma com sucesso."));
    }
}
