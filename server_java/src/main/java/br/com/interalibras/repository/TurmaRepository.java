package br.com.interalibras.repository;

import br.com.interalibras.entity.Turma;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface TurmaRepository extends JpaRepository<Turma, Long> {
    Optional<Turma> findByCodigo(String codigo);
}
