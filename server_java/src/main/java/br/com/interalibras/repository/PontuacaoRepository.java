package br.com.interalibras.repository;

import br.com.interalibras.entity.Pontuacao;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface PontuacaoRepository extends JpaRepository<Pontuacao, Long> {
    List<Pontuacao> findByPersonagemId(Long personagemId);
}
