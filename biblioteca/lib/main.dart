import 'package:flutter/material.dart';
import 'biblioteca_api.dart';

const _ink = Color(0xFF1C2925);
const _pine = Color(0xFF173F37);
const _pineLight = Color(0xFF285B4F);
const _cream = Color(0xFFF4F0E7);
const _paper = Color(0xFFFFFDF8);
const _muted = Color(0xFF737B73);
const _line = Color(0xFFE5E0D5);
const _clay = Color(0xFFC97854);
const _gold = Color(0xFFD7B56D);

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
    final esquema = ColorScheme.fromSeed(
      seedColor: _pine,
      brightness: Brightness.light,
      primary: _pine,
      secondary: _clay,
      surface: _paper,
      error: const Color(0xFFB64D43),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Biblioteca Digital',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: esquema,
        scaffoldBackgroundColor: _cream,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: _ink, height: 1.08, letterSpacing: -1.1),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _ink, height: 1.12, letterSpacing: -0.7),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _ink),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _ink),
          bodyLarge: TextStyle(fontSize: 15, color: _ink, height: 1.45),
          bodyMedium: TextStyle(fontSize: 13, color: _muted, height: 1.4),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _cream,
          foregroundColor: _ink,
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8F6F0),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          hintStyle: const TextStyle(color: Color(0xFF9A9D95), fontSize: 14),
          labelStyle: const TextStyle(color: _muted, fontSize: 14),
          prefixIconColor: _muted,
          suffixIconColor: _muted,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: _line)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: _line)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: _pine, width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFB64D43))),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFB64D43), width: 1.5)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _pine,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 52),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _pine,
            minimumSize: const Size(0, 48),
            side: const BorderSide(color: _line),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        cardTheme: CardThemeData(
          color: _paper,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: _line)),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _ink,
          contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _paper,
          indicatorColor: const Color(0xFFE2EBE5),
          elevation: 0,
          labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: _paper,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titleTextStyle: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: _ink),
        ),
      ),
      home: !logado
          ? LoginPage(api: api, onEntrar: entrar)
          : administrador
              ? AdminHomePage(api: api, onSair: sair)
              : UsuarioHomePage(api: api, usuario: usuario, onSair: sair),
    );
  }
}

// -----------------------------------------------------------------------------
// Peças visuais compartilhadas
// -----------------------------------------------------------------------------

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.size = 48, this.inverse = false});
  final double size;
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: inverse ? Colors.white.withValues(alpha: .12) : _pine,
        borderRadius: BorderRadius.circular(size * .28),
        border: inverse ? Border.all(color: Colors.white24) : null,
      ),
      child: Icon(Icons.auto_stories_rounded, color: inverse ? Colors.white : const Color(0xFFF4E8CE), size: size * .52),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text, {this.color = _muted});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.7, color: color),
      );
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.text, required this.available});
  final String text;
  final bool available;

  @override
  Widget build(BuildContext context) {
    final cor = available ? const Color(0xFF326C52) : const Color(0xFF9A634C);
    final fundo = available ? const Color(0xFFE6F0E8) : const Color(0xFFF5EAE2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(30)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: cor, fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({required this.title, this.width = 82, this.height = 112});
  final String title;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    const colors = [Color(0xFF315B50), Color(0xFFB66E51), Color(0xFF53677D), Color(0xFF9A8554), Color(0xFF795E70)];
    final color = colors[title.hashCode.abs() % colors.length];
    final iniciais = title.trim().isEmpty ? 'L' : title.trim().characters.first.toUpperCase();
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [BoxShadow(color: color.withValues(alpha: .22), blurRadius: 12, offset: const Offset(3, 6))],
      ),
      child: Stack(children: [
        Positioned(left: 8, top: 0, bottom: 0, child: Container(width: 2, color: Colors.white.withValues(alpha: .22))),
        Positioned(right: 10, top: 10, child: Icon(Icons.auto_awesome, color: Colors.white.withValues(alpha: .35), size: 13)),
        Center(child: Container(
          width: width * .52,
          height: height * .52,
          decoration: BoxDecoration(border: Border.all(color: Colors.white.withValues(alpha: .55), width: 1.2), shape: BoxShape.circle),
          child: Center(child: Text(iniciais, style: TextStyle(color: Colors.white, fontSize: width * .25, fontWeight: FontWeight.w300, fontFamily: 'serif'))),
        )),
        Positioned(left: 10, right: 8, bottom: 10, child: Container(height: 2, color: Colors.white.withValues(alpha: .5))),
      ]),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.kicker, required this.title, this.trailing});
  final String kicker;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 18, 2, 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Eyebrow(kicker),
            const SizedBox(height: 5),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
          ])),
          if (trailing != null) trailing!,
        ]),
      );
}

