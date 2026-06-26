import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/tema_app.dart';
import 'core/constants/constantes_app.dart';
import 'data/repositories/repositorio_aluguel.dart';
import 'data/repositories/repositorio_aluguel_supabase.dart';
import 'mvvm/usuario_controle.dart';
import 'pages/login_tela.dart';
import 'mvvm/viewmodels/app_state.dart';

// Dados de conexao com o Supabase, que funciona como backend do app.
const urlSupabase = 'https://etyqhfnkxiijwdhmfbvq.supabase.co';

// Chave publica anonima usada pelo cliente Flutter para acessar o Supabase.
const chaveAnonimaSupabase =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV0eXFoZm5reGlpandkaG1mYnZxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyMDg0MjMsImV4cCI6MjA5Njc4NDQyM30.jsQSc3ta0o1ox3lQjH4CS30dFv3hX883vlDzzNsNRf4';

// Inicializa o aplicativo.
Future<void> main() async {
  // Garante que o Flutter esteja pronto antes de inicializar servicos externos.
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  // Abre a conexao com o Supabase antes de montar a interface.
  await Supabase.initialize(
    url: urlSupabase,
    publishableKey: chaveAnonimaSupabase,
  );

  // Registra os ViewModels que serao usados pelas telas com Provider.
  runApp(
    MultiProvider(
      providers: [
        // Repositorio principal usado pelo estado do sistema de aluguel.
        Provider<RepositorioAluguel>(
          create: (_) => RepositorioAluguelSupabase(),
        ),
        // Guarda dados do usuario logado e regras de autenticacao.
        ChangeNotifierProvider(create: (_) => UsuarioControle()),
        // Mantem o estado geral usado pelas telas atuais do aplicativo.
        ChangeNotifierProvider<AppState>(
          create: (context) =>
              AppState(repositorioAluguel: context.read<RepositorioAluguel>()),
        ),
      ],
      child: const AplicativoPrincipal(),
    ),
  );
}

// Atalho global para o cliente Supabase ja inicializado no main().
final supabase = Supabase.instance.client;

// Widget raiz do aplicativo.
class AplicativoPrincipal extends StatelessWidget {
  const AplicativoPrincipal({super.key});

  // Constroi o MaterialApp.
  @override
  Widget build(BuildContext context) {
    final temaBase = TemaApp.temaClaro;

    return MaterialApp(
      title: ConstantesApp.nomeApp,
      debugShowCheckedModeBanner: false,
      theme: temaBase.copyWith(
        textTheme: GoogleFonts.robotoTextTheme(temaBase.textTheme),
      ),
      home: const LoginPagina(),
    );
  }
}
