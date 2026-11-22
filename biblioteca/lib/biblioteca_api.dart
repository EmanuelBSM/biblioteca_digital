import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

class BibliotecaApi {
  // Windows: localhost | Android Emulator: 10.0.2.2 | Celular: IP do computador.
  static const String baseUrl = 'http://localhost:3000';

  String? token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Map<String, dynamic> _json(http.Response resposta) {
    final corpo = utf8.decode(resposta.bodyBytes);
    if (corpo.trim().isEmpty) return <String, dynamic>{};

    try {
      final decodificado = jsonDecode(corpo);
      if (decodificado is Map<String, dynamic>) return decodificado;
      return <String, dynamic>{};
    } on FormatException {
      return <String, dynamic>{};
    }
  }

  void _verificarResposta(http.Response resposta, int esperado) {
    if (resposta.statusCode != esperado) {
      final dados = _json(resposta);
      final mensagem = dados['erro']?.toString() ??
          'Não foi possível concluir a solicitação (HTTP ${resposta.statusCode}).';
      throw ApiException(resposta.statusCode, mensagem);
    }
  }

  Future<Map<String, dynamic>> loginUsuario(String email, String senha) async {
    final resposta = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'tipo': 'usuario', 'email': email, 'senha': senha}),
    );
    _verificarResposta(resposta, 200);
    final dados = _json(resposta);
    token = dados['token']?.toString();
    return dados;
  }

  Future<Map<String, dynamic>> loginAdmin(String login, String senha) async {
    final resposta = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'tipo': 'admin', 'login': login, 'senha': senha}),
    );
    _verificarResposta(resposta, 200);
    final dados = _json(resposta);
    token = dados['token']?.toString();
    return dados;
  }

  Future<Map<String, dynamic>> cadastrarUsuario(
    String nome,
    String email,
    String senha,
  ) async {
    final resposta = await http.post(
      Uri.parse('$baseUrl/auth/cadastro'),
      headers: _headers,
      body: jsonEncode({'nome': nome, 'email': email, 'senha': senha}),
    );
    _verificarResposta(resposta, 201);
    final dados = _json(resposta);
    token = dados['token']?.toString();
    return dados;
  }

  Future<void> logout() async {
    if (token != null) {
      try {
        await http.post(Uri.parse('$baseUrl/auth/logout'), headers: _headers);
      } finally {
        token = null;
      }
    }
  }

  Future<List<dynamic>> listarLivros() async {
    final resposta = await http.get(Uri.parse('$baseUrl/livros'));
    _verificarResposta(resposta, 200);
    return jsonDecode(utf8.decode(resposta.bodyBytes));
  }

  Future<Map<String, dynamic>> cadastrarLivro(
    String titulo,
    String autor, {
    int? ano,
  }) async {
    final resposta = await http.post(
      Uri.parse('$baseUrl/livros'),
      headers: _headers,
      body: jsonEncode({'titulo': titulo, 'autor': autor, 'ano': ano}),
    );
    _verificarResposta(resposta, 201);
    return _json(resposta);
  }

  Future<List<dynamic>> listarUsuarios() async {
    final resposta = await http.get(Uri.parse('$baseUrl/usuarios'), headers: _headers);
    _verificarResposta(resposta, 200);
    return jsonDecode(utf8.decode(resposta.bodyBytes));
  }

  Future<List<dynamic>> listarEmprestimos() async {
    final resposta = await http.get(Uri.parse('$baseUrl/emprestimos'), headers: _headers);
    _verificarResposta(resposta, 200);
    return jsonDecode(utf8.decode(resposta.bodyBytes));
  }

  Future<Map<String, dynamic>> emprestarLivro(int idLivro, {int? idUsuario}) async {
    final resposta = await http.post(
      Uri.parse('$baseUrl/emprestimos'),
      headers: _headers,
      body: jsonEncode({
        'id_livro': idLivro,
        if (idUsuario != null) 'id_usuario': idUsuario,
      }),
    );
    _verificarResposta(resposta, 201);
    return _json(resposta);
  }

  Future<Map<String, dynamic>> devolverLivro(int idEmprestimo) async {
    final resposta = await http.post(
      Uri.parse('$baseUrl/emprestimos/$idEmprestimo/devolver'),
      headers: _headers,
    );
    _verificarResposta(resposta, 200);
    return _json(resposta);
  }
}
