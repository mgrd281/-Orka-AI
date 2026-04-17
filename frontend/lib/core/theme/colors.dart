/// Orka AI — Design System Colors
///
/// Brand colors: Electric Violet primary, Cyan accent
/// Dark mode is the default and hero experience.
///
import 'package:flutter/material.dart';

class OrkaColors {
  OrkaColors._();

  // === Brand ===
  static const primary = Color(0xFF6C5CE7);
  static const primaryDark = Color(0xFF5A4BD1);
  static const primaryLight = Color(0xFF8B7CF6);
  static const secondary = Color(0xFF00D2FF);
  static const secondaryDark = Color(0xFF00B4D8);

  // === Dark Mode ===
  static const surfaceDark = Color(0xFF0D0D1A);
  static const surfaceCard = Color(0xFF161628);
  static const surfaceCardHover = Color(0xFF1E1E38);
  static const surfaceElevated = Color(0xFF1A1A32);
  static const borderDark = Color(0xFF2A2A4A);
  static const textPrimaryDark = Color(0xFFFFFFFF);
  static const textSecondaryDark = Color(0xFF8B8BA7);
  static const textTertiaryDark = Color(0xFF5A5A7A);

  // === Light Mode ===
  static const surfaceLight = Color(0xFFF8F9FC);
  static const surfaceCardLight = Color(0xFFFFFFFF);
  static const surfaceElevatedLight = Color(0xFFF0F1F5);
  static const borderLight = Color(0xFFE4E5EA);
  static const textPrimaryLight = Color(0xFF1A1A2E);
  static const textSecondaryLight = Color(0xFF6B6B80);
  static const textTertiaryLight = Color(0xFF9999AA);

  // === Status ===
  static const success = Color(0xFF00C48C);
  static const successLight = Color(0xFF00E6A0);
  static const warning = Color(0xFFFFB800);
  static const error = Color(0xFFFF4757);
  static const info = Color(0xFF3B82F6);

  // === Agent Colors ===
  static const agentAnalyst = Color(0xFF6C5CE7);
  static const agentResearcher = Color(0xFF00D2FF);
  static const agentCreative = Color(0xFFFF6B9D);
  static const agentCritic = Color(0xFFFFB800);
  static const agentSynthesizer = Color(0xFF00C48C);
  static const agentJudge = Color(0xFFE17055);

  // === Gradients ===
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF8B5CF6)],
  );

  static const premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const surfaceGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D0D1A), Color(0xFF121225)],
  );
}
