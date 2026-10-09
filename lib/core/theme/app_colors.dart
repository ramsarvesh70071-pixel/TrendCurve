import 'package:flutter/material.dart';

/// Centralized color palette for Trend Curve.
/// Curated for a premium, sleek data-analytics aesthetic.
class AppColors {
  AppColors._();

  // Primary Brand Colors (Electric Indigo)
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryContainerLight = Color(0xFFEEF2FF);
  static const Color primaryContainerDark = Color(0xFF1E1B4B);

  // Secondary Accent Colors (Vibrant Teal / Cyan)
  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondaryDark = Color(0xFF0891B2);
  static const Color secondaryLight = Color(0xFF67E8F9);
  static const Color secondaryContainerLight = Color(0xFFECFEFF);
  static const Color secondaryContainerDark = Color(0xFF164E63);

  // Tertiary Accent (Purple Violet)
  static const Color tertiary = Color(0xFF8B5CF6);
  static const Color tertiaryLight = Color(0xFFA78BFA);

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color successLight = Color(0xFF34D399);
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color successContainerDark = Color(0xFF064E3B);

  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color warningContainerDark = Color(0xFF78350F);

  static const Color danger = Color(0xFFEF4444); // Crimson / Rose
  static const Color dangerLight = Color(0xFFF87171);
  static const Color dangerContainer = Color(0xFFFEE2E2);
  static const Color dangerContainerDark = Color(0xFF7F1D1D);
  static const Color error = danger;
  static const Color accent = secondary;
  static const Color textSecondary = textSecondaryLight;

  static const Color info = Color(0xFF3B82F6);
  static const Color infoContainer = Color(0xFFDBEAFE);
  static const Color infoContainerDark = Color(0xFF1E3A8A);

  // Neutral Colors - Light Theme
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardBorderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color dividerLight = Color(0xFFE2E8F0);

  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color textMutedLight = Color(0xFF94A3B8); // Slate 400

  // Neutral Colors - Dark Theme
  static const Color backgroundDark = Color(0xFF090D16); // Deep Navy Black
  static const Color surfaceDark = Color(0xFF0F172A); // Slate 900
  static const Color cardDark = Color(0xFF1E293B); // Slate 800
  static const Color cardBorderDark = Color(0xFF334155); // Slate 700
  static const Color dividerDark = Color(0xFF1E293B);

  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color textMutedDark = Color(0xFF64748B); // Slate 500

  // Chart Palette (Curated distinct hues)
  static const List<Color> chartPalette = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF06B6D4), // Cyan
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
    Color(0xFF3B82F6), // Blue
    Color(0xFF14B8A6), // Teal
  ];

  // Category Colors
  static const Map<String, Color> categoryColors = {
    'Business': Color(0xFF6366F1),
    'Finance': Color(0xFF10B981),
    'Health': Color(0xFFEF4444),
    'Productivity': Color(0xFF8B5CF6),
    'Social': Color(0xFFEC4899),
    'Education': Color(0xFF06B6D4),
    'Technology': Color(0xFF3B82F6),
    'Custom': Color(0xFFF59E0B),
  };
}
