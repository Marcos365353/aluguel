import '../../data/models/inquilino.dart';
import '../../data/repositories/repositorio_aluguel_supabase.dart';

// Acesso aos inquilinos no Supabase.
// Mantem a tela isolada dos detalhes do repositorio.
class InquilinoServico {
  final _repository = RepositorioAluguelSupabase();

  // Busca todos os inquilinos.
  Future<List<Inquilino>> buscarTodos() async {
    final dados = await _repository.buscarDados();
    return dados.inquilinos;
  }

  // Cria ou atualiza um inquilino.
  Future<void> salvar(Inquilino inquilino) {
    return _repository.salvarInquilino(inquilino);
  }

  // Exclui inquilino pelo id.
  Future<void> delete(String id) {
    return _repository.excluirInquilino(id);
  }
}
