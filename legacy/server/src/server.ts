import {
  AppDataSource,
  MAIN_DATABASE,
  Maintenance,
} from "./persistence/data-source";
import express from "express";
import cors from "cors";
import routes from "./routes/routes";

require("dotenv").config();

const app = express();

const PORT = process.env.PORT || 50990;

app.use(cors());
app.use(express.json({ limit: "50mb" }));
app.use(express.urlencoded({ extended: true }));

app.use("/server", routes);

Maintenance.initialize().then(() => {
  Maintenance.query(`Create database ${MAIN_DATABASE};`)
    .catch(() => console.log("Banco de dados já existe!"))
    .finally(() => {
      AppDataSource.initialize()
        .then(() => {
          AppDataSource.query(`CREATE EXTENSION if not exists unaccent;`)
            .then(() => { })
            .catch(() => { });
          app.listen(PORT, async () => {
            console.log(
              `\n======> Server is running in port: ${PORT}! :D <======\n`
            );
          });
        })
        .catch((error) => {
          console.log("Ops! Ocorreu um erro.");
          console.error(error);
        });
    });
});
