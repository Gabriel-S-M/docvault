import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Indigo palette
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo700 = Color(0xFF4338CA);
  static const Color indigo800 = Color(0xFF3730A3);
  static const Color indigo950 = Color(0xFF1E1B4B);

  // Stone Grayscale palette (Light Mode)
  static const Color stone50 = Color(0xFFFAFAF9);
  static const Color stone100 = Color(0xFFF5F5F4);
  static const Color stone200 = Color(0xFFE7E5E4);
  static const Color stone300 = Color(0xFFD6D3D1);
  static const Color stone400 = Color(0xFFA8A29E);
  static const Color stone500 = Color(0xFF78716C);
  static const Color stone600 = Color(0xFF57534E);
  static const Color stone700 = Color(0xFF44403C);
  static const Color stone800 = Color(0xFF292524);
  static const Color stone900 = Color(0xFF1C1917);
  static const Color stone950 = Color(0xFF0C0A09);
}

class AppTheme {
  static ThemeData lightTheme() {
    final baseTextTheme = Typography.material2021().black;
    final textTheme = GoogleFonts.interTextTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.stone50,
      colorScheme: ColorScheme.light(
        primary: AppColors.indigo700,
        secondary: AppColors.indigo600,
        surface: Colors.white,
        onSurface: AppColors.stone900,
        outline: AppColors.stone200,
      ),
      textTheme: textTheme.copyWith(
        titleLarge: textTheme.titleLarge?.copyWith(
          color: AppColors.stone900,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          color: AppColors.stone900,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: AppColors.stone800,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          color: AppColors.stone500,
        ),
        labelSmall: GoogleFonts.jetBrainsMono(
          color: AppColors.stone400,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.stone50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.stone400, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.stone200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.stone200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.indigo600, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.stone200,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData darkTheme() {
    final baseTextTheme = Typography.material2021().white;
    final textTheme = GoogleFonts.interTextTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.stone950,
      colorScheme: ColorScheme.dark(
        primary: AppColors.indigo500,
        secondary: AppColors.indigo400,
        surface: AppColors.stone900,
        onSurface: AppColors.stone100,
        outline: AppColors.stone700,
      ),
      textTheme: textTheme.copyWith(
        titleLarge: textTheme.titleLarge?.copyWith(
          color: AppColors.stone100,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          color: AppColors.stone100,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: AppColors.stone200,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          color: AppColors.stone400,
        ),
        labelSmall: GoogleFonts.jetBrainsMono(
          color: AppColors.stone400,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.stone800,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.stone500, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.stone700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.stone700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.indigo500, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.stone700,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
