import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/tema_app.dart';
import 'core/constants/constantes_app.dart';
import 'data/repositories/repositorio_aluguel.dart';
import 'data/repositories/repositorio_aluguel_supabase.dart';
import 'pages/contratos_tela.dart';
import 'pages/dashboard_tela.dart';
import 'pages/imoveis_tela.dart';
import 'pages/inquilinos_tela.dart';
import 'pages/pagamentos_tela.dart';
import 'views/login_local_tela.dart';
import 'mvvm/viewmodels/app_state.dart';

// Este widget era a raiz original do app.
// Hoje o main.dart monta os providers, mas esta classe ainda mostra a estrutura completa.
class AplicativoAluguel extends StatelessWidget {
  const AplicativoAluguel({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider deixa os dados disponiveis para todas as telas filhas.
    return MultiProvider(
      providers: [
        Provider<RepositorioAluguel>(
          create: (_) => RepositorioAluguelSupabase(),
        ),
        ChangeNotifierProvider<AppState>(
          create: (context) =>
              AppState(repositorioAluguel: context.read<RepositorioAluguel>()),
        ),
      ],
      child: MaterialApp(
        title: ConstantesApp.nomeApp,
        debugShowCheckedModeBanner: false,
        theme: TemaApp.temaClaro,
        home: const ControleSessao(),
      ),
    );
  }
}

// Decide se mostra a tela de login ou a tela principal.
class ControleSessao extends StatefulWidget {
  const ControleSessao({super.key});

  @override
  State<ControleSessao> createState() => _ControleSessaoState();
}

class _ControleSessaoState extends State<ControleSessao> {
  // Guarda se o usuario entrou no sistema.
  bool _estaLogado = false;

  @override
  Widget build(BuildContext context) {
    if (!_estaLogado) {
      return LoginLocalTela(
        aoEntrar: () {
          context.read<AppState>().inicializar();
          setState(() => _estaLogado = true);
        },
      );
    }

    return EstruturaPrincipal(
      aoSair: () => setState(() => _estaLogado = false),
    );
  }
}

// Tela principal depois do login.
// Ela junta AppBar, paginas e barra de navegacao inferior.
class EstruturaPrincipal extends StatelessWidget {
  const EstruturaPrincipal({super.key, required this.aoSair});

  final VoidCallback aoSair;

  static const List<String> _titles = [
    'Dashboard',
    'Imóveis',
    'Inquilinos',
    'Contratos',
    'Financeiro',
  ];

  // Cada item desta lista corresponde a uma aba da barra inferior.
  static const List<Widget> _pages = [
    DashboardPagina(),
    ImoveisPagina(),
    InquilinosPagina(),
    ContratosPagina(),
    PagamentosPagina(),
  ];

  @override
  Widget build(BuildContext context) {
    // Consumer escuta o AppState. Quando os dados mudam, a tela atualiza.
    return Consumer<AppState>(
      builder: (context, estado, _) {
        // Enquanto os dados carregam, mostra um circulo de espera.
        if (estado.carregando) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se der erro ao carregar dados, mostra uma mensagem simples.
        if (estado.mensagemErro != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Erro de inicialização')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  estado.mensagemErro!,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        // IndexedStack mantem as paginas vivas e troca apenas a aba visivel.
        return Scaffold(
          appBar: AppBar(
            title: Text(_titles[estado.indiceAbaAtual]),
            actions: [
              IconButton(
                onPressed: estado.recarregar,
                icon: const Icon(Icons.refresh),
                tooltip: 'Atualizar',
              ),
              IconButton(
                onPressed: aoSair,
                icon: const Icon(Icons.logout),
                tooltip: 'Sair',
              ),
            ],
          ),
          body: IndexedStack(index: estado.indiceAbaAtual, children: _pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: estado.indiceAbaAtual,
            onDestinationSelected: estado.definirAba,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.home_work_outlined),
                selectedIcon: Icon(Icons.home_work),
                label: 'Imóveis',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Inquilinos',
              ),
              NavigationDestination(
                icon: Icon(Icons.description_outlined),
                selectedIcon: Icon(Icons.description),
                label: 'Contratos',
              ),
              NavigationDestination(
                icon: Icon(Icons.payments_outlined),
                selectedIcon: Icon(Icons.payments),
                label: 'Financeiro',
              ),
            ],
          ),
        );
      },
    );
  }
}
