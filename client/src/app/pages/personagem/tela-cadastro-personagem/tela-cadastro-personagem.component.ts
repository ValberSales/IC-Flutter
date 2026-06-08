import { Component, Input, OnInit } from '@angular/core';
import { MessageService } from 'primeng/api';
import { DialogService } from 'primeng/dynamicdialog';
import { MenuAvatarComponent } from 'src/app/components/menu-avatar/menu-avatar.component';
import { Personagem } from 'src/app/model/Personagem';
import { PersonagemService } from 'src/app/service/personagem.service';

@Component({
  selector: 'app-tela-cadastro-personagem',
  templateUrl: './tela-cadastro-personagem.component.html',
  styleUrl: './tela-cadastro-personagem.component.scss',
})
export class TelaCadastroPersonagemComponent implements OnInit {
  @Input()
  personagem: Personagem = new Personagem();

  constructor(
    public service: PersonagemService,
    public message: MessageService,
    public dialog: DialogService
  ) {}

  ngOnInit(): void {
    if (!this.personagem) this.personagem = new Personagem();
  }

  async save() {
    if (!this.personagem?.nome) {
      this.message.add({
        severity: 'info',
        summary: 'Aviso',
        detail: 'Informe o nome do personagem',
      });
      return;
    }

    this.service
      .savePromise(this.personagem)
      .then((ret) => {
        this.message.add({
          severity: 'success',
          summary: 'Sucesso',
          detail: 'Personagem salvo com sucesso!',
        });
        this.personagem = new Personagem();
      })
      .catch((err) => {
        console.error(err);
        this.message.add({
          severity: 'erro',
          summary: 'Erro',
          detail: 'Ocorreu um erro ao salvar o personagem!',
        });
      });
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
}
