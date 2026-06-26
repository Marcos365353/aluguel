import 'package:flutter/foundation.dart';

import '../data/models/locador.dart';
import '../services/dao/locador_servico.dart';

// Controle de locadores.
// Controla a lista de proprietarios/locadores.
class LocadorControle extends ChangeNotifier {
  final LocadorServico _dao = LocadorServico();
  List<Locador> _locadores = [];

  // Lista somente leitura usada pelas telas.
  List<Locador> get locadores => List.unmodifiable(_locadores);

  // Busca locadores no DAO.
  Future<void> carregarLocadores() async {
    _locadores = await _dao.buscarTodos();
    notifyListeners();
  }

  // Salva locador e atualiza a lista.
  Future<void> salvarLocador(Locador locador) async {
    await _dao.salvar(locador);
    await carregarLocadores();
  }

  // Remove locador pelo id.
  Future<void> deletarLocador(String id) async {
    await _dao.delete(id);
    await carregarLocadores();
  }
}
