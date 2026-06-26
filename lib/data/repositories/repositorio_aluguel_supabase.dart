import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/contrato_tabela.dart' as contrato_tabela;
import '../../models/imovel_tabela.dart' as imovel_tabela;
import '../../models/inquilino_tabela.dart' as inquilino_tabela;
import '../../models/locador_tabela.dart' as locador_tabela;
import '../../models/notificacao_tabela.dart' as notificacao_tabela;
import '../../models/pagamento_tabela.dart' as pagamento_tabela;
import '../models/status_contrato.dart';
import '../models/locador.dart';
import '../models/status_imovel.dart';
import '../models/contrato_aluguel.dart';
import '../models/imovel.dart';
import '../models/dados_aluguel.dart';
import '../models/notificacao_aluguel.dart';
import '../models/pagamento_aluguel.dart';
import '../models/inquilino.dart';
import 'repositorio_aluguel.dart';

// Esta classe conversa com as tabelas do Supabase.
// Ela transforma os dados do banco em objetos usados pelo app.
class RepositorioAluguelSupabase implements RepositorioAluguel {
  // Pega o cliente do Supabase que foi aberto no main.dart.
  SupabaseClient get _cliente => Supabase.instance.client;

  @override
  Future<DadosAluguel> buscarDados() async {
    // Busca todas as tabelas principais de uma vez.
    final results = await Future.wait([
      _cliente.from('locadores').select().order('nome'),
      _cliente.from('inquilinos').select().order('nome'),
      _cliente.from('imoveis').select().order('endereco'),
      _cliente.from('contratos_aluguel').select().order('data_inicio'),
      _cliente.from('pagamentos_aluguel').select().order('data_pagamento'),
      _cliente
          .from('notificacoes_aluguel')
          .select()
          .order('enviado_em', ascending: false),
    ]);

    return DadosAluguel(
      locadores: _comoLinhas(results[0]).map(_locadorDoMapa).toList(),
      inquilinos: _comoLinhas(results[1]).map(_inquilinoDoMapa).toList(),
      imoveis: _comoLinhas(results[2]).map(_imovelDoMapa).toList(),
      contratos: _comoLinhas(results[3]).map(_contratoDoMapa).toList(),
      pagamentos: _comoLinhas(results[4]).map(_pagamentoDoMapa).toList(),
      notificacoes: _comoLinhas(results[5]).map(_notificacaoDoMapa).toList(),
    );
  }

  @override
  Future<void> salvarLocador(Locador locador) async {
    // Upsert cria se nao existir, ou atualiza se ja existir.
    await _cliente.from('locadores').upsert(_locadorParaMapa(locador));
  }

  @override
  Future<void> excluirLocador(String id) async {
    await _cliente.from('locadores').delete().eq('id', id);
  }

  @override
  Future<void> salvarInquilino(Inquilino inquilino) async {
    // Salva os dados do inquilino na tabela inquilinos.
    await _cliente.from('inquilinos').upsert(_inquilinoParaMapa(inquilino));
  }

  @override
  Future<void> excluirInquilino(String id) async {
    await _cliente.from('inquilinos').delete().eq('id', id);
  }

  @override
  Future<void> salvarImovel(Imovel imovel) async {
    // Salva os dados do imovel na tabela imoveis.
    await _cliente.from('imoveis').upsert(_imovelParaMapa(imovel));
  }

  @override
  Future<void> excluirImovel(String id) async {
    await _cliente.from('imoveis').delete().eq('id', id);
  }

