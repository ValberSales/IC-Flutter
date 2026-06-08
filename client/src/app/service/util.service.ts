import { Injectable } from '@angular/core';
import { Personagem } from '../model/Personagem';
import { Usuario } from '../model/Usuario';

export enum ELocalStorageKeys {
  AUTH_LIBRAS = 'AUTH_LIBRAS',
  USUARIO_LOGADO = 'USUARIO_LOGADO',
  PERSONAGEM = 'PERSONAGEM',
  CODIGO_TURMA = 'CODIGO_TURMA',
  LAST_LOGIN = 'LAST_LOGIN'
}

@Injectable({
  providedIn: 'root',
})
export class UtilService {
  private static auth;
  private static usuario;
  private static personagem;

  public static isLoggedIn(): boolean {
    if(!!this.auth) return true;
    else if(!!UtilService.getAuth()) return true;
    return false;
  }

  public static loggout() {
    this.auth = undefined;
    this.usuario = undefined;
    this.personagem = undefined;
    localStorage.removeItem(ELocalStorageKeys.AUTH_LIBRAS);
    localStorage.removeItem(ELocalStorageKeys.PERSONAGEM);
    localStorage.removeItem(ELocalStorageKeys.USUARIO_LOGADO);
    localStorage.removeItem(ELocalStorageKeys.LAST_LOGIN);
  }

  public static setAuth(value: string) {
    this.auth = value;
    localStorage.setItem(ELocalStorageKeys.AUTH_LIBRAS, value);
    localStorage.setItem(ELocalStorageKeys.LAST_LOGIN, new Date().toString());
  }

  public static getAuth() {
    if(this.auth) return this.auth;
    this.auth = localStorage.getItem(ELocalStorageKeys.AUTH_LIBRAS);
    return this.auth;
  }

  public static setUsuario(value: Usuario) {
    this.usuario = value;
    localStorage.setItem(ELocalStorageKeys.USUARIO_LOGADO, JSON.stringify(value));
  }

  public static getUsuario(): Usuario {
    if(this.usuario) return this.usuario;
    this.usuario = JSON.parse(localStorage.getItem(ELocalStorageKeys.USUARIO_LOGADO));
    return this.usuario;
  }

  public static setPersonagem(value: Personagem) {
    this.personagem = value;
    localStorage.setItem(ELocalStorageKeys.PERSONAGEM, JSON.stringify(value));
  }

  public static getPersonagem(): Personagem {
    if(this.personagem) return this.personagem;
    this.personagem = JSON.parse(localStorage.getItem(ELocalStorageKeys.PERSONAGEM));
    if(!this.personagem) this.personagem = new Personagem();
    return this.personagem;
  }
}
