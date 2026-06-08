import { AbstractModel } from "./AbstractModel";
import { Usuario } from "./Usuario";

export class Turma extends AbstractModel {
    nome: string = "";
    codigo: string = "";
    dataGeracaoCodigo: Date;
    palavras: number[];
    usuario: Usuario;
}