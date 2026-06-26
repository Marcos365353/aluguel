import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/formatadores.dart';
import '../core/utils/texto_busca.dart';
import '../data/models/contrato_aluguel.dart';
import '../data/models/pagamento_aluguel.dart';
import '../data/models/forma_pagamento.dart';
import '../mvvm/viewmodels/app_state.dart';
import '../widgets/campo_busca_filtro.dart';

// Tela financeira.
// Registra pagamentos, mostra relatorio rapido, gera avisos e lista recebimentos.
class PagamentosTela extends StatefulWidget {
  const PagamentosTela({super.key});

  @override
  State<PagamentosTela> createState() => _PagamentosTelaState();
}

class _PagamentosTelaState extends State<PagamentosTela> {
  // Campo usado para buscar pagamentos na lista.
  // Quando o texto muda, a lista de pagamentos e recalculada no build.
  final _controladorBusca = TextEditingController();

  @override
  void dispose() {
    _controladorBusca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escuta o AppState para atualizar pagamentos, relatorios e avisos.
    return Consumer<AppState>(
      builder: (context, estado, _) {
        // Filtra pagamentos por inquilino, imovel, forma, valor e datas.
        // Se o contrato foi removido, ainda deixa o pagamento pesquisavel.
        final pagamentosFiltrados = estado.pagamentos.where((pagamento) {
          final contrato = _encontrarContrato(estado, pagamento);
          return TextoBusca.contem(_controladorBusca.text, [
            contrato?.inquilinoNome ?? 'Contrato removido',
            contrato?.imovelEndereco,
            pagamento.formaPagamento.rotulo,
            FormatadoresApp.moeda(pagamento.valorPago),
            pagamento.valorPago.toStringAsFixed(2),
            FormatadoresApp.data(pagamento.dataVencimento),
            FormatadoresApp.data(pagamento.dataPagamento),
          ]);
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Primeiro card: formulario para registrar um novo pagamento.
            _CartaoRegistroPagamento(estado: estado),
            const SizedBox(height: 12),
            // Segundo card: resumo calculado a partir de contratos e pagamentos.
            _CartaoRelatorios(estado: estado),
            const SizedBox(height: 12),
            // Terceiro card: geracao e exibicao dos avisos de vencimento.
            _CartaoNotificacoes(estado: estado),
            const SizedBox(height: 20),
            // Lista final: pagamentos ja registrados no Supabase.
            Text(
              'Pagamentos registrados',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (estado.pagamentos.isEmpty)
              // Estado vazio geral: ainda nao existe pagamento salvo.
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nenhum pagamento registrado.'),
                ),
              )
            else if (pagamentosFiltrados.isEmpty) ...[
              CampoBuscaFiltro(
                controlador: _controladorBusca,
                textoDica: 'Filtrar pagamentos',
                // Aplica o filtro assim que o usuario digita.
                aoMudar: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              // Estado vazio do filtro: existem pagamentos, mas nenhum bate com a busca.
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nenhum pagamento encontrado.'),
                ),
              ),
            ] else ...[
              CampoBuscaFiltro(
                controlador: _controladorBusca,
                textoDica: 'Filtrar pagamentos',
                // Aplica o filtro assim que o usuario digita.
                aoMudar: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              for (
                var indice = 0;
                indice < pagamentosFiltrados.length;
                indice++
              ) ...[
                if (indice > 0) const SizedBox(height: 10),
                _CartaoPagamento(
                  pagamento: pagamentosFiltrados[indice],
                  contrato: _encontrarContrato(
                    estado,
                    pagamentosFiltrados[indice],
                  ),
                  onDelete: () => _confirmarExclusaoPagamento(
                    context,
                    pagamentosFiltrados[indice],
                  ),
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  ContratoAluguel? _encontrarContrato(
    AppState estado,
    PagamentoAluguel pagamento,
  ) {
    // Encontra o contrato ligado ao pagamento.
    // Pode retornar null se o contrato foi excluido.
    final contrato = estado.contratos.where(
      (item) => item.id == pagamento.contratoId,
    );
    return contrato.isEmpty ? null : contrato.first;
  }

  Future<void> _confirmarExclusaoPagamento(
    BuildContext context,
    PagamentoAluguel pagamento,
  ) async {
    // Pergunta antes de apagar o pagamento.
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir pagamento'),
        content: const Text('Deseja excluir este pagamento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmado != true || !context.mounted) {
      // Se cancelar ou a tela nao existir mais, nao faz nada.
      return;
    }

    try {
      // Exclui o pagamento pelo AppState.
      await context.read<AppState>().excluirPagamento(pagamento.id);
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir o pagamento.')),
      );
      return;
    }

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pagamento excluído com sucesso.')),
    );
  }
}

// Cartao onde o usuario registra um pagamento de aluguel.
class _CartaoRegistroPagamento extends StatefulWidget {
  const _CartaoRegistroPagamento({required this.estado});

  // Estado com contratos ativos e pagamentos existentes.
  final AppState estado;

  @override
  State<_CartaoRegistroPagamento> createState() =>
      _EstadoCartaoRegistroPagamento();
}

class _EstadoCartaoRegistroPagamento extends State<_CartaoRegistroPagamento> {
  // Contrato selecionado para receber o pagamento.
  String? _contractId;

  // Forma de pagamento escolhida no dropdown.
  FormaPagamento _method = FormaPagamento.pix;

  // Controladores dos campos de data e valor.
  final _controladorDataVencimento = TextEditingController();
  final _controladorDataPagamento = TextEditingController();
  final _controladorValor = TextEditingController();

  @override
  void dispose() {
    _controladorDataVencimento.dispose();
    _controladorDataPagamento.dispose();
    _controladorValor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contratos = widget.estado.contratosAtivos;
    // Sem contrato ativo nao existe aluguel para receber.
    if (contratos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Nenhum contrato ativo para registrar pagamento.'),
        ),
      );
    }

    // Escolhe um contrato inicial e preenche datas/valor.
    _contractId ??= contratos.first.id;
    final selecionado = contratos.firstWhere(
      (contrato) => contrato.id == _contractId,
      orElse: () => contratos.first,
    );
    _sincronizarControladores(selecionado);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registrar pagamento',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: selecionado.id,
              decoration: const InputDecoration(labelText: 'Contrato'),
              items: contratos
                  .map(
                    (contrato) => DropdownMenuItem(
                      value: contrato.id,
                      child: Text(
                        '${contrato.inquilinoNome} - ${contrato.imovelEndereco}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              selectedItemBuilder: (context) => contratos
                  .map(
                    (contrato) => Text(
                      '${contrato.inquilinoNome} - ${contrato.imovelEndereco}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                  .toList(),
              onChanged: (valor) {
                if (valor == null) {
                  return;
                }

                final contrato = contratos.firstWhere(
                  (item) => item.id == valor,
                );
                setState(() {
                  _contractId = valor;
                  // Ao trocar contrato, recalcula vencimento e valor padrao.
                  _controladorDataVencimento.text = FormatadoresApp.data(
                    contrato.proximoVencimento(widget.estado.pagamentos),
                  );
                  _controladorValor.text = FormatadoresApp.decimalParaCampo(
                    contrato.valorMensal,
                  );
                });
              },
            ),
            const SizedBox(height: 12),
            _LinhaCamposResponsiva(
              children: [
                TextField(
                  controller: _controladorDataVencimento,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    labelText: 'Parcela venc.',
                    hintText: 'dd/mm/aaaa',
                  ),
                ),
                TextField(
                  controller: _controladorDataPagamento,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    labelText: 'Data pag.',
                    hintText: 'dd/mm/aaaa',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _LinhaCamposResponsiva(
              children: [
                TextField(
                  controller: _controladorValor,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Valor pago'),
                ),
                DropdownButtonFormField<FormaPagamento>(
                  isExpanded: true,
                  initialValue: _method,
                  decoration: const InputDecoration(labelText: 'Forma'),
                  items: FormaPagamento.values
                      .map(
                        (metodo) => DropdownMenuItem(
                          value: metodo,
                          child: Text(
                            metodo.rotulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (valor) {
                    if (valor != null) {
                      setState(() => _method = valor);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => _enviar(selecionado),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Registrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sincronizarControladores(ContratoAluguel selecionado) {
    // Preenche os campos automaticamente quando ainda estao vazios.
    // Isso evita sobrescrever algo que o usuario ja digitou manualmente.
    if (_controladorDataVencimento.text.isEmpty) {
      _controladorDataVencimento.text = FormatadoresApp.data(
        selecionado.proximoVencimento(widget.estado.pagamentos),
      );
    }
    if (_controladorDataPagamento.text.isEmpty) {
      _controladorDataPagamento.text = FormatadoresApp.data(DateTime.now());
    }
    if (_controladorValor.text.isEmpty) {
      _controladorValor.text = FormatadoresApp.decimalParaCampo(
        selecionado.valorMensal,
      );
    }
  }

  Future<void> _enviar(ContratoAluguel contrato) async {
    // Valida datas e valor antes de registrar pagamento.
    final dataVencimento = FormatadoresApp.lerData(
      _controladorDataVencimento.text,
    );
    final dataPagamento = FormatadoresApp.lerData(
      _controladorDataPagamento.text,
    );
    final amount = FormatadoresApp.lerDecimal(_controladorValor.text);

    if (dataVencimento == null ||
        dataPagamento == null ||
        amount == null ||
        amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revise data e valor do pagamento.')),
      );
      return;
    }

    try {
      // Envia o pagamento para o AppState salvar no Supabase.
      // Depois o AppState recarrega os dados e atualiza a tela.
      await context.read<AppState>().registrarPagamento(
        contrato: contrato,
        dataVencimento: dataVencimento,
        dataPagamento: dataPagamento,
        valorPago: amount,
        formaPagamento: _method,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível registrar pagamento.')),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      // Limpa apenas o vencimento para preparar a proxima parcela do contrato.
      _controladorDataVencimento.clear();
      _controladorDataPagamento.text = FormatadoresApp.data(DateTime.now());
      _controladorValor.text = FormatadoresApp.decimalParaCampo(
        contrato.valorMensal,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pagamento registrado com sucesso.')),
    );
  }
}

// Linha que muda para coluna em telas pequenas.
class _LinhaCamposResponsiva extends StatelessWidget {
  const _LinhaCamposResponsiva({required this.children});

  // Campos que ficam em linha larga ou em coluna no celular.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 380) {
          // Em telas estreitas, empilha os campos para evitar overflow.
          return Column(
            children: [
              for (var indice = 0; indice < children.length; indice++) ...[
                if (indice > 0) const SizedBox(height: 12),
                children[indice],
              ],
            ],
          );
        }

        // Em telas largas, divide o espaco igualmente.
        return Row(
          children: [
            for (var indice = 0; indice < children.length; indice++) ...[
              if (indice > 0) const SizedBox(width: 12),
              Expanded(child: children[indice]),
            ],
          ],
        );
      },
    );
  }
}

// Cartao com resumo financeiro rapido.
class _CartaoRelatorios extends StatelessWidget {
  const _CartaoRelatorios({required this.estado});

  // Estado usado para calcular contratos ativos, vencidos, receita e pendencias.
  final AppState estado;

  @override
  Widget build(BuildContext context) {
    // Metricas centraliza os calculos do relatorio rapido.
    final metricas = estado.metricas;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Relatório rápido',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            _LinhaRelatorio(
              rotulo: 'Contratos ativos',
              valor: metricas.contratosAtivos.toString(),
            ),
            _LinhaRelatorio(
              rotulo: 'Contratos vencidos',
              valor: metricas.contratosVencidos.toString(),
            ),
            _LinhaRelatorio(
              rotulo: 'Pagamentos no mês',
              valor: FormatadoresApp.moeda(metricas.receitaMes),
            ),
            _LinhaRelatorio(
              rotulo: 'Parcelas pendentes',
              valor: metricas.pendenciasMes.toString(),
            ),
          ],
        ),
      ),
    );
  }
}

// Cartao que cria e mostra avisos de vencimento.
class _CartaoNotificacoes extends StatelessWidget {
  const _CartaoNotificacoes({required this.estado});

  // Estado com avisos ja gerados e metodo para gerar novos avisos.
  final AppState estado;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Avisos de vencimento',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  // Gera avisos olhando os proximos vencimentos dos contratos ativos.
                  onPressed: () => _generate(context),
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text('Gerar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (estado.notificacoes.isEmpty)
              // Estado vazio: nenhum aviso foi gerado ainda.
              const Text('Nenhum aviso registrado.')
            else
              // Mostra os tres avisos mais recentes para manter o card compacto.
              ...estado.notificacoes
                  .take(3)
                  .map(
                    (notificacao) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(notificacao.inquilinoNome),
                      subtitle: Text(notificacao.mensagem),
                      trailing: Text(notificacao.status),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _generate(BuildContext context) async {
    // Pede para o AppState gerar avisos dos proximos vencimentos.
    // O AppState salva os avisos na tabela notificacoes_aluguel.
    final count = await context.read<AppState>().gerarAvisosVencimento();

    if (!context.mounted) {
      return;
    }

    final mensagem = count == 0
        ? 'Nenhum contrato ativo para gerar aviso.'
        : '$count aviso(s) gerado(s).';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }
}

// Cartao de um pagamento ja registrado.
class _CartaoPagamento extends StatelessWidget {
  const _CartaoPagamento({
    required this.pagamento,
    required this.contrato,
    required this.onDelete,
  });

  // Pagamento mostrado neste card.
  final PagamentoAluguel pagamento;

  // Contrato relacionado. Pode ser null se o contrato foi removido.
  final ContratoAluguel? contrato;

  // Acao chamada quando o usuario toca em excluir.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.receipt_long_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contrato?.inquilinoNome ?? 'Contrato removido',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pagamento.formaPagamento.rotulo} - venc. ${FormatadoresApp.data(pagamento.dataVencimento)}',
                      ),
                      Text(
                        '${FormatadoresApp.moeda(pagamento.valorPago)} em ${FormatadoresApp.data(pagamento.dataPagamento)}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            IconButton.filledTonal(
              tooltip: 'Excluir pagamento',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

// Linha usada dentro do relatorio rapido.
class _LinhaRelatorio extends StatelessWidget {
  const _LinhaRelatorio({required this.rotulo, required this.valor});

  // Nome do indicador.
  final String rotulo;

  // Valor ja formatado para exibir.
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(rotulo),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
