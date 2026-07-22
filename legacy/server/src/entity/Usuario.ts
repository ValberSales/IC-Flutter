import { Entity, Column, PrimaryColumn, PrimaryGeneratedColumn, OneToMany, Unique } from "typeorm";
import { GenericEntity } from "./GenericEntity";
import { Palavra } from "./Palavra";
import { Personagem } from "./Personagem";
import { Turma } from "./Turma";

@Entity()
@Unique(['username'])
export class Usuario extends GenericEntity {

    @Column({default: '', nullable: true})
    nome: string;

    @Column({default: '', nullable: true})
    username: string;

    @Column({default: '', nullable: true, length: 1024})
    password: string;

    @Column({default: '', nullable: true})
    email: string;

    @OneToMany(
        () => Personagem,
        personagem => personagem.usuario,
        { eager: true, nullable: true, cascade: ['insert', 'update', 'remove', 'recover', 'soft-remove'], createForeignKeyConstraints: false }
    )
    personagens: Personagem[];

    @OneToMany(
        () => Palavra,
        palavra => palavra.usuario,
        { eager: true, nullable: true, cascade: ['insert', 'update', 'remove', 'recover', 'soft-remove'], createForeignKeyConstraints: false }
    )
    palavras: Palavra[];

    @OneToMany(
        () => Turma,
        turma => turma.usuario,
        { eager: true, nullable: true, cascade: ['insert', 'update', 'remove', 'recover', 'soft-remove'], createForeignKeyConstraints: false }
    )
    turmas: Turma[];
}