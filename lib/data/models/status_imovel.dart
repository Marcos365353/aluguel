// Status possiveis de um imovel.
enum StatusImovel { disponivel, alugado, inativo }

// Converte o status do imovel entre tela e banco de dados.
extension StatusImovelX on StatusImovel {
  String get rotulo {
    switch (this) {
      case StatusImovel.disponivel:
        return 'Disponível';
      case StatusImovel.alugado:
        return 'Alugado';
      case StatusImovel.inativo:
        return 'Inativo';
    }
  }

  // Valor gravado na coluna status da tabela imoveis.
  String get valorBanco {
    switch (this) {
      case StatusImovel.disponivel:
        return 'disponivel';
      case StatusImovel.alugado:
        return 'alugado';
      case StatusImovel.inativo:
        return 'inativo';
    }
  }

  // Converte o texto vindo do banco para o enum usado no app.
  static StatusImovel doBanco(String valor) {
    switch (valor) {
      case 'alugado':
      case 'rented':
        return StatusImovel.alugado;
      case 'inativo':
      case 'inactive':
        return StatusImovel.inativo;
      case 'disponivel':
      case 'available':
      default:
        return StatusImovel.disponivel;
    }
  }
}
