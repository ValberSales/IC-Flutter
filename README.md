# 🤟 Alfabetiza Libras - Plataforma Gamificada de Aprendizado de Libras

[![Flutter](https://img.shields.io/badge/Frontend-Flutter%203.x-02569B?logo=flutter)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM%20%7C%20Repository-orange)](https://flutter.dev)
[![Java](https://img.shields.io/badge/Backend-Spring%20Boot%203%20%7C%20Java%2025-007396?logo=openjdk)](https://spring.io)
[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL%2015-4169E1?logo=postgresql)](https://www.postgresql.org)
[![MinIO](https://img.shields.io/badge/Storage-MinIO-C72C48?logo=minio)](https://min.io)
[![Docker](https://img.shields.io/badge/Infrastructure-Docker-2496ED?logo=docker)](https://www.docker.com)
[![Tests](https://img.shields.io/badge/Tests-41%2F41%20Passing-success)](https://flutter.dev)

> 🎓 **Projeto de Iniciação Científica (IC) - UTFPR Câmpus Pato Branco**
> 
> Este repositório é fruto de uma pesquisa de Iniciação Científica (IC) dedicada ao aperfeiçoamento, modernização arquitetural e expansão da plataforma educativa desenvolvida originalmente como **Trabalho de Conclusão de Curso (TCC)** por **Luan Filipe Finatto**.
> 
> 🔗 Repositório de referência do TCC original: [finattttto/TCC](https://github.com/finattttto/TCC)

---

## 📌 Sobre o Projeto

O **Alfabetiza Libras** é uma plataforma educacional inclusiva e gamificada desenvolvida para auxiliar o ensino e a prática da Língua Brasileira de Sinais (Libras) para crianças e estudantes surdos ou ouvintes.

---

## 🎮 Funcionalidades Principais

### 1. Hub de Jogos Pedagógicos
- 🔤 **Alfabeto Manual**: Exploração e prática dos sinais dactilológicos das letras de A a Z e Ç com ilustrações e fotos de referência.
- 🧠 **Jogo da Memória**: Associação visual e memorização entre letras e seus respectivos sinais.
- 🔍 **Jogo de Adivinhação**: Montagem de palavras em Libras com card responsivo, slots dinâmicos, suporte a mouse/trackpad e feedback do mascote.
- 📖 **Jogo de Palavras**: Associação de imagens reais às palavras corretas com alternativas dinâmicas e balanceamento de distratores.

### 2. Níveis de Dificuldade & Gamificação
- Níveis **Fácil** (com dicas), **Médio** e **Difícil** (sem dicas) sincronizados perfeitamente em toda a aplicação.
- Rastreamento isolado de conclusão e percentual de aproveitamento que inicia em 0% e progride com as atividades concluídas.
- Diálogo animado de celebração com confetes ao atingir 100% de conclusão de cada módulo.

### 3. Autenticação Inclusiva & Gestão de Usuários
- 👶 **Cadastro Infantil Simplificado**: Apenas com o primeiro nome da criança, nome de usuário e avatar, sem exigir e-mail ou dados sensíveis.
- 🕹️ **Modo Convidado**: Permite que crianças joguem imediatamente sem necessidade de cadastro, mantendo o progresso salvo localmente.
- 👩‍🏫 **Área do Professor & Gestão Pedagógica**: Painel administrativo com gestão de turmas por código PIN, criação de atividades, relatórios analíticos de precisão por aluno/turma, exportação em CSV/impressão e gestão de perfil docente.

### 4. Cache e Armazenamento Offline de Mídias
- Gerenciamento local persistente de imagens e mídia no dispositivo móvel através de `MediaStorageService` com suporte a pré-carregamento determinístico por SHA-256 e pavimentação para reprodutor de vídeo.

---

## 🏗️ Arquitetura do Sistema

```
IC-Flutter/
├── flutter_client/         # Frontend Multiplataforma (Flutter / Web / Mobile)
│   ├── lib/
│   │   ├── core/           # Constantes de tema, cores, helpers e utilitários
│   │   ├── data/           # Models, Repositories, Services HTTP e Storage Local/Mídia
│   │   ├── state/          # Gerenciamento de Estado Central (AppStateProvider)
│   │   └── ui/             # Padrão MVVM: Views, ViewModels e Widgets por Feature
│   └── test/               # Suíte completa de testes unitários e de integração
└── server_java/            # Backend RESTful (Spring Boot 3 / Java 25)
    ├── src/main/java/br/com/interalibras/
    │   ├── config/         # Configurações de Segurança, MinIO e Seeder (DataLoader)
    │   ├── controller/     # Controllers REST concisos
    │   ├── entity/         # Entidades JPA (Usuario, Turma, Atividade, Pontuacao)
    │   ├── repository/     # Interfaces Spring Data JPA
    │   ├── security/       # JWT Auth Provider e Filters
    │   └── service/        # Camada de Serviços de Domínio e Regras de Negócio
    └── src/main/resources/ # application.yml
```

---

## 🚀 Como Executar o Projeto Localmente

### 1️⃣ Pré-requisitos
- **Flutter SDK** (3.x ou superior)
- **Java OpenJDK** (versão 21 ou 25) e **Maven**
- **Docker** e **Docker Compose**

---

### 2️⃣ Iniciar o Banco de Dados e Storage (Docker)
Certifique-se de que o **Docker Desktop** está em execução:
```bash
docker compose up -d
```
> Containers iniciados:
> - 🛢️ **PostgreSQL 15** na porta `5432`
> - 📦 **MinIO Storage** na porta `9000` (Console Admin na porta `9001`)

---

### 3️⃣ Iniciar o Servidor Backend (Spring Boot Java)
```bash
cd server_java
mvn clean spring-boot:run
```
> ℹ️ Servidor online em `http://localhost:8081`.

---

### 4️⃣ Iniciar a Aplicação Client (Flutter)
```bash
cd flutter_client
flutter pub get
flutter run -d chrome
```

---

## 🔑 Credenciais Padrão de Acesso

| Perfil | Usuário / Login | Senha |
| :--- | :--- | :--- |
| **Administrador / Professor** | `admin` | `123456` |

---

## 🤝 Créditos Oficiais

- **Autoria do Projeto (Flutter & Spring Boot)**: Valber Sales Junior
- **Orientadora**: Profª. Drª. Rúbia Eliza de Oliveira Schultz Ascari
- **Colaboradoras**: Profª. Me. Mirelia Flausino Vogel e Profª. Me. Aline Brancalione
- **Projeto Base Original (TCC em Angular/Node.js)**: Luan Filipe Finatto ([finattttto/TCC](https://github.com/finattttto/TCC))
- **Instituição**: Universidade Tecnológica Federal do Paraná (UTFPR) - Câmpus Pato Branco

---

## 📄 Licença e Direitos Reservados

Projeto desenvolvido para fins acadêmicos e pedagógicos no âmbito de Iniciação Científica (IC).  
© UTFPR - Câmpus Pato Branco. Todos os direitos reservados.
