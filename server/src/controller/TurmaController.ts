import { GenericController } from "./GenericController";
import { Request, Response } from "express";
import { IController } from "./IController";
import { Turma } from "../entity/Turma";
import { AppDataSource } from "../persistence/data-source";
import { HEADER_USER_ID } from "../jwt/check-jwt";
import { Palavra } from "../entity/Palavra";
import { In, MoreThan } from "typeorm";
import { Personagem } from "../entity/Personagem";

class TurmaController extends GenericController<Turma> implements IController {
  public index(request: Request, response: Response) {
    return super.index(request, response, AppDataSource.getRepository(Turma));
  }

  public async save(request: Request, response: Response) {
    if (!!request?.headers?.[HEADER_USER_ID]) {
      request.body.usuario = { id: request.headers[HEADER_USER_ID] };
    } else request.body.usuario = null;

    // const palavras = request.body.palavras as Palavra[];
    // request.body.palavras = palavras.map((p) => p.id);

    return super.save(request, response, AppDataSource.getRepository(Turma));
  }

  public show(request: Request, response: Response) {
    return super.show(request, response, AppDataSource.getRepository(Turma));
  }

  public update(request: Request, response: Response) {
    if (!!request?.headers?.[HEADER_USER_ID]) {
      request.body.usuario = { id: request.headers[HEADER_USER_ID] };
    } else request.body.usuario = null;
    return super.update(request, response, AppDataSource.getRepository(Turma));
  }

  public remove(request: Request, response: Response) {
    return super.remove(request, response, AppDataSource.getRepository(Turma));
  }

  public async geraNovoCodigo(request: Request, response: Response) {
    try {
      const turmaId = request.params.id as string;
      const code = await geraCodigoUnicoParaTurma(Number(turmaId));
      return response.status(200).json({ code });
    } catch (error) {
      return response.status(500).json({ error: error.message });
    }
  }

  public async buscaTurmaPeloCodigo(request: Request, response: Response) {
    try {
      const codigo = request.params.codigo as string;
      const turma = await AppDataSource.getRepository(Turma).findOne({
        where: {
          codigo: codigo
        },
      });

      if (!turma?.id)
        return response.status(200).json({ message: "Código de sala inválido!" });

      if(turma.dataGeracaoCodigo < new Date(Date.now() - 24 * 60 * 60 * 1000)) {
        return response.status(200).json({ message: "Código de sala vencido!" });
      }

      const palavras: Palavra[] = await AppDataSource.getRepository(
        Palavra
      ).findBy({
        id: In(turma.palavras),
      });

      const personagens: Personagem[] = await AppDataSource.getRepository(
        Personagem
      ).findBy({
        usuario: { id: turma.usuario?.id },
      });

      return response.status(200).json({ turma, palavras, personagens });
    } catch (error) {
      return response.status(500).json({ error: error.message });
    }
  }
}

async function geraCodigoUnicoParaTurma(turmaId: number): Promise<string> {
  const turmaRepository = AppDataSource.getRepository(Turma);
  let uniqueCode: string;

  do {
    uniqueCode = generateRandomCode();
  } while (!(await isCodeUnique(uniqueCode)));

  const turma = await turmaRepository.findOneBy({ id: turmaId });
  if (!turma) {
    throw new Error("Turma não encontrada");
  }

  turma.codigo = uniqueCode;
  turma.dataGeracaoCodigo = new Date();
  await turmaRepository.save(turma);

  return uniqueCode;
}

async function isCodeUnique(code: string): Promise<boolean> {
  const turmaRepository = AppDataSource.getRepository(Turma);
  const turma = await turmaRepository.findOne({
    where: {
      codigo: code,
      dataGeracaoCodigo: MoreThan(new Date(Date.now() - 24 * 60 * 60 * 1000)),
    },
  });
  return !turma;
}

function generateRandomCode(): string {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  let code = "";
  for (let i = 0; i < 6; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}

export default new TurmaController();
