import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/formatadores.dart';
import '../core/utils/texto_busca.dart';
import '../data/models/contrato_aluguel.dart';
import '../data/models/imovel.dart';
import '../data/models/inquilino.dart';
import '../data/models/status_contrato.dart';
import '../mvvm/viewmodels/app_state.dart';
import '../widgets/campo_busca_filtro.dart';

// Tela de contratos.
// Aqui o usuario liga um imovel a um inquilino e define periodo, valor e vencimento.
class ContratosTela extends StatefulWidget {
  const ContratosTela({super.key});

  @override
  State<ContratosTela> createState() => _ContratosTelaState();
}

class _ContratosTelaState extends State<ContratosTela> {
  // Texto usado para filtrar contratos na lista.
  // Quando o texto muda, a lista e recalculada no build.
  final _controladorBusca = TextEditingController();

  @override
  void dispose() {
    _controladorBusca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Consumer atualiza a tela quando contratos, imoveis ou inquilinos mudam.
    return Consumer<AppState>(
      builder: (context, estado, _) {
        // So pode criar contrato se ja existir pelo menos um imovel e um inquilino.
        final canCreate =
            estado.imoveis.isNotEmpty && estado.inquilinos.isNotEmpty;
        // Filtro por endereco, inquilino, status, valor, datas e dia de vencimento.
        final contratosFiltrados = estado.contratos.where((contrato) {
          return TextoBusca.contem(_controladorBusca.text, [
            contrato.imovelEndereco,
            contrato.inquilinoNome,
            contrato.status.rotulo,
            contrato.observacoes,
            FormatadoresApp.moeda(contrato.valorMensal),
            contrato.valorMensal.toStringAsFixed(2),
            FormatadoresApp.data(contrato.dataInicio),
            FormatadoresApp.data(contrato.dataFim),
            contrato.diaVencimento.toString(),
          ]);
        }).toList();

        return Scaffold(
          body: estado.contratos.isEmpty
              // Estado vazio geral: mostra mensagem diferente se faltam dados base.
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      canCreate
                          ? 'Nenhum contrato cadastrado.'
                          : 'Cadastre ao menos um imóvel e um inquilino para gerar contratos.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    CampoBuscaFiltro(
                      controlador: _controladorBusca,
                      textoDica: 'Filtrar contratos',
                      // Aplica o filtro assim que o usuario digita.
                      aoMudar: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    if (contratosFiltrados.isEmpty)
                      // Estado vazio do filtro: existem contratos, mas nenhum bate com a busca.
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Nenhum contrato encontrado.'),
                        ),
                      )
                    else
                      for (
                        var indice = 0;
                        indice < contratosFiltrados.length;
                        indice++
                      ) ...[
                        if (indice > 0) const SizedBox(height: 10),
                        _CartaoContrato(
                          contrato: contratosFiltrados[indice],
                          onEdit: () => _abrirFormulario(
                            context,
                            contrato: contratosFiltrados[indice],
                          ),
                        ),
                      ],
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            // Desabilita o botao enquanto nao houver imovel e inquilino cadastrados.
            onPressed: canCreate ? () => _abrirFormulario(context) : null,
            icon: const Icon(Icons.note_add_outlined),
            label: const Text('Gerar contrato'),
          ),
        );
      },
    );
  }

  Future<void> _abrirFormulario(
    BuildContext context, {
    ContratoAluguel? contrato,
  }) async {
    // Pega o estado atual para montar o formulario com imoveis e inquilinos.
    // O dialog precisa dessas listas para preencher os dropdowns.
    final estado = context.read<AppState>();
    final resultado = await showDialog<_DadosFormularioContrato>(
      context: context,
      builder: (_) => _DialogoFormularioContrato(
        imoveis: estado.imoveis,
        inquilinos: estado.inquilinos,
        contrato: contrato,
      ),
    );

    if (resultado == null || !context.mounted) {
      // Resultado nulo significa que o usuario cancelou o formulario.
      return;
    }

    try {
      // Envia os dados para o AppState salvar no Supabase.
      await context.read<AppState>().salvarContrato(
        id: contrato?.id,
        imovel: resultado.imovel,
        locador: estado.locadorPrincipal,
        inquilino: resultado.inquilino,
        dataInicio: resultado.dataInicio,
        dataFim: resultado.dataFim,
        diaVencimento: resultado.diaVencimento,
        valorMensal: resultado.valorMensal,
        status: resultado.status,
        observacoes: resultado.observacoes,
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar o contrato.')),
      );
      return;
    }

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          contrato == null
              ? 'Contrato gerado com sucesso.'
              : 'Contrato atualizado com sucesso.',
        ),
      ),
    );
  }
}

