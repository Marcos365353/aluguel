import '../data/models/status_contrato.dart';

// Modelo da tabela public.contratos_aluguel no Supabase.
// Representa o acordo entre locador, inquilino e imovel.
class Contrato {
  const Contrato({
    required this.id,
    required this.imovelId,
    required this.imovelEndereco,
    required this.locadorId,
    required this.locadorNome,
    required this.inquilinoId,
    required this.inquilinoNome,
    required this.dataInicio,
    required this.dataFim,
    required this.diaVencimento,
    required this.valorMensal,
    required this.status,
    required this.observacoes,
    this.criadoEm,
    this.atualizadoEm,
  });

  static const nomeTabela = 'contratos_aluguel';

  final String id;
  final String imovelId;
  final String imovelEndereco;
  final String locadorId;
  final String locadorNome;
  final String inquilinoId;
  final String inquilinoNome;
  final DateTime dataInicio;
  final DateTime dataFim;
  final int diaVencimento;
  final double valorMensal;
  final StatusContrato status;
  final String observacoes;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  factory Contrato.deMapa(Map<String, dynamic> map) {
    return Contrato(
      id: map['id'] as String,
      imovelId: map['imovel_id'] as String,
      imovelEndereco: map['imovel_endereco'] as String,
      locadorId: map['locador_id'] as String,
      locadorNome: map['locador_nome'] as String,
      inquilinoId: map['inquilino_id'] as String,
      inquilinoNome: map['inquilino_nome'] as String,
      dataInicio: DateTime.parse(map['data_inicio'] as String),
      dataFim: DateTime.parse(map['data_fim'] as String),
      diaVencimento: map['dia_vencimento'] as int,
      valorMensal: (map['valor_mensal'] as num).toDouble(),
      status: StatusContratoX.doBanco(map['status'] as String),
      observacoes: map['observacoes'] as String,
      criadoEm: _lerData(map['criado_em']),
      atualizadoEm: _lerData(map['atualizado_em']),
    );
  }

  Map<String, dynamic> paraMapa() {
    return {
      'id': id,
      'imovel_id': imovelId,
      'imovel_endereco': imovelEndereco,
      'locador_id': locadorId,
      'locador_nome': locadorNome,
      'inquilino_id': inquilinoId,
      'inquilino_nome': inquilinoNome,
      'data_inicio': dataInicio.toIso8601String(),
      'data_fim': dataFim.toIso8601String(),
      'dia_vencimento': diaVencimento,
      'valor_mensal': valorMensal,
      'status': status.valorBanco,
      'observacoes': observacoes,
    };
  }

  static DateTime? _lerData(Object? valor) {
    return valor == null ? null : DateTime.parse(valor as String);
  }
}
