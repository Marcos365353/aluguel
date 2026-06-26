import 'package:flutter/foundation.dart';

import '../data/models/pagamento_aluguel.dart';
import '../services/dao/pagamento_servico.dart';

// Controle de pagamentos.
// Controla a lista de pagamentos de aluguel.
class PagamentoControle extends ChangeNotifier {
  final PagamentoServico _dao = PagamentoServico();
  List<PagamentoAluguel> _pagamentos = [];

  // Lista protegida para a tela nao alterar direto.
  List<PagamentoAluguel> get pagamentos => List.unmodifiable(_pagamentos);

  // Carrega todos os pagamentos.
  Future<void> carregarPagamentos() async {
    _pagamentos = await _dao.buscarTodos();
    notifyListeners();
  }

  // Adiciona um pagamento e atualiza a lista.
  Future<void> adicionarPagamento(PagamentoAluguel pagamento) async {
    await _dao.create(pagamento);
    await carregarPagamentos();
  }

  // Exclui um pagamento pelo id.
  Future<void> deletarPagamento(String id) async {
    await _dao.delete(id);
    await carregarPagamentos();
  }
}
