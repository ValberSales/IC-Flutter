package br.com.interalibras.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;

@Entity
@Table(name = "itens_atividade")
public class ItemAtividade {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String descricao;
    private String imagem;

    @Column(columnDefinition = "TEXT")
    private String opcoesJson; // JSON array string e.g. ["Opção 1", "Opção 2"]

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "atividade_id")
    @JsonBackReference
    private Atividade atividade;

    public ItemAtividade() {}

    public ItemAtividade(String descricao, String imagem, String opcoesJson) {
        this.descricao = descricao;
        this.imagem = imagem;
        this.opcoesJson = opcoesJson;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }

    public String getImagem() { return imagem; }
    public void setImagem(String imagem) { this.imagem = imagem; }

    public String getOpcoesJson() { return opcoesJson; }
    public void setOpcoesJson(String opcoesJson) { this.opcoesJson = opcoesJson; }

    public Atividade getAtividade() { return atividade; }
    public void setAtividade(Atividade atividade) { this.atividade = atividade; }
}
