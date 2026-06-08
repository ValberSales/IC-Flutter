import { Entity, Column, ManyToOne } from "typeorm";
import { GenericEntity } from "./GenericEntity";
import { Usuario } from "./Usuario";

@Entity()
export class Personagem extends GenericEntity {

    @Column({nullable: true})
    nome: string;
    
    @Column({nullable: true})
    dataNascimento: Date;

    @Column({nullable: true, default: 'FACIL'})
    dificuldade: string;

    @Column({nullable: true, type: 'text'})
	avatar: string;
    
    @ManyToOne(
        () => Usuario,
        usuario => usuario.personagens,
        { nullable: true, createForeignKeyConstraints: false }
    )
    usuario: Usuario;
}