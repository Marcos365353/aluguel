import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Controle do usuario: cuida do login e do sair.
class UsuarioControle extends ChangeNotifier {
  User? _usuarioAtual;

  User? get usuarioAtual => _usuarioAtual;
  bool get estaLogado => _usuarioAtual != null;

  Future<bool> entrar(String email, String senha) async {
    try {
      // Envia e-mail e senha para o Supabase conferir.
      final resposta = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: senha,
      );

      // Se o Supabase devolver um usuario, o login deu certo.
      _usuarioAtual = resposta.user;
      notifyListeners();
      return resposta.user != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> sair() async {
    // Encerra a sessao no Supabase e limpa o usuario do app.
    await Supabase.instance.client.auth.signOut();
    _usuarioAtual = null;
    notifyListeners();
  }
}
