import 'package:flutter/material.dart';
import 'biblioteca_api.dart';

void main() => runApp(const BibliotecaApp());

class BibliotecaApp extends StatefulWidget {
  const BibliotecaApp({super.key});

  @override
  State<BibliotecaApp> createState() => _BibliotecaAppState();
}

class _BibliotecaAppState extends State<BibliotecaApp> {
  final BibliotecaApi api = BibliotecaApi();
  bool logado = false;
  bool administrador = false;
  Map<String, dynamic> usuario = {};

  void entrar(Map<String, dynamic> dados) {
    setState(() {
      logado = true;
      administrador = dados['tipo'] == 'admin';
      usuario = Map<String, dynamic>.from(dados['usuario'] ?? {});
    });
  }

  Future<void> sair() async {
    await api.logout();
    if (!mounted) return;
    setState(() {
      logado = false;
      administrador = false;
      usuario = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Biblioteca Digital',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF7F7FB),
      ),
      home: !logado
          ? LoginPage(api: api, onEntrar: entrar)
          : administrador
              ? AdminHomePage(api: api, onSair: sair)
              : UsuarioHomePage(api: api, usuario: usuario, onSair: sair),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.api, required this.onEntrar});
  final BibliotecaApi api;
  final ValueChanged<Map<String, dynamic>> onEntrar;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final senha = TextEditingController();
  final loginAdmin = TextEditingController(text: 'admin');

  // Os controladores e a chave do formulário pertencem ao State da tela.
  // O cadastro é exibido na própria tela, sem abrir AlertDialog/rota modal.
  final nomeCadastro = TextEditingController();
  final emailCadastro = TextEditingController();
  final senhaCadastro = TextEditingController();
  final cadastroFormKey = GlobalKey<FormState>();

  bool modoAdmin = false;
  bool mostrarCadastro = false;
  bool ocultarSenha = true;
  bool ocultarSenhaCadastro = true;
  bool carregando = false;
  String? erroCadastro;

  @override
  void dispose() {
    email.dispose();
    senha.dispose();
    loginAdmin.dispose();
    nomeCadastro.dispose();
    emailCadastro.dispose();
    senhaCadastro.dispose();
    super.dispose();
  }

