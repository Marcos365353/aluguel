// Modelo interno de aviso de vencimento.
// Cada aviso fica ligado a um contrato.
class NotificacaoAluguel {
  const NotificacaoAluguel({
    required this.id,
    required this.contratoId,
    required this.inquilinoNome,
    required this.mensagem,
    required this.enviadoEm,
    required this.status,
  });

  final String id;
  final String contratoId;
  final String inquilinoNome;
  final String mensagem;
  final DateTime enviadoEm;
  final String status;
}
