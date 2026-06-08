import { Injectable } from '@angular/core';
import { AbstractService } from './abstract.service';
import { HttpClient } from '@angular/common/http';
import { Pontuacao } from '../model/Pontuacao';
import { Personagem } from '../model/Personagem';
import { ELocalStorageKeys } from './util.service';
import { Turma } from '../model/Turma';
import { IndexDbService } from '../util/indexdb.service';
import { HttpRequest, UriBuilder } from '../util/http-requests';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class PontuacaoService extends AbstractService<Pontuacao> {
  override endpoint: string = 'pontuacao';

  constructor(http: HttpClient) {
    super(http);
  }

  buscaPeloIdPersonagem(id: any): Observable<any> {
    return new HttpRequest<any>(this.http)
      .endpoint(`${this.endpoint}-personagem`)
      .uri(new UriBuilder().subpath(id).build())
      .doGet();
  }

  async trataPontuacao(pontuacao: Pontuacao): Promise<Pontuacao> {
    if (pontuacao.acertos < 5 && pontuacao.erros < 5) return pontuacao;
    const personagem: Personagem | null = JSON.parse(
      localStorage.getItem(ELocalStorageKeys.PERSONAGEM)
    );
    if (!personagem) return pontuacao;
    pontuacao.personagem = personagem;
    pontuacao.dificuldade = personagem.dificuldade;

    const turma: Turma | null = await IndexDbService.buscaSalaNoIndexDB();

    pontuacao.createdAt = new Date();

    if (turma?.id && (!pontuacao?.id || pontuacao?.id >= 0)) {
      return await this.savePromise(pontuacao);
    } else {
      return IndexDbService.salvaPontuacao(pontuacao);
    }
  }
}
