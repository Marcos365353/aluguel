import 'package:flutter/foundation.dart';

import '../../core/utils/formatadores.dart';
import '../../data/seed/dados_exemplo.dart';
import '../../data/models/locador.dart';
import '../../data/models/contrato_aluguel.dart';
import '../../data/models/metricas_aluguel.dart';
import '../../data/models/imovel.dart';
import '../../data/models/notificacao_aluguel.dart';
import '../../data/models/pagamento_aluguel.dart';
import '../../data/models/inquilino.dart';
import '../../data/models/status_contrato.dart';
import '../../data/models/forma_pagamento.dart';
import '../../data/models/status_pagamento.dart';
import '../../data/models/status_imovel.dart';
import '../../data/repositories/repositorio_aluguel.dart';

// AppState e o estado principal do aplicativo.
// As telas chamam esta classe, e ela chama o repositorio que conversa com o banco.
class AppState extends ChangeNotifier {
  AppState({required RepositorioAluguel repositorioAluguel})
    : _repositorioAluguel = repositorioAluguel;

  final RepositorioAluguel _repositorioAluguel;

  // Variaveis de controle da tela.
  bool _carregando = true;
  String? _mensagemErro;
  int _indiceAbaAtual = 0;

  // Listas carregadas do banco/Supabase.
  List<Locador> _locadores = const [];
  List<Inquilino> _inquilinos = const [];
  List<Imovel> _imoveis = const [];
  List<ContratoAluguel> _contratos = const [];
  List<PagamentoAluguel> _pagamentos = const [];
  List<NotificacaoAluguel> _notificacoes = const [];

  bool get carregando => _carregando;
  String? get mensagemErro => _mensagemErro;
  int get indiceAbaAtual => _indiceAbaAtual;
  List<Locador> get locadores => _locadores;
  List<Inquilino> get inquilinos => _inquilinos;
  List<Imovel> get imoveis => _imoveis;
  List<ContratoAluguel> get contratos => _contratos;
  List<PagamentoAluguel> get pagamentos => _pagamentos;
  List<NotificacaoAluguel> get notificacoes => _notificacoes;

  // Se nao existir locador salvo, usa um locador de exemplo.
  Locador get locadorPrincipal =>
      _locadores.isEmpty ? DadosExemplo.locadorExemplo : _locadores.first;

  // Calcula os numeros do dashboard com base nos dados carregados.
  MetricasAluguel get metricas => MetricasAluguel.dosDados(
    imoveis: _imoveis,
    contratos: _contratos,
    pagamentos: _pagamentos,
  );

  // Retorna apenas os contratos que ainda estao ativos.
  List<ContratoAluguel> get contratosAtivos {
    return _contratos.where((contrato) => contrato.estaAtivo).toList();
  }

  // Carrega os dados quando o usuario entra no app.
  Future<void> inicializar() async {
    _definirCarregando(true);
    _mensagemErro = null;

    try {
      await _ensureDadosExemplo();
      await _carregarDados();
    } catch (error, stackTrace) {
      debugPrint('Falha ao inicializar: $error');
      debugPrintStack(stackTrace: stackTrace);
      _mensagemErro = 'Não foi possível carregar os dados do aplicativo.';
    } finally {
      _definirCarregando(false);
    }
  }

  // Recarrega os dados quando o usuario toca no botao atualizar.
  Future<void> recarregar() async {
    _definirCarregando(true);
    _mensagemErro = null;

    try {
      await _carregarDados();
    } catch (error, stackTrace) {
      debugPrint('Falha ao atualizar: $error');
      debugPrintStack(stackTrace: stackTrace);
      _mensagemErro = 'Falha ao atualizar os dados.';
    } finally {
      _definirCarregando(false);
    }
  }

  // Salva ou atualiza o locador.
  Future<void> salvarLocador({
    String? id,
    required String nome,
    required String cpf,
    required String telefone,
    required String email,
  }) async {
    await _repositorioAluguel.salvarLocador(
      Locador(
        id: id ?? FormatadoresApp.gerarId('locador'),
        nome: nome,
        cpf: cpf,
        telefone: telefone,
        email: email,
      ),
    );
    await _carregarDados();
  }

  // Exclui o locador pelo id.
  Future<void> excluirLocador(String id) async {
    await _repositorioAluguel.excluirLocador(id);
    await _carregarDados();
  }

  // Salva ou atualiza o inquilino.
  Future<void> salvarInquilino({
    String? id,
    required String nome,
    required String cpf,
    required String telefone,
    required String email,
  }) async {
    await _repositorioAluguel.salvarInquilino(
      Inquilino(
        id: id ?? FormatadoresApp.gerarId('inquilino'),
        nome: nome,
        cpf: cpf,
        telefone: telefone,
        email: email,
      ),
    );
    await _carregarDados();
  }

  // Exclui o inquilino pelo id.
  Future<void> excluirInquilino(String id) async {
    await _repositorioAluguel.excluirInquilino(id);
    await _carregarDados();
  }

  // Salva ou atualiza um imovel.
  Future<void> salvarImovel({
    String? id,
    required String endereco,
    required String tipo,
    required double valorAluguel,
    required StatusImovel status,
  }) async {
    await _repositorioAluguel.salvarImovel(
      Imovel(
        id: id ?? FormatadoresApp.gerarId('imovel'),
        endereco: endereco,
        tipo: tipo,
        valorAluguel: valorAluguel,
        status: status,
      ),
    );
    await _carregarDados();
  }

  // Exclui um imovel pelo id.
  Future<void> excluirImovel(String id) async {
    await _repositorioAluguel.excluirImovel(id);
    await _carregarDados();
  }

