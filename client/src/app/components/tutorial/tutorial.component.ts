import { CommonModule } from '@angular/common';
import { Component, Input, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ButtonModule } from 'primeng/button';
import { EAtividade } from 'src/app/model/Pontuacao';

@Component({
  selector: 'app-tutorial',
  standalone: true,
  imports: [CommonModule, FormsModule, ButtonModule],
  templateUrl: './tutorial.component.html',
  styleUrl: './tutorial.component.scss',
})
export class TutorialComponent implements OnInit {
  @Input()
  atividade: EAtividade;

  visible: boolean = false;
  tutorial: string;

  ngOnInit(): void {
    switch (this.atividade) {
      case EAtividade.JOGO_ADIVINHACAO:
        this.tutorial = 'assets/tutorial/tutorial_jogo_adivinhacao.gif';
        break;
      case EAtividade.JOGO_MEMORIA:
        this.tutorial = 'assets/tutorial/tutorial_jogo_memoria.gif';
        break;
      case EAtividade.JOGO_ALFABETO:
        this.tutorial = 'assets/tutorial/tutorial_jogo_letras.gif';
        break;
      case EAtividade.JOGO_PALAVRAS:
        this.tutorial = 'assets/tutorial/tutorial_jogo_palavras.gif';
        break;
    }
  }
}
