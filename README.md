# 🤟 Alfabetiza Libras - Plataforma Gamificada de Aprendizado de Libras

[![Flutter](https://img.shields.io/badge/Frontend-Flutter%203.x-02569B?logo=flutter)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM%20%7C%20Repository-orange)](https://flutter.dev)
[![Java](https://img.shields.io/badge/Backend-Spring%20Boot%203%20%7C%20Java%2025-007396?logo=openjdk)](https://spring.io)
[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL%2015-4169E1?logo=postgresql)](https://www.postgresql.org)
[![MinIO](https://img.shields.io/badge/Storage-MinIO%20S3-C72C48?logo=minio)](https://min.io)
[![Docker](https://img.shields.io/badge/Infrastructure-Docker%20Compose-2496ED?logo=docker)](https://www.docker.com)
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
- 🔍 **Jogo de Adivinhação**: Montagem interativa de palavras em Libras com card central responsivo, slots dinâmicos, suporte a teclado/mouse/toque e feedback do mascote.
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

### 4. Arquitetura Híbrida & Suporte Offline
- **Persistência Local (SharedPreferences / IndexedDB / Hive)**: Permite o funcionamento fluido offline no navegador e em dispositivos móveis.
- **Cache de Mídias Local (`MediaStorageService`)**: Download e cache de imagens de atividades com nomenclatura determinística via hash SHA-256 no armazenamento persistente do dispositivo, economizando banda e pavimentando futuras expansões de vídeo.

---

## 🏗️ Arquitetura do Sistema

O projeto adota boas práticas de engenharia de software com separação clara de responsabilidades:

### 📱 Frontend Flutter (`flutter_client/`) — Padrão MVVM
```
flutter_client/
├── lib/
│   ├── core/               # Constantes (AppColors), helpers e diálogos reutilizáveis
│   │   └── profile/        # Subcomponentes modulares de perfil
│   ├── data/               # Models de Domínio, Repositories, Serviços de Mídia e API REST
│   │   ├── models/         # Usuario, Turma, Atividade, Pontuacao, Palavra
│   │   ├── repositories/   # AuthRepository, TurmaRepository, AtividadeRepository, RelatorioRepository
│   │   ├── services/       # ApiService (HTTP Client com interceptors)
│   │   └── storage/        # LocalStorageService e MediaStorageService (Cache local)
│   ├── state/              # Gerenciamento de Estado Central (AppStateProvider)
│   └── ui/                 # Telas (Views), ViewModels e Widgets específicos por Feature
│       ├── core/           # Widgets compartilhados (Header, Modais de Atividade, Dropzones)
│       └── features/       # area_professor, home, jogo_hub, jogo_adivinhacao, jogo_memoria, jogo_palavras...
└── test/                   # Suíte de 41 Testes Unitários e de Integração
```

### ☕ Backend Spring Boot (`server_java/`) — Arquitetura em Camadas
```
server_java/
└── src/main/java/br/com/interalibras/
    ├── config/             # Configurações do MinIO, Spring Security e Seeder (DataLoader)
    ├── controller/         # REST Controllers concisos (HTTP request handling e DTO responses)
    ├── entity/             # Entidades JPA (Usuario, Turma, Atividade, ItemAtividade, Pontuacao)
    ├── repository/         # Interfaces Spring Data JPA
    ├── security/           # JWT Token Provider, Auth Filters e UserDetails
    └── service/            # Camada de Serviços de Domínio (@Service com regras de negócio e analytics)
        ├── TurmaService.java
        ├── RelatorioService.java
        ├── UsuarioService.java
        ├── PontuacaoService.java
        └── AtividadeService.java
```

---

## 🚀 Como Executar o Projeto Localmente

### 1️⃣ Pré-requisitos
- **Flutter SDK** (3.24+ / 3.44+)
- **Java OpenJDK** (versão 21 ou 25) e **Apache Maven**
- **Docker** e **Docker Compose**

---

### 2️⃣ Iniciar os Serviços de Infraestrutura (Docker)
Inicie o banco de dados relacional e o storage S3:
```bash
docker compose up -d
```
> Serviços iniciados:
> - 🛢️ **PostgreSQL 15**: porta `5432` (`interalibras_db`)
> - 📦 **MinIO Storage**: porta `9000` (Console Administrativo em `http://localhost:9001`)

---

### 3️⃣ Iniciar o Servidor Backend (Spring Boot)
```bash
cd server_java
mvn clean spring-boot:run
```
> ℹ️ A API REST estará disponível em `http://localhost:8081`.

---

### 4️⃣ Iniciar a Aplicação Client (Flutter Web ou Mobile)
```bash
cd flutter_client
flutter pub get
flutter run -d chrome --web-port=3000
```
> 🌐 A aplicação Web abrirá em `http://localhost:3000`.

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

- **Desenvolvimento e Autoria (Flutter & Spring Boot)**: Valber Sales Junior
- **Orientadora**: Profª. Drª. Rúbia Eliza de Oliveira Schultz Ascari
- **Colaboradoras do Projeto**:
  - Profª. Me. Mirelia Flausino Vogel
  - Profª. Me. Aline Brancalione
- **Projeto Base de Referência (TCC em Angular/Node.js)**: Luan Filipe Finatto ([finattttto/TCC](https://github.com/finattttto/TCC))
- **Instituição de Ensino e Pesquisa**: Universidade Tecnológica Federal do Paraná (UTFPR) - Câmpus Pato Branco

---

## 📄 Licença e Direitos

Projeto desenvolvido estritamente para fins acadêmicos, educativos e de inclusão social no âmbito de Iniciação Científica (IC).  
© **UTFPR - Câmpus Pato Branco**. Todos os direitos reservados.
