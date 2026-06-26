import 'dart:math';

import 'package:intl/intl.dart';

// Classe com funcoes de formatacao usadas em varias telas.
class FormatadoresApp {
  const FormatadoresApp._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final DateFormat _date = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm');

  // Formata valor em real.
  static String moeda(double valor) => _currency.format(valor);

  // Formata datas para dd/mm/aaaa.
  static String data(DateTime valor) => _date.format(valor);
  static String dataHora(DateTime valor) => _dateTime.format(valor);

  // Mostra numero decimal com virgula, como o usuario espera no Brasil.
  static String decimalParaCampo(double valor) {
    return valor.toStringAsFixed(2).replaceAll('.', ',');
  }

  // Converte texto digitado em numero.
  static double? lerDecimal(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }

  // Converte texto dd/mm/aaaa em DateTime.
  static DateTime? lerData(String raw) {
    try {
      return _date.parseStrict(raw.trim());
    } on FormatException {
      return null;
    }
  }

  // Gera um id simples para salvar registros no banco.
  static String gerarId(String prefix) {
    final random = Random();
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}-${random.nextInt(99999)}';
  }
}
