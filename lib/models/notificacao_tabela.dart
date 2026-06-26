// Modelo da tabela public.notificacoes_aluguel no Supabase.
// Esta classe representa os avisos de vencimento salvos no banco.
class Notificacao {
  const Notificacao({
    required this.id,
    required this.contratoId,
    required this.inquilinoNome,
    required this.mensagem,
    required this.enviadoEm,
    required this.status,
    this.criadoEm,
    this.atualizadoEm,
  });

  // Nome da tabela usada pelos servicos/DAOs ao consultar o Supabase.
  static const nomeTabela = 'notificacoes_aluguel';

  // Identificador unico da notificacao.
  final String id;

  // Id do contrato que gerou este aviso.
  final String contratoId;

  // Nome do inquilino mostrado na tela financeira.
  final String inquilinoNome;

  // Texto do aviso, por exemplo informando vencimento proximo.
  final String mensagem;

  // Data em que o aviso foi gerado/enviado pelo sistema.
  final DateTime enviadoEm;

  // Status textual do aviso salvo no banco.
  final String status;

  // Datas controladas pelo banco para auditoria do registro.
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  // Converte o mapa vindo do Supabase para um objeto Notificacao.
  // As chaves aqui precisam bater com as colunas da tabela notificacoes_aluguel.
  factory Notificacao.deMapa(Map<String, dynamic> map) {
    return Notificacao(
      id: map['id'] as String,
      contratoId: map['contrato_id'] as String,
      inquilinoNome: map['inquilino_nome'] as String,
      mensagem: map['mensagem'] as String,
      enviadoEm: DateTime.parse(map['enviado_em'] as String),
      status: map['status'] as String,
      criadoEm: _lerData(map['criado_em']),
      atualizadoEm: _lerData(map['atualizado_em']),
    );
  }

  // Converte o objeto Notificacao para o mapa enviado ao Supabase.
  // Nao envia criado_em/atualizado_em porque o banco preenche esses campos.
  Map<String, dynamic> paraMapa() {
    return {
      'id': id,
      'contrato_id': contratoId,
      'inquilino_nome': inquilinoNome,
      'mensagem': mensagem,
      'enviado_em': enviadoEm.toIso8601String(),
      'status': status,
    };
  }

  // Le datas opcionais do banco.
  // Se o Supabase retornar null, o app mantem o campo como null.
  static DateTime? _lerData(Object? valor) {
    return valor == null ? null : DateTime.parse(valor as String);
  }
}
