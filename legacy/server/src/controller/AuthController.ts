import { Request, Response } from "express";
import * as jwt from "jsonwebtoken";
import { Usuario } from "../entity/Usuario";
import configJwt from "../jwt/config-jwt";
import { decrypt, encrypt } from "../cipher";
import { AppDataSource } from "../persistence/data-source";

class AuthController {
  public async login(request: Request, response: Response) {
    try {
      const { username, password } = request.body;
      const usuarioRepository = AppDataSource.getRepository(Usuario);
      const user = await usuarioRepository.findOneBy({
        username,
      });
      if (user) {
        console.log(user);
  
        const decrypted = decrypt(user?.password);
        if (decrypted == password) {
          const newToken = jwt.sign({ username, id: user.id }, configJwt.jwtSecret);
          return response.status(200).json({
            usuario: user,
            token: newToken,
          });
        }
      }
    } catch (e) {
      console.log(e);
    }

    return response.status(401).send("Usuário ou senha incorretos!");
  }

  public async cadastro(request: Request, response: Response) {
    try {
      const user = request.body as Usuario;
      const usuarioRepository = AppDataSource.getRepository(Usuario);

      const found = await usuarioRepository.findOneBy({
        username: user.username,
      });
      if (found) {
        return response.status(409).send({ message: "Usuário já cadastrado!" });
      }

      user.password = encrypt(user?.password);
      const saved = await usuarioRepository.save(user);

      const newToken = jwt.sign(
        { id: saved.id, username: user.username },
        configJwt.jwtSecret
      );

      return response.status(200).json({
        usuario: saved,
        token: newToken,
      });
    } catch (e: any) {
      return response.status(500).send(e?.message);
    }
  }
}

export default new AuthController();
