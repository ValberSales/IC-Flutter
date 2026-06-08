
import { AbstractModel } from "./AbstractModel";
import { Usuario } from "./Usuario";

export class Personagem extends AbstractModel {
    nome: string;
    dataNascimento: Date;
    dificuldade: 'FACIL' | 'MEDIO' | 'DIFICIL' = 'FACIL';
    avatar: string = 'assets/avatar/avatar_1.jpg';
    usuario: Usuario;
}