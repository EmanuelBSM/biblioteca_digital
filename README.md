# Biblioteca Digital — API REST + Flutter

Projeto didático simples com cadastro/login de usuários, login administrativo, catálogo de livros, empréstimos e devoluções.

## 1. Iniciar a API

No terminal, entre na pasta `api` e execute:

```bash
npm install
npm start
```

A API inicia em `http://localhost:3000`.

## 2. Acesso administrativo

Login inicial:

- Usuário: `admin`
- Senha: `admin123`

O administrador pode cadastrar livros, consultar usuários e gerenciar empréstimos. Para trocar as credenciais, defina as variáveis de ambiente `ADMIN_LOGIN` e `ADMIN_SENHA` antes de iniciar o servidor.

## 3. Usuários

Na tela inicial do Flutter, selecione **Usuário** e escolha **Não tem conta? Cadastre-se**. Informe nome, e-mail e senha. Após o cadastro, o aplicativo entra automaticamente na conta.

O usuário pode consultar o catálogo, pegar livros emprestados e devolver apenas os próprios empréstimos.

## 4. Preparar e executar o Flutter

Na pasta do projeto Flutter (onde está `pubspec.yaml`):

```bash
flutter pub add http
flutter pub get
flutter run -d windows
```

Copie `flutter/lib/main.dart` e `flutter/lib/biblioteca_api.dart` deste pacote para a pasta `lib` do projeto Flutter.

No arquivo `biblioteca_api.dart`, o endereço padrão é `http://localhost:3000` para Windows. Para Android Emulator, altere para `http://10.0.2.2:3000`.

## 5. Regras básicas de acesso

- Qualquer pessoa pode consultar o catálogo de livros.
- Somente o administrador autenticado pode cadastrar livros e consultar todos os usuários e empréstimos.
- Usuários autenticados podem fazer empréstimos para a própria conta e devolver somente seus próprios livros.
- As senhas dos usuários são armazenadas como hash com salt; não são devolvidas pela API.
- Os tokens são mantidos em memória e expiram quando o servidor é reiniciado. É uma autenticação simplificada para projeto didático, não um sistema de produção.

## 6. Endpoints

| Método | Endpoint | Acesso | Função |
|---|---|---|---|
| POST | `/auth/cadastro` | Público | Criar conta de usuário |
| POST | `/auth/login` | Público | Login de usuário ou administrador |
| POST | `/auth/logout` | Logado | Encerrar sessão |
| GET | `/livros` | Público | Listar livros |
| POST | `/livros` | Administrador | Cadastrar livro |
| GET | `/usuarios` | Administrador | Listar usuários |
| GET | `/emprestimos` | Logado | Listar empréstimos permitidos ao perfil |
| POST | `/emprestimos` | Logado | Registrar empréstimo |
| POST | `/emprestimos/:id/devolver` | Logado | Registrar devolução |

Os dados são armazenados em `api/dados.json`, criado automaticamente na primeira execução. Se já existir um arquivo com usuários antigos (sem senha), o usuário pode criar uma senha pela tela de cadastro usando o mesmo e-mail.
