import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/constantes_app.dart';
import '../mvvm/usuario_controle.dart';
import '../mvvm/viewmodels/app_state.dart';
import 'inicio_tela.dart';

// Tela de login conectada ao Supabase Auth.
class LoginPagina extends StatefulWidget {
  const LoginPagina({super.key});

  @override
  State<LoginPagina> createState() => _LoginPaginaState();
}

class _LoginPaginaState extends State<LoginPagina> {
  // Chave usada para validar todos os campos do formulario de uma vez.
  final _formKey = GlobalKey<FormState>();

  // Controladores guardam o que o usuario digitou nos campos.
  final _controladorEmail = TextEditingController();
  final _controladorSenha = TextEditingController();

  // Controla se a senha aparece ou fica escondida no campo.
  bool _obscurePassword = true;

  // Controla o estado do botao enquanto o login esta sendo enviado.
  bool _carregando = false;

  @override
  void dispose() {
    _controladorEmail.dispose();
    _controladorSenha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    // Primeiro confere se os campos foram preenchidos corretamente.
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Bloqueia o botao e mostra o indicador de carregamento.
    setState(() => _carregando = true);

    // Envia e-mail e senha para o controle, que chama o Supabase Auth.
    final usuarioVM = context.read<UsuarioControle>();
    final sucesso = await usuarioVM.entrar(
      _controladorEmail.text.trim().toLowerCase(),
      _controladorSenha.text,
    );

    if (!mounted) {
      return;
    }

    if (sucesso) {
      // Depois do login, carrega os dados das tabelas do Supabase.
      await context.read<AppState>().inicializar();

      if (!mounted) {
        return;
      }

      // Troca a tela de login pela tela principal do aplicativo.
      setState(() => _carregando = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const InicioPagina()),
      );
      return;
    }

    // Se chegou aqui, o Supabase recusou o login.
    setState(() => _carregando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('E-mail ou senha incorretos.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.home_work_rounded,
                    size: 70,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  ConstantesApp.nomeApp,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Insira o login e senha para continuar',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 32),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _controladorEmail,
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            // Valida se o e-mail foi preenchido e tem formato basico.
                            validator: (valor) {
                              if (valor == null || valor.trim().isEmpty) {
                                return 'Digite seu e-mail';
                              }
                              if (!valor.contains('@')) {
                                return 'E-mail invalido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _controladorSenha,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                // Alterna entre mostrar e esconder a senha.
                                onPressed: () => setState(() {
                                  _obscurePassword = !_obscurePassword;
                                }),
                              ),
                            ),
                            validator: (valor) {
                              if (valor == null || valor.isEmpty) {
                                return 'Digite sua senha';
                              }
                              if (valor.length < 6) {
                                return 'A senha deve ter pelo menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              // Enquanto carrega, evita clicar duas vezes no login.
                              onPressed: _carregando ? null : _entrar,
                              icon: _carregando
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.login_rounded,
                                      color: Colors.white,
                                    ),
                              label: Text(
                                _carregando ? 'Entrando...' : 'Entrar',
                                style: const TextStyle(fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
