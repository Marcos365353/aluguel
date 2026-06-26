// Modelo da tabela public.locadores no Supabase.
// Representa o dono/proprietario dos imoveis.
class Locador {
  const Locador({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.email,
    this.criadoEm,
    this.atualizadoEm,
  });

  static const nomeTabela = 'locadores';

  final String id;
  final String nome;
  final String cpf;
  final String telefone;
  final String email;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  factory Locador.deMapa(Map<String, dynamic> map) {
    return Locador(
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
