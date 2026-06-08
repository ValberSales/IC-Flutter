import { CommonModule } from '@angular/common';
import { Component, Input } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { TableModule } from 'primeng/table';
import { Pontuacao } from 'src/app/model/Pontuacao';

@Component({
  selector: 'app-tabela-pontuacao',
  standalone: true,
  imports: [CommonModule, FormsModule, TableModule],
  templateUrl: './tabela-pontuacao.component.html',
  styleUrl: './tabela-pontuacao.component.scss',
})
export class TabelaPontuacaoComponent {
  @Input()
  pontuacao: Pontuacao[] = [];

  getFieldDificuldade(dificuldade: string) {
    switch (dificuldade) {
      case 'FACIL':
        return 'Fácil';
      case 'MEDIO':
        return 'Médio';
      case 'DIFICIL':
        return 'Difícil';
      default:
        return 'Fácil';
    }
  }

  getDate(date: any) {
    return new Date(date);
  }
}
