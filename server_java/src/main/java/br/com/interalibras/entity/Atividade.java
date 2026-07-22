package br.com.interalibras.entity;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "atividades")
public class Atividade {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String titulo;
    private String tipoJogo; // 'JOGO_ADIVINHACAO' | 'JOGO_PALAVRAS'
    private boolean ativo = true;
    private boolean rascunho = false;
    private String dificuldade = "FACIL";
    private String criadoPor;

    @OneToMany(mappedBy = "atividade", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    @JsonManagedReference
    private List<ItemAtividade> itens = new ArrayList<>();

    private LocalDateTime createdAt = LocalDateTime.now();

    public Atividade() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getTipoJogo() { return tipoJogo; }
    public void setTipoJogo(String tipoJogo) { this.tipoJogo = tipoJogo; }

    public boolean isAtivo() { return ativo; }
    public void setAtivo(boolean ativo) { this.ativo = ativo; }

    public boolean isRascunho() { return rascunho; }
    public void setRascunho(boolean rascunho) { this.rascunho = rascunho; }

    public String getDificuldade() { return dificuldade; }
    public void setDificuldade(String dificuldade) { this.dificuldade = dificuldade; }

    public String getCriadoPor() { return criadoPor; }
    public void setCriadoPor(String criadoPor) { this.criadoPor = criadoPor; }

    public List<ItemAtividade> getItens() { return itens; }
    public void setItens(List<ItemAtividade> itens) { this.itens = itens; }

    public void addItem(ItemAtividade item) {
        itens.add(item);
        item.setAtividade(this);
    }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
