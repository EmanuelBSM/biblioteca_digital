// API REST da Biblioteca Digital com autenticação de usuários e administrador.
// Requer: npm install express

const express = require('express');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const app = express();
const PORTA = Number(process.env.PORT || 3000);
const ADMIN_LOGIN = process.env.ADMIN_LOGIN || 'admin';
const ADMIN_SENHA = process.env.ADMIN_SENHA || 'admin123';
const arquivoDados = path.join(__dirname, 'dados.json');
const sessoes = new Map(); // Tokens são invalidados quando a API é reiniciada.

app.use(express.json());

// Cria o arquivo de dados na primeira execução, sem apagar dados existentes.
if (!fs.existsSync(arquivoDados)) {
  fs.writeFileSync(
    arquivoDados,
    JSON.stringify({ livros: [], usuarios: [], emprestimos: [] }, null, 2)
  );
}

function lerDados() {
  const dados = JSON.parse(fs.readFileSync(arquivoDados, 'utf8'));
  dados.livros ||= [];
  dados.usuarios ||= [];
  dados.emprestimos ||= [];
  return dados;
}

function salvarDados(dados) {
  fs.writeFileSync(arquivoDados, JSON.stringify(dados, null, 2));
}

function proximoId(lista) {
  return lista.length
    ? Math.max(...lista.map(item => Number(item.id) || 0)) + 1
    : 1;
}

function emailNormalizado(email) {
  return String(email || '').trim().toLowerCase();
}

function criarHashSenha(senha) {
  const sal = crypto.randomBytes(16).toString('hex');
  const hash = crypto.scryptSync(String(senha), sal, 64).toString('hex');
  return `${sal}:${hash}`;
}

function conferirSenha(senha, senhaHash) {
  if (!senhaHash || !senhaHash.includes(':')) return false;

  const [sal, hashSalvo] = senhaHash.split(':');
  const hashAtual = crypto.scryptSync(String(senha), sal, 64);
  const hashEsperado = Buffer.from(hashSalvo, 'hex');

  return hashAtual.length === hashEsperado.length &&
    crypto.timingSafeEqual(hashAtual, hashEsperado);
}

function usuarioPublico(usuario) {
  return {
    id: usuario.id,
    nome: usuario.nome,
    email: usuario.email
  };
}

function criarSessao(tipo, usuario = null) {
  const token = crypto.randomBytes(32).toString('hex');
  sessoes.set(token, {
    tipo,
    usuarioId: usuario ? usuario.id : null
  });

  return {
    token,
    tipo,
    usuario: usuario ? usuarioPublico(usuario) : {
      nome: 'Administrador',
      login: ADMIN_LOGIN
    }
  };
}

function exigirLogin(req, res, next) {
  const authorization = req.headers.authorization || '';
  const token = authorization.startsWith('Bearer ')
    ? authorization.slice(7)
    : '';
  const sessao = sessoes.get(token);

  if (!sessao) {
    return res.status(401).json({ erro: 'Faça login para continuar.' });
  }

  req.token = token;
  req.sessao = sessao;
  next();
}

function exigirAdmin(req, res, next) {
  if (req.sessao.tipo !== 'admin') {
    return res.status(403).json({
      erro: 'Apenas o administrador pode executar esta ação.'
    });
  }
  next();
}

app.get('/', (req, res) => {
  res.json({ mensagem: 'API da Biblioteca Digital funcionando!' });
});

