// Ajuda as telas a fazerem busca ignorando maiusculas, acentos e simbolos.
class TextoBusca {
  const TextoBusca._();

  // Verifica se todos os termos buscados aparecem em algum dos valores.
  static bool contem(String busca, Iterable<String?> values) {
    final terms = normalizar(
      busca,
    ).split(RegExp(r'\s+')).where((term) => term.isNotEmpty).toList();

    if (terms.isEmpty) {
      return true;
    }

    final text = values.whereType<String>().map(normalizar).join(' ');
    return terms.every(text.contains);
  }

  // Deixa o texto simples para comparacao.
  static String normalizar(String valor) {
    return valor
        .toLowerCase()
        .replaceAll(RegExp('[áàâãä]'), 'a')
        .replaceAll(RegExp('[éèêë]'), 'e')
        .replaceAll(RegExp('[íìîï]'), 'i')
        .replaceAll(RegExp('[óòôõö]'), 'o')
        .replaceAll(RegExp('[úùûü]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }
}
