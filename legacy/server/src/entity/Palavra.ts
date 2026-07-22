import { Entity, Column, ManyToOne, JoinColumn } from "typeorm";
import { GenericEntity } from "./GenericEntity";
import { Usuario } from "./Usuario";

@Entity()
export class Palavra extends GenericEntity {

    @Column({default: '', nullable: true})
    descricao: string;

    @Column({default: 'JOGO_ADIVINHACAO', nullable: true})
    tipo: string;

    @Column({default: '', nullable: true, type: 'text'})
    imagem: string;
    
    @ManyToOne(
        () => Usuario,
        usuario => usuario.palavras,
        { nullable: true, createForeignKeyConstraints: false }
    )
    usuario: Usuario;

    @Column({ type: 'simple-array', nullable: true })
    opcoes: string[];

}