// Cartao expansivel que mostra detalhes de um contrato.
class _CartaoContrato extends StatelessWidget {
  const _CartaoContrato({required this.contrato, required this.onEdit});

  // Contrato que sera mostrado neste card expansivel.
  final ContratoAluguel contrato;

  // Acao chamada quando o usuario toca em editar.
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Card(
      child: ExpansionTile(
        // O card comeca fechado para a lista ficar mais compacta.
        leading: const Icon(Icons.description_outlined),
        title: Text(
          contrato.imovelEndereco,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${contrato.inquilinoNome} - ${contrato.status.rotulo}\n'
          '${FormatadoresApp.moeda(contrato.valorMensal)}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          // Detalhes que aparecem somente quando o usuario expande o contrato.
          const Divider(),
          _LinhaInformacao(rotulo: 'Inquilino', valor: contrato.inquilinoNome),
          _LinhaInformacao(
            rotulo: 'Período',
            valor:
                '${FormatadoresApp.data(contrato.dataInicio)} a ${FormatadoresApp.data(contrato.dataFim)}',
          ),
          _LinhaInformacao(
            rotulo: 'Vencimento',
            valor: 'Dia ${contrato.diaVencimento}',
          ),
          if (contrato.observacoes.isNotEmpty)
            _LinhaInformacao(rotulo: 'Condições', valor: contrato.observacoes),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: cores.error),
                onPressed: () => _confirmarExclusao(context),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Excluir'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarExclusao(BuildContext context) async {
    // Confirma antes de apagar o contrato.
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir contrato'),
        content: const Text('Deseja excluir este contrato e seus registros?'),
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
      // Exclui o contrato e depois a tela atualiza pelo AppState.
      await context.read<AppState>().excluirContrato(contrato.id);
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir o contrato.')),
      );
      return;
    }

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contrato excluído com sucesso.')),
    );
  }
}

// Linha simples usada para mostrar rotulo e valor dentro do contrato.
class _LinhaInformacao extends StatelessWidget {
  const _LinhaInformacao({required this.rotulo, required this.valor});

  // Texto fixo da esquerda, por exemplo "Inquilino" ou "Vencimento".
  final String rotulo;

  // Valor mostrado na direita.
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              rotulo,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}

// Dados que voltam do formulario de contrato.
class _DadosFormularioContrato {
  const _DadosFormularioContrato({
    required this.imovel,
    required this.inquilino,
    required this.dataInicio,
    required this.dataFim,
    required this.diaVencimento,
    required this.valorMensal,
    required this.status,
    required this.observacoes,
  });

  // Imovel escolhido no dropdown.
  final Imovel imovel;

  // Inquilino escolhido no dropdown.
  final Inquilino inquilino;

  // Data inicial do contrato.
  final DateTime dataInicio;

  // Data final do contrato.
  final DateTime dataFim;

  // Dia mensal de vencimento do aluguel.
  final int diaVencimento;

  // Valor mensal combinado no contrato.
  final double valorMensal;

  // Status escolhido no formulario.
  final StatusContrato status;

  // Observacoes/condicoes digitadas pelo usuario.
  final String observacoes;
}

// Formulario usado para criar ou editar contrato.
class _DialogoFormularioContrato extends StatefulWidget {
  const _DialogoFormularioContrato({
    required this.imoveis,
    required this.inquilinos,
    this.contrato,
  });

  // Listas usadas para preencher os campos de selecao.
  final List<Imovel> imoveis;
  final List<Inquilino> inquilinos;

  // Quando vier preenchido, o dialog abre em modo edicao.
  final ContratoAluguel? contrato;

  @override
  State<_DialogoFormularioContrato> createState() =>
      _EstadoDialogoFormularioContrato();
}

