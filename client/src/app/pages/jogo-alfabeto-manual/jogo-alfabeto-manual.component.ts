import {
  ChangeDetectorRef,
  Component,
  OnInit,
} from '@angular/core';
import { MessageService } from 'primeng/api';
import letrasData from '../../data/alfabeto-manual.json';
import letrasDataProf from '../../data/alfabeto-manual-profe.json';
import { ETipoFeedback } from 'src/app/model/enum/EFeedback';
import { Letra } from 'src/app/model/interface/ILetra';
import { UtilService } from 'src/app/service/util.service';

class LetraJogoAlfabetoManual {
  letra: Letra;
  pendente: boolean;
}

@Component({
  selector: 'app-jogo-alfabeto-manual',
  templateUrl: './jogo-alfabeto-manual.component.html',
  styleUrl: './jogo-alfabeto-manual.component.scss',
})
export class JogoAlfabetoManualComponent implements OnInit {
  letras: Letra[] = [];
  letraSorteada: Letra | null = null;
  opcoes: LetraJogoAlfabetoManual[] = [];

  feedback: ETipoFeedback = ETipoFeedback.VAZIO;
  acerto: boolean = false;
  animacao: boolean = false;

  acertos: number = 0;
  erros: number = 0;

  constructor(public msg: MessageService, private cdr: ChangeDetectorRef) {}

  get isFacil() {
    return UtilService.getPersonagem().dificuldade == 'FACIL';
  }

  get isMedio() {
    return UtilService.getPersonagem().dificuldade == 'MEDIO';
  }

  ngOnInit(): void {
    // this.letras = letrasData;
    if(localStorage.getItem("LETRAS_ANTIGAS")) {
      this.letras = letrasData;
    } else this.letras = letrasDataProf;
    this.novoJogo();
  }

  novoJogo(): void {
    this.acerto = false;
    this.letraSorteada = this.sortearLetra();
    this.opcoes = this.gerarOpcoes();
    this.inicioAnimacao();
  }

  sortearLetra(): Letra {
    const index = Math.floor(Math.random() * this.letras.length);
    return this.letras[index];
  }

  gerarOpcoes(): LetraJogoAlfabetoManual[] {
    const opcoes = [this.letraSorteada!];
    const restantes = this.letras.filter(
      (letra) => letra !== this.letraSorteada
    );
    const quantidade = this.isFacil ? 3 : this.isMedio ? 5 : 7;
    while (opcoes.length < quantidade) {
      const index = Math.floor(Math.random() * restantes.length);
      opcoes.push(restantes.splice(index, 1)[0]);
    }

    return this.embaralharArray(opcoes);
  }

  embaralharArray(array: Letra[]): LetraJogoAlfabetoManual[] {
    for (let i = array.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [array[i], array[j]] = [array[j], array[i]];
    }
    return array.map((item) => ({ letra: item, pendente: true }));
  }

  verificarResposta(opcao: LetraJogoAlfabetoManual): void {
    if (this.acerto || !opcao.pendente) return;
    if (opcao.letra == this.letraSorteada) {
      this.acerto = true;
      this.acertos++;
      this.feedback = ETipoFeedback.ACERTO;
    } else {
      opcao.pendente = false;
      this.erros++;
      this.feedback = ETipoFeedback.ERRO;
    }
  }

  getAcerto(opcao: Letra) {
    return opcao == this.letraSorteada && this.acerto;
  }

  clearFeedback() {
    this.feedback = ETipoFeedback.VAZIO;
  }

  inicioAnimacao(): void {
    this.animacao = true;

    setTimeout(() => {
      this.animacao = false;
    }, 600);
  }

  fimAnimacao(): void {
    this.animacao = false;
  }
}
