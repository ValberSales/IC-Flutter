import { Component, EventEmitter, OnInit, Output } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { Palavra } from 'src/app/model/Palavra';
import { PalavraService } from 'src/app/service/palavra.service';
import { ETelaAdminAtiva } from '../../usuario/pagina-inicial-usuario/pagina-inicial-usuario.component';
import { ConfirmationService, MessageService } from 'primeng/api';
import { UtilService } from 'src/app/service/util.service';

@Component({
  selector: 'app-tela-lista-palavra',
  templateUrl: './tela-lista-palavra.component.html',
  styleUrl: './tela-lista-palavra.component.scss',
})
export class TelaListaPalavraComponent implements OnInit {
  @Output()
  abrirEdicao: EventEmitter<any> = new EventEmitter<any>();

  palavras: Palavra[] = [];

  constructor(
    public service: PalavraService,
    public confirm: ConfirmationService,
    public mensagem: MessageService
  ) {}

  async ngOnInit() {
    const user = UtilService.getUsuario();
    this.palavras = await firstValueFrom(this.service.getAllRequest([{usuario: {id: user.id}}], 0, 999));
  }

  getLabelTipoJogo(tipo: string) {
    if(tipo == 'JOGO_ADIVINHACAO') return "Jogo Adivinhação";
    return "Jogo Palavras";
  }

  editar(palavra: Palavra) {
    this.abrirEdicao.emit({
      tipo: ETelaAdminAtiva.PALAVRA_CADASTRO,
      obj: palavra,
    });
  }

  excluir(palavra: Palavra) {
    this.confirm.confirm({
      message: 'Tem certeza que deseja excluir esse registro?',
      header: 'Confirme',
      icon: 'pi pi-exclamation-triangle',
      rejectLabel: 'Não',
      acceptLabel: 'Sim',
      rejectButtonStyleClass: 'confirm-button-danger',
      accept: () => {
        this.service.delete(palavra).subscribe({
          next: (value) => {
            this.palavras = this.palavras.filter((p) => p.id != palavra.id);
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
}
