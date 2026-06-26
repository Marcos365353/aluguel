import 'package:flutter/material.dart';

import '../views/dashboard_tela.dart';

// Pagina do dashboard.
// Ela existe para manter a organizacao no padrao MVVM: pages mostram telas.
class DashboardPagina extends StatelessWidget {
  const DashboardPagina({super.key});

  @override
  Widget build(BuildContext context) {
    // Reaproveita a tela completa que ja esta pronta em views.
    return const DashboardTela();
  }
}
