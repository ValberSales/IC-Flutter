import { Injectable } from '@angular/core';
import { Personagem } from '../model/Personagem';
import { AbstractService } from './abstract.service';
import { HttpClient } from '@angular/common/http';
import { ConfirmationService } from 'primeng/api';

@Injectable({
  providedIn: 'root',
})
export class PersonagemService extends AbstractService<Personagem> {
  override endpoint: string = 'personagem';

  constructor(http: HttpClient) {
    super(http);
  }
}
