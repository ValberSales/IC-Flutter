import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { MessageService } from 'primeng/api';
import { ETipoFeedback } from 'src/app/model/enum/EFeedback';
import { Palavra } from 'src/app/model/Palavra';
import familiaData from '../../data/familia-padrao.json';
import { ELocalStorageKeys, UtilService } from 'src/app/service/util.service';
import { TurmaService } from 'src/app/service/turma.service';
import { Subscription } from 'rxjs';
import { EEntidades, IndexDbService } from 'src/app/util/indexdb.service';

class PalavraJogo {
  palavra: string;
  pendente: boolean;
}

@Component({
  selector: 'app-jogo-palavras',
  templateUrl: './jogo-palavras.component.html',
  styleUrl: './jogo-palavras.component.scss',
})
export class JogoPalavrasComponent implements OnInit {
  private subscription!: Subscription;

  palavras: Palavra[] = [];
  palavrasJogo: PalavraJogo[] = [];
  selectedPalavra: Palavra;

  feedback: ETipoFeedback = ETipoFeedback.VAZIO;
  acerto: boolean = false;
  animacao: boolean = false;

  acertos: number = 0;
  erros: number = 0;

  constructor(public turmaService: TurmaService) {
    this.subscription = IndexDbService.onCarregouSala.subscribe(() => {
      this.ngOnInit();
    });
  }

  get isFacil() {
    return UtilService.getPersonagem().dificuldade == 'FACIL';
  }

  get isMedio() {
    return UtilService.getPersonagem().dificuldade == 'MEDIO';
  }

  async ngOnInit() {
    const db = IndexDbService.getDb();
    await db.open();
    const list: Palavra[] = await db.table(EEntidades.PALAVRA).toArray();
    this.palavras = list.filter((p) => p.tipo == 'JOGO_PALAVRAS');
    if(!this.palavras.length) this.palavras = familiaData as Palavra[];
    db.close();
    this.novoJogo();
  }

  novoJogo(): void {
    this.acerto = false;
    this.sortearPalavra();
  }

  sortearPalavra() {
    this.selectedPalavra =
      this.palavras[Math.floor(Math.random() * this.palavras.length)];

    this.palavrasJogo = this.selectedPalavra.opcoes.map((o) => ({
      palavra: o,
      pendente: true,
    }));

    const palavraCorreta = {
      palavra: this.selectedPalavra.descricao,
      pendente: true,
    };

    if (!this.palavrasJogo.some((p) => p.palavra === palavraCorreta.palavra)) {
      this.palavrasJogo.push(palavraCorreta);
    }

    this.palavrasJogo = this.palavrasJogo.sort(() => Math.random() - 0.5);

    const limite = this.isFacil
      ? 3
      : this.isMedio
      ? 4
      : this.palavrasJogo.length;
    this.palavrasJogo = this.palavrasJogo.slice(0, limite);

    if (!this.palavrasJogo.some((p) => p.palavra === palavraCorreta.palavra)) {
      this.palavrasJogo.pop();
      this.palavrasJogo.push(palavraCorreta);
    }
  }

  verificarResposta(opcao: PalavraJogo): void {
    if (this.acerto || !opcao.pendente) return;
    if (opcao.palavra == this.selectedPalavra.descricao) {
      this.acerto = true;
      this.acertos++;
      this.feedback = ETipoFeedback.ACERTO;
    } else {
      opcao.pendente = false;
      this.erros++;
      this.feedback = ETipoFeedback.ERRO;
    }
  }

  getAcerto(opcao: string) {
    return opcao == this.selectedPalavra.descricao && this.acerto;
  }

  clearFeedback() {
    this.feedback = ETipoFeedback.VAZIO;
  }
}
