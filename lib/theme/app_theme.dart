import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================
  // COLORS — violet/purple cinema palette
  // ============================================================

  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF9D7BFF);

  static const Color accentYellow = Color(0xFFFFC94A); // IMDb-style badge

  // Light (kept for completeness — the reference design is dark-only)
  static const Color lightBackground = Color(0xFFF5F3FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0xFFEFECFA);

  // Dark — deep violet-black, not neutral gray
  static const Color darkBackground = Color(0xFF100E1B);
  static const Color darkSurface = Color(0xFF1A1729);
  static const Color darkSurface2 = Color(0xFF211D34);

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,

      primaryContainer: Color(0xFFE4D9FF),
      onPrimaryContainer: Color(0xFF2C1065),

      secondary: primaryLight,
      onSecondary: Colors.white,

      secondaryContainer: Color(0xFFEDE4FF),
      onSecondaryContainer: Color(0xFF2C1065),

      surface: lightSurface,
      onSurface: Color(0xFF1A1729),

      surfaceContainerLowest: Color(0xFFF5F3FB),
      surfaceContainerLow: Color(0xFFF0EDF9),
      surfaceContainer: Color(0xFFEAE6F5),
      surfaceContainerHigh: Color(0xFFE3DEF1),
      surfaceContainerHighest: Color(0xFFDCD5EC),

      onSurfaceVariant: Color(0xFF6E6A80),

      outline: Color(0xFFC4BEDA),
      outlineVariant: Color(0xFFE0DBF0),

      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF1A1729),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w900,
        color: Color(0xFF1A1729),
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: lightSurface,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: Color(0xFFE0DBF0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF8E89A0),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary, width: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: const Color(0xFF1A1729),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0DBF0),
      thickness: 1,
      space: 1,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 0,
      height: 72,
      indicatorColor: primary.withValues(alpha: 0.12),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 10,
          fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
          color: selected ? primary : const Color(0xFF7C7791),
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? primary : const Color(0xFF7C7791),
          size: selected ? 23 : 21,
        );
      }),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFEAE6F5),
      selectedColor: primary,
      disabledColor: const Color(0xFFE3DEF1),
      labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
      secondaryLabelStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
      side: const BorderSide(color: Color(0xFFE0DBF0)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1A1729),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primary,
      strokeWidth: 3,
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  // ============================================================
  // DARK THEME — matches the reference design
  // ============================================================

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      onPrimary: Colors.white,

      primaryContainer: Color(0xFF4C2E99),
      onPrimaryContainer: Color(0xFFE4D9FF),

      secondary: Color(0xFFC4A6FF),
      onSecondary: Color(0xFF2C1065),

      secondaryContainer: Color(0xFF3B2270),
      onSecondaryContainer: Color(0xFFE4D9FF),

      surface: darkSurface,
      onSurface: Color(0xFFF1EEFA),

      surfaceContainerLowest: Color(0xFF100E1B),
      surfaceContainerLow: Color(0xFF161326),
      surfaceContainer: Color(0xFF1D192E),
      surfaceContainerHigh: Color(0xFF241F38),
      surfaceContainerHighest: Color(0xFF2C2642),

      onSurfaceVariant: Color(0xFFB4AEC9),

      outline: Color(0xFF615A7A),
      outlineVariant: Color(0xFF383152),

      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFFF1EEFA),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w900,
        color: Color(0xFFF1EEFA),
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: darkSurface,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF201C33),
      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: Color(0xFF383152)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: primaryDark, width: 1.5),
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF8E88A6),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryDark,
        side: const BorderSide(color: primaryDark, width: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryDark,
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: const Color(0xFFF1EEFA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFF383152),
      thickness: 1,
      space: 1,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF171429),
      elevation: 0,
      height: 72,
      indicatorColor: primaryDark.withValues(alpha: 0.18),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 10,
          fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
          color: selected ? primaryDark : const Color(0xFF938DA9),
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? primaryDark : const Color(0xFF938DA9),
          size: selected ? 23 : 21,
        );
      }),
    ),

    chipTheme: const ChipThemeData(
      backgroundColor: Color(0xFF241F38),
      selectedColor: primaryDark,
      labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
      secondaryLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
      side: BorderSide(color: Color(0xFF383152)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(13)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFFEDE9F7),
      contentTextStyle: const TextStyle(
        color: Color(0xFF1A1729),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryDark,
      strokeWidth: 3,
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}