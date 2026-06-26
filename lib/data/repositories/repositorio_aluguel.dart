import '../models/locador.dart';
import '../models/contrato_aluguel.dart';
import '../models/imovel.dart';
import '../models/dados_aluguel.dart';
import '../models/notificacao_aluguel.dart';
import '../models/pagamento_aluguel.dart';
import '../models/inquilino.dart';

// Contrato do repositorio.
// Ele define as operacoes usadas pela fonte de dados do app.
abstract class RepositorioAluguel {
  // Busca todos os dados principais do app.
  Future<DadosAluguel> buscarDados();

  // Cria ou atualiza locador.
  Future<void> salvarLocador(Locador locador);

  // Exclui locador.
  Future<void> excluirLocador(String id);

  // Cria ou atualiza inquilino.
  Future<void> salvarInquilino(Inquilino inquilino);

  // Exclui inquilino.
  Future<void> excluirInquilino(String id);

  // Cria ou atualiza imovel.
  Future<void> salvarImovel(Imovel imovel);

  // Exclui imovel.
  Future<void> excluirImovel(String id);

  // Cria ou atualiza contrato.
  Future<void> salvarContrato(ContratoAluguel contrato);

  // Exclui contrato.
  Future<void> excluirContrato(String id);

  // Registra pagamento.
  Future<void> criarPagamento(PagamentoAluguel pagamento);

  // Exclui pagamento.
  Future<void> excluirPagamento(String id);

  // Salva avisos de vencimento.
  Future<void> criarNotificacoes(List<NotificacaoAluguel> notificacoes);
}