  @override
  Future<void> salvarContrato(ContratoAluguel contrato) async {
    // Antes de salvar, verifica se o contrato ja estava ligado a outro imovel.
    final linhasAnteriores = await _cliente
        .from('contratos_aluguel')
        .select('imovel_id')
        .eq('id', contrato.id)
        .limit(1);
    final imovelAnteriorId = linhasAnteriores.isEmpty
        ? null
        : linhasAnteriores.first['imovel_id'] as String;

    await _cliente
        .from('contratos_aluguel')
        .upsert(_contratoParaMapa(contrato));
    // Depois de salvar o contrato, atualiza se o imovel esta alugado ou livre.
    await _atualizarStatusImovel(contrato.imovelId);

    if (imovelAnteriorId != null && imovelAnteriorId != contrato.imovelId) {
      await _atualizarStatusImovel(imovelAnteriorId);
    }
  }

  @override
  Future<void> excluirContrato(String id) async {
    final linhas = await _cliente
        .from('contratos_aluguel')
        .select('imovel_id')
        .eq('id', id)
        .limit(1);

    await _cliente.from('contratos_aluguel').delete().eq('id', id);

    if (linhas.isNotEmpty) {
      await _atualizarStatusImovel(linhas.first['imovel_id'] as String);
    }
  }

  @override
  Future<void> criarPagamento(PagamentoAluguel pagamento) async {
    // Registra um pagamento novo na tabela pagamentos_aluguel.
    await _cliente
        .from('pagamentos_aluguel')
        .insert(_pagamentoParaMapa(pagamento));
  }

  @override
  Future<void> excluirPagamento(String id) async {
    await _cliente.from('pagamentos_aluguel').delete().eq('id', id);
  }

  @override
  Future<void> criarNotificacoes(List<NotificacaoAluguel> notificacoes) async {
    if (notificacoes.isEmpty) {
      return;
    }

    await _cliente
        .from('notificacoes_aluguel')
        .insert(notificacoes.map(_notificacaoParaMapa).toList());
  }

  Future<void> _atualizarStatusImovel(String imovelId) async {
    // Se existir contrato ativo, o imovel fica como alugado.
    final contratosAtivos = await _cliente
        .from('contratos_aluguel')
        .select('id')
        .eq('imovel_id', imovelId)
        .eq('status', StatusContrato.ativo.valorBanco);

    await _cliente
        .from('imoveis')
        .update({
          'status': contratosAtivos.isEmpty
              ? StatusImovel.disponivel.valorBanco
              : StatusImovel.alugado.valorBanco,
        })
        .eq('id', imovelId);
  }

  static List<Map<String, dynamic>> _comoLinhas(Object? valor) {
    return (valor as List)
        .map((linha) => Map<String, dynamic>.from(linha as Map))
        .toList();
  }

  // Os metodos abaixo convertem entre Map do Supabase e classes do Dart.
  static Locador _locadorDoMapa(Map<String, dynamic> map) {
    final locador = locador_tabela.Locador.deMapa(map);
    return Locador(
      id: locador.id,
      nome: locador.nome,
      cpf: locador.cpf,
      telefone: locador.telefone,
      email: locador.email,
    );
  }

  static Map<String, Object?> _locadorParaMapa(Locador locador) {
    return locador_tabela.Locador(
      id: locador.id,
      nome: locador.nome,
      cpf: locador.cpf,
      telefone: locador.telefone,
      email: locador.email,
    ).paraMapa();
  }

  static Inquilino _inquilinoDoMapa(Map<String, dynamic> map) {
    final inquilino = inquilino_tabela.Inquilino.deMapa(map);
    return Inquilino(
      id: inquilino.id,
      nome: inquilino.nome,
      cpf: inquilino.cpf,
      telefone: inquilino.telefone,
      email: inquilino.email,
    );
  }

  static Map<String, Object?> _inquilinoParaMapa(Inquilino inquilino) {
    return inquilino_tabela.Inquilino(
      id: inquilino.id,
      nome: inquilino.nome,
      cpf: inquilino.cpf,
      telefone: inquilino.telefone,
      email: inquilino.email,
    ).paraMapa();
  }

