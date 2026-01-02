import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.turquoise,
    colorScheme: ColorScheme.light(
      primary: AppColors.turquoise,
      secondary: AppColors.info,
      surface: AppColors.surface,
      error: AppColors.coral,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onPrimary,
      onSurface: AppColors.textDark,
      onError: AppColors.onPrimary,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cardWhite,
      elevation: 0.5,
      iconTheme: IconThemeData(color: AppColors.navy),
      titleTextStyle: TextStyle(
        color: AppColors.navy,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardColor: AppColors.cardWhite,
    cardTheme: CardThemeData(
      color: AppColors.cardWhite,
      elevation: 1,
      shadowColor: AppColors.turquoise.withValues(alpha: 0.06),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColors.turquoise,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.disabled.withValues(alpha: 0.6),
        disabledForegroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        side: const BorderSide(color: AppColors.info),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        foregroundColor: AppColors.info,
        disabledForegroundColor: AppColors.disabled,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.textGray.withValues(alpha: 0.28)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.textGray.withValues(alpha: 0.28)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.turquoise, width: 1.4),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.info.withValues(alpha: 0.12),
      selectedColor: AppColors.turquoise.withValues(alpha: 0.14),
      labelStyle: const TextStyle(
        color: AppColors.navy,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    dividerTheme: const DividerThemeData(space: 24, thickness: 0.8),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
      ),
      bodyLarge: TextStyle(fontSize: 14, color: AppColors.navy),
      bodyMedium: TextStyle(fontSize: 13, color: AppColors.textGray),
    ),
  );
}
