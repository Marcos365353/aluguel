import '../../core/utils/formatadores.dart';
import '../models/locador.dart';
import '../models/contrato_aluguel.dart';
import '../models/imovel.dart';
import '../models/inquilino.dart';
import '../models/status_contrato.dart';
import '../models/status_imovel.dart';

// Dados de exemplo para o app nao abrir vazio quando a base estiver limpa.
class DadosExemplo {
  const DadosExemplo._();

  // Locador de exemplo.
  static const locadorExemplo = Locador(
    id: 'locador-demo',
    nome: 'Marcos Vinicius',
    cpf: '000.000.000-00',
    telefone: '(65) 99999-0000',
    email: 'marcos@email.com',
  );

  // Inquilino de exemplo.
  static const inquilinoExemplo = Inquilino(
    id: 'inquilino-demo',
    nome: 'Cliente Exemplo',
    cpf: '111.111.111-11',
    telefone: '(65) 98888-0000',
    email: 'cliente@email.com',
  );

  // Imovel de exemplo.
  static const imovelExemplo = Imovel(
    id: 'imovel-demo',
    endereco: 'Rua das Flores, 120 - Centro',
    tipo: 'Casa',
    valorAluguel: 1200,
    status: StatusImovel.alugado,
  );

  // Contrato de exemplo gerado com a data atual.
  static ContratoAluguel contratoExemplo() {
    final agora = DateTime.now();
    return ContratoAluguel(
      id: 'contrato-demo',
      imovelId: imovelExemplo.id,
      imovelEndereco: imovelExemplo.endereco,
      locadorId: locadorExemplo.id,
      locadorNome: locadorExemplo.nome,
      inquilinoId: inquilinoExemplo.id,
      inquilinoNome: inquilinoExemplo.nome,
      dataInicio: DateTime(agora.year, agora.month, 1),
      dataFim: DateTime(agora.year + 1, agora.month, 1),
      diaVencimento: 10,
      valorMensal: imovelExemplo.valorAluguel,
      status: StatusContrato.ativo,
      observacoes:
          'Contrato demonstrativo criado em ${FormatadoresApp.data(agora)}.',
    );
  }
}
