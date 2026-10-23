import 'package:flutter/material.dart';

/// GM Cebi's own look: ink background, brass accent, teal secondary.
/// Large touch targets everywhere (minimum 56 dp) for one-handed use at the table.
class AppColors {
  static const ink = Color(0xFF121318);
  static const inkSurface = Color(0xFF1A1C22);
  static const inkRaised = Color(0xFF23262E);
  static const inkHigh = Color(0xFF2C3039);
  static const brass = Color(0xFFE3A857);
  static const brassDeep = Color(0xFF9A6A1F);
  static const teal = Color(0xFF5BB5A8);
  static const tealDeep = Color(0xFF2E7D73);
  static const ember = Color(0xFFF2706B);
  static const parchment = Color(0xFFF7F4EE);
  static const text = Color(0xFFECE7DF);
}

const minTouch = 56.0;

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = dark
      ? const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.brass,
          onPrimary: Color(0xFF241A08),
          primaryContainer: Color(0xFF4A3614),
          onPrimaryContainer: Color(0xFFFFDDAF),
          secondary: AppColors.teal,
          onSecondary: Color(0xFF00201C),
          secondaryContainer: Color(0xFF1E4A44),
          onSecondaryContainer: Color(0xFFB7EFE6),
          tertiary: Color(0xFFB9A3E8),
          onTertiary: Color(0xFF241544),
          error: AppColors.ember,
          onError: Color(0xFF3B0907),
          surface: AppColors.inkSurface,
          onSurface: AppColors.text,
          onSurfaceVariant: Color(0xFFBDB6AB),
          surfaceContainerLowest: AppColors.ink,
          surfaceContainerLow: Color(0xFF16181D),
          surfaceContainer: AppColors.inkRaised,
          surfaceContainerHigh: AppColors.inkHigh,
          surfaceContainerHighest: Color(0xFF353A44),
          outline: Color(0xFF4A4F5A),
          outlineVariant: Color(0xFF353A44),
        )
      : const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.brassDeep,
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFFFDDAF),
          onPrimaryContainer: Color(0xFF2B1A00),
          secondary: AppColors.tealDeep,
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFB7EFE6),
          onSecondaryContainer: Color(0xFF00201C),
          tertiary: Color(0xFF5E4A8E),
          onTertiary: Colors.white,
          error: Color(0xFFB3261E),
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Color(0xFF1D1B18),
          onSurfaceVariant: Color(0xFF55504A),
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: AppColors.parchment,
          surfaceContainer: Color(0xFFF0ECE4),
          surfaceContainerHigh: Color(0xFFE9E4DA),
          surfaceContainerHighest: Color(0xFFE1DBCF),
          outline: Color(0xFF8A847A),
          outlineVariant: Color(0xFFD3CDC2),
        );

  final base = ThemeData(colorScheme: scheme, useMaterial3: true, brightness: brightness);
  final text = base.textTheme.apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface).copyWith(
        bodyLarge: base.textTheme.bodyLarge?.copyWith(fontSize: 17, height: 1.45),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.45),
      );
  const big = Size(minTouch, minTouch);
  return base.copyWith(
    scaffoldBackgroundColor: dark ? AppColors.ink : AppColors.parchment,
    textTheme: text,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? AppColors.ink : AppColors.parchment,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: scheme.surfaceContainerLow,
      indicatorColor: scheme.primaryContainer,
      labelTextStyle: WidgetStatePropertyAll(text.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
    ),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: big, textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(minimumSize: big, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(minimumSize: big)),
    iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(minimumSize: big)),
    listTileTheme: const ListTileThemeData(minVerticalPadding: 12, contentPadding: EdgeInsets.symmetric(horizontal: 16)),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainer,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    chipTheme: base.chipTheme.copyWith(labelStyle: text.labelLarge, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHigh,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      extendedTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
  );
}
