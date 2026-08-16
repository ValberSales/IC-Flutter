package br.com.alfabetizalibras.security;

import br.com.alfabetizalibras.repository.UsuarioRepository;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    private final UsuarioRepository usuarioRepository;

    public SecurityConfig(JwtAuthenticationFilter jwtAuthenticationFilter, UsuarioRepository usuarioRepository) {
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
        this.usuarioRepository = usuarioRepository;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public UserDetailsService userDetailsService() {
        return username -> usuarioRepository.findByUsername(username)
                .map(u -> new User(
                        u.getUsername(),
                        u.getPassword() != null ? u.getPassword() : "",
                        List.of(
                            new SimpleGrantedAuthority("ROLE_" + (u.getRole() != null ? u.getRole().toUpperCase() : "USER")),
                            new SimpleGrantedAuthority(u.getRole() != null ? u.getRole().toUpperCase() : "USER")
                        )
                ))
                .orElseThrow(() -> new UsernameNotFoundException("Usuário não encontrado: " + username));
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(AbstractHttpConfigurer::disable)
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                // Rotas Públicas
                .requestMatchers("/api/auth/**", "/api/files/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/atividades/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/turmas/aluno/**").permitAll()
                .requestMatchers(HttpMethod.POST, "/api/turmas/entrar").permitAll()
                .requestMatchers("/api/pontuacoes/**").permitAll()
                
                // Rotas de Usuário Autenticado (troca de senha própria e atualização de perfil)
                .requestMatchers(HttpMethod.POST, "/api/usuarios/change-password").authenticated()
                .requestMatchers(HttpMethod.PUT, "/api/usuarios/**").authenticated()

                // Rotas Protegidas de Gestão (Admin / Professor)
                .requestMatchers("/api/relatorios/**").hasAnyAuthority("ROLE_ADMIN", "ROLE_PROFESSOR", "ADMIN", "PROFESSOR")
                .requestMatchers("/api/turmas/**").hasAnyAuthority("ROLE_ADMIN", "ROLE_PROFESSOR", "ADMIN", "PROFESSOR")
                .requestMatchers("/api/usuarios/**").hasAnyAuthority("ROLE_ADMIN", "ROLE_PROFESSOR", "ADMIN", "PROFESSOR")
                .requestMatchers(HttpMethod.POST, "/api/atividades/**").hasAnyAuthority("ROLE_ADMIN", "ROLE_PROFESSOR", "ADMIN", "PROFESSOR")
                .requestMatchers(HttpMethod.PUT, "/api/atividades/**").hasAnyAuthority("ROLE_ADMIN", "ROLE_PROFESSOR", "ADMIN", "PROFESSOR")
                .requestMatchers(HttpMethod.DELETE, "/api/atividades/**").hasAnyAuthority("ROLE_ADMIN", "ROLE_PROFESSOR", "ADMIN", "PROFESSOR")

                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(List.of("*"));
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setAllowCredentials(true);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