Widget _loading() => const Center(child: CircularProgressIndicator(color: _pine));

Widget _emptyState(String title, String subtitle, IconData icon) => Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 76, height: 76, decoration: const BoxDecoration(color: Color(0xFFEAEDE5), shape: BoxShape.circle), child: Icon(icon, color: _pine, size: 34)),
          const SizedBox(height: 18),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 7),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: _muted, height: 1.4)),
        ]),
      ),
    );

// -----------------------------------------------------------------------------
// Login e cadastro
// -----------------------------------------------------------------------------

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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> entrar() async {
    if (senha.text.isEmpty || (modoAdmin ? loginAdmin.text.trim().isEmpty : email.text.trim().isEmpty)) {
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
    setState(() { carregando = true; erroCadastro = null; });
    try {
      final dados = await widget.api.cadastrarUsuario(nomeCadastro.text.trim(), emailCadastro.text.trim(), senhaCadastro.text);
      if (!mounted) return;
      widget.onEntrar(dados);
    } catch (e) {
      if (!mounted) return;
      setState(() => erroCadastro = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 900;
        if (desktop) {
          return Row(children: [
            Expanded(flex: 5, child: _brandPanel(compact: false)),
            Expanded(flex: 4, child: Container(
              color: _cream,
              child: SafeArea(child: Center(child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
                child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: _authCard()),
              ))),
            )),
          ]);
        }
        return Container(
          color: _cream,
          child: SafeArea(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            child: Column(children: [
              _brandPanel(compact: true),
              const SizedBox(height: 18),
              ConstrainedBox(constraints: const BoxConstraints(maxWidth: 500), child: _authCard()),
              const SizedBox(height: 14),
              const Text('UM ESPAÇO PARA DESCOBRIR NOVAS HISTÓRIAS', style: TextStyle(color: _muted, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
            ]),
          )),
        );
      }),
    );
  }

  Widget _brandPanel({required bool compact}) {
    return Container(
      constraints: compact ? const BoxConstraints(minHeight: 205) : null,
      padding: EdgeInsets.all(compact ? 23 : 54),
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_pine, Color(0xFF102F2A)]),
      ),
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned(right: compact ? -10 : 60, top: compact ? 10 : 60, child: Icon(Icons.menu_book_rounded, size: compact ? 100 : 230, color: Colors.white.withValues(alpha: .045))),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: compact ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween, children: [
          Row(children: [const _BrandMark(size: 46, inverse: true), const SizedBox(width: 13), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('BIBLIOTECA', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2.0)), Text('digital', style: TextStyle(color: Color(0xFFE7D6B3), fontSize: 12, fontFamily: 'serif', fontStyle: FontStyle.italic))])]),
          SizedBox(height: compact ? 26 : 0),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Eyebrow('Leitura sem fronteiras', color: const Color(0xFFD8C9A7)),
            const SizedBox(height: 12),
            Text('Histórias que\nencontram leitores.', style: TextStyle(color: Colors.white, fontSize: compact ? 29 : 47, height: 1.04, letterSpacing: -1.5, fontWeight: FontWeight.w800, fontFamily: 'serif')),
            const SizedBox(height: 12),
            Text('Seu próximo capítulo começa aqui.', style: TextStyle(color: Colors.white.withValues(alpha: .68), fontSize: compact ? 12 : 15)),
          ]),
          if (!compact) ...[
            Row(children: [
              _miniBook(const Color(0xFFBD7956), -7),
              _miniBook(const Color(0xFF647C70), 0),
              _miniBook(const Color(0xFFD0AC65), 7),
              const SizedBox(width: 25),
            ]),
          ],
        ]),
      ]),
    );
  }

  Widget _miniBook(Color color, double rotation) => Transform.rotate(
        angle: rotation * .025,
        child: Container(width: 43, height: 65, margin: const EdgeInsets.only(right: 7), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4), border: Border(left: BorderSide(color: Colors.white.withValues(alpha: .4), width: 3))), child: const Center(child: Icon(Icons.auto_stories, color: Colors.white70, size: 19))),
      );

  Widget _authCard() {
    return Container(
      padding: const EdgeInsets.all(27),
      decoration: BoxDecoration(color: _paper, borderRadius: BorderRadius.circular(25), border: Border.all(color: _line), boxShadow: [BoxShadow(color: _ink.withValues(alpha: .045), blurRadius: 30, offset: const Offset(0, 13))]),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: mostrarCadastro ? _cadastroForm() : _loginForm(),
      ),
    );
  }

  Widget _loginForm() {
    return Column(key: const ValueKey('login'), crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _Eyebrow('Acesse sua estante'),
      const SizedBox(height: 8),
      Text('Que bom ter você\npor aqui.', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontFamily: 'serif')),
      const SizedBox(height: 8),
      const Text('Entre para explorar o catálogo e seus empréstimos.'),
      const SizedBox(height: 23),
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: const Color(0xFFF0EEE7), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Expanded(child: _modeButton('Leitor', Icons.person_outline_rounded, false)),
          Expanded(child: _modeButton('Administração', Icons.shield_outlined, true)),
        ]),
      ),
      const SizedBox(height: 20),
      if (modoAdmin)
        TextField(controller: loginAdmin, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Login administrativo', prefixIcon: Icon(Icons.badge_outlined)))
      else
        TextField(controller: email, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.alternate_email_rounded))),
      const SizedBox(height: 12),
      TextField(
        controller: senha,
        obscureText: ocultarSenha,
        onSubmitted: (_) => entrar(),
        decoration: InputDecoration(labelText: 'Senha', prefixIcon: const Icon(Icons.lock_outline_rounded), suffixIcon: IconButton(tooltip: ocultarSenha ? 'Mostrar senha' : 'Ocultar senha', onPressed: () => setState(() => ocultarSenha = !ocultarSenha), icon: Icon(ocultarSenha ? Icons.visibility_outlined : Icons.visibility_off_outlined))),
      ),
      const SizedBox(height: 19),
      SizedBox(width: double.infinity, child: FilledButton(onPressed: carregando ? null : entrar, child: carregando ? const SizedBox(height: 19, width: 19, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Entrar na biblioteca'), SizedBox(width: 9), Icon(Icons.arrow_forward_rounded, size: 18)]))),
      if (!modoAdmin) ...[
        const SizedBox(height: 13),
        Center(child: Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [const Text('Primeira visita? ', style: TextStyle(color: _muted, fontSize: 13)), TextButton(onPressed: carregando ? null : () => setState(() => mostrarCadastro = true), child: const Text('Criar uma conta', style: TextStyle(fontWeight: FontWeight.w800)))])),
      ] else ...[
        const SizedBox(height: 14),
        Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF4F0E7), borderRadius: BorderRadius.circular(12)), child: const Row(children: [Icon(Icons.info_outline, size: 16, color: _muted), SizedBox(width: 8), Expanded(child: Text('Acesso inicial: admin / admin123', style: TextStyle(color: _muted, fontSize: 11)))])),
      ],
    ]);
  }

  Widget _modeButton(String label, IconData icon, bool admin) {
    final selecionado = modoAdmin == admin;
    return Material(color: selecionado ? _paper : Colors.transparent, borderRadius: BorderRadius.circular(11), child: InkWell(
      borderRadius: BorderRadius.circular(11), onTap: carregando ? null : () => setState(() => modoAdmin = admin),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16, color: selecionado ? _pine : _muted), const SizedBox(width: 6), Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(color: selecionado ? _pine : _muted, fontSize: 12, fontWeight: FontWeight.w700)))])),
    ));
  }

  Widget _cadastroForm() {
    return Form(
      key: cadastroFormKey,
      child: Column(key: const ValueKey('cadastro'), crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [IconButton(onPressed: carregando ? null : () => setState(() { mostrarCadastro = false; erroCadastro = null; }), icon: const Icon(Icons.arrow_back_rounded), style: IconButton.styleFrom(backgroundColor: const Color(0xFFF0EEE7))), const SizedBox(width: 8), const _Eyebrow('Nova conta')]),
        const SizedBox(height: 13),
        Text('Sua próxima\nleitura começa aqui.', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontFamily: 'serif')),
        const SizedBox(height: 8),
        const Text('Crie seu acesso para reservar e acompanhar livros.'),
        const SizedBox(height: 22),
        TextFormField(controller: nomeCadastro, textCapitalization: TextCapitalization.words, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Nome completo', prefixIcon: Icon(Icons.person_outline_rounded)), validator: (v) => v == null || v.trim().isEmpty ? 'Informe seu nome.' : null),
        const SizedBox(height: 12),
        TextFormField(controller: emailCadastro, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, onChanged: (_) { if (erroCadastro != null) setState(() => erroCadastro = null); }, decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.alternate_email_rounded)), validator: (v) => v == null || !v.trim().contains('@') ? 'Informe um e-mail válido.' : null),
        const SizedBox(height: 12),
        TextFormField(controller: senhaCadastro, obscureText: ocultarSenhaCadastro, decoration: InputDecoration(labelText: 'Senha (mínimo 4 caracteres)', prefixIcon: const Icon(Icons.lock_outline_rounded), suffixIcon: IconButton(onPressed: () => setState(() => ocultarSenhaCadastro = !ocultarSenhaCadastro), icon: Icon(ocultarSenhaCadastro ? Icons.visibility_outlined : Icons.visibility_off_outlined))), validator: (v) => v == null || v.length < 4 ? 'Use pelo menos 4 caracteres.' : null),
        if (erroCadastro != null) ...[const SizedBox(height: 12), Text(erroCadastro!, style: const TextStyle(color: Color(0xFFB64D43), fontWeight: FontWeight.w600, fontSize: 12))],
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: carregando ? null : cadastrar, child: carregando ? const SizedBox(height: 19, width: 19, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Criar minha conta'))),
        const SizedBox(height: 8),
        Center(child: TextButton(onPressed: carregando ? null : () => setState(() { mostrarCadastro = false; erroCadastro = null; }), child: const Text('Já tenho uma conta'))),
      ]),
    );
  }
}

