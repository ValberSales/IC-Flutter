import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { HttpRequest } from '../util/http-requests';
import { Usuario } from '../model/Usuario';

@Injectable({
  providedIn: 'root',
})
export class UserService {
  constructor(private http: HttpClient) {}

  login(obj: {username: string, password: string}) {
    return new HttpRequest<any>(this.http)
      .endpoint('login')
      .body(obj)
      .doPostBody();
  }

  cadastroRequest(user: Usuario) {
    return new HttpRequest<any>(this.http)
      .endpoint('cadastro')
      .body(user)
      .doPostBody();
  }
}
