import { Request, Response, NextFunction } from "express";
import * as jwt from "jsonwebtoken";
import configJwt from "./config-jwt";

export const HEADER_USERNAME = "username";
export const HEADER_USER_ID = "id";
export const HEADER_AUTH = "auth";

export const checkJwt = async (req: Request, res: Response, next: NextFunction) => {
  let token = <string>req.headers[HEADER_AUTH];
  let jwtPayload;
  try {
    jwtPayload = <any>jwt.verify(token, configJwt.jwtSecret);
    res.locals.jwtPayload = jwtPayload;
  } catch (error) {
    res.status(401).send("Não foi possível autorizar a requisição.");
    return;
  }

  req.headers[HEADER_USER_ID] = jwtPayload[HEADER_USER_ID];
  req.headers[HEADER_USERNAME] = jwtPayload[HEADER_USERNAME];
  
  next();
};