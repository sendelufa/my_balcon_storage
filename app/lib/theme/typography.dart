import 'package:flutter/material.dart';

/// App typography scale defining font sizes and weights.
///
/// Follows Material Design 3 typography guidelines with a minimal aesthetic.
/// Uses system fonts for native feel on each platform.
class AppTypography {
  AppTypography._();

  // ================================
  // FONT SIZES
  // ================================

  // Headings
  static const double h1Size = 32.0;
  static const double h2Size = 28.0;
  static const double h3Size = 24.0;
  static const double h4Size = 20.0;
  static const double h5Size = 18.0;
  static const double h6Size = 16.0;

  // Body and UI text
  static const double bodyLargeSize = 16.0;
  static const double bodyMediumSize = 14.0;
  static const double bodySmallSize = 12.0;

  // Labels and captions
  static const double labelLargeSize = 14.0;
  static const double labelMediumSize = 12.0;
  static const double labelSmallSize = 11.0;

  // Caption
  static const double captionSize = 10.0;

  // ================================
  // FONT WEIGHTS
  // ================================

  /// Thin - 100
  static const FontWeight weightThin = FontWeight.w100;

  /// Extra Light - 200
  static const FontWeight weightExtraLight = FontWeight.w200;

  /// Light - 300
  static const FontWeight weightLight = FontWeight.w300;

  /// Regular - 400
  static const FontWeight weightRegular = FontWeight.w400;

  /// Medium - 500
  static const FontWeight weightMedium = FontWeight.w500;

  /// Semi Bold - 600
  static const FontWeight weightSemiBold = FontWeight.w600;

  /// Bold - 700
  static const FontWeight weightBold = FontWeight.w700;

  /// Extra Bold - 800
  static const FontWeight weightExtraBold = FontWeight.w800;

  // ================================
  // LETTER SPACING
  // ================================

  /// Tight letter spacing for headings
  static const double letterSpacingTight = -0.5;

  /// Normal letter spacing
  static const double letterSpacingNormal = 0.0;

  /// Slightly wide letter spacing for uppercase text
  static const double letterSpacingWide = 0.5;

  /// Wide letter spacing for buttons and labels
  static const double letterSpacingWider = 1.0;

  // ================================
  // LINE HEIGHTS
  // ================================

  /// Tight line height for headings
  static const double lineHeightTight = 1.2;

  /// Normal line height for body text
  static const double lineHeightNormal = 1.5;

  /// Relaxed line height for readable paragraphs
  static const double lineHeightRelaxed = 1.75;

  // ================================
  // TEXT STYLES
  // ================================

  /// H1 - Largest heading, for page titles
  static const TextStyle h1 = TextStyle(
    fontSize: h1Size,
    fontWeight: weightMedium,
    letterSpacing: letterSpacingTight,
    height: lineHeightTight,
  );

  /// H2 - Large heading, for section titles
  static const TextStyle h2 = TextStyle(
    fontSize: h2Size,
    fontWeight: weightMedium,
    letterSpacing: letterSpacingTight,
    height: lineHeightTight,
  );

  /// H3 - Medium heading, for card titles
  static const TextStyle h3 = TextStyle(
    fontSize: h3Size,
    fontWeight: weightMedium,
    letterSpacing: letterSpacingNormal,
    height: lineHeightTight,
  );

  /// H4 - Small heading, for list section headers
  static const TextStyle h4 = TextStyle(
    fontSize: h4Size,
    fontWeight: weightSemiBold,
    letterSpacing: letterSpacingNormal,
    height: lineHeightTight,
  );

  /// H5 - Smaller heading, for subtitles
  static const TextStyle h5 = TextStyle(
    fontSize: h5Size,
    fontWeight: weightSemiBold,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  /// H6 - Smallest heading, for overline text
  static const TextStyle h6 = TextStyle(
    fontSize: h6Size,
    fontWeight: weightSemiBold,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
  );

  /// Body Large - Primary body text with emphasis
  static const TextStyle bodyLarge = TextStyle(
    fontSize: bodyLargeSize,
    fontWeight: weightRegular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  /// Body Medium - Standard body text
  static const TextStyle bodyMedium = TextStyle(
    fontSize: bodyMediumSize,
    fontWeight: weightRegular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  /// Body Small - Secondary body text
  static const TextStyle bodySmall = TextStyle(
    fontSize: bodySmallSize,
    fontWeight: weightRegular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  /// Label Large - Prominent labels (buttons, tabs)
  static const TextStyle labelLarge = TextStyle(
    fontSize: labelLargeSize,
    fontWeight: weightMedium,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
  );

  /// Label Medium - Standard labels
  static const TextStyle labelMedium = TextStyle(
    fontSize: labelMediumSize,
    fontWeight: weightMedium,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
  );

  /// Label Small - Compact labels
  static const TextStyle labelSmall = TextStyle(
    fontSize: labelSmallSize,
    fontWeight: weightMedium,
    letterSpacing: letterSpacingWider,
    height: lineHeightNormal,
  );

  /// Caption - Minimal text for hints and metadata
  static const TextStyle caption = TextStyle(
    fontSize: captionSize,
    fontWeight: weightRegular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  // ================================
  // MATERIAL TEXT THEME
  // ================================

  /// Creates Material TextTheme from AppTypography
  static TextTheme createTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: h1.copyWith(color: textColor),
      displayMedium: h2.copyWith(color: textColor),
      displaySmall: h3.copyWith(color: textColor),
      headlineMedium: h4.copyWith(color: textColor),
      headlineSmall: h5.copyWith(color: textColor),
      titleLarge: h6.copyWith(color: textColor),
      bodyLarge: bodyLarge.copyWith(color: textColor),
      bodyMedium: bodyMedium.copyWith(color: textColor),
      bodySmall: bodySmall.copyWith(color: textColor),
      labelLarge: labelLarge.copyWith(color: textColor),
      labelMedium: labelMedium.copyWith(color: textColor),
      labelSmall: labelSmall.copyWith(color: textColor),
    );
  }

  // ================================
  // HELPER METHODS
  // ================================

  /// Get heading style by level (1-6)
  static TextStyle heading(int level) {
    switch (level) {
      case 1:
        return h1;
      case 2:
        return h2;
      case 3:
        return h3;
      case 4:
        return h4;
      case 5:
        return h5;
      case 6:
        return h6;
      default:
        return h4;
    }
  }

  /// Get body style by size
  static TextStyle body({BodySize size = BodySize.medium}) {
    switch (size) {
      case BodySize.large:
        return bodyLarge;
      case BodySize.medium:
        return bodyMedium;
      case BodySize.small:
        return bodySmall;
    }
  }

  /// Get label style by size
  static TextStyle label({LabelSize size = LabelSize.medium}) {
    switch (size) {
      case LabelSize.large:
        return labelLarge;
      case LabelSize.medium:
        return labelMedium;
      case LabelSize.small:
        return labelSmall;
    }
  }
}

/// Enum for body text sizes
enum BodySize { large, medium, small }

/// Enum for label text sizes
enum LabelSize { large, medium, small }
