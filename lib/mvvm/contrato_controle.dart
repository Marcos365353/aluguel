import 'package:flutter/foundation.dart';

import '../data/models/contrato_aluguel.dart';
import '../services/dao/contrato_servico.dart';

// Controle de contratos no padrao MVVM.
// Ele busca, salva e remove contratos usando o DAO.
class ContratoControle extends ChangeNotifier {
  final ContratoServico _dao = ContratoServico();
  List<ContratoAluguel> _contratos = [];

  // Devolve uma copia segura da lista para a tela.
  List<ContratoAluguel> get contratos => List.unmodifiable(_contratos);

  // Carrega contratos do banco e avisa a tela para redesenhar.
  Future<void> carregarContratos() async {
    _contratos = await _dao.buscarTodos();
    notifyListeners();
  }

  // Salva um contrato e atualiza a lista.
  Future<void> salvarContrato(ContratoAluguel contrato) async {
    await _dao.salvar(contrato);
    await carregarContratos();
  }

  // Exclui um contrato e atualiza a lista.
  Future<void> deletarContrato(String id) async {
    await _dao.delete(id);
    await carregarContratos();
  }
}
