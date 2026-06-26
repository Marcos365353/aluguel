// Status possiveis de um contrato de aluguel.
enum StatusContrato { ativo, encerrado, cancelado }

// Ajuda a mostrar texto na tela e converter para o valor salvo no banco.
extension StatusContratoX on StatusContrato {
  String get rotulo {
    switch (this) {
      case StatusContrato.ativo:
        return 'Ativo';
      case StatusContrato.encerrado:
        return 'Encerrado';
      case StatusContrato.cancelado:
        return 'Cancelado';
    }
  }

  // Valor gravado na coluna status da tabela contratos_aluguel.
  String get valorBanco {
    switch (this) {
      case StatusContrato.ativo:
        return 'ativo';
      case StatusContrato.encerrado:
        return 'encerrado';
      case StatusContrato.cancelado:
        return 'cancelado';
    }
  }

  // Converte o texto vindo do banco para o enum usado no Dart.
  static StatusContrato doBanco(String valor) {
    switch (valor) {
      case 'encerrado':
      case 'finished':
        return StatusContrato.encerrado;
      case 'cancelado':
      case 'canceled':
        return StatusContrato.cancelado;
      case 'ativo':
      case 'active':
      default:
        return StatusContrato.ativo;
    }
  }
}
