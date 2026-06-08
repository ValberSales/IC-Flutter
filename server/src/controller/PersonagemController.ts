import { GenericController } from "./GenericController";
import { Request, Response } from "express";
import { IController } from "./IController";
import { Personagem } from "../entity/Personagem";
import { AppDataSource } from "../persistence/data-source";
import { HEADER_USER_ID } from "../jwt/check-jwt";

class PersonagemController
  extends GenericController<Personagem>
  implements IController
{
  public index(request: Request, response: Response) {
    return super.index(
      request,
      response,
      AppDataSource.getRepository(Personagem)
    );
  }

  public async save(request: Request, response: Response) {
    if (!!request?.headers?.[HEADER_USER_ID]) {
      request.body.usuario = { id: request.headers[HEADER_USER_ID] };
    } else request.body.usuario = null;

    return super.save(
      request,
      response,
      AppDataSource.getRepository(Personagem)
    );
  }

  public show(request: Request, response: Response) {
    return super.show(
      request,
      response,
      AppDataSource.getRepository(Personagem)
    );
  }

  public update(request: Request, response: Response) {
    if(!!request?.headers?.[HEADER_USER_ID]) {
      request.body.usuario = {id: request.headers[HEADER_USER_ID]}
    } else request.body.usuario = null;
    
    return super.update(
      request,
      response,
      AppDataSource.getRepository(Personagem)
    );
  }

  public remove(request: Request, response: Response) {
    return super.remove(
      request,
      response,
      AppDataSource.getRepository(Personagem)
    );
  }
}

export default new PersonagemController();
