import 'contrato_aluguel.dart';
import 'imovel.dart';
import 'pagamento_aluguel.dart';
import 'status_imovel.dart';

// Guarda os numeros que aparecem no dashboard.
class MetricasAluguel {
  const MetricasAluguel({
    required this.totalImoveis,
    required this.imoveisAlugados,
    required this.contratosAtivos,
    required this.receitaMes,
    required this.pendenciasMes,
    required this.contratosVencidos,
  });

  final int totalImoveis;
  final int imoveisAlugados;
  final int contratosAtivos;
  final double receitaMes;
  final int pendenciasMes;
  final int contratosVencidos;

  // Cria os indicadores usando listas de imoveis, contratos e pagamentos.
  factory MetricasAluguel.dosDados({
    required List<Imovel> imoveis,
    required List<ContratoAluguel> contratos,
    required List<PagamentoAluguel> pagamentos,
    DateTime? agora,
  }) {
    final hoje = agora ?? DateTime.now();
    // Considera somente contratos ativos para calcular pendencias.
    final contratosAtivos = contratos.where((contrato) => contrato.estaAtivo);

    // Soma os pagamentos feitos no mes atual.
    final receitaMes = pagamentos
        .where(
          (pagamento) =>
              pagamento.status.estaPago &&
              pagamento.dataPagamento.year == hoje.year &&
              pagamento.dataPagamento.month == hoje.month,
        )
        .fold<double>(0, (sum, pagamento) => sum + pagamento.valorPago);

    // Conta parcelas pendentes e contratos atrasados no mes.
    var pendenciasMes = 0;
    var contratosVencidos = 0;
    final dateOnly = DateTime(hoje.year, hoje.month, hoje.day);

    for (final contrato in contratosAtivos) {
      final dataVencimento = contrato.vencimentoDoMes(hoje.year, hoje.month);
      if (!contrato.mesAtualPago(pagamentos, agora: hoje)) {
        pendenciasMes++;
        if (dataVencimento.isBefore(dateOnly)) {
          contratosVencidos++;
        }
      }
    }

    // Retorna tudo pronto para o dashboard mostrar.
    return MetricasAluguel(
      totalImoveis: imoveis.length,
      imoveisAlugados: imoveis
          .where((imovel) => imovel.status == StatusImovel.alugado)
          .length,
      contratosAtivos: contratosAtivos.length,
      receitaMes: receitaMes,
      pendenciasMes: pendenciasMes,
      contratosVencidos: contratosVencidos,
    );
  }
}
