package br.com.interalibras.repository;

import br.com.interalibras.entity.Personagem;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface PersonagemRepository extends JpaRepository<Personagem, Long> {
    List<Personagem> findByUsuarioId(Long usuarioId);
}
