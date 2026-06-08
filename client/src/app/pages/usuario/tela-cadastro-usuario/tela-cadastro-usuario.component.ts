import { Component } from '@angular/core';
import { Usuario } from 'src/app/model/Usuario';
import { MessageService, PrimeNGConfig } from 'primeng/api';
import { UserService } from 'src/app/service/user.service';
import { ELocalStorageKeys } from 'src/app/service/util.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-tela-cadastro-usuario',
  templateUrl: './tela-cadastro-usuario.component.html',
  styleUrl: './tela-cadastro-usuario.component.scss',
})
export class TelaCadastroUsuarioComponent {
  user: Usuario = new Usuario();
  confirmPassword: string;

  constructor(public userService: UserService, public msg: MessageService, public router: Router) {}

  doValidate(): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      if(!this.user.password || !this.user.nome || !this.user.email || !this.user.username) {
        this.msg.add({
          severity: 'warn',
          summary: 'Aviso',
          detail: 'Preencha todos os campos!',
        });
        return reject();
      }
      if (this.user.password != this.confirmPassword) {
        this.msg.add({
          severity: 'warn',
          summary: 'Aviso',
          detail: 'As senhas não coincidem!',
        });
        return reject();
      }
      return resolve();
    });
  }

  onCadastro() {
    this.doValidate().then(() => {
      this.userService.cadastroRequest(this.user).subscribe({
        next: (value) => {
          console.log(value);
          if (value?.token) {
            localStorage.setItem(ELocalStorageKeys.AUTH_LIBRAS, value.token);
            localStorage.setItem(ELocalStorageKeys.USUARIO_LOGADO, JSON.stringify(value.usuario));
          }
          this.msg.add({
            severity: 'success',
            summary: 'Sucesso',
            detail: 'Cadastro realizado com sucesso!',
          });
          this.router.navigateByUrl("/inicio-admin");
        },
        error: (err) => {
          console.log(err);
          if(err.status == 409) {
            this.msg.add({
              severity: 'info',
              summary: 'Aviso',
              detail: 'Já existe um cadastro com esse usuário!',
            });
          } else {
            this.msg.add({
              severity: 'error',
              summary: 'Erro',
              detail: 'Ocorreu um erro ao cadastrar!',
            });
          }
        },
      });
    });
  }
}