  void mensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  Future<void> entrar() async {
    if (senha.text.isEmpty ||
        (modoAdmin
            ? loginAdmin.text.trim().isEmpty
            : email.text.trim().isEmpty)) {
      mensagem('Preencha os campos de login e senha.');
      return;
    }

    setState(() => carregando = true);
    try {
      final dados = modoAdmin
          ? await widget.api.loginAdmin(loginAdmin.text.trim(), senha.text)
          : await widget.api.loginUsuario(email.text.trim(), senha.text);

      if (!mounted) return;
      widget.onEntrar(dados);
    } catch (e) {
      mensagem(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> cadastrar() async {
    if (!(cadastroFormKey.currentState?.validate() ?? false)) return;

    setState(() {
      carregando = true;
      erroCadastro = null;
    });
    try {
      final dados = await widget.api.cadastrarUsuario(
        nomeCadastro.text.trim(),
        emailCadastro.text.trim(),
        senhaCadastro.text,
      );

      if (!mounted) return;
      // A API já devolve o token e os dados do usuário. O app troca a tela
      // principal sem precisar fechar um diálogo que ainda esteja animando.
      widget.onEntrar(dados);
    } catch (e) {
      if (!mounted) return;
      final erro = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        erroCadastro = erro;
      });
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return mostrarCadastro ? _telaCadastro(context) : _telaLogin(context);
  }

  Widget _telaCadastro(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
        leading: IconButton(
          tooltip: 'Voltar',
          icon: const Icon(Icons.arrow_back),
          onPressed: carregando
              ? null
              : () => setState(() => mostrarCadastro = false),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: cadastroFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        child: Icon(Icons.person_add_alt_1, size: 32),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Cadastro de usuário',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: nomeCadastro,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Nome completo',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (valor) =>
                            (valor == null || valor.trim().isEmpty)
                                ? 'Informe seu nome.'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: emailCadastro,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) {
                          if (erroCadastro != null) {
                            setState(() => erroCadastro = null);
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (valor) =>
                            (valor == null || !valor.trim().contains('@'))
                                ? 'Informe um e-mail válido.'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: senhaCadastro,
                        obscureText: ocultarSenhaCadastro,
                        decoration: InputDecoration(
                          labelText: 'Senha (mínimo 4 caracteres)',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: ocultarSenhaCadastro
                                ? 'Mostrar senha'
                                : 'Ocultar senha',
                            icon: Icon(
                              ocultarSenhaCadastro
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () => setState(() {
                              ocultarSenhaCadastro = !ocultarSenhaCadastro;
                            }),
                          ),
                        ),
                        validator: (valor) =>
                            (valor == null || valor.length < 4)
                                ? 'Use pelo menos 4 caracteres.'
                                : null,
                      ),
                      if (erroCadastro != null) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            erroCadastro!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: carregando ? null : cadastrar,
                          child: carregando
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Criar conta'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: carregando
                            ? null
                            : () => setState(() {
                                  mostrarCadastro = false;
                                  erroCadastro = null;
                                }),
                        child: const Text('Já tenho uma conta'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _telaLogin(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 34,
                      child: Icon(Icons.local_library, size: 36),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Biblioteca Digital',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text('Entre para acessar o sistema'),
                    const SizedBox(height: 24),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('Usuário'),
                          icon: Icon(Icons.person),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text('Administrador'),
                          icon: Icon(Icons.admin_panel_settings),
                        ),
                      ],
                      selected: {modoAdmin},
                      onSelectionChanged: carregando
                          ? null
                          : (valor) =>
                              setState(() => modoAdmin = valor.first),
                    ),
                    const SizedBox(height: 20),
                    if (modoAdmin)
                      TextField(
                        controller: loginAdmin,
                        decoration: const InputDecoration(
                          labelText: 'Login administrativo',
                          prefixIcon: Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(),
                        ),
                      )
                    else
                      TextField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: senha,
                      obscureText: ocultarSenha,
                      onSubmitted: (_) => entrar(),
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            ocultarSenha
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() {
                            ocultarSenha = !ocultarSenha;
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: carregando ? null : entrar,
                        child: carregando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Entrar'),
                      ),
                    ),
                    if (!modoAdmin)
                      TextButton(
                        onPressed: carregando
                            ? null
                            : () => setState(() => mostrarCadastro = true),
                        child: const Text('Não tem conta? Cadastre-se'),
                      ),
                    if (modoAdmin) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Acesso inicial: admin / admin123',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key, required this.api, required this.onSair});
  final BibliotecaApi api;
  final VoidCallback onSair;

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int abaAtual = 0;
  bool carregando = true;
  List<dynamic> livros = [], usuarios = [], emprestimos = [];

  @override
  void initState() { super.initState(); carregarDados(); }

  void mensagem(String texto) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto))); }

  Future<void> carregarDados() async {
    setState(() => carregando = true);
    try {
      final dados = await Future.wait([widget.api.listarLivros(), widget.api.listarUsuarios(), widget.api.listarEmprestimos()]);
      if (!mounted) return;
      setState(() { livros = dados[0]; usuarios = dados[1]; emprestimos = dados[2]; });
    } catch (e) { mensagem('Falha ao carregar dados: $e'); }
    finally { if (mounted) setState(() => carregando = false); }
  }

  Future<void> adicionarLivro() async {
    final titulo = TextEditingController(), autor = TextEditingController(), ano = TextEditingController();
    final formulario = GlobalKey<FormState>();
    final salvar = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Cadastrar livro'),
      content: Form(key: formulario, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: titulo, decoration: const InputDecoration(labelText: 'Título'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o título' : null),
        TextFormField(controller: autor, decoration: const InputDecoration(labelText: 'Autor'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o autor' : null),
        TextField(controller: ano, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Ano (opcional)')),
      ]))),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () { if (formulario.currentState!.validate()) Navigator.pop(context, true); }, child: const Text('Salvar'))],
    ));
    if (salvar == true) {
      try {
        await widget.api.cadastrarLivro(titulo.text.trim(), autor.text.trim(), ano: ano.text.trim().isEmpty ? null : int.tryParse(ano.text.trim()));
        await carregarDados(); mensagem('Livro cadastrado.');
      } catch (e) { mensagem('Erro: $e'); }
    }
    titulo.dispose(); autor.dispose(); ano.dispose();
  }

  Future<void> novoEmprestimo() async {
    final disponiveis = livros.where((l) => l['disponivel'] == true).toList();
    if (disponiveis.isEmpty || usuarios.isEmpty) { mensagem('É necessário ter livros disponíveis e usuários cadastrados.'); return; }
    int? idLivro = (disponiveis.first['id'] as num).toInt();
    int? idUsuario = (usuarios.first['id'] as num).toInt();
    final dados = await showDialog<Map<String, int>>(context: context, builder: (context) => StatefulBuilder(builder: (context, atualizar) => AlertDialog(
      title: const Text('Registrar empréstimo'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<int>(value: idLivro, isExpanded: true, decoration: const InputDecoration(labelText: 'Livro'), items: disponiveis.map((l) => DropdownMenuItem(value: (l['id'] as num).toInt(), child: Text(l['titulo'].toString(), overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) => atualizar(() => idLivro = v)),
        DropdownButtonFormField<int>(value: idUsuario, isExpanded: true, decoration: const InputDecoration(labelText: 'Usuário'), items: usuarios.map((u) => DropdownMenuItem(value: (u['id'] as num).toInt(), child: Text(u['nome'].toString(), overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) => atualizar(() => idUsuario = v)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), FilledButton(onPressed: () { if (idLivro != null && idUsuario != null) Navigator.pop(context, {'livro': idLivro!, 'usuario': idUsuario!}); }, child: const Text('Confirmar'))],
    )));
    if (dados == null) return;
    try { await widget.api.emprestarLivro(dados['livro']!, idUsuario: dados['usuario']); await carregarDados(); mensagem('Empréstimo registrado.'); }
    catch (e) { mensagem('Erro: $e'); }
  }

  Future<void> devolver(int id) async {
    try { await widget.api.devolverLivro(id); await carregarDados(); mensagem('Devolução registrada.'); }
    catch (e) { mensagem('Erro: $e'); }
  }

  String nomeLivro(int id) {
    final encontrados = livros.where((l) => (l['id'] as num).toInt() == id);
    return encontrados.isEmpty ? 'Livro #$id' : encontrados.first['titulo'].toString();
  }

  String nomeUsuario(int id) {
    final encontrados = usuarios.where((u) => (u['id'] as num).toInt() == id);
    return encontrados.isEmpty ? 'Usuário #$id' : encontrados.first['nome'].toString();
  }

  @override
  Widget build(BuildContext context) {
    final titulos = ['Livros', 'Usuários', 'Empréstimos'];
    return Scaffold(
      appBar: AppBar(title: Text('Administração • ${titulos[abaAtual]}'), actions: [IconButton(onPressed: carregarDados, icon: const Icon(Icons.refresh), tooltip: 'Atualizar'), IconButton(onPressed: widget.onSair, icon: const Icon(Icons.logout), tooltip: 'Sair')]),
      body: carregando && livros.isEmpty && usuarios.isEmpty && emprestimos.isEmpty ? const Center(child: CircularProgressIndicator()) : _conteudo(),
      floatingActionButton: abaAtual == 0 ? FloatingActionButton.extended(onPressed: adicionarLivro, icon: const Icon(Icons.add), label: const Text('Cadastrar livro')) : abaAtual == 2 ? FloatingActionButton.extended(onPressed: novoEmprestimo, icon: const Icon(Icons.add), label: const Text('Empréstimo')) : null,
      bottomNavigationBar: NavigationBar(selectedIndex: abaAtual, onDestinationSelected: (v) => setState(() => abaAtual = v), destinations: const [NavigationDestination(icon: Icon(Icons.menu_book), label: 'Livros'), NavigationDestination(icon: Icon(Icons.people), label: 'Usuários'), NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Empréstimos')]),
    );
  }

  Widget _vazio(String texto) => Center(child: Text(texto, textAlign: TextAlign.center));

  Widget _conteudo() {
    if (abaAtual == 0) return livros.isEmpty ? _vazio('Nenhum livro cadastrado.') : ListView(children: livros.map((l) => Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), child: ListTile(leading: const Icon(Icons.menu_book), title: Text(l['titulo'].toString()), subtitle: Text('${l['autor']} • ${l['ano'] ?? 'Ano não informado'}'), trailing: Text(l['disponivel'] == true ? 'Disponível' : 'Emprestado')))).toList());
    if (abaAtual == 1) return usuarios.isEmpty ? _vazio('Nenhum usuário cadastrado.') : ListView(children: usuarios.map((u) => Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), child: ListTile(leading: const Icon(Icons.person), title: Text(u['nome'].toString()), subtitle: Text(u['email'].toString())))).toList());
    return emprestimos.isEmpty ? _vazio('Nenhum empréstimo registrado.') : ListView(children: emprestimos.map((e) {
      final id = (e['id'] as num).toInt();
      final titulo = nomeLivro((e['id_livro'] as num).toInt());
      final nome = nomeUsuario((e['id_usuario'] as num).toInt());
      final devolvido = e['devolvido'] == true;
      return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), child: ListTile(leading: const Icon(Icons.assignment), title: Text(titulo), subtitle: Text('$nome • Empréstimo #$id'), trailing: devolvido ? const Text('Devolvido') : TextButton(onPressed: () => devolver(id), child: const Text('Devolver'))));
    }).toList());
  }
}

