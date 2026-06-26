// Modelo interno de locador/proprietario.
// Ele representa os dados usados pelo app depois de buscar no banco.
class Locador {
  const Locador({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.email,
  });

  final String id;
  final String nome;
  final String cpf;
  final String telefone;
  final String email;
}
