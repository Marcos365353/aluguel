import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/formatadores.dart';
import '../data/models/contrato_aluguel.dart';
import '../mvvm/viewmodels/app_state.dart';
import '../widgets/cartao_resumo.dart';

// Tela principal do sistema.
// Mostra os indicadores do aluguel, vencimentos proximos e contratos ativos.
class DashboardTela extends StatelessWidget {
  const DashboardTela({super.key});

  @override
  Widget build(BuildContext context) {
    // O dashboard escuta o AppState para mostrar numeros sempre atualizados.
    return Consumer<AppState>(
      builder: (context, estado, _) {
        // Metrics calcula totais como imoveis, recebidos e pendencias.
        final metricas = estado.metricas;
        // Lista contratos ativos que vencem nos proximos 7 dias.
        final vencemLogo = _contratosDueSoon(estado);

        return RefreshIndicator(
          // Puxar a tela para baixo recarrega os dados vindos do Supabase.
          onRefresh: estado.recarregar,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Cartoes de resumo calculados em RentalMetrics pelo AppState.
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  CartaoResumo(
                    titulo: 'Imóveis',
                    valor: metricas.totalImoveis.toString(),
                    icon: Icons.home_work,
                  ),
                  CartaoResumo(
                    titulo: 'Alugados',
                    valor: metricas.imoveisAlugados.toString(),
                    icon: Icons.real_estate_agent,
                  ),
                  CartaoResumo(
                    titulo: 'Recebido no mês',
                    valor: FormatadoresApp.moeda(metricas.receitaMes),
                    icon: Icons.payments,
                  ),
                  CartaoResumo(
                    titulo: 'Pendências',
                    valor: metricas.pendenciasMes.toString(),
                    icon: Icons.warning_amber,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Secao de vencimentos proximos usada para ver cobrancas futuras.
              Text(
                'Vencimentos próximos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (vencemLogo.isEmpty)
                // Estado vazio: nenhum aluguel vence dentro da janela de 7 dias.
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Nenhum aluguel vence nos próximos 7 dias.'),
                  ),
                )
              else
                ...vencemLogo.map((contrato) {
                  // Calcula a proxima parcela pendente deste contrato.
                  final dataVencimento = contrato.proximoVencimento(
                    estado.pagamentos,
                  );
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.event_available),
                      title: Text(contrato.inquilinoNome),
                      subtitle: Text(contrato.imovelEndereco),
                      trailing: Text(FormatadoresApp.data(dataVencimento)),
                    ),
                  );
                }),
              const SizedBox(height: 20),
              // Mostra uma lista curta para nao deixar o dashboard muito longo.
              Text(
                'Contratos ativos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (estado.contratosAtivos.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Nenhum contrato ativo cadastrado.'),
                  ),
                )
              else
                ...estado.contratosAtivos
                    .take(4)
                    .map(
                      (contrato) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.description_outlined),
                          title: Text(contrato.imovelEndereco),
                          subtitle: Text(
                            '${contrato.inquilinoNome} - vence dia ${contrato.diaVencimento}',
                          ),
                          trailing: Text(
                            FormatadoresApp.moeda(contrato.valorMensal),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  // Procura contratos ativos com vencimento entre hoje e os proximos 7 dias.
  List<ContratoAluguel> _contratosDueSoon(AppState estado) {
    final agora = DateTime.now();
    // Remove horario para comparar somente o dia.
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final limite = hoje.add(const Duration(days: 7));

    final contratos = estado.contratosAtivos.where((contrato) {
      // O contrato calcula a proxima parcela com base nos pagamentos existentes.
      final dataVencimento = contrato.proximoVencimento(
        estado.pagamentos,
        agora: hoje,
      );
      return !dataVencimento.isBefore(hoje) && !dataVencimento.isAfter(limite);
    }).toList();

    // Ordena pelo vencimento mais proximo.
    contratos.sort(
      (a, b) => a
          .proximoVencimento(estado.pagamentos, agora: hoje)
          .compareTo(b.proximoVencimento(estado.pagamentos, agora: hoje)),
    );
    return contratos;
  }
}
