import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/utils/texto_busca.dart';
import '../data/models/inquilino.dart';
import '../mvvm/viewmodels/app_state.dart';
import '../widgets/campo_busca_filtro.dart';

// Tela de inquilinos.
// Aqui ficam a listagem, o filtro, o cadastro, a edicao e a exclusao.
class InquilinosTela extends StatefulWidget {
  const InquilinosTela({super.key});

  @override
  State<InquilinosTela> createState() => _InquilinosTelaState();
}

class _InquilinosTelaState extends State<InquilinosTela> {
  // Controla o texto digitado no filtro de inquilinos.
  // A cada digitacao a tela redesenha e recalcula a lista filtrada.
  final _controladorBusca = TextEditingController();

  @override
  void dispose() {
    _controladorBusca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Consumer escuta o AppState e atualiza a tela quando a lista muda.
    return Consumer<AppState>(
      builder: (context, estado, _) {
        // Filtra por nome, CPF, telefone e email.
        // Tambem compara CPF e telefone apenas com numeros.
        final inquilinosFiltrados = estado.inquilinos.where((inquilino) {
          return TextoBusca.contem(_controladorBusca.text, [
            inquilino.nome,
            inquilino.cpf,
            inquilino.telefone,
            inquilino.email,
            _onlyDigits(inquilino.cpf),
            _onlyDigits(inquilino.telefone),
          ]);
        }).toList();

        return Scaffold(
          body: estado.inquilinos.isEmpty
              // Estado vazio geral: ainda nao existe nenhum inquilino salvo.
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Nenhum inquilino cadastrado.'),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    CampoBuscaFiltro(
                      controlador: _controladorBusca,
                      textoDica: 'Filtrar inquilinos',
                      // Aplica o filtro assim que o usuario digita.
                      aoMudar: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    if (inquilinosFiltrados.isEmpty)
                      // Estado vazio do filtro: existem inquilinos, mas nenhum bate com a busca.
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Nenhum inquilino encontrado.'),
                        ),
                      )
                    else
                      for (
                        var indice = 0;
                        indice < inquilinosFiltrados.length;
                        indice++
                      ) ...[
                        if (indice > 0) const SizedBox(height: 10),
                        _CartaoInquilino(
                          inquilino: inquilinosFiltrados[indice],
                          onEdit: () => _abrirFormulario(
                            context,
                            inquilino: inquilinosFiltrados[indice],
                          ),
                          onDelete: () => _confirmarExclusao(
                            context,
                            inquilinosFiltrados[indice],
                          ),
                        ),
                      ],
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            // Abre o formulario em modo cadastro.
            onPressed: () => _abrirFormulario(context),
            icon: const Icon(Icons.person_add_alt),
            label: const Text('Novo inquilino'),
          ),
        );
      },
    );
  }

  Future<void> _abrirFormulario(
    BuildContext context, {
    Inquilino? inquilino,
  }) async {
    // Abre o formulario. Se receber um inquilino, o formulario vira edicao.
    final resultado = await showDialog<_DadosFormularioInquilino>(
      context: context,
      builder: (_) => _DialogoFormularioInquilino(inquilino: inquilino),
    );

    if (resultado == null || !context.mounted) {
      // Resultado nulo significa que o usuario cancelou o formulario.
      return;
    }

    try {
      // Envia os dados para o AppState salvar no Supabase.
      await context.read<AppState>().salvarInquilino(
        id: inquilino?.id,
        nome: resultado.nome,
        cpf: resultado.cpf,
        telefone: resultado.telefone,
        email: resultado.email,
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar o inquilino.')),
      );
      return;
    }

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          inquilino == null
              ? 'Inquilino cadastrado com sucesso.'
              : 'Inquilino atualizado com sucesso.',
        ),
      ),
    );
  }

  Future<void> _confirmarExclusao(
    BuildContext context,
    Inquilino inquilino,
  ) async {
    // Confirma antes de apagar para evitar exclusao sem querer.
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir inquilino'),
        content: Text('Deseja excluir ${inquilino.nome}?'),
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
      // Exclui o inquilino pelo AppState.
      await context.read<AppState>().excluirInquilino(inquilino.id);
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
      const SnackBar(content: Text('Inquilino excluído com sucesso.')),
    );
  }
}

// Cartao que mostra os dados resumidos de um inquilino.
class _CartaoInquilino extends StatelessWidget {
  const _CartaoInquilino({
    required this.inquilino,
    required this.onEdit,
    required this.onDelete,
  });

  // Inquilino que sera mostrado neste card.
  final Inquilino inquilino;

  // Acao chamada quando o usuario toca em editar.
  final VoidCallback onEdit;

