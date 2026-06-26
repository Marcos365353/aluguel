// Modelo interno de inquilino.
// Guarda os dados que aparecem na tela de inquilinos e nos contratos.
class Inquilino {
  const Inquilino({
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