  static Imovel _imovelDoMapa(Map<String, dynamic> map) {
    final imovel = imovel_tabela.Imovel.deMapa(map);
    return Imovel(
      id: imovel.id,
      endereco: imovel.endereco,
      tipo: imovel.tipo,
      valorAluguel: imovel.valorAluguel,
      status: imovel.status,
    );
  }

  static Map<String, Object?> _imovelParaMapa(Imovel imovel) {
    return imovel_tabela.Imovel(
      id: imovel.id,
      endereco: imovel.endereco,
      tipo: imovel.tipo,
      valorAluguel: imovel.valorAluguel,
      status: imovel.status,
    ).paraMapa();
  }

  static ContratoAluguel _contratoDoMapa(Map<String, dynamic> map) {
    final contrato = contrato_tabela.Contrato.deMapa(map);
    return ContratoAluguel(
      id: contrato.id,
      imovelId: contrato.imovelId,
      imovelEndereco: contrato.imovelEndereco,
      locadorId: contrato.locadorId,
      locadorNome: contrato.locadorNome,
      inquilinoId: contrato.inquilinoId,
      inquilinoNome: contrato.inquilinoNome,
      dataInicio: contrato.dataInicio,
      dataFim: contrato.dataFim,
      diaVencimento: contrato.diaVencimento,
      valorMensal: contrato.valorMensal,
      status: contrato.status,
      observacoes: contrato.observacoes,
    );
  }

  static Map<String, Object?> _contratoParaMapa(ContratoAluguel contrato) {
    return contrato_tabela.Contrato(
      id: contrato.id,
      imovelId: contrato.imovelId,
      imovelEndereco: contrato.imovelEndereco,
      locadorId: contrato.locadorId,
      locadorNome: contrato.locadorNome,
      inquilinoId: contrato.inquilinoId,
      inquilinoNome: contrato.inquilinoNome,
      dataInicio: contrato.dataInicio,
      dataFim: contrato.dataFim,
      diaVencimento: contrato.diaVencimento,
      valorMensal: contrato.valorMensal,
      status: contrato.status,
      observacoes: contrato.observacoes,
    ).paraMapa();
  }

  static PagamentoAluguel _pagamentoDoMapa(Map<String, dynamic> map) {
    final pagamento = pagamento_tabela.Pagamento.deMapa(map);
    return PagamentoAluguel(
      id: pagamento.id,
      contratoId: pagamento.contratoId,
      dataVencimento: pagamento.dataVencimento,
      dataPagamento: pagamento.dataPagamento,
      valorPago: pagamento.valorPago,
      formaPagamento: pagamento.formaPagamento,
      status: pagamento.status,
    );
  }

  static Map<String, Object?> _pagamentoParaMapa(PagamentoAluguel pagamento) {
    return pagamento_tabela.Pagamento(
      id: pagamento.id,
      contratoId: pagamento.contratoId,
      dataVencimento: pagamento.dataVencimento,
      dataPagamento: pagamento.dataPagamento,
      valorPago: pagamento.valorPago,
      formaPagamento: pagamento.formaPagamento,
      status: pagamento.status,
    ).paraMapa();
  }

  static NotificacaoAluguel _notificacaoDoMapa(Map<String, dynamic> map) {
    final notificacao = notificacao_tabela.Notificacao.deMapa(map);
    return NotificacaoAluguel(
      id: notificacao.id,
      contratoId: notificacao.contratoId,
      inquilinoNome: notificacao.inquilinoNome,
      mensagem: notificacao.mensagem,
      enviadoEm: notificacao.enviadoEm,
      status: notificacao.status,
    );
  }

  static Map<String, Object?> _notificacaoParaMapa(
    NotificacaoAluguel notificacao,
  ) {
    return notificacao_tabela.Notificacao(
      id: notificacao.id,
      contratoId: notificacao.contratoId,
      inquilinoNome: notificacao.inquilinoNome,
      mensagem: notificacao.mensagem,
      enviadoEm: notificacao.enviadoEm,
      status: notificacao.status,
    ).paraMapa();
  }
}
