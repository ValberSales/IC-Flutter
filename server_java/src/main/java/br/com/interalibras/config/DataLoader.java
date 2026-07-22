package br.com.interalibras.config;

import br.com.interalibras.entity.Atividade;
import br.com.interalibras.entity.ItemAtividade;
import br.com.interalibras.entity.Usuario;
import br.com.interalibras.repository.AtividadeRepository;
import br.com.interalibras.repository.UsuarioRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataLoader implements CommandLineRunner {

    private final AtividadeRepository atividadeRepository;
    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;

    public DataLoader(AtividadeRepository atividadeRepository, UsuarioRepository usuarioRepository, PasswordEncoder passwordEncoder) {
        this.atividadeRepository = atividadeRepository;
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        // 1. Criar usuário padrão admin se não existir
        if (!usuarioRepository.existsByUsername("admin")) {
            Usuario admin = new Usuario(null, "Professor Admin", "admin@interalibras.com.br", "admin", passwordEncoder.encode("123456"));
            usuarioRepository.save(admin);
        }

        // 2. Semear Atividades Padrão se o repositório de atividades estiver vazio
        if (atividadeRepository.count() == 0) {
            // Tema Adivinhação: Animais da Natureza
            Atividade temaAnimais = new Atividade();
            temaAnimais.setTitulo("Animais da Natureza");
            temaAnimais.setTipoJogo("JOGO_ADIVINHACAO");
            temaAnimais.setDificuldade("FACIL");
            temaAnimais.setAtivo(true);
            temaAnimais.setCriadoPor("Sistema InteraLibras");

            temaAnimais.addItem(newItem("Gato", "assets/animais/gato.png", "[]"));
            temaAnimais.addItem(newItem("Cachorro", "assets/animais/cachorro.png", "[]"));
            temaAnimais.addItem(newItem("Leão", "assets/animais/leao.png", "[]"));
            temaAnimais.addItem(newItem("Vaca", "assets/animais/vaca.png", "[]"));
            temaAnimais.addItem(newItem("Macaco", "assets/animais/macaco.png", "[]"));
            temaAnimais.addItem(newItem("Elefante", "assets/animais/elefante.png", "[]"));

            atividadeRepository.save(temaAnimais);

            // Tema Jogo de Palavras: Membros da Família
            Atividade temaFamilia = new Atividade();
            temaFamilia.setTitulo("Membros da Família");
            temaFamilia.setTipoJogo("JOGO_PALAVRAS");
            temaFamilia.setDificuldade("FACIL");
            temaFamilia.setAtivo(true);
            temaFamilia.setCriadoPor("Sistema InteraLibras");

            temaFamilia.addItem(newItem("Mãe", "assets/familia/mae.jpg", "[\"Mãe\", \"Pai\", \"Tia\"]"));
            temaFamilia.addItem(newItem("Pai", "assets/familia/pai.jpg", "[\"Pai\", \"Tio\", \"Avô\"]"));
            temaFamilia.addItem(newItem("Avô", "assets/familia/avo.jpg", "[\"Avô\", \"Irmão\", \"Primo\"]"));
            temaFamilia.addItem(newItem("Irmã", "assets/familia/irma.jpg", "[\"Irmã\", \"Mãe\", \"Tia\"]"));

            atividadeRepository.save(temaFamilia);
        }
    }

    private ItemAtividade newItem(String desc, String img, String opcoesJson) {
        return new ItemAtividade(desc, img, opcoesJson);
    }
}
