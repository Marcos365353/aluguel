// Formas de pagamento aceitas no aluguel.
enum FormaPagamento { dinheiro, pix, cartao, transferenciaBancaria }

// Converte a forma de pagamento entre tela e banco de dados.
extension FormaPagamentoX on FormaPagamento {
  String get rotulo {
    switch (this) {
      case FormaPagamento.dinheiro:
        return 'Dinheiro';
      case FormaPagamento.pix:
        return 'Pix';
      case FormaPagamento.cartao:
        return 'Cartão';
      case FormaPagamento.transferenciaBancaria:
        return 'Transferência';
    }
  }

  // Valor gravado na coluna forma_pagamento da tabela pagamentos_aluguel.
  String get valorBanco {
    switch (this) {
      case FormaPagamento.dinheiro:
        return 'dinheiro';
      case FormaPagamento.pix:
        return 'pix';
      case FormaPagamento.cartao:
        return 'cartao';
      case FormaPagamento.transferenciaBancaria:
        return 'transferencia_bancaria';
    }
  }

  // Converte o texto vindo do banco para o enum usado no app.
  static FormaPagamento doBanco(String valor) {
    switch (valor) {
      case 'pix':
        return FormaPagamento.pix;
      case 'cartao':
      case 'card':
        return FormaPagamento.cartao;
      case 'transferencia_bancaria':
      case 'bank_transfer':
        return FormaPagamento.transferenciaBancaria;
      case 'dinheiro':
      case 'cash':
      default:
        return FormaPagamento.dinheiro;
    }
  }
}
