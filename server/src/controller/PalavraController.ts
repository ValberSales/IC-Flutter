
import {GenericController} from './GenericController';
import {Request, Response} from 'express';
import { IController } from './IController';
import { Palavra } from '../entity/Palavra';
import { AppDataSource } from '../persistence/data-source';
import { HEADER_USER_ID } from '../jwt/check-jwt';
import e from 'cors';

class PalavraController
    extends GenericController<Palavra>
    implements IController {
  public index(request: Request, response: Response) {
    return super.index(
        request,
        response,
        AppDataSource.getRepository(Palavra)
    );
  }
  
  public async save(request: Request, response: Response) {
    if(!!request?.headers?.[HEADER_USER_ID]) {
      request.body.usuario = {id: request.headers[HEADER_USER_ID]}
    } else request.body.usuario = null;
    
    return super.save(
        request,
        response,
        AppDataSource.getRepository(Palavra)
    );
  }
  
  public show(request: Request, response: Response) {
    return super.show(
        request,
        response,
        AppDataSource.getRepository(Palavra)
    );
  }
  
  public update(request: Request, response: Response) {

    if(!!request?.headers?.[HEADER_USER_ID]) {
      request.body.usuario = {id: request.headers[HEADER_USER_ID]}
    } else request.body.usuario = null;
    
    return super.update(
        request,
        response,
        AppDataSource.getRepository(Palavra)
    );
  }
  
  public remove(request: Request, response: Response) {
    return super.remove(
        request,
        response,
        AppDataSource.getRepository(Palavra)
    );
  }
  
}

export default new PalavraController();