// -----------------------------------------------------------------------------
// Área administrativa
// -----------------------------------------------------------------------------

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
      title: const Text('Adicionar ao catálogo'),
      content: Form(key: formulario, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: titulo, decoration: const InputDecoration(labelText: 'Título do livro'), validator: (v) => v == null || v.trim().isEmpty ? 'Informe o título' : null),
        const SizedBox(height: 10),
        TextFormField(controller: autor, decoration: const InputDecoration(labelText: 'Autor'), validator: (v) => v == null || v.trim().isEmpty ? 'Informe o autor' : null),
        const SizedBox(height: 10),
        TextField(controller: ano, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Ano de publicação (opcional)')),
      ]))),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () { if (formulario.currentState!.validate()) Navigator.pop(context, true); }, child: const Text('Salvar livro'))],
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
        DropdownButtonFormField<int>(initialValue: idLivro, isExpanded: true, decoration: const InputDecoration(labelText: 'Livro'), items: disponiveis.map((l) => DropdownMenuItem(value: (l['id'] as num).toInt(), child: Text(l['titulo'].toString(), overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) => atualizar(() => idLivro = v)),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(initialValue: idUsuario, isExpanded: true, decoration: const InputDecoration(labelText: 'Usuário'), items: usuarios.map((u) => DropdownMenuItem(value: (u['id'] as num).toInt(), child: Text(u['nome'].toString(), overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) => atualizar(() => idUsuario = v)),
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
    final largura = MediaQuery.sizeOf(context).width;
    final titulos = ['Acervo', 'Leitores', 'Empréstimos'];
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [const _BrandMark(size: 37), const SizedBox(width: 11), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Biblioteca Digital', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), Text('PAINEL ADMINISTRATIVO  /  ${titulos[abaAtual].toUpperCase()}', style: const TextStyle(color: _muted, fontSize: 9, letterSpacing: 1.1, fontWeight: FontWeight.w700))])]),
        actions: [IconButton(tooltip: 'Atualizar dados', onPressed: carregarDados, icon: const Icon(Icons.refresh_rounded)), IconButton(tooltip: 'Sair', onPressed: widget.onSair, icon: const Icon(Icons.logout_rounded)), const SizedBox(width: 8)],
      ),
      body: carregando && livros.isEmpty && usuarios.isEmpty && emprestimos.isEmpty
          ? _loading()
          : SafeArea(child: Column(children: [
              Padding(padding: EdgeInsets.fromLTRB(largura < 600 ? 16 : 28, 8, largura < 600 ? 16 : 28, 0), child: _adminHero()),
              Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: largura < 600 ? 12 : 26), child: _conteudo())),
            ])),
      floatingActionButton: abaAtual == 0
          ? FloatingActionButton.extended(onPressed: adicionarLivro, backgroundColor: _clay, foregroundColor: Colors.white, icon: const Icon(Icons.add_rounded), label: const Text('Adicionar livro'))
          : abaAtual == 2
              ? FloatingActionButton.extended(onPressed: novoEmprestimo, backgroundColor: _clay, foregroundColor: Colors.white, icon: const Icon(Icons.add_rounded), label: const Text('Novo empréstimo'))
              : null,
      bottomNavigationBar: NavigationBar(selectedIndex: abaAtual, onDestinationSelected: (v) => setState(() => abaAtual = v), destinations: const [
        NavigationDestination(icon: Icon(Icons.auto_stories_outlined), selectedIcon: Icon(Icons.auto_stories_rounded), label: 'Acervo'),
        NavigationDestination(icon: Icon(Icons.people_outline_rounded), selectedIcon: Icon(Icons.people_rounded), label: 'Leitores'),
        NavigationDestination(icon: Icon(Icons.swap_horiz_rounded), selectedIcon: Icon(Icons.swap_horiz_rounded), label: 'Empréstimos'),
      ]),
    );
  }

  Widget _adminHero() {
    final totalAtivos = emprestimos.where((e) => e['devolvido'] != true).length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: _pine, borderRadius: BorderRadius.circular(23), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_pine, Color(0xFF285B4F)])),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const _Eyebrow('Espaço de gestão', color: Color(0xFFD8C9A7)),
          const SizedBox(height: 7),
          const Text('Cuidando de cada\nhistória.', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800, fontFamily: 'serif', height: 1.05)),
          const SizedBox(height: 9),
          Text('Gerencie o acervo e acompanhe as movimentações.', style: TextStyle(color: Colors.white.withValues(alpha: .7), fontSize: 11)),
        ])),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _heroMetric('${livros.length}', 'LIVROS'),
          const SizedBox(height: 10),
          _heroMetric('$totalAtivos', 'EM ABERTO'),
        ]),
      ]),
    );
  }

  Widget _heroMetric(String valor, String legenda) => Container(width: 92, padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .1), borderRadius: BorderRadius.circular(13), border: Border.all(color: Colors.white.withValues(alpha: .12))), child: Column(children: [Text(valor, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 21)), Text(legenda, style: const TextStyle(color: Color(0xFFD2DED5), fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 1))]));

  Widget _conteudo() {
    if (carregando) return _loading();
    if (abaAtual == 0) {
      if (livros.isEmpty) return _emptyState('Seu acervo começa aqui', 'Adicione o primeiro livro para disponibilizá-lo aos leitores.', Icons.auto_stories_outlined);
      return Column(children: [const _SectionHeading(kicker: 'Coleção cadastrada', title: 'Livros do acervo'), Expanded(child: _bookGrid(livros, admin: true))]);
    }
    if (abaAtual == 1) {
      if (usuarios.isEmpty) return _emptyState('Nenhum leitor ainda', 'As contas criadas no aplicativo aparecerão nesta lista.', Icons.people_outline_rounded);
      return Column(children: [const _SectionHeading(kicker: 'Comunidade', title: 'Leitores cadastrados'), Expanded(child: ListView.separated(padding: const EdgeInsets.only(bottom: 90), itemCount: usuarios.length, separatorBuilder: (_, __) => const SizedBox(height: 9), itemBuilder: (context, i) {
        final u = usuarios[i] as Map<String, dynamic>;
        final nome = u['nome']?.toString() ?? 'Leitor';
        return Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: _paper, borderRadius: BorderRadius.circular(17), border: Border.all(color: _line)), child: Row(children: [Container(width: 45, height: 45, decoration: BoxDecoration(color: const Color(0xFFE6ECE5), borderRadius: BorderRadius.circular(14)), child: Center(child: Text(nome.isEmpty ? 'L' : nome[0].toUpperCase(), style: const TextStyle(color: _pine, fontSize: 18, fontWeight: FontWeight.w800)))), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(nome, style: const TextStyle(color: _ink, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(u['email']?.toString() ?? '', style: const TextStyle(color: _muted, fontSize: 12))])), const Icon(Icons.verified_user_outlined, color: _pineLight, size: 19)]));
      }))]);
    }
    if (emprestimos.isEmpty) return _emptyState('Nenhuma movimentação', 'Quando um livro for emprestado, o registro aparecerá aqui.', Icons.swap_horiz_rounded);
    return Column(children: [const _SectionHeading(kicker: 'Circulação', title: 'Histórico de empréstimos'), Expanded(child: ListView.separated(padding: const EdgeInsets.only(bottom: 90), itemCount: emprestimos.length, separatorBuilder: (_, __) => const SizedBox(height: 9), itemBuilder: (context, i) {
      final e = emprestimos[i] as Map<String, dynamic>;
      final id = (e['id'] as num).toInt();
      final devolvido = e['devolvido'] == true;
      final titulo = nomeLivro((e['id_livro'] as num).toInt());
      final nome = nomeUsuario((e['id_usuario'] as num).toInt());
      return Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: _paper, borderRadius: BorderRadius.circular(17), border: Border.all(color: _line)), child: Row(children: [
        _BookCover(title: titulo, width: 48, height: 65), const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(titulo, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _ink, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text('$nome  •  Registro #$id', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 11)), const SizedBox(height: 7), _StatusTag(text: devolvido ? 'Devolvido' : 'Em andamento', available: devolvido)])),
        if (!devolvido) TextButton(onPressed: () => devolver(id), child: const Text('Devolver')) else const Padding(padding: EdgeInsets.all(9), child: Icon(Icons.check_circle_rounded, color: _pineLight)),
      ]));
    }))]);
  }

  Widget _bookGrid(List<dynamic> lista, {required bool admin}) => LayoutBuilder(builder: (context, constraints) {
    final colunas = constraints.maxWidth >= 1100 ? 3 : constraints.maxWidth >= 650 ? 2 : 1;
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 95, top: 2),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: colunas, crossAxisSpacing: 12, mainAxisSpacing: 12, mainAxisExtent: 166),
      itemCount: lista.length,
      itemBuilder: (context, i) {
        final l = lista[i] as Map<String, dynamic>;
        return _BookCard(livro: l, admin: admin, onEmprestar: admin ? null : () {});
      },
    );
  });
}

