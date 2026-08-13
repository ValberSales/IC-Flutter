package br.com.interalibras.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

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

    @Transient
    @JsonProperty("opcoes")
    private List<String> opcoes;

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

    @JsonProperty("opcoes")
    public List<String> getOpcoes() {
        if (opcoes == null && opcoesJson != null && !opcoesJson.trim().isEmpty()) {
            try {
                ObjectMapper mapper = new ObjectMapper();
                opcoes = mapper.readValue(opcoesJson, new com.fasterxml.jackson.core.type.TypeReference<List<String>>(){});
            } catch (Exception e) {
                opcoes = new ArrayList<>();
            }
        }
        return opcoes != null ? opcoes : new ArrayList<>();
    }

    @JsonProperty("opcoes")
    public void setOpcoes(List<String> opcoes) {
        this.opcoes = opcoes;
        if (opcoes != null) {
            try {
                ObjectMapper mapper = new ObjectMapper();
                this.opcoesJson = mapper.writeValueAsString(opcoes);
            } catch (Exception e) {
                this.opcoesJson = "[]";
            }
        }
    }

    @PrePersist
    @PreUpdate
    public void syncOpcoesJson() {
        if (opcoes != null) {
            try {
                ObjectMapper mapper = new ObjectMapper();
                this.opcoesJson = mapper.writeValueAsString(opcoes);
            } catch (Exception e) {
                // ignore
            }
        }
    }

    public Atividade getAtividade() { return atividade; }
    public void setAtividade(Atividade atividade) { this.atividade = atividade; }
}
