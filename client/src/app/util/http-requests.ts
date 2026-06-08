import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from 'src/environments/environment';
import { ELocalStorageKeys } from '../service/util.service';

export interface IUriBuilder {
  subpath(subpath: string): IUriBuilder;
  param(aparam: string, avalue: string | string[]): IUriBuilder;
  build(): string;
}

export interface IHttpRequest<T> {
  api(apiUrl: string): IHttpRequest<T>;
  endpoint(endpoint: string): IHttpRequest<T>;
  uri(uri: string): IHttpRequest<T>;
  header(header: string, value: string): IHttpRequest<T>;
  param(param: string, value: string): IHttpRequest<T>;
  body(val: T): IHttpRequest<T>;
  doGet(): Observable<T>;
  doPost(): Observable<T>;
  doPostBody(tokenDiferente?: boolean): Observable<T>;
  doDelete(): Observable<T>;
}

export class HttpRequest<T> implements IHttpRequest<T> {
  private _endpoint = '';
  private _uri = '';
  private _headers = new Map<string, string>();
  private _params = new Map<string, string>();
  private _body?: T;
  private _urlApi = environment.api;

  constructor(private http: HttpClient) {}

  endpoint(endpoint: string): IHttpRequest<T> {
    this._endpoint = endpoint;
    return this;
  }

  uri(uri: string): IHttpRequest<T> {
    this._uri = uri;
    return this;
  }

  header(header: string, value: string): IHttpRequest<T> {
    this._headers.set(header, value);
    return this;
  }

  param(param: string, value: string): IHttpRequest<T> {
    this._params.set(param, value);
    return this;
  }

  api(apiUrl: string): IHttpRequest<T> {
    this._urlApi = apiUrl;
    return this;
  }

  private getToken(): string {
    return localStorage.getItem(ELocalStorageKeys.AUTH_LIBRAS) || '';
  }

  body(val: T): IHttpRequest<T> {
    this._body = val;
    return this;
  }

  private buildHeaders(useCustomToken = false): HttpHeaders {
    const headers = new HttpHeaders({
      Accept: 'application/json; charset=utf-8',
      auth: this.getToken(),
    });

    this._headers.forEach((value, key) => {
      headers.append(key, value);
    });
    return headers;
  }

  private buildParams(): string {
    const params = new URLSearchParams();
    this._params.forEach((value, key) => {
      params.append(key, value);
    });
    return params.toString();
  }

  private buildFullUrl(): string {
    let url = `${this._urlApi}/${this._endpoint}`;
    if (this._uri) {
      url += this._uri.startsWith('/') ? this._uri : `/${this._uri}`;
    }
    return url;
  }

  doGet(): Observable<T> {
    const url = this.buildFullUrl();
    const params = this.buildParams();
    return this.http.get<T>(params ? `${url}?${params}` : url, {
      headers: this.buildHeaders(),
    });
  }

  doPost(): Observable<T> {
    const headers = this.buildHeaders();
    if (!headers.has('Content-Type')) {
      headers.append('Content-Type', 'application/x-www-form-urlencoded');
    }
    return this.http.post<T>(this.buildFullUrl(), this.buildParams(), { headers });
  }

  doPostBody(tokenDiferente = false): Observable<T> {
    return this.http.post<T>(this.buildFullUrl(), this._body, {
      headers: this.buildHeaders(tokenDiferente),
    });
  }

  doDelete(): Observable<T> {
    return this.http.delete<T>(this.buildFullUrl(), {
      headers: this.buildHeaders(),
    });
  }
}

export class UriBuilder implements IUriBuilder {
  private _subpaths: string[] = [];
  private _params = new Map<string, string>();

  subpath(subpath: string): IUriBuilder {
    this._subpaths.push(subpath);
    return this;
  }

  param(aparam: string, avalue: string): IUriBuilder {
    this._params.set(aparam, avalue);
    return this;
  }

  build(): string {
    const path = this._subpaths.join('/');
    const params = Array.from(this._params.entries())
      .map(([key, value]) => `${key}=${encodeURIComponent(value)}`)
      .join('&');
    return `/${path}${params ? '?' + params : ''}`;
  }
}
