import 'package:test/test.dart';

import 'package:aluguel_app/data/models/contrato_aluguel.dart';
import 'package:aluguel_app/data/models/metricas_aluguel.dart';
import 'package:aluguel_app/data/models/imovel.dart';
import 'package:aluguel_app/data/models/pagamento_aluguel.dart';
import 'package:aluguel_app/data/models/status_contrato.dart';
import 'package:aluguel_app/data/models/forma_pagamento.dart';
import 'package:aluguel_app/data/models/status_pagamento.dart';
import 'package:aluguel_app/data/models/status_imovel.dart';

void main() {
  test('MetricasAluguel calcula contratos, recebimentos e pendencias', () {
    final agora = DateTime(2026, 5, 14);

    final imoveis = [
      const Imovel(
        id: 'p1',
        endereco: 'Rua A',
        tipo: 'Casa',
        valorAluguel: 1000,
        status: StatusImovel.alugado,
      ),
      const Imovel(
        id: 'p2',
        endereco: 'Rua B',
        tipo: 'Apartamento',
        valorAluguel: 900,
        status: StatusImovel.disponivel,
      ),
    ];

    final contratos = [
      ContratoAluguel(
        id: 'c1',
        imovelId: 'p1',
        imovelEndereco: 'Rua A',
        locadorId: 'l1',
        locadorNome: 'Proprietario',
        inquilinoId: 't1',
        inquilinoNome: 'Inquilino',
        dataInicio: DateTime(2026, 1, 1),
        dataFim: DateTime(2027, 1, 1),
        diaVencimento: 10,
        valorMensal: 1000,
        status: StatusContrato.ativo,
        observacoes: '',
      ),
    ];

    final pagamentos = [
      PagamentoAluguel(
        id: 'pay1',
        contratoId: 'c1',
        dataVencimento: DateTime(2026, 4, 10),
        dataPagamento: DateTime(2026, 5, 2),
        valorPago: 1000,
        formaPagamento: FormaPagamento.pix,
        status: StatusPagamento.pago,
      ),
    ];

    final metricas = MetricasAluguel.dosDados(
      imoveis: imoveis,
      contratos: contratos,
      pagamentos: pagamentos,
      agora: agora,
    );

    expect(metricas.totalImoveis, 2);
    expect(metricas.imoveisAlugados, 1);
    expect(metricas.contratosAtivos, 1);
    expect(metricas.receitaMes, 1000);
    expect(metricas.pendenciasMes, 1);
    expect(metricas.contratosVencidos, 1);
  });

  test('ContratoAluguel mantem vencimento atrasado como proxima pendencia', () {
    final contrato = ContratoAluguel(
      id: 'c1',
      imovelId: 'p1',
      imovelEndereco: 'Rua A',
      locadorId: 'l1',
      locadorNome: 'Proprietario',
      inquilinoId: 't1',
      inquilinoNome: 'Inquilino',
      dataInicio: DateTime(2026, 1, 1),
      dataFim: DateTime(2027, 1, 1),
      diaVencimento: 10,
      valorMensal: 1000,
      status: StatusContrato.ativo,
      observacoes: '',
    );

    final vencimento = contrato.proximoVencimento(
      const [],
      agora: DateTime(2026, 6, 25),
    );

    expect(vencimento, DateTime(2026, 6, 10));
  });

  test(
    'ContratoAluguel avanca para o mes seguinte quando parcela foi paga',
    () {
      final contrato = ContratoAluguel(
        id: 'c1',
        imovelId: 'p1',
        imovelEndereco: 'Rua A',
        locadorId: 'l1',
        locadorNome: 'Proprietario',
        inquilinoId: 't1',
        inquilinoNome: 'Inquilino',
        dataInicio: DateTime(2026, 1, 1),
        dataFim: DateTime(2027, 1, 1),
        diaVencimento: 10,
        valorMensal: 1000,
        status: StatusContrato.ativo,
        observacoes: '',
      );

      final vencimento = contrato.proximoVencimento([
        PagamentoAluguel(
          id: 'pay1',
          contratoId: 'c1',
          dataVencimento: DateTime(2026, 6, 10),
          dataPagamento: DateTime(2026, 6, 10),
          valorPago: 1000,
          formaPagamento: FormaPagamento.pix,
          status: StatusPagamento.pago,
        ),
      ], agora: DateTime(2026, 6, 25));

      expect(vencimento, DateTime(2026, 7, 10));
    },
  );
}
