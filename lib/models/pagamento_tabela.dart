import '../data/models/forma_pagamento.dart';
import '../data/models/status_pagamento.dart';

// Modelo da tabela public.pagamentos_aluguel no Supabase.
// Esta classe representa o formato exato que o banco usa para salvar pagamentos.
class Pagamento {
  const Pagamento({
    required this.id,
    required this.contratoId,
    required this.dataVencimento,
    required this.dataPagamento,
    required this.valorPago,
    required this.formaPagamento,
    required this.status,
    this.criadoEm,
    this.atualizadoEm,
  });

  // Nome da tabela usada pelos servicos/DAOs ao consultar o Supabase.
  static const nomeTabela = 'pagamentos_aluguel';

  // Identificador unico do pagamento.
  final String id;

  // Id do contrato ao qual este pagamento pertence.
  final String contratoId;

  // Data da parcela que estava vencendo.
  final DateTime dataVencimento;

  // Data em que o pagamento foi registrado como pago.
  final DateTime dataPagamento;

  // Valor efetivamente pago pelo inquilino.
  final double valorPago;

  // Forma de pagamento: pix, dinheiro, cartao ou transferencia bancaria.
  final FormaPagamento formaPagamento;

  // Status salvo no banco, por exemplo pago ou cancelado.
  final StatusPagamento status;

  // Datas controladas pelo banco para auditoria do registro.
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  // Converte o mapa vindo do Supabase para um objeto Pagamento.
  // As chaves aqui precisam bater com as colunas da tabela pagamentos_aluguel.
  factory Pagamento.deMapa(Map<String, dynamic> map) {
    return Pagamento(
      id: map['id'] as String,
      contratoId: map['contrato_id'] as String,
      dataVencimento: DateTime.parse(map['data_vencimento'] as String),
      dataPagamento: DateTime.parse(map['data_pagamento'] as String),
      valorPago: (map['valor_pago'] as num).toDouble(),
      formaPagamento: FormaPagamentoX.doBanco(map['forma_pagamento'] as String),
      status: StatusPagamentoX.doBanco(map['status'] as String),
      criadoEm: _lerData(map['criado_em']),
      atualizadoEm: _lerData(map['atualizado_em']),
    );
  }

  // Converte o objeto Pagamento para o mapa enviado ao Supabase.
  // Nao envia criado_em/atualizado_em porque o banco preenche esses campos.
  Map<String, dynamic> paraMapa() {
    return {
      'id': id,
      'contrato_id': contratoId,
      'data_vencimento': dataVencimento.toIso8601String(),
      'data_pagamento': dataPagamento.toIso8601String(),
      'valor_pago': valorPago,
      'forma_pagamento': formaPagamento.valorBanco,
      'status': status.valorBanco,
    };
  }

  // Le datas opcionais do banco.
  // Se o Supabase retornar null, o app mantem o campo como null.
  static DateTime? _lerData(Object? valor) {
    return valor == null ? null : DateTime.parse(valor as String);
  }
}