// CADASTRO DE USUÁRIO COMUM
app.post('/auth/cadastro', (req, res) => {
  const nome = String(req.body.nome || '').trim();
  const email = emailNormalizado(req.body.email);
  const senha = String(req.body.senha || '');

  if (!nome || !email || !senha) {
    return res.status(400).json({ erro: 'Informe nome, e-mail e senha.' });
  }
  if (!email.includes('@')) {
    return res.status(400).json({ erro: 'Informe um e-mail válido.' });
  }
  if (senha.length < 4) {
    return res.status(400).json({
      erro: 'A senha deve ter pelo menos 4 caracteres.'
    });
  }

  const dados = lerDados();
  const existente = dados.usuarios.find(
    usuario => emailNormalizado(usuario.email) === email
  );

  // Compatibilidade: permite criar senha para usuários cadastrados na versão antiga.
  if (existente && existente.senhaHash) {
    return res.status(409).json({
      codigo: 'EMAIL_DUPLICADO',
      erro: 'Este e-mail já está cadastrado. Faça login ou use outro e-mail.'
    });
  }

  let usuario;
  if (existente) {
    existente.nome = nome;
    existente.email = email;
    existente.senhaHash = criarHashSenha(senha);
    usuario = existente;
  } else {
    usuario = {
      id: proximoId(dados.usuarios),
      nome,
      email,
      senhaHash: criarHashSenha(senha)
    };
    dados.usuarios.push(usuario);
  }

  salvarDados(dados);
  res.status(201).json(criarSessao('usuario', usuario));
});

// LOGIN DE USUÁRIO OU ADMINISTRADOR
app.post('/auth/login', (req, res) => {
  const tipo = req.body.tipo || 'usuario';
  const senha = String(req.body.senha || '');

  if (tipo === 'admin') {
    const login = String(req.body.login || '').trim();
    if (login !== ADMIN_LOGIN || senha !== ADMIN_SENHA) {
      return res.status(401).json({
        erro: 'Login ou senha do administrador incorretos.'
      });
    }
    return res.json(criarSessao('admin'));
  }

  if (tipo !== 'usuario') {
    return res.status(400).json({ erro: 'Tipo de login inválido.' });
  }

  const email = emailNormalizado(req.body.email);
  const usuario = lerDados().usuarios.find(
    item => emailNormalizado(item.email) === email
  );

  if (!usuario || !conferirSenha(senha, usuario.senhaHash)) {
    return res.status(401).json({ erro: 'E-mail ou senha incorretos.' });
  }

  res.json(criarSessao('usuario', usuario));
});

// LOGOUT
app.post('/auth/logout', exigirLogin, (req, res) => {
  sessoes.delete(req.token);
  res.json({ mensagem: 'Logout realizado.' });
});

// LIVROS: consulta pública; apenas o administrador cadastra.
app.get('/livros', (req, res) => {
  res.json(lerDados().livros);
});

app.post('/livros', exigirLogin, exigirAdmin, (req, res) => {
  const titulo = String(req.body.titulo || '').trim();
  const autor = String(req.body.autor || '').trim();
  const ano = req.body.ano === null || req.body.ano === undefined || req.body.ano === ''
    ? null
    : Number(req.body.ano);

  if (!titulo || !autor) {
    return res.status(400).json({ erro: 'Informe o título e o autor.' });
  }
  if (ano !== null && !Number.isInteger(ano)) {
    return res.status(400).json({ erro: 'O ano deve ser um número inteiro.' });
  }

  const dados = lerDados();
  const livro = {
    id: proximoId(dados.livros),
    titulo,
    autor,
    ano,
    disponivel: true
  };

  dados.livros.push(livro);
  salvarDados(dados);
  res.status(201).json(livro);
});

// USUÁRIOS: apenas administrador pode consultar todos ou cadastrar manualmente.
app.get('/usuarios', exigirLogin, exigirAdmin, (req, res) => {
  res.json(lerDados().usuarios.map(usuarioPublico));
});

