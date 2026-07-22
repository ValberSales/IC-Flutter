import { Entity, Column, PrimaryColumn, PrimaryGeneratedColumn, OneToMany, ManyToOne } from "typeorm";
import { GenericEntity } from "./GenericEntity";
import { Usuario } from "./Usuario";


@Entity()
export class Turma extends GenericEntity {

    @Column({default: '', nullable: true})
    nome: string;

    @Column({default: '', nullable: true})
    codigo: string;

    @Column({nullable: true})
    dataGeracaoCodigo: Date;

    @Column({ type: 'simple-array', nullable: true })
    palavras: number[];

    @ManyToOne(
        () => Usuario,
        usuario => usuario.turmas,
        { nullable: true, createForeignKeyConstraints: false }
    )
    usuario: Usuario;
}