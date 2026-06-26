// Modelo da tabela public.inquilinos no Supabase.
// Representa a pessoa que aluga o imovel.
class Inquilino {
  const Inquilino({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.email,
    this.criadoEm,
    this.atualizadoEm,
  });

  static const nomeTabela = 'inquilinos';

  final String id;
  final String nome;
  final String cpf;
  final String telefone;
  final String email;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  factory Inquilino.deMapa(Map<String, dynamic> map) {
    return Inquilino(
      id: map['id'] as String,
      nome: map['nome'] as String,
      cpf: map['cpf'] as String,
      telefone: map['telefone'] as String,
      email: map['email'] as String,
      criadoEm: _lerData(map['criado_em']),
      atualizadoEm: _lerData(map['atualizado_em']),
    );
  }

  Map<String, dynamic> paraMapa() {
    return {
      'id': id,
      'nome': nome,
      'cpf': cpf,
      'telefone': telefone,
      'email': email,
    };
  }

  static DateTime? _lerData(Object? valor) {
    return valor == null ? null : DateTime.parse(valor as String);
  }
}
