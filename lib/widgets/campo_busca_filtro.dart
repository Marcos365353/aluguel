import 'package:flutter/material.dart';

// Campo de busca reutilizado nas listas do sistema.
class CampoBuscaFiltro extends StatelessWidget {
  const CampoBuscaFiltro({
    super.key,
    required this.controlador,
    required this.textoDica,
    this.aoMudar,
  });

  // Controla o texto digitado no campo de busca.
  final TextEditingController controlador;

  // Texto mostrado dentro do campo, como "Filtrar inquilinos".
  final String textoDica;

  // Funcao chamada quando o usuario digita ou limpa a busca.
  final ValueChanged<String>? aoMudar;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controlador,
      onChanged: aoMudar,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        labelText: textoDica,
        prefixIcon: const Icon(Icons.search),
        // O botao de limpar aparece somente quando existe texto digitado.
        suffixIcon: controlador.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  // Limpa o texto e avisa a tela para atualizar o filtro.
                  controlador.clear();
                  aoMudar?.call('');
                },
                icon: const Icon(Icons.close),
                tooltip: 'Limpar filtro',
              ),
      ),
    );
  }
}
