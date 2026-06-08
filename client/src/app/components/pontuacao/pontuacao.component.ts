import { Component, Input, OnDestroy, OnInit } from '@angular/core';
import { EAtividade, Pontuacao } from 'src/app/model/Pontuacao';
import { PontuacaoService } from 'src/app/service/pontuacao.service';

@Component({
  selector: 'app-pontuacao',
  templateUrl: './pontuacao.component.html',
  styleUrl: './pontuacao.component.scss',
})
export class PontuacaoComponent implements OnDestroy {
  @Input() acertos: number = 0;
  @Input() erros: number = 0;
  @Input() atividade: EAtividade;

  get somatoria() {
    const total = this.acertos + this.erros;
    const media = total > 0 ? (this.acertos / total) * 10 : 0;
    return media;
  }

  constructor(private service: PontuacaoService) {}

  pontuacao: Pontuacao = new Pontuacao();

  ngOnDestroy(): void {
    this.pontuacao.acertos = this.acertos;
    this.pontuacao.erros = this.erros;
    this.pontuacao.atividade = this.atividade;
    this.service
      .trataPontuacao(this.pontuacao)
      .then(() => {})
      .catch((err) => {});
  }
}
