import { Component, ViewEncapsulation } from '@angular/core';
import { Router } from '@angular/router';
import { MenuItem, MessageService } from 'primeng/api';
import { AppComponent } from 'src/app/app.component';
import { ELocalStorageKeys, UtilService } from 'src/app/service/util.service';
import { IndexDbService } from 'src/app/util/indexdb.service';

@Component({
  selector: 'app-header',
  templateUrl: './app-header.component.html',
  styleUrl: './app-header.component.scss',
})
export class AppHeaderComponent {
  private debounceTimer: any;

  items: MenuItem = [];

  get logged() {
    return UtilService.isLoggedIn();
  }

  constructor(
    public router: Router,
    public indexDb: IndexDbService,
    public message: MessageService
  ) {
    this.montaMenu();
    this.codigo = localStorage.getItem(ELocalStorageKeys.CODIGO_TURMA) || "";
  }

  codigo: string;

  onEnter() {
    setTimeout(() => {
      if (this.codigo.length == 6) {
        localStorage.setItem(ELocalStorageKeys.CODIGO_TURMA, this.codigo);
        this.indexDb.sincronizaSala();
      }else {
        this.message.add({
          severity: 'info',
          summary: "Aviso",
          detail: 'O código precisa ter 6 digitos!'
        })
      }
    }, 100);
  }

  montaMenu() {
    this.items = [
      {
        label: 'Início',
        icon: 'pi pi-home',
        command: () => {
          this.router.navigateByUrl('');
        },
      },
      {
        separator: true,
      },
      // {
      //   visible: this.logged,
      //   label: `Bem vindo, ${UtilService.getUsuario().nome}`,
      // },
      {
        visible: this.logged,
        label: 'Gerencial',
        icon: 'pi pi-graduation-cap',
        command: () => {
          this.router.navigateByUrl('/inicio-admin');
        },
      },
      {
        visible: this.logged,
        label: 'Sair',
        icon: 'pi pi-sign-out',
        command: () => {
          UtilService.loggout();
          this.router.navigateByUrl('/login');
        },
      },
      {
        visible: !this.logged,
        label: 'Entrar',
        icon: 'pi pi-sign-in',
        command: () => {
          this.router.navigateByUrl('/login');
        },
      },
      {
        visible: !this.logged,
        label: 'Cadastrar',
        icon: 'pi pi-user-plus',
        command: () => {
          this.router.navigateByUrl('/cadastro-user');
        },
      },
      {
        label: 'Limpar sala',
        icon: 'pi pi-trash',
        visible: !!localStorage.getItem(ELocalStorageKeys.CODIGO_TURMA),
        command: async () => {
          localStorage.removeItem(ELocalStorageKeys.CODIGO_TURMA);
          const db = IndexDbService.getDb();
          await db.open();
          await db.table('PALAVRA').clear();
          await db.table('TURMA').clear();
          await IndexDbService.limpaPersonagensSala();
          db.close();
          this.message.add({
            severity: 'success',
            summary: "Sucesso",
            detail: 'Sala limpa com sucesso!'
          })
        },
      },
      {
        separator: true
      },
      {
        label: localStorage.getItem("LETRAS_ANTIGAS") ? 'Modo colorido' : 'Modo simples',
        icon: 'pi pi-palette',
        command: () => {
          if(localStorage.getItem("LETRAS_ANTIGAS")) {
            localStorage.removeItem("LETRAS_ANTIGAS");
          } else {
            localStorage.setItem("LETRAS_ANTIGAS", 'true')
          }
          this.router.navigateByUrl('');
        },
      },
      {
        label: 'Sobre',
        icon: 'pi pi-info-circle',
        command: () => {
          this.router.navigateByUrl('/sobre');
        },
      },
    ];
  }
}
