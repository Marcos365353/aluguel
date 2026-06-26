import 'package:flutter/foundation.dart';

import '../data/models/contrato_aluguel.dart';
import '../data/models/pagamento_aluguel.dart';

// Controle simples para calcular valores financeiros.
class SaldoAluguelControle extends ChangeNotifier {
  // Soma o valor previsto dos contratos ativos.
  double calcularReceitaMensalPrevista(List<ContratoAluguel> contratos) {
    return contratos
        .where((contrato) => contrato.estaAtivo)
        .fold(0, (total, contrato) => total + contrato.valorMensal);
  }

  // Soma os pagamentos que realmente foram recebidos.
  double calcularReceitaRecebida(List<PagamentoAluguel> pagamentos) {
    return pagamentos
        .where((pagamento) => pagamento.status.estaPago)
        .fold(0, (total, pagamento) => total + pagamento.valorPago);
  }
}
