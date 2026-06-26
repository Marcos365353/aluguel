import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/formatadores.dart';
import '../core/utils/texto_busca.dart';
import '../data/models/imovel.dart';
import '../data/models/status_imovel.dart';
import '../mvvm/viewmodels/app_state.dart';
import '../widgets/campo_busca_filtro.dart';

// Tela de imoveis. Aqui o usuario cadastra, edita, filtra e exclui imoveis.
class ImoveisTela extends StatefulWidget {
  const ImoveisTela({super.key});

  @override
  State<ImoveisTela> createState() => _ImoveisTelaState();
}

class _ImoveisTelaState extends State<ImoveisTela> {
  // Controla o texto digitado no filtro de imoveis.
  // Quando o usuario digita, a lista e recalculada no build.
  final _controladorBusca = TextEditingController();

  @override
  void dispose() {
    _controladorBusca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Consumer pega os dados do AppState e atualiza a tela quando eles mudam.
    return Consumer<AppState>(
      builder: (context, estado, _) {
        // Filtra os imoveis pelo texto digitado no campo de busca.
        // A busca olha endereco, tipo, status e valor do aluguel.
        final imoveisFiltrados = estado.imoveis.where((imovel) {
          return TextoBusca.contem(_controladorBusca.text, [
            imovel.endereco,
            imovel.tipo,
            imovel.status.rotulo,
            FormatadoresApp.moeda(imovel.valorAluguel),
            imovel.valorAluguel.toStringAsFixed(2),
          ]);
        }).toList();

        return Scaffold(
          body: estado.imoveis.isEmpty
              // Estado vazio geral: ainda nao existe nenhum imovel cadastrado.
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Nenhum imóvel cadastrado.'),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    CampoBuscaFiltro(
                      controlador: _controladorBusca,
                      textoDica: 'Filtrar imóveis',
                      // Redesenha a tela para aplicar o filtro a cada digitacao.
                      aoMudar: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    if (imoveisFiltrados.isEmpty)
                      // Estado vazio do filtro: existem imoveis, mas nenhum bate com a busca.
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Nenhum imóvel encontrado.'),
                        ),
                      )
                    else
                      for (
                        var indice = 0;
                        indice < imoveisFiltrados.length;
                        indice++
                      ) ...[
                        if (indice > 0) const SizedBox(height: 10),
                        _CartaoImovel(
                          imovel: imoveisFiltrados[indice],
                          onEdit: () => _abrirFormulario(
                            context,
                            imovel: imoveisFiltrados[indice],
                          ),
                          onDelete: () => _confirmarExclusao(
                            context,
                            imoveisFiltrados[indice],
                          ),
                        ),
                      ],
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            // Abre o mesmo formulario usado para cadastro e edicao.
            onPressed: () => _abrirFormulario(context),
            icon: const Icon(Icons.add),
            label: const Text('Novo imóvel'),
          ),
        );
      },
    );
  }

  Future<void> _abrirFormulario(BuildContext context, {Imovel? imovel}) async {
    // Abre o formulario. Se receber um imovel, o formulario vira edicao.
    final resultado = await showDialog<_DadosFormularioImovel>(
      context: context,
      builder: (_) => _DialogoFormularioImovel(imovel: imovel),
    );

    if (resultado == null || !context.mounted) {
      // Resultado nulo significa que o usuario cancelou o formulario.
      return;
    }

    try {
      // Envia os dados do formulario para o AppState salvar no Supabase.
      await context.read<AppState>().salvarImovel(
        id: imovel?.id,
        endereco: resultado.endereco,
        tipo: resultado.tipo,
        valorAluguel: resultado.valorAluguel,
        status: resultado.status,
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar o imóvel.')),
      );
      return;
    }

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          imovel == null
              ? 'Imóvel cadastrado com sucesso.'
              : 'Imóvel atualizado com sucesso.',
        ),
      ),
    );
  }

  Future<void> _confirmarExclusao(BuildContext context, Imovel imovel) async {
    // Antes de apagar, pergunta se o usuario tem certeza.
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir imóvel'),
        content: Text('Deseja excluir ${imovel.endereco}?'),
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
      // Pede para o AppState excluir o imovel.
      await context.read<AppState>().excluirImovel(imovel.id);
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível excluir: existe contrato vinculado.'),
        ),
      );
      return;
    }

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Imóvel excluído com sucesso.')),
    );
  }
}

