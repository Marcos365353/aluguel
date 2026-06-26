import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../mvvm/usuario_controle.dart';
import 'login_tela.dart';

// Tela principal apos entrar, mantendo as telas de aluguel existentes.
class InicioPagina extends StatelessWidget {
  const InicioPagina({super.key});

  @override
  Widget build(BuildContext context) {
    // EstruturaPrincipal e a estrutura com AppBar, abas e conteudo principal.
    return EstruturaPrincipal(
      aoSair: () async {
        // Ao sair, encerra a sessao no Supabase e volta para o login.
        await context.read<UsuarioControle>().sair();

        if (!context.mounted) {
          return;
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPagina()),
        );
      },
    );
  }
}
