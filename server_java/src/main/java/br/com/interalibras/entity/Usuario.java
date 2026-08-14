package br.com.interalibras.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "usuarios")
public class Usuario {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nome;

    @Column(unique = true, nullable = true)
    private String email;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(unique = true, nullable = true)
    private String codigoIdentificador;

    @Column(nullable = false)
    private String password;

    private String avatar = "assets/avatar/avatar_1.jpg";

    private String role = "USER";

    private Boolean mustChangePassword = false;

    private LocalDateTime createdAt = LocalDateTime.now();

    public Usuario() {}

    public Usuario(Long id, String nome, String email, String username, String password) {
        this.id = id;
        this.nome = nome;
        this.email = email;
        this.username = username;
        this.password = password;
        this.avatar = "assets/avatar/avatar_1.jpg";
        this.role = "USER";
        this.mustChangePassword = false;
    }

    public Usuario(Long id, String nome, String email, String username, String codigoIdentificador, String password, String avatar, String role) {
        this.id = id;
        this.nome = nome;
        this.email = email;
        this.username = username;
        this.codigoIdentificador = codigoIdentificador;
        this.password = password;
        this.avatar = avatar != null ? avatar : "assets/avatar/avatar_1.jpg";
        this.role = role != null ? role : "USER";
        this.mustChangePassword = false;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getCodigoIdentificador() { return codigoIdentificador; }
    public void setCodigoIdentificador(String codigoIdentificador) { this.codigoIdentificador = codigoIdentificador; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getAvatar() { return avatar; }
    public void setAvatar(String avatar) { this.avatar = avatar; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public Boolean getMustChangePassword() { return mustChangePassword != null ? mustChangePassword : false; }
    public void setMustChangePassword(Boolean mustChangePassword) { this.mustChangePassword = mustChangePassword; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
