package br.com.alfabetizalibras.repository;

import br.com.alfabetizalibras.entity.Atividade;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface AtividadeRepository extends JpaRepository<Atividade, Long> {
    List<Atividade> findAllByOrderByTituloAsc();
    List<Atividade> findByAtivoTrueAndRascunhoFalseOrderByTituloAsc();
    Optional<Atividade> findByRascunhoTrue();
    List<Atividade> findByTipoJogo(String tipoJogo);
}
