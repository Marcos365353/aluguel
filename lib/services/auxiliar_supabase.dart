import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/conexao_supabase.dart';

// Helper para centralizar a conexao com o Supabase.
class AuxiliarSupabase {
  AuxiliarSupabase._iniciar();

  // Instancia unica do helper.
  static final AuxiliarSupabase instancia = AuxiliarSupabase._iniciar();

  // Informa se existem credenciais configuradas.
  bool get estaConfigurado => ConexaoSupabase.temCredenciais;

  // Cliente usado para fazer consultas no Supabase.
  SupabaseClient get cliente => ConexaoSupabase.cliente;

  // Inicializa a conexao com o Supabase.
  Future<bool> inicializar() => ConexaoSupabase.inicializar();
}
