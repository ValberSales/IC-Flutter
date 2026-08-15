package br.com.interalibras.service;

import br.com.interalibras.entity.Atividade;
import br.com.interalibras.repository.AtividadeRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;

/**
 * Serviço responsável pelo ciclo de vida, persistência e status de visibilidade de temas e atividades pedagógicas.
 */
@Service
@Transactional
public class AtividadeService {

    private final AtividadeRepository atividadeRepository;

    public AtividadeService(AtividadeRepository atividadeRepository) {
        this.atividadeRepository = atividadeRepository;
    }

    @Transactional(readOnly = true)
    public List<Atividade> findAll(Boolean apenasAtivas) {
        if (Boolean.TRUE.equals(apenasAtivas)) {
            return atividadeRepository.findByAtivoTrueAndRascunhoFalseOrderByTituloAsc();
        }
        return atividadeRepository.findAllByOrderByTituloAsc();
    }

    public Atividade createOrUpdate(Atividade atividade) {
        if (atividade.getItens() != null) {
            atividade.getItens().forEach(item -> item.setAtividade(atividade));
        }

        if (!atividade.isRascunho()) {
            Optional<Atividade> rascunhoAntigo = atividadeRepository.findByRascunhoTrue();
            rascunhoAntigo.ifPresent(r -> atividadeRepository.deleteById(r.getId()));
        }

        return atividadeRepository.save(atividade);
    }

    public Atividade update(Long id, Atividade atividade) {
        atividade.setId(id);
        if (atividade.getItens() != null) {
            atividade.getItens().forEach(item -> item.setAtividade(atividade));
        }
        return atividadeRepository.save(atividade);
    }

    public Atividade toggleStatus(Long id) {
        Atividade a = atividadeRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Atividade não encontrada com ID " + id));

        a.setAtivo(!a.isAtivo());
        return atividadeRepository.save(a);
    }

    public Atividade togglePublica(Long id, Boolean publica) {
        Atividade a = atividadeRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Atividade não encontrada com ID " + id));

        if (publica != null) {
            a.setPublica(publica);
        } else {
            a.setPublica(!a.isPublica());
        }
        return atividadeRepository.save(a);
    }

    public void delete(Long id) {
        if (!atividadeRepository.existsById(id)) {
            throw new NoSuchElementException("Atividade não encontrada com ID " + id);
        }
        atividadeRepository.deleteById(id);
    }

    @Transactional(readOnly = true)
    public Optional<Atividade> getRascunho() {
        return atividadeRepository.findByRascunhoTrue();
    }
}
