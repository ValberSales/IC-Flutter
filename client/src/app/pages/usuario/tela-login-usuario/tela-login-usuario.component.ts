import { Component } from '@angular/core';
import { Route, Router } from '@angular/router';
import { MessageService } from 'primeng/api';
import { UserService } from 'src/app/service/user.service';
import { UtilService } from 'src/app/service/util.service';

@Component({
  selector: 'app-tela-login-usuario',
  templateUrl: './tela-login-usuario.component.html',
  styleUrl: './tela-login-usuario.component.scss'
})
export class TelaLoginUsuarioComponent {

  constructor(
    public userService: UserService,
    public msg: MessageService, 
    private router: Router
  ) {}

  username: string = '';
  password: string = '';

  onLogin() {
    this.userService.login({username: this.username, password: this.password}).subscribe({
      next: (value) => {
        if (value?.token) {
          UtilService.setUsuario(value.usuario)
          UtilService.setAuth(value.token);
          this.msg.add({
            severity: 'success',
            summary: 'Sucesso',
            detail: 'Login realizado com sucesso!',
          });
          this.router.navigateByUrl("/inicio-admin")
        }
      },
      error: (err) => {
        this.msg.add({
          severity: 'info',
          summary: 'Aviso',
          detail: 'Não foi possivel realizar seu login!',
        });
      },
    })
  }
}