// Cartao que mostra um imovel na lista.
class _CartaoImovel extends StatelessWidget {
  const _CartaoImovel({
    required this.imovel,
    required this.onEdit,
    required this.onDelete,
  });

  // Imovel que sera mostrado neste card.
  final Imovel imovel;

  // Acao chamada quando o usuario toca em editar.
  final VoidCallback onEdit;

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
                  child: Icon(Icons.home_work_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        imovel.endereco,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${imovel.tipo} - ${FormatadoresApp.moeda(imovel.valorAluguel)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              // O Wrap evita estouro horizontal quando a tela e estreita.
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(label: Text(imovel.status.rotulo)),
                IconButton.filledTonal(
                  tooltip: 'Editar imóvel',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                ),
                IconButton.filledTonal(
                  tooltip: 'Excluir imóvel',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Classe simples para transportar os dados digitados no formulario.
class _DadosFormularioImovel {
  const _DadosFormularioImovel({
    required this.endereco,
    required this.tipo,
    required this.valorAluguel,
    required this.status,
  });

  // Endereco digitado pelo usuario.
  final String endereco;

  // Tipo do imovel, por exemplo casa, apartamento ou sala comercial.
  final String tipo;

  // Valor mensal do aluguel ja convertido para double.
  final double valorAluguel;

  // Status escolhido no formulario.
  final StatusImovel status;
}

// Dialog com os campos usados para criar ou editar imovel.
class _DialogoFormularioImovel extends StatefulWidget {
  const _DialogoFormularioImovel({this.imovel});

  final Imovel? imovel;

  @override
  State<_DialogoFormularioImovel> createState() =>
      _EstadoDialogoFormularioImovel();
}

class _EstadoDialogoFormularioImovel extends State<_DialogoFormularioImovel> {
  // Controladores dos campos do formulario.
  late final TextEditingController _controladorEndereco;
  late final TextEditingController _controladorTipo;
  late final TextEditingController _controladorAluguel;

  // Guarda o status selecionado no dropdown.
  late StatusImovel _status;

  @override
  void initState() {
    super.initState();
    // Se for edicao, os campos ja abrem preenchidos.
    _controladorEndereco = TextEditingController(
      text: widget.imovel?.endereco ?? '',
    );
    _controladorTipo = TextEditingController(text: widget.imovel?.tipo ?? '');
    _controladorAluguel = TextEditingController(
      text: widget.imovel == null
          ? ''
          : FormatadoresApp.decimalParaCampo(widget.imovel!.valorAluguel),
    );
    // Novo imovel comeca como disponivel; edicao usa o status salvo.
    _status = widget.imovel?.status ?? StatusImovel.disponivel;
  }

  @override
  void dispose() {
    _controladorEndereco.dispose();
    _controladorTipo.dispose();
    _controladorAluguel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.imovel == null ? 'Novo imóvel' : 'Editar imóvel'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controladorEndereco,
              decoration: const InputDecoration(labelText: 'Endereço'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controladorTipo,
              decoration: const InputDecoration(labelText: 'Tipo do imóvel'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controladorAluguel,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Valor do aluguel'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<StatusImovel>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: StatusImovel.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.rotulo),
                    ),
                  )
                  .toList(),
              onChanged: (valor) {
                if (valor != null) {
                  setState(() => _status = valor);
                }
              },
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

  void _enviar() {
    // Le e valida os campos antes de fechar o formulario.
    final endereco = _controladorEndereco.text.trim();
    final tipo = _controladorTipo.text.trim();
    final valorAluguel = FormatadoresApp.lerDecimal(_controladorAluguel.text);

    // Todos os campos sao obrigatorios e o aluguel precisa ser maior que zero.
    if (endereco.isEmpty ||
        tipo.isEmpty ||
        valorAluguel == null ||
        valorAluguel <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os dados do imóvel.')),
      );
      return;
    }

    // Fecha o dialog devolvendo os dados validados para _abrirFormulario.
    Navigator.pop(
      context,
      _DadosFormularioImovel(
        endereco: endereco,
        tipo: tipo,
        valorAluguel: valorAluguel,
        status: _status,
      ),
    );
  }
}
