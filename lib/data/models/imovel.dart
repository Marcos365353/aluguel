import 'status_imovel.dart';

// Modelo interno de imovel.
// Guarda endereco, tipo, valor do aluguel e status.
class Imovel {
  const Imovel({
    required this.id,
    required this.endereco,
    required this.tipo,
    required this.valorAluguel,
    required this.status,
  });

  final String id;
  final String endereco;
  final String tipo;
  final double valorAluguel;
  final StatusImovel status;
}
