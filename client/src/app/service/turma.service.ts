import { Injectable } from '@angular/core';
import { Turma } from '../model/Turma';
import { AbstractService } from './abstract.service';
import { HttpClient } from '@angular/common/http';
import { ConfirmationService } from 'primeng/api';
import { Observable } from 'rxjs';
import { HttpRequest, UriBuilder } from '../util/http-requests';

@Injectable({
  providedIn: 'root',
})
export class TurmaService extends AbstractService<Turma> {
  override endpoint: string = 'turma';

  constructor(http: HttpClient) {
    super(http);
  }

  geraNovoCodigo(id: any): Observable<any> {
    return new HttpRequest<any>(this.http)
      .endpoint(`${this.endpoint}-codigo`)
      .uri(new UriBuilder().subpath(id).build())
      .doGet();
  }

  buscaPeloCodigo(codigo: any): Observable<any> {
    return new HttpRequest<any>(this.http)
      .endpoint(`${this.endpoint}-busca`)
      .uri(new UriBuilder().subpath(codigo).build())
      .doGet();
  }
}
