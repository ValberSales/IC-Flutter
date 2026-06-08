import { Component, OnInit } from '@angular/core';
import { MenuItem } from 'primeng/api';
import { Palavra } from 'src/app/model/Palavra';

@Component({
  selector: 'app-pagina-inicial-usuario',
  templateUrl: './pagina-inicial-usuario.component.html',
  styleUrl: './pagina-inicial-usuario.component.scss',
})
export class PaginaInicialUsuarioComponent implements OnInit {
  model: MenuItem[];
  objEdicao: any;
  telaAtiva: ETelaAdminAtiva = ETelaAdminAtiva.PERFIL;

  constructor() {
    this.model = [
      {
        label: 'Home',
        items: [
          {
            label: 'Perfil',
            icon: 'pi pi-fw pi-user-edit',
            command: () => {
              this.objEdicao = undefined;
              this.telaAtiva = ETelaAdminAtiva.PERFIL;
            },
          },
        ],
      },
      {
        label: 'Personagens',
        items: [
          {
            label: 'Novo personagem',
            icon: 'pi pi-fw pi-user-plus',
            command: () => {
              this.objEdicao = undefined;
              this.telaAtiva = ETelaAdminAtiva.PERSONAGEM_CADASTRO;
            },
          },
          {
            label: 'Listar personagens',
            icon: 'pi pi-fw pi-users',
            command: () => {
              this.objEdicao = undefined;
              this.telaAtiva = ETelaAdminAtiva.PERSONAGEM_LISTA;
            },
          },
        ],
      },
      {
        label: 'Palavras',
        items: [
          {
            label: 'Nova palavra',
            icon: 'pi pi-fw pi-pencil',
            command: () => {
              this.objEdicao = undefined;
              this.telaAtiva = ETelaAdminAtiva.PALAVRA_CADASTRO;
            },
          },
          {
            label: 'Listar palavras',
            icon: 'pi pi-fw pi-book',
            command: () => {
              this.objEdicao = undefined;
              this.telaAtiva = ETelaAdminAtiva.PALAVRA_LISTA;
            },
          },
        ],
      },
      {
        label: 'Salas',
        items: [
          {
            label: 'Nova sala',
            icon: 'pi pi-fw pi-graduation-cap',
            command: () => {
              this.objEdicao = undefined;
              this.telaAtiva = ETelaAdminAtiva.SALA_CADASTRO;
            },
          },
          {
            label: 'Listar salas',
            icon: 'pi pi-fw pi-align-justify',
            command: () => {
              this.objEdicao = undefined;
              this.telaAtiva = ETelaAdminAtiva.SALA_LISTA;
            },
          },
        ],
      },
    ];
  }

  ngOnInit(): void {}

  editar(event) {
    if (event?.tipo) {
      this.objEdicao = event.obj;
      this.telaAtiva = event.tipo;
    }
  }
}

export enum ETelaAdminAtiva {
  PERFIL = 'PERFIL',
  PERSONAGEM_CADASTRO = 'PERSONAGEM_CADASTRO',
  PERSONAGEM_LISTA = 'PERSONAGEM_LISTA',
  PALAVRA_CADASTRO = 'PALAVRA_CADASTRO',
  PALAVRA_LISTA = 'PALAVRA_LISTA',
  SALA_CADASTRO = 'SALA_CADASTRO',
  SALA_LISTA = 'SALA_LISTA',
}
