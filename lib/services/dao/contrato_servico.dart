import '../../data/models/contrato_aluguel.dart';
import '../../data/repositories/repositorio_aluguel_supabase.dart';

// Acesso aos contratos no Supabase.
// Centraliza leitura, criacao, atualizacao e exclusao.
class ContratoServico {
  final _repository = RepositorioAluguelSupabase();

  // Le todos os contratos cadastrados.
  Future<List<ContratoAluguel>> buscarTodos() async {
    final dados = await _repository.buscarDados();
    return dados.contratos;
  }

  // Cria ou atualiza um contrato.
  Future<void> salvar(ContratoAluguel contrato) {
    return _repository.salvarContrato(contrato);
  }

  // Exclui contrato pelo id.
  Future<void> delete(String id) {
    return _repository.excluirContrato(id);
  }
}
