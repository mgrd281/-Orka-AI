/// Orka AI — Theme Configuration
///
/// Premium dark and light themes with cinematic minimalism.
/// Dark mode is the hero experience.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';
import 'typography.dart';

class OrkaTheme {
  OrkaTheme._();

  // === Dark Theme (Primary) ===
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: OrkaColors.surfaceDark,
        colorScheme: const ColorScheme.dark(
          primary: OrkaColors.primary,
          onPrimary: Colors.white,
          secondary: OrkaColors.secondary,
          onSecondary: Colors.white,
          surface: OrkaColors.surfaceDark,
          onSurface: OrkaColors.textPrimaryDark,
          error: OrkaColors.error,
          outline: OrkaColors.borderDark,
        ),

        // App Bar
        appBarTheme: AppBarTheme(
          backgroundColor: OrkaColors.surfaceDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: OrkaTypography.headlineSmall.copyWith(
            color: OrkaColors.textPrimaryDark,
          ),
          iconTheme: const IconThemeData(color: OrkaColors.textPrimaryDark),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),

        // Cards
        cardTheme: CardTheme(
          color: OrkaColors.surfaceCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: OrkaColors.borderDark, width: 0.5),
          ),
          margin: EdgeInsets.zero,
        ),

        // Input
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: OrkaColors.surfaceCard,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: OrkaColors.borderDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: OrkaColors.borderDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: OrkaColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: OrkaColors.error),
          ),
          hintStyle: OrkaTypography.bodyMedium.copyWith(
            color: OrkaColors.textTertiaryDark,
          ),
          labelStyle: OrkaTypography.labelMedium.copyWith(
            color: OrkaColors.textSecondaryDark,
          ),
        ),

        // Elevated Button
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: OrkaColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: OrkaTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Text Button
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: OrkaColors.primary,
            textStyle: OrkaTypography.labelLarge,
          ),
        ),

        // Outlined Button
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: OrkaColors.textPrimaryDark,
            side: const BorderSide(color: OrkaColors.borderDark),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: OrkaTypography.labelLarge,
          ),
        ),

        // Bottom Nav
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: OrkaColors.surfaceDark,
          selectedItemColor: OrkaColors.primary,
          unselectedItemColor: OrkaColors.textTertiaryDark,
          elevation: 0,
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: OrkaColors.borderDark,
          thickness: 0.5,
        ),

        // Chip
        chipTheme: ChipThemeData(
          backgroundColor: OrkaColors.surfaceCard,
          selectedColor: OrkaColors.primary.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          side: const BorderSide(color: OrkaColors.borderDark),
          labelStyle: OrkaTypography.labelMedium.copyWith(
            color: OrkaColors.textPrimaryDark,
          ),
        ),

        // Text theme
        textTheme: TextTheme(
          displayLarge: OrkaTypography.displayLarge.copyWith(color: OrkaColors.textPrimaryDark),
          displayMedium: OrkaTypography.displayMedium.copyWith(color: OrkaColors.textPrimaryDark),
          displaySmall: OrkaTypography.displaySmall.copyWith(color: OrkaColors.textPrimaryDark),
          headlineLarge: OrkaTypography.headlineLarge.copyWith(color: OrkaColors.textPrimaryDark),
          headlineMedium: OrkaTypography.headlineMedium.copyWith(color: OrkaColors.textPrimaryDark),
          headlineSmall: OrkaTypography.headlineSmall.copyWith(color: OrkaColors.textPrimaryDark),
          bodyLarge: OrkaTypography.bodyLarge.copyWith(color: OrkaColors.textPrimaryDark),
          bodyMedium: OrkaTypography.bodyMedium.copyWith(color: OrkaColors.textPrimaryDark),
          bodySmall: OrkaTypography.bodySmall.copyWith(color: OrkaColors.textSecondaryDark),
          labelLarge: OrkaTypography.labelLarge.copyWith(color: OrkaColors.textPrimaryDark),
          labelMedium: OrkaTypography.labelMedium.copyWith(color: OrkaColors.textSecondaryDark),
          labelSmall: OrkaTypography.labelSmall.copyWith(color: OrkaColors.textTertiaryDark),
        ),
      );

  // === Light Theme ===
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: OrkaColors.surfaceLight,
        colorScheme: const ColorScheme.light(
          primary: OrkaColors.primary,
          onPrimary: Colors.white,
          secondary: OrkaColors.secondary,
          onSecondary: Colors.white,
          surface: OrkaColors.surfaceLight,
          onSurface: OrkaColors.textPrimaryLight,
          error: OrkaColors.error,
          outline: OrkaColors.borderLight,
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: OrkaColors.surfaceLight,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: OrkaTypography.headlineSmall.copyWith(
            color: OrkaColors.textPrimaryLight,
          ),
          iconTheme: const IconThemeData(color: OrkaColors.textPrimaryLight),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),

        cardTheme: CardTheme(
          color: OrkaColors.surfaceCardLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: OrkaColors.borderLight, width: 0.5),
          ),
          margin: EdgeInsets.zero,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: OrkaColors.surfaceCardLight,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: OrkaColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: OrkaColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: OrkaColors.primary, width: 1.5),
          ),
          hintStyle: OrkaTypography.bodyMedium.copyWith(
            color: OrkaColors.textTertiaryLight,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: OrkaColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        textTheme: TextTheme(
          displayLarge: OrkaTypography.displayLarge.copyWith(color: OrkaColors.textPrimaryLight),
          displayMedium: OrkaTypography.displayMedium.copyWith(color: OrkaColors.textPrimaryLight),
          displaySmall: OrkaTypography.displaySmall.copyWith(color: OrkaColors.textPrimaryLight),
          headlineLarge: OrkaTypography.headlineLarge.copyWith(color: OrkaColors.textPrimaryLight),
          headlineMedium: OrkaTypography.headlineMedium.copyWith(color: OrkaColors.textPrimaryLight),
          headlineSmall: OrkaTypography.headlineSmall.copyWith(color: OrkaColors.textPrimaryLight),
          bodyLarge: OrkaTypography.bodyLarge.copyWith(color: OrkaColors.textPrimaryLight),
          bodyMedium: OrkaTypography.bodyMedium.copyWith(color: OrkaColors.textPrimaryLight),
          bodySmall: OrkaTypography.bodySmall.copyWith(color: OrkaColors.textSecondaryLight),
          labelLarge: OrkaTypography.labelLarge.copyWith(color: OrkaColors.textPrimaryLight),
          labelMedium: OrkaTypography.labelMedium.copyWith(color: OrkaColors.textSecondaryLight),
          labelSmall: OrkaTypography.labelSmall.copyWith(color: OrkaColors.textTertiaryLight),
        ),
      );
}
