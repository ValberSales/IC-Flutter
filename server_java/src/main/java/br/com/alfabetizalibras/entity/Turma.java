package br.com.alfabetizalibras.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "turmas")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Turma {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nome;

    private String descricao;

    @Column(unique = true, nullable = false)
    private String codigo;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "usuario_id")
    private Usuario usuario;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "turmas_alunos",
        joinColumns = @JoinColumn(name = "turma_id"),
        inverseJoinColumns = @JoinColumn(name = "usuario_id")
    )
    private Set<Usuario> alunos = new HashSet<>();

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "turmas_atividades",
        joinColumns = @JoinColumn(name = "turma_id"),
        inverseJoinColumns = @JoinColumn(name = "atividade_id")
    )
    private Set<Atividade> atividades = new HashSet<>();

    private LocalDateTime createdAt = LocalDateTime.now();

    public Turma() {}

    public Turma(Long id, String nome, String descricao, String codigo, Usuario usuario) {
        this.id = id;
        this.nome = nome;
        this.descricao = descricao;
        this.codigo = codigo;
        this.usuario = usuario;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }

    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }

    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }

    public Usuario getUsuario() { return usuario; }
    public void setUsuario(Usuario usuario) { this.usuario = usuario; }

    public Set<Usuario> getAlunos() { return alunos; }
    public void setAlunos(Set<Usuario> alunos) { this.alunos = alunos; }

    public Set<Atividade> getAtividades() { return atividades; }
    public void setAtividades(Set<Atividade> atividades) { this.atividades = atividades; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public void addAluno(Usuario aluno) {
        if (this.alunos == null) this.alunos = new HashSet<>();
        this.alunos.add(aluno);
    }

    public void removeAluno(Usuario aluno) {
        if (this.alunos != null) {
            this.alunos.remove(aluno);
        }
    }

    public void addAtividade(Atividade atividade) {
        if (this.atividades == null) this.atividades = new HashSet<>();
        this.atividades.add(atividade);
    }

    public void removeAtividade(Atividade atividade) {
        if (this.atividades != null) {
            this.atividades.remove(atividade);
        }
    }
}
