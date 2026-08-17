# 🤟 Alfabetiza Libras - Plataforma Gamificada de Aprendizado de Libras

[![Flutter](https://img.shields.io/badge/Frontend-Flutter%203.x-02569B?logo=flutter)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM%20%7C%20Repository-orange)](https://flutter.dev)
[![Java](https://img.shields.io/badge/Backend-Spring%20Boot%203%20%7C%20Java%2021-007396?logo=openjdk)](https://spring.io)
[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL%2015-4169E1?logo=postgresql)](https://www.postgresql.org)
[![MinIO](https://img.shields.io/badge/Storage-MinIO%20S3-C72C48?logo=minio)](https://min.io)
[![Docker](https://img.shields.io/badge/Microservices-Docker%20Compose-2496ED?logo=docker)](https://www.docker.com)
[![Cloudflare](https://img.shields.io/badge/Deploy-Cloudflare%20Tunnel-F38020?logo=cloudflare)](https://cloudflare.com)
[![Tests](https://img.shields.io/badge/Tests-41%2F41%20Passing%20(100%25)-success)](https://flutter.dev)

> 🎓 **Projeto de Iniciação Científica (IC) - UTFPR Câmpus Pato Branco**
> 
> Este repositório é fruto de uma pesquisa acadêmica de Iniciação Científica (IC) dedicada ao aperfeiçoamento, modernização arquitetural e expansão da plataforma educativa desenvolvida originalmente como **Trabalho de Conclusão de Curso (TCC)** por **Luan Filipe Finatto**.
> 
> 🔗 Repositório de referência do TCC original: [finattttto/TCC](https://github.com/finattttto/TCC)

---

## 📌 Sobre o Projeto

O **Alfabetiza Libras** é uma plataforma educacional interativa, responsiva e inclusiva desenvolvida para auxiliar o aprendizado e a alfabetização em **Língua Brasileira de Sinais (Libras)** para crianças e estudantes surdos ou ouvintes.

A aplicação combina **metodologias lúdicas de gamificação**, **acessibilidade visual adaptada**, **gestão de turmas por código PIN** e **métricas pedagógicas detalhadas** para professores e educadores.

---

## 🎮 Funcionalidades Principais

### 1. Hub de Jogos Pedagógicos
- 🔤 **Alfabeto Manual & Dactilologia**: Exploração de todas as letras de A a Z e Ç, combinando ilustrações didáticas e fotos reais com as mãos.
- 🧠 **Jogo da Memória**: Associação visual e memorização de pares entre letras e suas configurações de mão em Libras.
- 🔍 **Jogo de Adivinhação**: Montagem interativa de palavras em Libras com card central responsivo, slots dinâmicos, suporte a teclado/mouse/toque e feedback visual e animado do mascote guaxinim.
- 📖 **Jogo de Palavras**: Associação de imagens reais às palavras corretas com alternativas dinâmicas e distribuição balanceada de distratores.

### 2. Níveis de Dificuldade & Gamificação
- Três níveis de desafio perfeitamente calibrados:
  - 🟢 **Fácil**: Com dicas visuais e apoio inicial.
  - 🟡 **Médio**: Desafios intermediários com menor tempo de apoio.
  - 🔴 **Difícil**: Sem dicas, ideal para fixação avançada.
- Rastreamento isolado de conclusão e percentual de aproveitamento com início em 0% e progressão real.
- Diálogo animado de celebração com confetes e incentivo ao atingir 100% de conclusão de cada módulo.

### 3. Autenticação Inclusiva & Gestão de Usuários
- 👶 **Cadastro Infantil Simplificado**: Apenas o primeiro nome da criança, gerando automaticamente identificador único e avatar divertido sem coletar dados sensíveis.
- 🕹️ **Modo Convidado**: Permite acesso imediato aos jogos educativos sem necessidade de cadastro, salvando progresso localmente.
- 👩‍🏫 **Área do Professor & Gestão Pedagógica**:
  - **Turmas Escolares**: Criação e gestão de turmas com geração de código PIN único (ex: `LBR-4821`) para acesso simplificado dos alunos.
  - **Criação de Atividades**: Construtor completo de novos temas e palavras para os jogos de Adivinhação e Palavras, com upload e pré-visualização de imagens.
  - **Direcionamento e Visibilidade**: Controle granular de temas públicos (para todos) ou privados (exclusivos para turmas específicas).
  - **Analytics & Relatórios**: Painel com cálculo de taxa de aproveitamento, distribuição de níveis dominados e exportação em CSV ou impressão formatada.
  - **Perfil Docente**: Gerenciamento de credenciais, troca de senha e alteração de avatar.

### 4. Responsividade, Orientação & Design de Ícones
- 📱 **Bloqueio de Rotação em Smartphones**: Em celulares (`shortestSide < 600dp`), o aplicativo fixa a orientação em modo retrato (*portrait*) para conforto e ergonomia infantil.
- 🖥️ **Rotação Livre em Tablets e Web**: Em tablets e navegadores desktop, a rotação e o layout responsivo são totalmente liberados.
- 🦝 **Material 3 Adaptive Icons (Android 13+ / Monet Engine)**:
  - **Camada Foreground**: Rosto do mascote guaxinim centralizado e perfeitamente ajustado na *safe zone* circular (72dp) do canvas de 108dp.
  - **Camada Background**: Suporte dinâmico a tema claro (`#8C52FF` $\rightarrow$ `#512DA8`) e tema escuro (`#512DA8` $\rightarrow$ `#1E0A45`).
  - **Themed Icons**: Camada monocromática que adapta o ícone às cores do papel de parede do usuário.
- 🌐 **Favicon Web Transparente**: Favicon vetorial com o rosto do mascote isolado com fundo transparente.

---

## 🏗️ Arquitetura do Sistema

O projeto adota boas práticas de engenharia de software com arquitetura em microsserviços containerizados:

```
IC-Flutter/
├── docker-compose.yml       # Orquestração completa de microsserviços (OrbStack / Docker)
├── .env.example             # Modelo seguro de variáveis de ambiente
├── server_java/             # Backend REST em Spring Boot (Java 21)
│   ├── Dockerfile           # Build multi-stage Maven + JRE 21 Alpine
│   └── src/main/java/br/com/alfabetizalibras/
└── flutter_client/          # Frontend Multiplataforma Flutter (Web & Android)
    ├── Dockerfile           # Build Flutter Web + Nginx Alpine SPA
    ├── nginx.conf           # Servidor Web com suporte a roteamento SPA e gzip
    ├── assets/raccoon/      # Vetores SVG e assets visuais do mascote
    ├── android/             # Configurações nativas, drawables e ícones adaptativos
    └── lib/                 # Código-fonte Dart (Padrão MVVM com ChangeNotifier/Provider)
```

---

## 🚀 Execução em Microsserviços (Docker / OrbStack)

A stack inteira foi containerizada no padrão microsserviços para subir localmente ou em produção com um único comando.

### 1️⃣ Configurar o Ambiente
Copie o template de variáveis de ambiente:
```bash
cp .env.example .env
```
*(Preencha os valores de senhas e, se for utilizar o túnel da Cloudflare, insira o `CLOUDFLARE_TUNNEL_TOKEN`).*

### 2️⃣ Subir todos os Microsserviços
```bash
docker compose up -d --build
```
> **Serviços Orquestrados**:
> - 🛢️ **postgres** (`:5432`): Banco de dados relacional PostgreSQL 15.
> - 📦 **minio** (`:9000` / `:9001`): Armazenamento de arquivos e imagens S3-compatible.
> - 🔧 **createbuckets**: Job que provisiona e configura políticas públicas no MinIO.
> - ☕ **backend** (`:8081`): API REST em Spring Boot (Java 21).
> - 🌐 **frontend** (`:3000`): Servidor Nginx com Flutter Web SPA.
> - ☁️ **tunnel**: Conector Cloudflare Tunnel para publicação online segura.

---

## 📱 Build do APK Android

Para compilar o pacote de produção apontando dinamicamente para a API online:

```bash
cd flutter_client
flutter build apk --release --dart-define=API_URL=https://al-api.pepperdelivery.com.br
```

O arquivo gerado estará disponível em:
`flutter_client/build/app/outputs/flutter-apk/app-release.apk`

---

## 🧪 Execução de Testes Automatizados

### Testes do Frontend (Flutter)
```bash
cd flutter_client
flutter test
```
> ✅ **41/41 testes passando com 100% de cobertura funcional** (Fluxos de autenticação, persistência, regras de visibilidade de turmas, repositórios e ViewModels de jogos).

### Compilação do Backend (Maven)
```bash
cd server_java
mvn test-compile
```

---

## 🔑 Credenciais Padrão de Acesso

| Perfil | Usuário / Login | Senha Padrão |
| :--- | :--- | :--- |
| **Administrador / Professor** | `admin` | `123456` |

---

## 🤝 Créditos Oficiais & Autoria

- **Desenvolvimento (IC Flutter & Spring Boot)**: Valber Sales Junior
- **Orientadora**: Profª. Drª. Rúbia Eliza de Oliveira Schultz Ascari
- **Colaboradores do Projeto**:
  - Profª. Me. Mirelia Flausino Vogel
  - Profª. Me. Aline Brancalione
  - Isacar Floriano de Freitas Junior
- **Projeto Base de Referência (TCC em Angular/Node.js)**: Luan Filipe Finatto ([finattttto/TCC](https://github.com/finattttto/TCC))
- **Instituição de Ensino e Pesquisa**: Universidade Tecnológica Federal do Paraná (UTFPR) - Câmpus Pato Branco

---

## 📄 Licença e Direitos

Projeto desenvolvido estritamente para fins acadêmicos, educativos e de inclusão social no âmbito de Iniciação Científica (IC).  
© **UTFPR - Câmpus Pato Branco**. Todos os direitos reservados.
