import { AbstractModel } from "./AbstractModel";
import { Usuario } from "./Usuario";

export class Palavra extends AbstractModel {
    tipo: 'JOGO_ADIVINHACAO' | 'JOGO_PALAVRAS' = 'JOGO_ADIVINHACAO';
    descricao: string;
    imagem: string;
    usuario: Usuario;
    opcoes: string[] = [];
}