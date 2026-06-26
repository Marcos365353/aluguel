import 'package:flutter/material.dart';

import '../core/constants/constantes_app.dart';

// Tela de login local.
// Ela fica separada do login principal com Supabase, que esta em pages/login_tela.dart.
class LoginLocalTela extends StatefulWidget {
  const LoginLocalTela({super.key, required this.aoEntrar});

  // Callback chamado quando o formulario local passa na validacao.
  final VoidCallback aoEntrar;

  @override
  State<LoginLocalTela> createState() => _LoginLocalTelaState();
}

class _LoginLocalTelaState extends State<LoginLocalTela> {
  // FormKey valida todos os campos antes de liberar a entrada.
  final _formKey = GlobalKey<FormState>();

  // Controladores dos campos digitados na tela.
  final _controladorUsuario = TextEditingController();
  final _controladorSenha = TextEditingController();

  // Controla se a senha aparece escondida ou visivel.
  bool _obscurePassword = true;

  @override
  void dispose() {
    _controladorUsuario.dispose();
    _controladorSenha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Cabecalho visual do app dentro do card de login.
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: cores.primaryContainer,
                          foregroundColor: cores.onPrimaryContainer,
                          child: const Icon(Icons.home_work, size: 34),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          ConstantesApp.nomeApp,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ConstantesApp.areaProprietario,
                          style: textTheme.bodyMedium?.copyWith(
                            color: cores.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        // Campo de usuario do login local.
                        TextFormField(
                          controller: _controladorUsuario,
                          autofillHints: const [AutofillHints.username],
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Usuário',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (valor) {
                            if (valor == null || valor.trim().isEmpty) {
                              return 'Informe o usuário.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        // Campo de senha com botao para mostrar ou ocultar o texto.
                        TextFormField(
                          controller: _controladorSenha,
                          autofillHints: const [AutofillHints.password],
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _enviar(),
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              tooltip: _obscurePassword
                                  ? 'Mostrar senha'
                                  : 'Ocultar senha',
                            ),
                          ),
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'Informe a senha.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),
                        // Botao que valida o formulario e chama aoEntrar.
                        FilledButton.icon(
                          onPressed: _enviar,
                          icon: const Icon(Icons.login),
                          label: const Text('Entrar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _enviar() {
    // Se algum campo falhar, o proprio Form mostra a mensagem de erro.
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    // Fecha o teclado antes de entrar na area interna.
    FocusScope.of(context).unfocus();
    // A navegacao real fica em quem criou esta tela.
    widget.aoEntrar();
  }
}