  // Acao chamada quando o usuario toca em excluir.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    // Monta as informacoes de contato em linhas separadas.
    final contact = [
      inquilino.cpf,
      if (inquilino.telefone.trim().isNotEmpty) inquilino.telefone,
      if (inquilino.email.trim().isNotEmpty) inquilino.email,
    ].join('\n');

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
                  child: Icon(Icons.person_outline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inquilino.nome,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(contact),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              // O Wrap evita estouro horizontal em telas pequenas.
              spacing: 8,
              runSpacing: 8,
              children: [
                IconButton.filledTonal(
                  tooltip: 'Editar inquilino',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                ),
                IconButton.filledTonal(
                  tooltip: 'Excluir inquilino',
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

// Guarda o resultado do formulario antes de salvar.
class _DadosFormularioInquilino {
  const _DadosFormularioInquilino({
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.email,
  });

  // Nome digitado no formulario.
  final String nome;

  // CPF digitado no formulario.
  final String cpf;

  // Telefone digitado no formulario.
  final String telefone;

  // Email digitado no formulario.
  final String email;
}

// Formulario de cadastro e edicao de inquilino.
class _DialogoFormularioInquilino extends StatefulWidget {
  const _DialogoFormularioInquilino({this.inquilino});

  // Quando vier preenchido, o dialog abre em modo edicao.
  final Inquilino? inquilino;

  @override
  State<_DialogoFormularioInquilino> createState() =>
      _EstadoDialogoFormularioInquilino();
}

class _EstadoDialogoFormularioInquilino
    extends State<_DialogoFormularioInquilino> {
  // Controladores dos campos do formulario.
  late final TextEditingController _controladorNome;
  late final TextEditingController _controladorCpf;
  late final TextEditingController _controladorTelefone;
  late final TextEditingController _controladorEmail;

  @override
  void initState() {
    super.initState();
    // Preenche os campos quando o usuario esta editando.
    _controladorNome = TextEditingController(
      text: widget.inquilino?.nome ?? '',
    );
    _controladorCpf = TextEditingController(
      text: _formatCpf(widget.inquilino?.cpf ?? ''),
    );
    _controladorTelefone = TextEditingController(
      text: _formatPhone(widget.inquilino?.telefone ?? ''),
    );
    _controladorEmail = TextEditingController(
      text: widget.inquilino?.email ?? '',
    );
  }

  @override
  void dispose() {
    _controladorNome.dispose();
    _controladorCpf.dispose();
    _controladorTelefone.dispose();
    _controladorEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.inquilino == null ? 'Novo inquilino' : 'Editar inquilino',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controladorNome,
              decoration: const InputDecoration(labelText: 'Nome do inquilino'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controladorCpf,
              keyboardType: TextInputType.number,
              inputFormatters: const [_CpfInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'CPF',
                hintText: '000.000.000-00',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controladorTelefone,
              keyboardType: TextInputType.phone,
              inputFormatters: const [_PhoneInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'Telefone',
                hintText: '(00) 00000-0000',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controladorEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
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
    // Valida nome, CPF e telefone antes de salvar.
    final nome = _controladorNome.text.trim();
    final cpf = _controladorCpf.text.trim();
    final telefone = _controladorTelefone.text.trim();
    final email = _controladorEmail.text.trim();
    // A validacao usa apenas numeros para aceitar texto com mascara.
    final cpfDigits = _onlyDigits(cpf);
    final phoneDigits = _onlyDigits(telefone);

    if (nome.isEmpty || cpfDigits.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe nome e CPF válido.')),
      );
      return;
    }

    if (telefone.isNotEmpty && phoneDigits.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um telefone válido.')),
      );
      return;
    }

    // Fecha o dialog devolvendo os dados validados para _abrirFormulario.
    Navigator.pop(
      context,
      _DadosFormularioInquilino(
        nome: nome,
        cpf: cpf,
        telefone: telefone,
        email: email,
      ),
    );
  }
}

// Remove tudo que nao e numero. Usado para validar CPF e telefone.
String _onlyDigits(String valor) => valor.replaceAll(RegExp(r'\D'), '');

// Aplica mascara de CPF ao texto que veio salvo ou digitado.
String _formatCpf(String valor) {
  final formatter = const _CpfInputFormatter();
  return formatter
      .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: valor))
      .text;
}

// Aplica mascara de telefone ao texto que veio salvo ou digitado.
String _formatPhone(String valor) {
  final formatter = const _PhoneInputFormatter();
  return formatter
      .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: valor))
      .text;
}

// Formatter que deixa o CPF no formato 000.000.000-00.
class _CpfInputFormatter extends TextInputFormatter {
  const _CpfInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = _onlyDigits(newValue.text);
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;
    final buffer = StringBuffer();

    for (var indice = 0; indice < limited.length; indice++) {
      if (indice == 3 || indice == 6) {
        buffer.write('.');
      } else if (indice == 9) {
        buffer.write('-');
      }
      buffer.write(limited[indice]);
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// Formatter que deixa o telefone no formato brasileiro.
class _PhoneInputFormatter extends TextInputFormatter {
  const _PhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = _onlyDigits(newValue.text);
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;
    final buffer = StringBuffer();

    for (var indice = 0; indice < limited.length; indice++) {
      if (indice == 0) {
        buffer.write('(');
      } else if (indice == 2) {
        buffer.write(') ');
      } else if (indice == 6 && limited.length <= 10) {
        buffer.write('-');
      } else if (indice == 7 && limited.length > 10) {
        buffer.write('-');
      }
      buffer.write(limited[indice]);
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
