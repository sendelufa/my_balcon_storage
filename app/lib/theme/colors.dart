import 'package:flutter/material.dart';

/// App color palette with teal/cyan accent color.
///
/// Supports light and dark themes with minimal styling.
/// Colors are designed to work with Material Design 3.
class AppColors {
  AppColors._();

  // ================================
  // PRIMARY (Teal/Cyan Accent)
  // ================================

  /// Primary accent color - Teal/Cyan from moodboard
  static const Color primary = Color(0xFF00BCD4);

  /// Lighter shade of primary for hover states
  static const Color primaryLight = Color(0xFF4DD0E1);

  /// Darker shade of primary for pressed states
  static const Color primaryDark = Color(0xFF0097A7);

  /// Primary color with reduced opacity for backgrounds
  static const Color primaryTransparent = Color(0x1F00BCD4);

  /// Primary color with very reduced opacity for subtle accents
  static const Color primarySubtle = Color(0x0D00BCD4);

  // ================================
  // SECONDARY
  // ================================

  /// Secondary accent color - Soft purple for variety
  static const Color secondary = Color(0xFF7E57C2);

  /// Lighter shade of secondary
  static const Color secondaryLight = Color(0xFFB39DDB);

  /// Darker shade of secondary
  static const Color secondaryDark = Color(0xFF512DA8);

  // ================================
  // BACKGROUND COLORS
  // ================================

  /// Main background color - light theme
  static const Color backgroundLight = Color(0xFFFAFAFA);

  /// Secondary background color - light theme (cards, surfaces)
  static const Color backgroundLightSecondary = Color(0xFFFFFFFF);

  /// Main background color - dark theme
  static const Color backgroundDark = Color(0xFF121212);

  /// Secondary background color - dark theme (cards, surfaces)
  static const Color backgroundDarkSecondary = Color(0xFF1E1E1E);

  /// Elevated surface background - light theme
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Elevated surface background - dark theme
  static const Color surfaceDark = Color(0xFF2C2C2C);

  // ================================
  // TEXT COLORS
  // ================================

  /// Primary text color - light theme (almost black)
  static const Color textPrimaryLight = Color(0xFF212121);

  /// Secondary text color - light theme (medium gray)
  static const Color textSecondaryLight = Color(0xFF757575);

  /// Disabled text color - light theme
  static const Color textDisabledLight = Color(0xFFBDBDBD);

  /// Primary text color - dark theme (almost white)
  static const Color textPrimaryDark = Color(0xFFFFFFFF);

  /// Secondary text color - dark theme (medium gray)
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  /// Disabled text color - dark theme
  static const Color textDisabledDark = Color(0xFF616161);

  // ================================
  // STATE COLORS
  // ================================

  /// Error color - red
  static const Color error = Color(0xFFE53935);

  /// Error color with background opacity
  static const Color errorBackground = Color(0x1FE53935);

  /// Success color - green
  static const Color success = Color(0xFF43A047);

  /// Success color with background opacity
  static const Color successBackground = Color(0x1F43A047);

  /// Warning color - amber
  static const Color warning = Color(0xFFFFB300);

  /// Warning color with background opacity
  static const Color warningBackground = Color(0x1FFFB300);

  /// Info color - blue
  static const Color info = Color(0xFF1E88E5);

  /// Info color with background opacity
  static const Color infoBackground = Color(0x1F1E88E5);

  // ================================
  // BORDER & DIVIDER COLORS
  // ================================

  /// Border color - light theme (minimal thin borders)
  static const Color borderLight = Color(0xFFE0E0E0);

  /// Border color - dark theme
  static const Color borderDark = Color(0xFF424242);

  /// Divider color - light theme
  static const Color dividerLight = Color(0xFFEEEEEE);

  /// Divider color - dark theme
  static const Color dividerDark = Color(0xFF363636);

  /// Focus outline color
  static const Color focus = Color(0xFF00BCD4);

  // ================================
  // OVERLAY & SHADOW COLORS
  // ================================

  /// Modal overlay color (scrim)
  static const Color overlay = Color(0x80000000);

  /// Shadow color for elevation
  static const Color shadow = Color(0x1F000000);

  // ================================
  // CUSTOM ACCENT COLORS (Future)
  // ================================

  /// Predefined accent colors for location/item type customization
  static const Map<String, Color> accentColors = {
    'teal': Color(0xFF00BCD4),
    'blue': Color(0xFF2196F3),
    'purple': Color(0xFF7E57C2),
    'green': Color(0xFF66BB6A),
    'orange': Color(0xFFFF9800),
    'red': Color(0xFFEF5350),
    'pink': Color(0xFFEC407A),
    'indigo': Color(0xFF5C6BC0),
  };

  /// Get accent color by name, returns primary if not found
  static Color getAccentColor(String name) {
    return accentColors[name.toLowerCase()] ?? primary;
  }

  // ================================
  // HELPERS
  // ================================

  /// Get appropriate text color based on theme brightness
  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? textPrimaryLight
        : textPrimaryDark;
  }

  /// Get appropriate secondary text color based on theme brightness
  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? textSecondaryLight
        : textSecondaryDark;
  }

  /// Get appropriate disabled text color based on theme brightness
  static Color textDisabled(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? textDisabledLight
        : textDisabledDark;
  }

  /// Get appropriate background color based on theme brightness
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? backgroundLight
        : backgroundDark;
  }

  /// Get appropriate surface color based on theme brightness
  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? surfaceLight
        : surfaceDark;
  }

  /// Get appropriate border color based on theme brightness
  static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? borderLight
        : borderDark;
  }

  /// Get appropriate divider color based on theme brightness
  static Color divider(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? dividerLight
        : dividerDark;
  }
}
