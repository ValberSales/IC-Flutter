import { Routes } from "@angular/router";
import { PaginaInicialComponent } from "./pages/pagina-inicial/pagina-inicial.component";
import { JogoAdivinhacaoComponent } from "./pages/jogo-adivinhacao/jogo-adivinhacao.component";
import { JogoAlfabetoManualComponent } from "./pages/jogo-alfabeto-manual/jogo-alfabeto-manual.component";
import { JogoMemoriaComponent } from "./pages/jogo-memoria/jogo-memoria.component";
import { TelaLoginUsuarioComponent } from "./pages/usuario/tela-login-usuario/tela-login-usuario.component";
import { TelaCadastroUsuarioComponent } from "./pages/usuario/tela-cadastro-usuario/tela-cadastro-usuario.component";
import { PaginaInicialUsuarioComponent } from "./pages/usuario/pagina-inicial-usuario/pagina-inicial-usuario.component";
import { JogoPalavrasComponent } from "./pages/jogo-palavras/jogo-palavras.component";
import { authGuard } from "./auth.guard";
import { SobreComponent } from "./pages/sobre/sobre.component";

export const routes: Routes = [
    { path: '', component: PaginaInicialComponent },
    { path: 'adivinhacao', component: JogoAdivinhacaoComponent },
    { path: 'alfabeto-manual', component: JogoAlfabetoManualComponent },
    { path: 'jogo-memoria', component: JogoMemoriaComponent },
    { path: 'jogo-palavra', component: JogoPalavrasComponent },
    { path: 'login', component: TelaLoginUsuarioComponent },
    { path: 'cadastro-user', component: TelaCadastroUsuarioComponent },
    { path: 'sobre', component: SobreComponent },

    { path: 'inicio-admin', component: PaginaInicialUsuarioComponent, canActivate: [authGuard] },
    { path: '**', redirectTo: '' }
];