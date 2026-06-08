import { Component, EventEmitter, OnInit, Output } from '@angular/core';
import { ConfirmationService, MessageService } from 'primeng/api';
import { firstValueFrom } from 'rxjs';
import { Personagem } from 'src/app/model/Personagem';
import { PersonagemService } from 'src/app/service/personagem.service';
import { ETelaAdminAtiva } from '../../usuario/pagina-inicial-usuario/pagina-inicial-usuario.component';
import { DialogService } from 'primeng/dynamicdialog';
import { PainelPontuacaoComponent } from 'src/app/components/painel-pontuacao/painel-pontuacao.component';
import { UtilService } from 'src/app/service/util.service';

@Component({
  selector: 'app-tela-lista-personagem',
  templateUrl: './tela-lista-personagem.component.html',
  styleUrl: './tela-lista-personagem.component.scss',
})
export class TelaListaPersonagemComponent implements OnInit {
  @Output()
  abrirEdicao: EventEmitter<any> = new EventEmitter<any>();

  personagens: Personagem[] = [];

  constructor(
    public service: PersonagemService,
    public confirm: ConfirmationService,
    public mensagem: MessageService,
    public dialogService: DialogService
  ) {}

  async ngOnInit() {
    const user = UtilService.getUsuario();
    this.personagens = await firstValueFrom(this.service.getAllRequest([{usuario: {id: user.id}}], 0, 999));
  }

  editar(personagem: Personagem) {
    this.abrirEdicao.emit({
      tipo: ETelaAdminAtiva.PERSONAGEM_CADASTRO,
      obj: personagem,
    });
  }

  excluir(personagem: Personagem) {
    this.confirm.confirm({
      message: 'Tem certeza que deseja excluir esse registro?',
      header: 'Confirme',
      icon: 'pi pi-exclamation-triangle',
      rejectLabel: 'Não',
      acceptLabel: 'Sim',
      rejectButtonStyleClass: 'confirm-button-danger',
      accept: () => {
        this.service.delete(personagem).subscribe({
          next: (value) => {
            this.personagens = this.personagens.filter(
              (p) => p.id != personagem.id
            );
            this.mensagem.add({
              severity: 'success',
              summary: 'Sucesso',
              detail: 'Registro apagado com sucesso!',
            });
          },
          error: (err) => {
            this.mensagem.add({
              severity: 'error',
              summary: 'Erro',
              detail: 'Ocorreu um erro ao apagar o registro!',
            });
          },
        });
      },
    });
  }

  consultarPontuacao(personagem: Personagem) {
    this.dialogService
      .open(PainelPontuacaoComponent, {
        header: `Histórico de pontuação: ${personagem?.nome}`,
        width: '800px',
        data: {
          personagem: personagem,
        },
      })
      .onClose.subscribe({
        next: (value) => {

        },
      });
  }
}
