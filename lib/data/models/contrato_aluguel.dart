import 'dart:math';

import 'status_contrato.dart';
import 'pagamento_aluguel.dart';

// Representa um contrato de aluguel.
// Ele guarda os dados e tambem algumas regras de vencimento.
class ContratoAluguel {
  const ContratoAluguel({
    required this.id,
    required this.imovelId,
    required this.imovelEndereco,
    required this.locadorId,
    required this.locadorNome,
    required this.inquilinoId,
    required this.inquilinoNome,
    required this.dataInicio,
    required this.dataFim,
    required this.diaVencimento,
    required this.valorMensal,
    required this.status,
    required this.observacoes,
  });

  final String id;
  final String imovelId;
  final String imovelEndereco;
  final String locadorId;
  final String locadorNome;
  final String inquilinoId;
  final String inquilinoNome;
  final DateTime dataInicio;
  final DateTime dataFim;
  final int diaVencimento;
  final double valorMensal;
  final StatusContrato status;
  final String observacoes;

  // Contrato ativo e o contrato que ainda esta valendo.
  bool get estaAtivo => status == StatusContrato.ativo;

  // Calcula o vencimento em um mes especifico.
  // Se o dia nao existir no mes, usa o ultimo dia.
  DateTime vencimentoDoMes(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, min(diaVencimento, lastDay));
  }

  // Descobre a proxima data de vencimento que ainda precisa ser paga.
  // Se a parcela deste mes venceu e nao foi paga, ela continua sendo pendente.
  DateTime proximoVencimento(
    List<PagamentoAluguel> pagamentos, {
    DateTime? agora,
  }) {
    final hoje = agora ?? DateTime.now();
    final inicioContrato = _dateOnly(dataInicio);
    var candidato = vencimentoDoMes(hoje.year, hoje.month);

    if (candidato.isBefore(inicioContrato)) {
      candidato = vencimentoDoMes(inicioContrato.year, inicioContrato.month);
      if (candidato.isBefore(inicioContrato)) {
        final proximoMes = DateTime(
          inicioContrato.year,
          inicioContrato.month + 1,
        );
        candidato = vencimentoDoMes(proximoMes.year, proximoMes.month);
      }
    }

    while (_isPaid(candidato, pagamentos)) {
      final proximoMes = DateTime(candidato.year, candidato.month + 1);
      candidato = vencimentoDoMes(proximoMes.year, proximoMes.month);
    }

    return candidato;
  }

  // Verifica se o aluguel do mes atual ja foi pago.
  bool mesAtualPago(List<PagamentoAluguel> pagamentos, {DateTime? agora}) {
    final hoje = agora ?? DateTime.now();
    return _isPaid(vencimentoDoMes(hoje.year, hoje.month), pagamentos);
  }

  // Procura um pagamento do contrato com a mesma data de vencimento.
  bool _isPaid(DateTime dataVencimento, List<PagamentoAluguel> pagamentos) {
    return pagamentos.any(
      (pagamento) =>
          pagamento.contratoId == id &&
          pagamento.status.estaPago &&
          _isSameDate(pagamento.dataVencimento, dataVencimento),
    );
  }

  // Remove hora, minuto e segundo para comparar so a data.
  static DateTime _dateOnly(DateTime valor) {
    return DateTime(valor.year, valor.month, valor.day);
  }

  // Compara duas datas ignorando o horario.
  static bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
