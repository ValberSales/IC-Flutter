import { Component, OnInit } from '@angular/core';
import { Usuario } from 'src/app/model/Usuario';
import { UtilService } from 'src/app/service/util.service';

@Component({
  selector: 'app-tela-perfil-usuario',
  templateUrl: './tela-perfil-usuario.component.html',
  styleUrl: './tela-perfil-usuario.component.scss'
})
export class TelaPerfilUsuarioComponent implements OnInit {

  usuario: Usuario;

  constructor() {}
  
  ngOnInit(): void {
    this.usuario = UtilService.getUsuario() || new Usuario();
  }

  save() {

  }
}
