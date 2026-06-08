import { EventEmitter, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { MessageService } from 'primeng/api';
import Dexie from 'dexie';
import { TurmaService } from '../service/turma.service';
import { ELocalStorageKeys } from '../service/util.service';
import { main } from '../app.component';
import { Personagem } from '../model/Personagem';
import { Turma } from '../model/Turma';
import { Pontuacao } from '../model/Pontuacao';

export enum EEntidades {
  PERSONAGEM = 'PERSONAGEM',
  PALAVRA = 'PALAVRA',
  TURMA = 'TURMA',
  PONTUACAO = 'PONTUACAO'
}

@Injectable({
  providedIn: 'root',
})
export class IndexDbService {
  public static onCarregouSala: EventEmitter<void> = new EventEmitter<void>();

  constructor(
    public http: HttpClient,
    public router: Router,
    public turmaService: TurmaService
  ) {}

  static getDb(): Dexie {
    const dbName = 'JOGO_LIBRAS_DATA';
    const db = new Dexie(dbName);
    db.version(1).stores({
      PERSONAGEM: '++id, nome',
      TURMA: '++id, nome',
      PALAVRA: '++id, descricao',
      PONTUACAO: '++id, atividade',
      CONFIG: 'key',
    });
    return db;
  }

  static async salvarNoIndexedDB(entidade: EEntidades, itens: any[], clear: boolean = true) {
    const db = this.getDb();
    if (!itens) itens = [];
    try {
      await db.open();
      if(clear) await db.table(entidade).clear();
      await db.table(entidade).bulkPut(itens);
    } catch (error) {
      console.log(`ERRO NA ENTIDADE: ${entidade}`);
      console.log(error);
    }
    db.close();
  }

  public async sincronizaSala() {
    const codigo = localStorage.getItem(ELocalStorageKeys.CODIGO_TURMA);
    const db = IndexDbService.getDb();
    await db.open();
    try {
      const turma = await db.table(EEntidades.TURMA).toArray();
      if (turma[0]?.codigo == codigo) {
        // return main.msg.add({
        //   severity: 'info',
        //   summary: 'Aviso',
        //   detail: 'Turma já carregada!',
        // });
      }
      await db.table(EEntidades.PALAVRA).clear();
      await db.table(EEntidades.TURMA).clear();
      await IndexDbService.limpaPersonagensSala();
      const sala = await firstValueFrom(
        this.turmaService.buscaPeloCodigo(codigo)
      );
      console.log(sala);
      if (!sala?.turma) {
        localStorage.removeItem(ELocalStorageKeys.CODIGO_TURMA);
        return main.msg.add({
          severity: 'info',
          summary: 'Aviso',
          detail: sala?.message,
        });
      }
      await IndexDbService.salvarNoIndexedDB(EEntidades.TURMA, [sala.turma]);
      await IndexDbService.salvarNoIndexedDB(EEntidades.PALAVRA, sala?.palavras);
      await IndexDbService.salvarNoIndexedDB(EEntidades.PERSONAGEM, sala?.personagens, false);

      main.msg.add({
        severity: 'success',
        summary: 'Sucesso',
        detail: 'Sala carregada com sucesso!',
      });
    } catch (error) {
      main.msg.add({
        severity: 'error',
        summary: 'Erro',
        detail: 'Ocorreu um erro ao carregar a Sala!',
      });
      console.error(error);
    } finally {
      db.close();
      IndexDbService.onCarregouSala.emit();
    }
  }

  static async buscaSalaNoIndexDB(): Promise<Turma> {
    const codigo = localStorage.getItem(ELocalStorageKeys.CODIGO_TURMA);
    if(!codigo) return null;
    const db = IndexDbService.getDb();
    await db.open();
    const turma = await db.table(EEntidades.TURMA).toArray();
    db.close();
    return turma?.[0] || null
  }

  static async limpaPersonagensSala() {
    const db = IndexDbService.getDb();
    try {
      await db.open();
      const list: Personagem[] = await db
        .table(EEntidades.PERSONAGEM)
        .toArray();
      for (const p of list) {
        if (p.id > 0) {
          await db.table(EEntidades.PERSONAGEM).delete(p.id);
        }
      }
      const listPontuacao: Pontuacao[] = await db
        .table(EEntidades.PONTUACAO)
        .toArray();
      for (const p of listPontuacao) {
        if (p.id > 0) {
          await db.table(EEntidades.PONTUACAO).delete(p.id);
        }
      }
      db.close();
    } catch (error) {
      console.log(error);
    }
  }

  static async salvaPersonagem(personagem: Personagem) {
    if (!personagem?.id) {
      personagem.id = await IndexDbService.proximoId('personagem_id');
    }

    const db = this.getDb();
    try {
      await db.open();
      await db.table(EEntidades.PERSONAGEM).put(personagem);
    } catch (error) {
      main.msg.add({
        severity: 'error',
        summary: 'Erro',
        detail: 'Ocorreu um erro ao salvar o personagem!',
      });
    }
    db.close();
    return personagem;
  }

  static async salvaPontuacao(pontuacao: Pontuacao) {
    if (!pontuacao?.id) {
      pontuacao.id = await IndexDbService.proximoId('pontuacao_id');
    }

    const db = this.getDb();
    try {
      await db.open();
      await db.table(EEntidades.PONTUACAO).put(pontuacao);
    } catch (error) {

    }
    db.close();
    return pontuacao;
  }

  static async buscaPontuacaoPersonagem(personagem: Personagem): Promise<Pontuacao[]> {
    const db = IndexDbService.getDb();
    await db.open();
    const pontuacao: Pontuacao[] = await db.table(EEntidades.PONTUACAO).toArray();
    db.close();
    return pontuacao.filter((p) => p.personagem?.id == personagem.id)
  }


  static async proximoId(entidade: string) {
    const db = this.getDb();
    try {
      await db.open();

      const config = await db.table('CONFIG').get(entidade);
      let lastNegativeId = config?.value ?? -1;
      const newNegativeId = lastNegativeId - 1;

      await db.table('CONFIG').put({ key: entidade, value: newNegativeId });
      db.close();
      return newNegativeId;
    } catch (error) {
      console.error('Erro ao gerar ID negativo:', error);
      throw error;
    }
  }
}
