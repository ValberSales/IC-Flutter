package br.com.alfabetizalibras.repository;

import br.com.alfabetizalibras.entity.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    Optional<Usuario> findByUsername(String username);
    Optional<Usuario> findByEmail(String email);
    Optional<Usuario> findByCodigoIdentificador(String codigoIdentificador);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
    boolean existsByCodigoIdentificador(String codigoIdentificador);

    @Query("SELECT u FROM Usuario u WHERE " +
           "LOWER(u.nome) LIKE LOWER(CONCAT('%', :busca, '%')) OR " +
           "LOWER(u.username) LIKE LOWER(CONCAT('%', :busca, '%')) OR " +
           "LOWER(u.codigoIdentificador) LIKE LOWER(CONCAT('%', :busca, '%'))")
    List<Usuario> buscarPorTermo(@Param("busca") String busca);
}
