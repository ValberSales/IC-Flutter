import { Component, OnInit } from '@angular/core';
import { MessageService } from 'primeng/api';
import letrasData from '../../data/alfabeto-manual.json';
import letrasDataProf from '../../data/alfabeto-manual-profe.json';
import { ETipoFeedback } from 'src/app/model/enum/EFeedback';
import { Letra } from 'src/app/model/interface/ILetra';
import { UtilService } from 'src/app/service/util.service';

@Component({
  selector: 'app-jogo-memoria',
  templateUrl: './jogo-memoria.component.html',
  styleUrl: './jogo-memoria.component.scss',
})
export class JogoMemoriaComponent implements OnInit {
  letras: Letra[] = [];
  cartas: Carta[] = [];
  primeiraCarta: Carta | null = null;
  segundaCarta: Carta | null = null;
  bloqueado: boolean = false;

  feedback: ETipoFeedback = ETipoFeedback.VAZIO;

  aguardandoInicio: boolean = false;
  endGame: boolean = false;

  acertos: number = 0;
  erros: number = 0;

  constructor(public msg: MessageService) {}

  get isFacil() {
    return UtilService.getPersonagem().dificuldade == 'FACIL';
  }

  get isMedio() {
    return UtilService.getPersonagem().dificuldade == 'MEDIO';
  }

  get width() {
    return this.isFacil ? '600px' : this.isMedio ? '600px' : '700px'
  }

  ngOnInit(): void {
    this.novoJogo();
  }

  novoJogo() {
    this.endGame = false;
    this.letras = this.sorteador();
    this.cartas = this.criarCartas();

    setTimeout(() => {
      this.cartas.forEach((c) => (c.revelado = false));
    }, 5000);
  }

  sorteador(): Letra[] {
    let letrasDataAtual;
    if(localStorage.getItem("LETRAS_ANTIGAS")) {
      letrasDataAtual = letrasData;
    } else letrasDataAtual = letrasDataProf;

    const shuffled = [...letrasDataAtual];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    const quantidade = this.isFacil ? 6 : this.isMedio ? 8 : 10;
    return shuffled.slice(0, quantidade);
  }

  criarCartas(): Carta[] {
    const cartasLetra = [...this.letras].map((letra) => ({
      ...letra,
      revelado: true,
      figura: false,
    }));
    const cartasImagem = [...this.letras].map((letra) => ({
      ...letra,
      revelado: true,
      figura: true,
    }));
    return this.embaralhar([...cartasLetra, ...cartasImagem]);
  }

  embaralhar(cartas: Carta[]): Carta[] {
    for (let i = cartas.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [cartas[i], cartas[j]] = [cartas[j], cartas[i]];
    }
    return cartas;
  }

  revelarCarta(carta: Carta): void {
    if (
      this.bloqueado ||
      carta.revelado ||
      (this.primeiraCarta && this.segundaCarta)
    )
      return;

    carta.revelado = true;

    if (!this.primeiraCarta) {
      this.primeiraCarta = carta;
      this.clearFeedback();
    } else if (!this.segundaCarta) {
      this.segundaCarta = carta;
      this.verificarPar();
    }
  }

  verificarPar(): void {
    if (this.primeiraCarta && this.segundaCarta) {
      if (this.primeiraCarta.letra == this.segundaCarta.letra) {
        this.feedback = ETipoFeedback.ACERTO;
        this.acertos++;
        this.resetarCartas();
        if (this.cartas.every((c) => c.revelado)) {
          this.endGame = true;
        }
      } else {
        this.feedback = ETipoFeedback.ERRO;
        this.erros++;
        this.bloqueado = true;
        setTimeout(() => {
          if (this.primeiraCarta) this.primeiraCarta.revelado = false;
          if (this.segundaCarta) this.segundaCarta.revelado = false;
          this.resetarCartas();
        }, 1000);
      }
    }
  }

  resetarCartas(): void {
    this.primeiraCarta = null;
    this.segundaCarta = null;
    this.bloqueado = false;
  }

  clearFeedback() {
    this.feedback = ETipoFeedback.VAZIO;
  }
}

export interface Carta extends Letra {
  figura: boolean;
  revelado: boolean;
}
