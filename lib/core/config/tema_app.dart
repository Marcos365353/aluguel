import 'package:flutter/material.dart';

// Classe que guarda o tema visual do aplicativo.
// Aqui ficam as cores, estilo de cards, inputs, botoes e barra de navegacao.
class TemaApp {
  const TemaApp._();

  static const _poolBlue = Color(0xFF00B8D9);
  static const _poolBlueDark = Color(0xFF007C91);
  static const _poolBlueLight = Color(0xFFC8F6FF);
  static const _poolBlueSoft = Color(0xFFE8FBFF);

  static ThemeData get temaClaro {
    // Cria a paleta principal a partir da cor azul escolhida para o app.
    const baseScheme = ColorScheme.light();
    final cores =
        ColorScheme.fromSeed(
          seedColor: _poolBlue,
          brightness: Brightness.light,
        ).copyWith(
          primary: _poolBlueDark,
          onPrimary: Colors.white,
          primaryContainer: _poolBlueLight,
          onPrimaryContainer: const Color(0xFF00363F),
          secondary: _poolBlue,
          onSecondary: Colors.white,
          secondaryContainer: _poolBlueSoft,
          onSecondaryContainer: const Color(0xFF004E5C),
          surface: Colors.white,
          onSurface: baseScheme.onSurface,
        );

    // Retorna o tema completo que sera usado no MaterialApp.
    return ThemeData(
      colorScheme: cores,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: cores.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _poolBlueSoft,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: _poolBlueLight),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _poolBlueSoft),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _poolBlueDark, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF8EF1FF),
        foregroundColor: Color(0xFF00363F),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: _poolBlueLight,
        iconTheme: WidgetStateProperty.resolveWith((estados) {
          if (estados.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFF005E6D));
          }
          return const IconThemeData(color: Color(0xFF4A6268));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((estados) {
          final cor = estados.contains(WidgetState.selected)
              ? const Color(0xFF005E6D)
              : const Color(0xFF4A6268);
          return TextStyle(color: cor, fontWeight: FontWeight.w700);
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _poolBlueSoft,
        selectedColor: _poolBlueLight,
        labelStyle: const TextStyle(color: Color(0xFF004E5C)),
        side: BorderSide.none,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cores.inverseSurface,
        contentTextStyle: TextStyle(color: cores.onInverseSurface),
      ),
    );
  }
}
