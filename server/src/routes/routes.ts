import { Router } from "express";
import UsuarioController from "../controller/UsuarioController";
import PalavraController from "../controller/PalavraController";
import PersonagemController from "../controller/PersonagemController";
import PontuacaoController from "../controller/PontuacaoController";
import TurmaController from "../controller/TurmaController";
import { checkJwt } from "../jwt/check-jwt";
import AuthController from "../controller/AuthController";

const routes = Router();

routes.route("/login").post(AuthController.login);

routes.route("/cadastro").post(AuthController.cadastro);

routes.route("/turma-busca/:codigo").get(TurmaController.buscaTurmaPeloCodigo);

routes
  .route("/pontuacao-personagem/:id")
  .get(PontuacaoController.buscaPontuacaPeloPersonagem);

routes.use(checkJwt);

routes
  .route("/palavra")
  .get(PalavraController.index)
  .post(PalavraController.save);

routes
  .route("/palavra/:id")
  .get(PalavraController.show)
  .put(PalavraController.update)
  .delete(PalavraController.remove);

routes
  .route("/personagem")
  .get(PersonagemController.index)
  .post(PersonagemController.save);

routes
  .route("/personagem/:id")
  .get(PersonagemController.show)
  .put(PersonagemController.update)
  .delete(PersonagemController.remove);

routes
  .route("/pontuacao")
  .get(PontuacaoController.index)
  .post(PontuacaoController.save);

routes
  .route("/pontuacao/:id")
  .get(PontuacaoController.show)
  .put(PontuacaoController.update)
  .delete(PontuacaoController.remove);

routes.route("/turma-codigo/:id").get(TurmaController.geraNovoCodigo);

routes.route("/turma").get(TurmaController.index).post(TurmaController.save);

routes
  .route("/turma/:id")
  .get(TurmaController.show)
  .put(TurmaController.update)
  .delete(TurmaController.remove);

routes
  .route("/usuario")
  .get(UsuarioController.index)
  .post(UsuarioController.save);

routes
  .route("/usuario/:id")
  .get(UsuarioController.show)
  .put(UsuarioController.update)
  .delete(UsuarioController.remove);

export default routes;
