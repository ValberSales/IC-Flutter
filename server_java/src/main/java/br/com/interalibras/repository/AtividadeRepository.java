package br.com.interalibras.repository;

import br.com.interalibras.entity.Atividade;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface AtividadeRepository extends JpaRepository<Atividade, Long> {
    List<Atividade> findByAtivoTrueAndRascunhoFalse();
    Optional<Atividade> findByRascunhoTrue();
    List<Atividade> findByTipoJogo(String tipoJogo);
}
