package br.com.interalibras.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "pontuacoes")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Pontuacao {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String atividade;
    private String tema;
    private int acertos;
    private int erros;
    private String dificuldade;
    private Boolean concluido = false;

    @Column(columnDefinition = "TEXT")
    private String progressoItens;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "usuario_id")
    @JsonIgnoreProperties({"password", "turmas", "hibernateLazyInitializer", "handler"})
    private Usuario usuario;

    private LocalDateTime createdAt = LocalDateTime.now();

    public Pontuacao() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getAtividade() { return atividade; }
    public void setAtividade(String atividade) { this.atividade = atividade; }

    public String getTema() { return tema; }
    public void setTema(String tema) { this.tema = tema; }

    public int getAcertos() { return acertos; }
    public void setAcertos(int acertos) { this.acertos = acertos; }

    public int getErros() { return erros; }
    public void setErros(int erros) { this.erros = erros; }

    public String getDificuldade() { return dificuldade; }
    public void setDificuldade(String dificuldade) { this.dificuldade = dificuldade; }

    public Boolean isConcluido() { return concluido != null && concluido; }
    public Boolean getConcluido() { return concluido; }
    public void setConcluido(Boolean concluido) { this.concluido = concluido; }

    public Usuario getUsuario() { return usuario; }
    public void setUsuario(Usuario usuario) { this.usuario = usuario; }

    public String getProgressoItens() { return progressoItens; }
    public void setProgressoItens(String progressoItens) { this.progressoItens = progressoItens; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
