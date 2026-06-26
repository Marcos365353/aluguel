import 'package:supabase_flutter/supabase_flutter.dart';

// Classe auxiliar para conectar no Supabase usando dart-define.
// Hoje o main.dart ja inicializa direto, mas esta classe fica como alternativa.
class ConexaoSupabase {
  ConexaoSupabase._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String chavePublicavel = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  // Verifica se a URL e a chave foram informadas.
  static bool get temCredenciais =>
      url.isNotEmpty && chavePublicavel.isNotEmpty;

  // Atalho para acessar o cliente Supabase depois da inicializacao.
  static SupabaseClient get cliente => Supabase.instance.client;

  // Inicializa o Supabase apenas se tiver credenciais.
  static Future<bool> inicializar() async {
    if (!temCredenciais) {
      return false;
    }

    await Supabase.initialize(url: url, publishableKey: chavePublicavel);

    return true;
  }
}
