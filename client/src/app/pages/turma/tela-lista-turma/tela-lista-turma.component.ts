import { Component, EventEmitter, OnInit, Output } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { Turma } from 'src/app/model/Turma';
import { TurmaService } from 'src/app/service/turma.service';
import { ETelaAdminAtiva } from '../../usuario/pagina-inicial-usuario/pagina-inicial-usuario.component';
import { ConfirmationService, MessageService } from 'primeng/api';
import { UtilService } from 'src/app/service/util.service';

@Component({
  selector: 'app-tela-lista-turma',
  templateUrl: './tela-lista-turma.component.html',
  styleUrl: './tela-lista-turma.component.scss',
})
export class TelaListaTurmaComponent implements OnInit {
  @Output()
  abrirEdicao: EventEmitter<any> = new EventEmitter<any>();

  turmas: Turma[] = [];

  constructor(
    public service: TurmaService,
    public confirm: ConfirmationService,
    public mensagem: MessageService
  ) {}

  async ngOnInit() {
    const user = UtilService.getUsuario();
    this.turmas = await firstValueFrom(this.service.getAllRequest([{usuario: {id: user.id}}], 0, 999));
  }

  editar(turma: Turma) {
    this.abrirEdicao.emit({
      tipo: ETelaAdminAtiva.SALA_CADASTRO,
      obj: turma,
    });
  }

  excluir(turma: Turma) {
    this.confirm.confirm({
      message: 'Tem certeza que deseja excluir esse registro?',
      header: 'Confirme',
      icon: 'pi pi-exclamation-triangle',
      rejectLabel: 'Não',
      acceptLabel: 'Sim',
      rejectButtonStyleClass: 'confirm-button-danger',
      accept: () => {
        this.service.delete(turma).subscribe({
          next: (value) => {
            this.turmas = this.turmas.filter((p) => p.id != turma.id);
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

  gerarCodigo(turma: Turma) {
    this.service.geraNovoCodigo(turma.id).subscribe({
      next: (value) => {
        if(value?.code) {
          turma.codigo = value.code;
          turma.dataGeracaoCodigo = new Date();
        }
      },
      error: (err) => {
        this.mensagem.add({
          severity: 'error',
          summary: 'Erro',
          detail: err?.data
        })
      },
    })
  }
}