// -----------------------------------------------------------------------------
// Área do leitor
// -----------------------------------------------------------------------------

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
    final nome = widget.usuario['nome']?.toString() ?? 'Leitor';
    final primeiroNome = nome.trim().isEmpty ? 'Leitor' : nome.trim().split(' ').first;
    final largura = MediaQuery.sizeOf(context).width;
    final ativos = emprestimos.where((e) => e['devolvido'] != true).length;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [const _BrandMark(size: 37), const SizedBox(width: 11), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Biblioteca Digital', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), Text('SUA ESTANTE PESSOAL', style: TextStyle(color: _muted, fontSize: 9, letterSpacing: 1.1, fontWeight: FontWeight.w700))])]),
        actions: [IconButton(tooltip: 'Atualizar catálogo', onPressed: carregar, icon: const Icon(Icons.refresh_rounded)), IconButton(tooltip: 'Sair', onPressed: widget.onSair, icon: const Icon(Icons.logout_rounded)), const SizedBox(width: 8)],
      ),
      body: SafeArea(child: Column(children: [
        Padding(padding: EdgeInsets.fromLTRB(largura < 600 ? 16 : 28, 8, largura < 600 ? 16 : 28, 0), child: _readerHero(primeiroNome, ativos)),
        Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: largura < 600 ? 12 : 26), child: _conteudo())),
      ])),
      bottomNavigationBar: NavigationBar(selectedIndex: aba, onDestinationSelected: (v) => setState(() => aba = v), destinations: const [
        NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore_rounded), label: 'Explorar'),
        NavigationDestination(icon: Icon(Icons.bookmark_border_rounded), selectedIcon: Icon(Icons.bookmark_rounded), label: 'Minha estante'),
      ]),
    );
  }

  Widget _readerHero(String nome, int ativos) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: const Color(0xFFE8E4D8), borderRadius: BorderRadius.circular(23), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFEDE8DC), Color(0xFFE1E9DF)])),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const _Eyebrow('Sua jornada de leitura'),
            const SizedBox(height: 7),
            Text('Olá, $nome.', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _pine, fontSize: 25, fontWeight: FontWeight.w800, fontFamily: 'serif')),
            const SizedBox(height: 5),
            const Text('Uma nova história espera por você.', style: TextStyle(color: _muted, fontSize: 11)),
            const SizedBox(height: 13),
            Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7), decoration: BoxDecoration(color: _paper.withValues(alpha: .8), borderRadius: BorderRadius.circular(30)), child: Text('$ativos ${ativos == 1 ? 'livro em leitura' : 'livros em leitura'}', style: const TextStyle(color: _pine, fontSize: 10, fontWeight: FontWeight.w800))),
          ])),
          const SizedBox(width: 10),
          Stack(alignment: Alignment.center, children: [
            Container(width: 88, height: 88, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .42), shape: BoxShape.circle)),
            const Icon(Icons.local_library_rounded, color: _pine, size: 54),
          ]),
        ]),
      );

  Widget _conteudo() {
    if (carregando && livros.isEmpty && emprestimos.isEmpty) return _loading();
    if (aba == 0) {
      if (livros.isEmpty) return _emptyState('A estante está vazia', 'Assim que a biblioteca cadastrar novos títulos, eles aparecerão aqui.', Icons.auto_stories_outlined);
      return Column(children: [
        _SectionHeading(kicker: 'Escolha sua próxima leitura', title: 'Explore o acervo', trailing: Text('${livros.length} títulos', style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700))),
        Expanded(child: RefreshIndicator(onRefresh: carregar, child: _readerBookGrid())),
      ]);
    }
    if (emprestimos.isEmpty) return _emptyState('Sua estante ainda está livre', 'Encontre um livro no catálogo e faça seu primeiro empréstimo.', Icons.bookmark_border_rounded);
    return Column(children: [const _SectionHeading(kicker: 'Seus registros', title: 'Minha estante'), Expanded(child: RefreshIndicator(onRefresh: carregar, child: ListView.separated(padding: const EdgeInsets.only(bottom: 18), itemCount: emprestimos.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (context, i) {
      final e = emprestimos[i] as Map<String, dynamic>;
      final devolvido = e['devolvido'] == true;
      final id = (e['id'] as num).toInt();
      final titulo = nomeLivro((e['id_livro'] as num).toInt());
      return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: _paper, borderRadius: BorderRadius.circular(18), border: Border.all(color: _line)), child: Row(children: [
        _BookCover(title: titulo, width: 58, height: 79), const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(titulo, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _ink, fontWeight: FontWeight.w800, fontSize: 14)), const SizedBox(height: 8), _StatusTag(text: devolvido ? 'Devolvido' : 'Em sua estante', available: devolvido)])),
        if (!devolvido) TextButton(onPressed: () => devolver(id), child: const Text('Devolver')) else const Padding(padding: EdgeInsets.all(9), child: Icon(Icons.check_circle_rounded, color: _pineLight)),
      ]));
    })))]);
  }

  Widget _readerBookGrid() => LayoutBuilder(builder: (context, constraints) {
    final colunas = constraints.maxWidth >= 1100 ? 3 : constraints.maxWidth >= 650 ? 2 : 1;
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 16, top: 2),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: colunas, crossAxisSpacing: 12, mainAxisSpacing: 12, mainAxisExtent: 178),
      itemCount: livros.length,
      itemBuilder: (context, i) {
        final l = livros[i] as Map<String, dynamic>;
        return _BookCard(livro: l, admin: false, onEmprestar: l['disponivel'] == true ? () => emprestar((l['id'] as num).toInt()) : null);
      },
    );
  });
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.livro, required this.admin, this.onEmprestar});
  final Map<String, dynamic> livro;
  final bool admin;
  final VoidCallback? onEmprestar;

  @override
  Widget build(BuildContext context) {
    final titulo = livro['titulo']?.toString() ?? 'Sem título';
    final autor = livro['autor']?.toString() ?? 'Autor não informado';
    final ano = livro['ano']?.toString() ?? 'Ano não informado';
    final disponivel = livro['disponivel'] == true;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: _paper, borderRadius: BorderRadius.circular(19), border: Border.all(color: _line)),
      child: Row(children: [
        _BookCover(title: titulo, width: 82, height: 116),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          _StatusTag(text: disponivel ? 'Disponível' : 'Emprestado', available: disponivel),
          const SizedBox(height: 8),
          Text(titulo, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _ink, fontWeight: FontWeight.w800, fontSize: 14, height: 1.2)),
          const SizedBox(height: 4),
          Text(autor, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 11)),
          const SizedBox(height: 3),
          Text(ano, style: const TextStyle(color: _muted, fontSize: 10)),
          if (!admin && disponivel) ...[
            const SizedBox(height: 7),
            SizedBox(height: 34, child: FilledButton.tonal(onPressed: onEmprestar, style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE5ECE5), foregroundColor: _pine, padding: const EdgeInsets.symmetric(horizontal: 12)), child: const Text('Pegar emprestado', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)))),
          ],
        ])),
      ]),
    );
  }
}
