import '../../data/models/imovel.dart';
import '../../data/repositories/repositorio_aluguel_supabase.dart';

// Acesso aos imoveis no Supabase.
// Mantem a tela isolada dos detalhes do repositorio.
class ImovelServico {
  final _repository = RepositorioAluguelSupabase();

  // Busca todos os imoveis.
  Future<List<Imovel>> buscarTodos() async {
    final dados = await _repository.buscarDados();
    return dados.imoveis;
  }

  // Cria ou atualiza um imovel.
  Future<void> salvar(Imovel imovel) {
    return _repository.salvarImovel(imovel);
  }

  // Exclui imovel pelo id.
  Future<void> delete(String id) {
    return _repository.excluirImovel(id);
  }
}
