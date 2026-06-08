import { Injectable } from '@angular/core';
import { AbstractModel } from '../model/AbstractModel';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { HttpRequest, UriBuilder } from '../util/http-requests';
import { ConfirmationService } from 'primeng/api';

@Injectable({
  providedIn: 'root',
})
export abstract class AbstractService<T extends AbstractModel> {
  http: HttpClient;
  abstract endpoint: string;

  constructor(http: HttpClient) {
    this.http = http;
  }

  getAllRequest(
    searchParams: any[] = [],
    skip = 0,
    take = 10,
    fields = undefined,
    order = undefined,
    count = false,
    relations = undefined
  ): Observable<T[]> {
    return new HttpRequest<any[]>(this.http)
      .endpoint(`${this.endpoint}`)
      .uri(
        new UriBuilder()
          .param('params', searchParams ? JSON.stringify(searchParams) : '')
          .param('skip', `${skip}`)
          .param('take', `${take}`)
          .param('fields', fields ? JSON.stringify(fields) : '')
          .param('order', order ? JSON.stringify(order) : '')
          .param('count', `${count}`)
          .param('relations', relations ? JSON.stringify(relations) : '')
          .build()
      )
      .doGet();
  }

  getByIdRequest(
    id: any = '',
    relations: string[] = undefined
  ): Observable<T> {
    return new HttpRequest<T>(this.http)
      .endpoint(`${this.endpoint}`)
      .uri(new UriBuilder().subpath(id).build())
      .header('relations', JSON.stringify(relations) ?? '')
      .doGet();
  }

  save(obj: T) {
    return new HttpRequest<any>(this.http)
      .endpoint(this.endpoint)
      .body(obj)
      .doPostBody();
  }

  savePromise(obj: T): Promise<T> {
    return new Promise((resolve, reject) => {
      this.save(obj).subscribe({
        next: (ret) => {
          resolve(ret);
        },
        error: (e) => {
          reject(e);
        },
      });
    });
  }

  delete(obj: T) {
    return new HttpRequest<any>(this.http)
      .endpoint(this.endpoint)
      .uri(new UriBuilder().subpath(obj?.id.toString()).build())
      .doDelete();
  }

}
