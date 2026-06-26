import 'locador.dart';
import 'contrato_aluguel.dart';
import 'imovel.dart';
import 'notificacao_aluguel.dart';
import 'pagamento_aluguel.dart';
import 'inquilino.dart';

// Pacote com todos os dados principais carregados do banco.
// O repositorio devolve isso para o AppState atualizar as telas.
class DadosAluguel {
  const DadosAluguel({
    required this.locadores,
    required this.inquilinos,
    required this.imoveis,
    required this.contratos,
    required this.pagamentos,
    required this.notificacoes,
  });

  final List<Locador> locadores;
  final List<Inquilino> inquilinos;
  final List<Imovel> imoveis;
  final List<ContratoAluguel> contratos;
  final List<PagamentoAluguel> pagamentos;
  final List<NotificacaoAluguel> notificacoes;
}
