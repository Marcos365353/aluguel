import '../../data/models/pagamento_aluguel.dart';
import '../../data/repositories/repositorio_aluguel_supabase.dart';

// Acesso aos pagamentos no Supabase.
// Centraliza leitura, criacao e exclusao.
class PagamentoServico {
  final _repository = RepositorioAluguelSupabase();

  // Busca todos os pagamentos.
  Future<List<PagamentoAluguel>> buscarTodos() async {
    final dados = await _repository.buscarDados();
    return dados.pagamentos;
  }

  // Cria um pagamento novo.
  Future<void> create(PagamentoAluguel pagamento) {
    return _repository.criarPagamento(pagamento);
  }

  // Exclui pagamento pelo id.
  Future<void> delete(String id) {
    return _repository.excluirPagamento(id);
  }
}
