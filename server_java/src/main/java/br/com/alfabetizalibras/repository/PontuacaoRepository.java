package br.com.alfabetizalibras.repository;

import br.com.alfabetizalibras.entity.Pontuacao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface PontuacaoRepository extends JpaRepository<Pontuacao, Long> {
    List<Pontuacao> findByUsuarioId(Long usuarioId);

    List<Pontuacao> findByUsuarioIdIn(List<Long> usuarioIds);

    List<Pontuacao> findByUsuarioIdOrderByCreatedAtDesc(Long usuarioId);

    @Query("SELECT p FROM Pontuacao p WHERE p.usuario.id IN :alunoIds ORDER BY p.createdAt DESC")
    List<Pontuacao> findByAlunoIds(@Param("alunoIds") List<Long> alunoIds);
}
