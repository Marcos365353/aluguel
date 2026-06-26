import 'package:flutter/material.dart';

// Cartao pequeno usado no dashboard para mostrar um numero importante.
class CartaoResumo extends StatelessWidget {
  const CartaoResumo({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icon,
  });

  // Texto pequeno que identifica o indicador, por exemplo "Imoveis".
  final String titulo;

  // Valor principal mostrado em destaque, por exemplo "3" ou "R$ 1.500,00".
  final String valor;

  // Icone usado para representar visualmente o indicador.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    // Mantem todos os cards com a mesma largura no dashboard.
    return SizedBox(
      width: 170,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          // Organiza icone, titulo e valor um abaixo do outro.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const SizedBox(height: 12),
              Text(titulo, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(valor, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
