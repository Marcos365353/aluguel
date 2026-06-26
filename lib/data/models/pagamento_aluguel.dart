import 'forma_pagamento.dart';
import 'status_pagamento.dart';

// Modelo interno de pagamento de aluguel.
class PagamentoAluguel {
  const PagamentoAluguel({
    required this.id,
    required this.contratoId,
    required this.dataVencimento,
    required this.dataPagamento,
    required this.valorPago,
    required this.formaPagamento,
    required this.status,
  });

  final String id;
  final String contratoId;
  final DateTime dataVencimento;
  final DateTime dataPagamento;
  final double valorPago;
  final FormaPagamento formaPagamento;
  final StatusPagamento status;
}

// Ajuda a perguntar se um pagamento esta marcado como pago.
extension PagamentoAluguelStatusX on StatusPagamento {
  bool get estaPago => this == StatusPagamento.pago;
}
