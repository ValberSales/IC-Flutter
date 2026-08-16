package br.com.alfabetizalibras.repository;

import br.com.alfabetizalibras.entity.Turma;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;

public interface TurmaRepository extends JpaRepository<Turma, Long> {
    Optional<Turma> findByCodigo(String codigo);
    
    boolean existsByCodigo(String codigo);

    List<Turma> findByUsuarioId(Long usuarioId);

    @Query("SELECT t FROM Turma t JOIN t.alunos a WHERE a.id = :alunoId")
    List<Turma> findByAlunoId(@Param("alunoId") Long alunoId);
}
