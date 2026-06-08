# TCC: Desenvolvimento de uma aplicação web interativa para contribuir com a alfabetização bilíngue de crianças surfas

Este repositório contém o código e a documentação do meu **Trabalho de Conclusão de Curso (TCC)**, que tem como objetivo o desenvolvimento de uma **aplicação web** para apoiar a alfabetização bilíngue de crianças surdas de 4 a 5 anos. O foco é o ensino de **Libras** (Língua Brasileira de Sinais) e o **Alfabeto Manual**, por meio de atividades educativas e interativas.

A aplicação permite **criar e personalizar personagens**, ajustar atividades e **acompanhar o progresso** dos alunos, proporcionando um aprendizado mais imersivo e adaptado às necessidades do público-alvo.

A aplicação pode ser acessada em [Alfabetiza Libras](https://libras.luizsv.com.br/).

## Tecnologias Utilizadas

A aplicação foi desenvolvida utilizando as seguintes tecnologias:

- **Frontend**:

  - **Angular**: Framework utilizado para a construção da interface de usuário.
  - **PrimeNG**: Biblioteca de componentes UI para Angular, utilizada para criar a interface visualmente agradável e responsiva.
  - **TypeScript**: Para garantir tipagem estática e maior segurança no desenvolvimento.
  - **IndexedDB**: Utilizado para o armazenamento persistente de dados no lado do cliente, como o progresso das atividades do aluno, respeitando as regras de negócio da aplicação.

- **Backend**:
  - **Node.js**: Plataforma utilizada para o desenvolvimento do servidor.
  - **Express.js**: Framework para gerenciamento de rotas e middlewares.
  - **TypeORM**: ORM utilizado para a integração com o banco de dados.
  - **PostgreSQL**: Banco de dados relacional utilizado para armazenar os dados da aplicação.

## Funcionalidades

- **Ensino de Libras**: Atividades baseadas em sinais de Libras e no Alfabeto Manual, estimulando o aprendizado bilíngue.

- **Cadastro de usuário**: Permite que o usuário crie uma conta dentro da aplicação.
- **Criação de personagens**: Permite que o usuário crie e personalize avatares que farão parte das atividades.
- **Personalização de atividades**: Adapte os exercícios e desafios para cada criança, levando em consideração seu progresso.
- **Acompanhamento de progresso**: Sistema que monitora o desempenho das crianças em cada atividade e oferece feedback.
- **Histórico de pontuação**: A aplicação armazena o historico de pontuação do personagem, para monitorar sua evolução.
- **Armazenamento Offline**: Utilização do **IndexedDB** para armazenar localmente o progresso das atividades e outros dados importantes no navegador, permitindo que o usuário continue seu aprendizado mesmo sem conexão com a internet.

## Recursos extras

Recursos extras utilizados para o desenvolvimento deste projeto:

- **Raccom**: Avatar utilizado como mascote da aplicação, utilizado para o feedback das atividades, disponivel em [OpenGameArt](https://opengameart.org/content/cute-raccoon-2d-game-sprite-and-animations).

- **Imagem de background**: Imagem utilizada como plano de fundo das atividades na aplicação, adquirida no site da [FreePik](www.freepik.com), disponível em: [Aquarela de fundo do dia da floresta](https://br.freepik.com/vetores-gratis/aquarela-de-fundo-do-dia-da-floresta_138739587.htm#fromView=search&page=1&position=20&uuid=cd82c59b-3ec6-4464-90f1-c771dcbd8298&new_detail=true&query=wallpaper+infantil+4k).

- **Avatares**: Pacote de avatares para personalizar os personagens, aquiridas no site da [FreePik](www.freepik.com), disponível em: [Pacote de ícones de diferentes perfis desenhados à mão](https://br.freepik.com/vetores-gratis/pacote-de-icones-de-diferentes-perfis-desenhados-a-mao_17863151.htm#fromView=search&page=1&position=2&uuid=d9c6e8e0-958e-48a0-a0f4-643e13b5d088&new_detail=true&query=avatar+infantil).

- **Materiais das atividades**: Os materiais padrões das atividades foram disponibilizados pelas professoras coorientadoras desse trabalho.

