import '../data/models/status_imovel.dart';

// Modelo da tabela public.imoveis no Supabase.
// Representa um imovel que pode estar disponivel, alugado ou inativo.
class Imovel {
  const Imovel({
    required this.id,
    required this.endereco,
    required this.tipo,
    required this.valorAluguel,
    required this.status,
    this.criadoEm,
    this.atualizadoEm,
  });

  static const nomeTabela = 'imoveis';

  final String id;
  final String endereco;
  final String tipo;
  final double valorAluguel;
  final StatusImovel status;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  factory Imovel.deMapa(Map<String, dynamic> map) {
    return Imovel(
      id: map['id'] as String,
      endereco: map['endereco'] as String,
      tipo: map['tipo'] as String,
      valorAluguel: (map['valor_aluguel'] as num).toDouble(),
      status: StatusImovelX.doBanco(map['status'] as String),
      criadoEm: _lerData(map['criado_em']),
      atualizadoEm: _lerData(map['atualizado_em']),
    );
  }

  Map<String, dynamic> paraMapa() {
    return {
      'id': id,
      'endereco': endereco,
      'tipo': tipo,
      'valor_aluguel': valorAluguel,
      'status': status.valorBanco,
    };
  }

  static DateTime? _lerData(Object? valor) {
    return valor == null ? null : DateTime.parse(valor as String);
  }
}
