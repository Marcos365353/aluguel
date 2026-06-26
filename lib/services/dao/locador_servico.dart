import '../../data/models/locador.dart';
import '../../data/repositories/repositorio_aluguel_supabase.dart';

// Acesso aos locadores no Supabase.
// Controla leitura, criacao, atualizacao e exclusao.
class LocadorServico {
  final _repository = RepositorioAluguelSupabase();

  // Busca todos os locadores.
  Future<List<Locador>> buscarTodos() async {
    final dados = await _repository.buscarDados();
    return dados.locadores;
  }

  // Cria ou atualiza um locador.
  Future<void> salvar(Locador locador) {
    return _repository.salvarLocador(locador);
  }

  // Exclui locador pelo id.
  Future<void> delete(String id) {
    return _repository.excluirLocador(id);
  }
}