class _EstadoDialogoFormularioContrato
    extends State<_DialogoFormularioContrato> {
  // Ids selecionados nos dropdowns.
  late String _propertyId;
  late String _tenantId;

  // Status selecionado no formulario.
  late StatusContrato _status;

  // Controladores dos campos de texto do formulario.
  late final TextEditingController _controladorInicio;
  late final TextEditingController _controladorFim;
  late final TextEditingController _controladorDiaVencimento;
  late final TextEditingController _controladorAluguel;
  late final TextEditingController _controladorObservacoes;

  @override
  void initState() {
    super.initState();
    // Se for edicao, usa os dados do contrato; se nao, usa valores padrao.
    final contrato = widget.contrato;
    final initialProperty = _findProperty(contrato?.imovelId);

    _propertyId = initialProperty.id;
    _tenantId = _findInquilino(contrato?.inquilinoId).id;
    _status = contrato?.status ?? StatusContrato.ativo;
    _controladorInicio = TextEditingController(
      text: FormatadoresApp.data(contrato?.dataInicio ?? DateTime.now()),
    );
    _controladorFim = TextEditingController(
      text: FormatadoresApp.data(
        contrato?.dataFim ??
            DateTime(DateTime.now().year + 1, DateTime.now().month, 1),
      ),
    );
    _controladorDiaVencimento = TextEditingController(
      text: (contrato?.diaVencimento ?? 10).toString(),
    );
    _controladorAluguel = TextEditingController(
      text: FormatadoresApp.decimalParaCampo(
        contrato?.valorMensal ?? initialProperty.valorAluguel,
      ),
    );
    _controladorObservacoes = TextEditingController(
      text: contrato?.observacoes ?? '',
    );
  }

  @override
  void dispose() {
    _controladorInicio.dispose();
    _controladorFim.dispose();
    _controladorDiaVencimento.dispose();
    _controladorAluguel.dispose();
    _controladorObservacoes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.contrato == null ? 'Gerar contrato' : 'Editar contrato',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _propertyId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Imóvel'),
              items: widget.imoveis
                  .map(
                    (imovel) => DropdownMenuItem(
                      value: imovel.id,
                      child: Text(
                        imovel.endereco,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (valor) {
                if (valor == null) {
                  return;
                }
                final imovel = _findProperty(valor);
                setState(() {
                  _propertyId = valor;
                  // Ao trocar o imovel, usa o valor de aluguel cadastrado nele.
                  _controladorAluguel.text = FormatadoresApp.decimalParaCampo(
                    imovel.valorAluguel,
                  );
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _tenantId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Inquilino'),
              items: widget.inquilinos
                  .map(
                    (inquilino) => DropdownMenuItem(
                      value: inquilino.id,
                      child: Text(
                        inquilino.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (valor) {
                if (valor != null) {
                  setState(() => _tenantId = valor);
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controladorInicio,
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(
                      labelText: 'Início',
                      hintText: 'dd/mm/aaaa',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controladorFim,
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(
                      labelText: 'Fim',
                      hintText: 'dd/mm/aaaa',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controladorDiaVencimento,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Dia venc.'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controladorAluguel,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Valor'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<StatusContrato>(
              initialValue: _status,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Status'),
              items: StatusContrato.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(
                        status.rotulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (valor) {
                if (valor != null) {
                  setState(() => _status = valor);
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controladorObservacoes,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Condições'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _enviar, child: const Text('Salvar')),
      ],
    );
  }

  Imovel _findProperty(String? id) {
    // Busca o imovel escolhido no dropdown.
    // Se nao achar, usa o primeiro para evitar formulario sem selecao.
    return widget.imoveis.firstWhere(
      (imovel) => imovel.id == id,
      orElse: () => widget.imoveis.first,
    );
  }

  Inquilino _findInquilino(String? id) {
    // Busca o inquilino escolhido no dropdown.
    // Se nao achar, usa o primeiro para evitar formulario sem selecao.
    return widget.inquilinos.firstWhere(
      (inquilino) => inquilino.id == id,
      orElse: () => widget.inquilinos.first,
    );
  }

  void _enviar() {
    // Converte texto em data, numero e valor antes de salvar.
    final dataInicio = FormatadoresApp.lerData(_controladorInicio.text);
    final dataFim = FormatadoresApp.lerData(_controladorFim.text);
    final diaVencimento = int.tryParse(_controladorDiaVencimento.text.trim());
    final valorMensal = FormatadoresApp.lerDecimal(_controladorAluguel.text);

    if (dataInicio == null ||
        dataFim == null ||
        diaVencimento == null ||
        diaVencimento < 1 ||
        diaVencimento > 31 ||
        valorMensal == null ||
        valorMensal <= 0 ||
        dataFim.isBefore(dataInicio)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revise datas, vencimento e valor.')),
      );
      return;
    }

    // Fecha o dialog devolvendo os dados validados para _abrirFormulario.
    Navigator.pop(
      context,
      _DadosFormularioContrato(
        imovel: _findProperty(_propertyId),
        inquilino: _findInquilino(_tenantId),
        dataInicio: dataInicio,
        dataFim: dataFim,
        diaVencimento: diaVencimento,
        valorMensal: valorMensal,
        status: _status,
        observacoes: _controladorObservacoes.text.trim(),
      ),
    );
  }
}
