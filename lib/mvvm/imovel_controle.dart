import 'package:flutter/foundation.dart';

import '../data/models/imovel.dart';
import '../services/dao/imovel_servico.dart';

// Controle de imoveis no padrao MVVM.
// Ele centraliza as operacoes da tela de imoveis.
class ImovelControle extends ChangeNotifier {
  final ImovelServico _dao = ImovelServico();
  List<Imovel> _imoveis = [];

  // Lista somente leitura para evitar alteracao direta pela tela.
  List<Imovel> get imoveis => List.unmodifiable(_imoveis);

  // Busca os imoveis e avisa quem estiver escutando.
  Future<void> carregarImoveis() async {
    _imoveis = await _dao.buscarTodos();
    notifyListeners();
  }

  // Salva um imovel e recarrega a lista.
  Future<void> salvarImovel(Imovel imovel) async {
    await _dao.salvar(imovel);
    await carregarImoveis();
  }

  // Remove um imovel pelo id.
  Future<void> deletarImovel(String id) async {
    await _dao.delete(id);
    await carregarImoveis();
  }
}
