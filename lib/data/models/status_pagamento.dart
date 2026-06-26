// Status possiveis de um pagamento.
enum StatusPagamento { pago, cancelado }

// Converte o status entre tela e banco de dados.
extension StatusPagamentoX on StatusPagamento {
  String get rotulo {
    switch (this) {
      case StatusPagamento.pago:
        return 'Pago';
      case StatusPagamento.cancelado:
        return 'Cancelado';
    }
  }

  // Valor gravado na coluna status da tabela pagamentos_aluguel.
  String get valorBanco {
    switch (this) {
      case StatusPagamento.pago:
        return 'pago';
      case StatusPagamento.cancelado:
        return 'cancelado';
    }
  }

  // Converte o texto vindo do banco para o enum do Dart.
  static StatusPagamento doBanco(String valor) {
    switch (valor) {
      case 'cancelado':
      case 'canceled':
        return StatusPagamento.cancelado;
      case 'pago':
      case 'paid':
      default:
        return StatusPagamento.pago;
    }
  }
}
