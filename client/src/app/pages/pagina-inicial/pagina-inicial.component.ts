import { Component, OnInit } from '@angular/core';
import { Router, RouterModule } from '@angular/router';
import { ConfirmationService, MessageService } from 'primeng/api';
import { DialogModule } from 'primeng/dialog';
import { DialogService } from 'primeng/dynamicdialog';
import { firstValueFrom } from 'rxjs';
import { MenuAvatarComponent } from 'src/app/components/menu-avatar/menu-avatar.component';
import { PainelPontuacaoComponent } from 'src/app/components/painel-pontuacao/painel-pontuacao.component';
import { Personagem } from 'src/app/model/Personagem';
import { PersonagemService } from 'src/app/service/personagem.service';
import { UtilService } from 'src/app/service/util.service';
import { EEntidades, IndexDbService } from 'src/app/util/indexdb.service';

export enum ETelaInicial {
  PADRAO = 'PADRAO',
  NOVO_PERSONAGEM = 'NOVO_PERSONAGEM',
  SELECAO_PERSONAGEM = 'SELECAO_PERSONAGEM',
}

@Component({
  selector: 'app-pagina-inicial',
  templateUrl: './pagina-inicial.component.html',
  styleUrl: './pagina-inicial.component.scss',
})
export class PaginaInicialComponent implements OnInit {
  personagem: Personagem = new Personagem();
  personagens: Personagem[] = [];
  isMoving: boolean = false;

  private _etapa: ETelaInicial = ETelaInicial.PADRAO;

  get etapa(): ETelaInicial {
    return this._etapa;
  }

  set etapa(value: ETelaInicial) {
    this._etapa = value;
    this.onEtapaChange(value);
  }

  get avatar() {
    return this.personagem?.avatar || 'assets/avatar/avatar_1.jpg';
  }

  get personagemAtivo() {
    return UtilService.getPersonagem();
  }

  constructor(
    public personagemService: PersonagemService,
    public router: Router,
    public dialog: DialogService,
    public confirm: ConfirmationService,
    public message: MessageService
  ) {}

  ngOnInit(): void {}

  private onEtapaChange(etapa: ETelaInicial): void {
    this.isMoving = true;
    setTimeout(() => {
      this.isMoving = false;
    }, 1000);
  }

  play() {
    this.router.navigateByUrl('/alfabeto-manual');
  }

  novoPersonagem() {
    this.personagem = new Personagem();
    this.etapa = ETelaInicial.NOVO_PERSONAGEM;
  }

  editarPersonagem() {
    this.personagem = this.personagemAtivo;
    this.etapa = ETelaInicial.NOVO_PERSONAGEM;
  }

  async savePersonagem() {
    if (this.personagem?.nome) {
      this.personagem = await IndexDbService.salvaPersonagem(this.personagem); //await this.personagemService.savePromise(this.personagem);
      UtilService.setPersonagem(this.personagem);
      this.personagem = new Personagem();
      this.etapa = ETelaInicial.PADRAO;
    }
  }

  async selecionarPersonagem() {
    const db = IndexDbService.getDb();
    await db.open();
    this.personagens = await db.table(EEntidades.PERSONAGEM).toArray();
    if (this.personagens.length)
      this.personagens = this.personagens.sort((a, b) =>
        a.nome.localeCompare(b.nome)
      );
    db.close();
    this.etapa = ETelaInicial.SELECAO_PERSONAGEM;
  }

  selectPersonagem(p: Personagem) {
    UtilService.setPersonagem(p);
    this.etapa = ETelaInicial.PADRAO;
  }

  mudarAvatar() {
    this.dialog
      .open(MenuAvatarComponent, {
        header: 'Selecione um Avatar',
      })
      .onClose.subscribe({
        next: (value) => {
          if (value) {
            this.personagem.avatar = value;
          }
        },
      });
  }

  consultarPontuacao() {
    this.dialog
      .open(PainelPontuacaoComponent, {
        header: `Histórico de pontuação: ${this.personagem?.nome}`,
        width: '800px',
        data: {
          personagem: this.personagem,
        },
      })
      .onClose.subscribe({
        next: (value) => {},
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
      accept: async () => {
        const db = IndexDbService.getDb();
        try {
          await db.open();
          await db.table(EEntidades.PERSONAGEM).delete(personagem.id);
          this.personagens = this.personagens.filter((p) => p.id != personagem.id);
          this.message.add({
            severity: 'success',
            summary: 'Sucesso!',
            detail: 'Personagem removido com sucesso!',
          });
        } catch (error) {
          console.log(error);
          
          this.message.add({
            severity: 'error',
            summary: 'Erro',
            detail: 'Ocorreu um erro ao remover o personagem!',
          });
        }
        db.close();
      },
    });
  }
}
