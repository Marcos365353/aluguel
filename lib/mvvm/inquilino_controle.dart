import 'package:flutter/foundation.dart';

import '../data/models/inquilino.dart';
import '../services/dao/inquilino_servico.dart';

// Controle de inquilinos.
// Fica entre a tela e o DAO.
class InquilinoControle extends ChangeNotifier {
  final InquilinoServico _dao = InquilinoServico();
  List<Inquilino> _inquilinos = [];

  // Lista protegida para a tela apenas ler.
  List<Inquilino> get inquilinos => List.unmodifiable(_inquilinos);

  // Carrega os inquilinos cadastrados.
  Future<void> carregarInquilinos() async {
    _inquilinos = await _dao.buscarTodos();
    notifyListeners();
  }

  // Salva um inquilino e atualiza a tela.
  Future<void> salvarInquilino(Inquilino inquilino) async {
    await _dao.salvar(inquilino);
    await carregarInquilinos();
  }

  // Exclui um inquilino pelo id.
  Future<void> deletarInquilino(String id) async {
    await _dao.delete(id);
    await carregarInquilinos();
  }
}