app.post('/usuarios', exigirLogin, exigirAdmin, (req, res) => {
  const nome = String(req.body.nome || '').trim();
  const email = emailNormalizado(req.body.email);
  const senha = String(req.body.senha || '');

  if (!nome || !email || !senha) {
    return res.status(400).json({ erro: 'Informe nome, e-mail e senha.' });
  }
  if (!email.includes('@')) {
    return res.status(400).json({ erro: 'Informe um e-mail válido.' });
  }
  if (senha.length < 4) {
    return res.status(400).json({ erro: 'A senha deve ter pelo menos 4 caracteres.' });
  }

  const dados = lerDados();
  if (dados.usuarios.some(item => emailNormalizado(item.email) === email)) {
    return res.status(409).json({
      codigo: 'EMAIL_DUPLICADO',
      erro: 'Este e-mail já está cadastrado.'
    });
  }

  const usuario = {
    id: proximoId(dados.usuarios),
    nome,
    email,
    senhaHash: criarHashSenha(senha)
  };

  dados.usuarios.push(usuario);
  salvarDados(dados);
  res.status(201).json(usuarioPublico(usuario));
});

// EMPRÉSTIMOS: usuário comum só vê e empresta para a própria conta.
app.get('/emprestimos', exigirLogin, (req, res) => {
  const emprestimos = lerDados().emprestimos;
  if (req.sessao.tipo === 'admin') return res.json(emprestimos);

  res.json(emprestimos.filter(
    item => item.id_usuario === req.sessao.usuarioId
  ));
});

app.post('/emprestimos', exigirLogin, (req, res) => {
  const idLivro = Number(req.body.id_livro);
  const idUsuario = req.sessao.tipo === 'admin'
    ? Number(req.body.id_usuario)
    : req.sessao.usuarioId;

  if (!idLivro || !idUsuario) {
    return res.status(400).json({ erro: 'Informe o livro e o usuário.' });
  }

  const dados = lerDados();
  const livro = dados.livros.find(item => item.id === idLivro);
  const usuario = dados.usuarios.find(item => item.id === idUsuario);

  if (!livro) return res.status(404).json({ erro: 'Livro não encontrado.' });
  if (!usuario) return res.status(404).json({ erro: 'Usuário não encontrado.' });
  if (!livro.disponivel) {
    return res.status(409).json({ erro: 'Este livro já está emprestado.' });
  }

  const emprestimo = {
    id: proximoId(dados.emprestimos),
    id_livro: livro.id,
    id_usuario: usuario.id,
    data_emprestimo: new Date().toISOString(),
    devolvido: false,
    data_devolucao: null
  };

  livro.disponivel = false;
  dados.emprestimos.push(emprestimo);
  salvarDados(dados);
  res.status(201).json(emprestimo);
});

// DEVOLUÇÃO: administrador ou o próprio usuário que pegou o livro.
app.post('/emprestimos/:id/devolver', exigirLogin, (req, res) => {
  const dados = lerDados();
  const emprestimo = dados.emprestimos.find(
    item => item.id === Number(req.params.id)
  );

  if (!emprestimo) {
    return res.status(404).json({ erro: 'Empréstimo não encontrado.' });
  }
  if (
    req.sessao.tipo !== 'admin' &&
    emprestimo.id_usuario !== req.sessao.usuarioId
  ) {
    return res.status(403).json({
      erro: 'Você não pode devolver o empréstimo de outro usuário.'
    });
  }
  if (emprestimo.devolvido) {
    return res.status(409).json({ erro: 'Este livro já foi devolvido.' });
  }

  emprestimo.devolvido = true;
  emprestimo.data_devolucao = new Date().toISOString();

  const livro = dados.livros.find(item => item.id === emprestimo.id_livro);
  if (livro) livro.disponivel = true;

  salvarDados(dados);
  res.json({ mensagem: 'Livro devolvido com sucesso.', emprestimo });
});

// Erro simples para JSON inválido.
app.use((erro, req, res, next) => {
  if (erro instanceof SyntaxError && erro.status === 400 && 'body' in erro) {
    return res.status(400).json({ erro: 'O corpo da requisição contém JSON inválido.' });
  }
  next(erro);
});

app.listen(PORTA, '0.0.0.0', () => {
  console.log(`API funcionando em http://localhost:${PORTA}`);
  console.log(`Login administrativo: ${ADMIN_LOGIN}`);
  console.log('Cadastro/login de usuário: /auth/cadastro e /auth/login');
});
