import { AbstractModel } from './AbstractModel';
import { Personagem } from './Personagem';

export enum EAtividade {
  JOGO_ADIVINHACAO = 'JOGO_ADIVINHACAO',
  JOGO_MEMORIA = 'JOGO_MEMORIA',
  JOGO_ALFABETO = 'JOGO_ALFABETO',
  JOGO_PALAVRAS = 'JOGO_PALAVRAS',
}

export class Pontuacao extends AbstractModel {
  atividade: EAtividade;
  acertos: number;
  erros: number;
  dificuldade: 'FACIL' | 'MEDIO' | 'DIFICIL';
  personagem: Personagem;
}
