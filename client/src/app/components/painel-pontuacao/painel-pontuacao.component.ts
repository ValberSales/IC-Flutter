import { CommonModule } from '@angular/common';
import { Component, Input, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { TabViewModule } from 'primeng/tabview';
import { EAtividade, Pontuacao } from 'src/app/model/Pontuacao';
import { TabelaPontuacaoComponent } from './tabela-pontuacao/tabela-pontuacao.component';
import { Personagem } from 'src/app/model/Personagem';
import { DynamicDialogConfig, DynamicDialogRef } from 'primeng/dynamicdialog';
import { ELocalStorageKeys } from 'src/app/service/util.service';
import { IndexDbService } from 'src/app/util/indexdb.service';
import { PontuacaoService } from 'src/app/service/pontuacao.service';
import { firstValueFrom } from 'rxjs';

@Component({
  selector: 'app-painel-pontuacao',
  standalone: true,
  imports: [CommonModule, FormsModule, TabViewModule, TabelaPontuacaoComponent],
  templateUrl: './painel-pontuacao.component.html',
  styleUrl: './painel-pontuacao.component.scss',
})
export class PainelPontuacaoComponent implements OnInit {
  personagem: Personagem;
  pontuacao: Pontuacao[] = [];

  constructor(
    private modal: DynamicDialogRef,
    private config: DynamicDialogConfig,
    private pontuacaoService: PontuacaoService
  ) {}

  async ngOnInit() {
    this.personagem = this.config?.data?.personagem;
    if (!this.personagem?.id) {
      this.personagem = JSON.parse(
        localStorage.getItem(ELocalStorageKeys.PERSONAGEM)
      );
    }
    if (!this.personagem) this.modal.close();

    if (this.personagem.id < 0) {
      this.pontuacao = await IndexDbService.buscaPontuacaoPersonagem(
        this.personagem
      );
    } else {
      this.pontuacao = await firstValueFrom(
        this.pontuacaoService.buscaPeloIdPersonagem(this.personagem.id)
      );
    }

    console.log(this.pontuacao);
  }

  getPontuacao(atividade: string) {
    return this.pontuacao.filter((p) => p.atividade == atividade);
  }
}