  // Salva ou atualiza um contrato de aluguel.
  Future<void> salvarContrato({
    String? id,
    required Imovel imovel,
    required Locador locador,
    required Inquilino inquilino,
    required DateTime dataInicio,
    required DateTime dataFim,
    required int diaVencimento,
    required double valorMensal,
    required StatusContrato status,
    required String observacoes,
  }) async {
    await _repositorioAluguel.salvarContrato(
      ContratoAluguel(
        id: id ?? FormatadoresApp.gerarId('contrato'),
        imovelId: imovel.id,
        imovelEndereco: imovel.endereco,
        locadorId: locador.id,
        locadorNome: locador.nome,
        inquilinoId: inquilino.id,
        inquilinoNome: inquilino.nome,
        dataInicio: dataInicio,
        dataFim: dataFim,
        diaVencimento: diaVencimento,
        valorMensal: valorMensal,
        status: status,
        observacoes: observacoes,
      ),
    );
    await _carregarDados();
  }

  // Exclui um pagamento pelo id.
  Future<void> excluirPagamento(String id) async {
    await _repositorioAluguel.excluirPagamento(id);
    await _carregarDados();
  }

  // Exclui um contrato pelo id.
  Future<void> excluirContrato(String id) async {
    await _repositorioAluguel.excluirContrato(id);
    await _carregarDados();
  }

  // Registra um pagamento feito pelo inquilino.
  Future<void> registrarPagamento({
    required ContratoAluguel contrato,
    required DateTime dataVencimento,
    required DateTime dataPagamento,
    required double valorPago,
    required FormaPagamento formaPagamento,
  }) async {
    await _repositorioAluguel.criarPagamento(
      PagamentoAluguel(
        id: FormatadoresApp.gerarId('pagamento'),
        contratoId: contrato.id,
        dataVencimento: dataVencimento,
        dataPagamento: dataPagamento,
        valorPago: valorPago,
        formaPagamento: formaPagamento,
        status: StatusPagamento.pago,
      ),
    );
    await _carregarDados();
  }

  // Gera avisos para o proximo vencimento pendente dos contratos ativos.
  Future<int> gerarAvisosVencimento() async {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final geradas = <NotificacaoAluguel>[];

    // Passa por todos os contratos ativos procurando a proxima parcela pendente.
    for (final contrato in contratosAtivos) {
      final dataVencimento = contrato.proximoVencimento(
        _pagamentos,
        agora: hoje,
      );
      final prazo = _descricaoPrazoVencimento(hoje, dataVencimento);

      final inquilino = _inquilinos.where(
        (item) => item.id == contrato.inquilinoId,
      );
      // Verifica se o inquilino tem algum contato cadastrado.
      final temContato =
          inquilino.isNotEmpty &&
          (inquilino.first.telefone.trim().isNotEmpty ||
              inquilino.first.email.trim().isNotEmpty);

      geradas.add(
        NotificacaoAluguel(
          id: FormatadoresApp.gerarId('notificacao'),
          contratoId: contrato.id,
          inquilinoNome: contrato.inquilinoNome,
          enviadoEm: agora,
          status: temContato ? 'Enviado' : 'Contato ausente',
          mensagem:
              'Aviso de vencimento: aluguel de ${contrato.imovelEndereco} '
              '$prazo, no valor de '
              '${FormatadoresApp.moeda(contrato.valorMensal)}.',
        ),
      );
    }

    await _repositorioAluguel.criarNotificacoes(geradas);
    await _carregarDados();
    return geradas.length;
  }

  // Monta um texto simples para explicar o prazo do aviso.
  String _descricaoPrazoVencimento(DateTime hoje, DateTime dataVencimento) {
    final dias = dataVencimento.difference(hoje).inDays;
    final dataFormatada = FormatadoresApp.data(dataVencimento);

    if (dias < 0) {
      final diasAtraso = dias.abs();
      return 'venceu em $dataFormatada, ha $diasAtraso dia(s)';
    }

    if (dias == 0) {
      return 'vence hoje ($dataFormatada)';
    }

    return 'vence em $dataFormatada, daqui a $dias dia(s)';
  }

  // Troca a aba aberta na barra inferior.
  void definirAba(int indice) {
    if (_indiceAbaAtual == indice) {
      return;
    }

    _indiceAbaAtual = indice;
    notifyListeners();
  }

  // Coloca dados iniciais para o app nao abrir totalmente vazio.
  Future<void> _ensureDadosExemplo() async {
    final dados = await _repositorioAluguel.buscarDados();

    if (dados.locadores.isEmpty) {
      await _repositorioAluguel.salvarLocador(DadosExemplo.locadorExemplo);
    }

    if (dados.imoveis.isNotEmpty ||
        dados.inquilinos.isNotEmpty ||
        dados.contratos.isNotEmpty) {
      return;
    }

    await _repositorioAluguel.salvarInquilino(DadosExemplo.inquilinoExemplo);
    await _repositorioAluguel.salvarImovel(DadosExemplo.imovelExemplo);
    await _repositorioAluguel.salvarContrato(DadosExemplo.contratoExemplo());
  }

  // Busca tudo no repositorio e atualiza as listas do AppState.
  Future<void> _carregarDados() async {
    final dados = await _repositorioAluguel.buscarDados();
    _locadores = dados.locadores;
    _inquilinos = dados.inquilinos;
    _imoveis = dados.imoveis;
    _contratos = dados.contratos;
    _pagamentos = dados.pagamentos;
    _notificacoes = dados.notificacoes;
    notifyListeners();
  }

  // Liga ou desliga o estado de carregamento.
  void _definirCarregando(bool valor) {
    if (_carregando == valor) {
      return;
    }

    _carregando = valor;
    notifyListeners();
  }
}
