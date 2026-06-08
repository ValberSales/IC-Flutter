import { Component, OnInit } from '@angular/core';
import letrasData from '../../data/alfabeto-manual.json';
import letrasDataProf from '../../data/alfabeto-manual-profe.json';
import palavraPadraoData from '../../data/animais-padrao.json';
import { MessageService } from 'primeng/api';
import { Letra } from 'src/app/model/interface/ILetra';
import { PalavraService } from 'src/app/service/palavra.service';
import { Palavra } from 'src/app/model/Palavra';
import { ETipoFeedback } from 'src/app/model/enum/EFeedback';
import { UtilService } from 'src/app/service/util.service';
import { EEntidades, IndexDbService } from 'src/app/util/indexdb.service';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-jogo-adivinhacao',
  templateUrl: './jogo-adivinhacao.component.html',
  styleUrl: './jogo-adivinhacao.component.scss',
  providers: [MessageService],
})
export class JogoAdivinhacaoComponent implements OnInit {
  private subscription!: Subscription;

  letras: Letra[] = [];
  draggedLetra: Letra;
  selectedLetras: (Letra | null)[] = [];

  obj: PalavraJogoAdivinhacaoDTO;

  palavras: Palavra[] = [];
  selectedPalavra: Palavra = new Palavra();

  endGame: boolean = true;
  feedback: ETipoFeedback = ETipoFeedback.VAZIO;

  acertos: number = 0;
  erros: number = 0;

  constructor(
    public msg: MessageService,
    public palavraService: PalavraService
  ) {
    if(localStorage.getItem("LETRAS_ANTIGAS")) {
      this.letras = letrasData;
    } else this.letras = letrasDataProf;
    
    this.subscription = IndexDbService.onCarregouSala.subscribe(() => {
      this.ngOnInit();
    });
  }

  get dicaLetra() {
    return UtilService.getPersonagem().dificuldade == 'FACIL';
  }

  get dicaPalavra() {
    return ['FACIL', 'MEDIO'].includes(UtilService.getPersonagem().dificuldade);
  }

  async ngOnInit() {
    const db = IndexDbService.getDb();
    await db.open();
    const list: Palavra[] = await db.table(EEntidades.PALAVRA).toArray();
    this.palavras = list.filter((p) => p.tipo == 'JOGO_ADIVINHACAO');
    if (!this.palavras.length) this.palavras = palavraPadraoData as Palavra[];
    db.close();
    this.geraNovaPalavra();
  }

  async geraNovaPalavra() {
    this.endGame = false;
    this.selectedPalavra =
      this.palavras[Math.floor(Math.random() * this.palavras.length)];

    this.obj = {
      palavra: this.selectedPalavra.descricao.toUpperCase(),
      letras: this.selectedPalavra.descricao.toUpperCase().split(''),
      acertos: [],
    };

    this.selectedLetras = Array(this.obj.palavra.length).fill(null);
  }

  async palavraCompleta() {
    this.endGame = true;
  }

  getImage() {
    return this.selectedPalavra.imagem;
  }

  dragStart(letra: Letra) {
    this.draggedLetra = letra;
  }

  drop(index: number) {
    if (
      this.draggedLetra &&
      this.obj.letras[index] === this.draggedLetra.letra
    ) {
      this.acertos++;
      this.feedback = ETipoFeedback.ACERTO;
      this.selectedLetras[index] = this.draggedLetra;
      this.obj.acertos[index] = this.draggedLetra.letra;
      if (
        this.obj.letras.length === this.obj.acertos.length &&
        this.obj.letras.every(
          (letra, index) => letra === this.obj.acertos[index]
        )
      ) {
        this.palavraCompleta();
      }
    } else {
      this.erros++;
      this.feedback = ETipoFeedback.ERRO;
    }
    this.draggedLetra = null;
  }

  dragEnd() {
    this.draggedLetra = null;
  }

  findIndex(product: Letra) {
    let index = -1;
    for (let i = 0; i < this.letras.length; i++) {
      if (product.letra === this.letras[i].letra) {
        index = i;
        break;
      }
    }
    return index;
  }

  clearFeedback() {
    this.feedback = ETipoFeedback.VAZIO;
  }
}

export interface PalavraJogoAdivinhacaoDTO {
  palavra: string;
  letras: string[];
  acertos: string[];
}
