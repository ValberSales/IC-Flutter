import { Injectable } from '@angular/core';
import { Palavra } from '../model/Palavra';
import { AbstractService } from './abstract.service';
import { HttpClient } from '@angular/common/http';
import { ConfirmationService } from 'primeng/api';

@Injectable({
  providedIn: 'root',
})
export class PalavraService extends AbstractService<Palavra> {
  override endpoint: string = 'palavra';

  constructor(http: HttpClient) {
    super(http);
  }
}