class UsuarioHomePage extends StatefulWidget {
  const UsuarioHomePage({super.key, required this.api, required this.usuario, required this.onSair});
  final BibliotecaApi api;
  final Map<String, dynamic> usuario;
  final VoidCallback onSair;

  @override
  State<UsuarioHomePage> createState() => _UsuarioHomePageState();
}

class _UsuarioHomePageState extends State<UsuarioHomePage> {
  int aba = 0;
  bool carregando = true;
  List<dynamic> livros = [], emprestimos = [];

  @override
  void initState() { super.initState(); carregar(); }

  void mensagem(String texto) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto))); }

  Future<void> carregar() async {
    setState(() => carregando = true);
    try {
      final dados = await Future.wait([widget.api.listarLivros(), widget.api.listarEmprestimos()]);
      if (!mounted) return;
      setState(() { livros = dados[0]; emprestimos = dados[1]; });
    } catch (e) { mensagem('Erro ao carregar: $e'); }
    finally { if (mounted) setState(() => carregando = false); }
  }

  Future<void> emprestar(int idLivro) async {
    try { await widget.api.emprestarLivro(idLivro); await carregar(); mensagem('Empréstimo realizado.'); }
    catch (e) { mensagem('Não foi possível emprestar: $e'); }
  }

  Future<void> devolver(int id) async {
    try { await widget.api.devolverLivro(id); await carregar(); mensagem('Livro devolvido.'); }
    catch (e) { mensagem('Não foi possível devolver: $e'); }
  }

  String nomeLivro(int id) {
    final encontrados = livros.where((l) => (l['id'] as num).toInt() == id);
    return encontrados.isEmpty ? 'Livro #$id' : encontrados.first['titulo'].toString();
  }

  @override
  Widget build(BuildContext context) {
    final nome = widget.usuario['nome'] ?? 'Usuário';
    return Scaffold(
      appBar: AppBar(title: Text('Olá, $nome'), actions: [IconButton(onPressed: carregar, icon: const Icon(Icons.refresh), tooltip: 'Atualizar'), IconButton(onPressed: widget.onSair, icon: const Icon(Icons.logout), tooltip: 'Sair')]),
      body: carregando && livros.isEmpty && emprestimos.isEmpty ? const Center(child: CircularProgressIndicator()) : _conteudo(),
      bottomNavigationBar: NavigationBar(selectedIndex: aba, onDestinationSelected: (v) => setState(() => aba = v), destinations: const [NavigationDestination(icon: Icon(Icons.menu_book), label: 'Catálogo'), NavigationDestination(icon: Icon(Icons.bookmark), label: 'Meus empréstimos')]),
    );
  }

  Widget _conteudo() {
    if (aba == 0) {
      if (livros.isEmpty) return const Center(child: Text('Ainda não há livros cadastrados.'));
      return RefreshIndicator(onRefresh: carregar, child: ListView(children: livros.map((l) {
        final disponivel = l['disponivel'] == true;
        return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.menu_book)),
          title: Text(l['titulo'].toString()),
          subtitle: Text('${l['autor']} • ${l['ano'] ?? 'Ano não informado'}'),
          trailing: disponivel ? FilledButton(onPressed: () => emprestar((l['id'] as num).toInt()), child: const Text('Emprestar')) : const Chip(label: Text('Indisponível')),
        ));
      }).toList()));
    }
    if (emprestimos.isEmpty) return const Center(child: Text('Você ainda não possui empréstimos.'));
    return RefreshIndicator(onRefresh: carregar, child: ListView(children: emprestimos.map((e) {
      final devolvido = e['devolvido'] == true;
      final id = (e['id'] as num).toInt();
      return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), child: ListTile(
        leading: const Icon(Icons.bookmark),
        title: Text(nomeLivro((e['id_livro'] as num).toInt())),
        subtitle: Text(devolvido ? 'Devolvido' : 'Empréstimo ativo'),
        trailing: devolvido ? const Icon(Icons.check_circle, color: Colors.green) : TextButton(onPressed: () => devolver(id), child: const Text('Devolver')),
      ));
    }).toList()));
  }
}
