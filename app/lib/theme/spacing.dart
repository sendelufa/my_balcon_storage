import 'package:flutter/material.dart';

/// App spacing system based on a 4px base unit.
///
/// All spacing values are multiples of 4 for consistency.
/// Provides named constants for semantic spacing.
class AppSpacing {
  AppSpacing._();

  // ================================
  // BASE UNIT
  // ================================

  /// Base unit for spacing (4px)
  static const double baseUnit = 4.0;

  // ================================
  // SPACING SCALE
  // ================================

  /// 4px - Extra small spacing
  static const double xs = baseUnit;

  /// 8px - Small spacing
  static const double sm = baseUnit * 2;

  /// 12px - Small-medium spacing
  static const double smMd = baseUnit * 3;

  /// 16px - Medium spacing (default)
  static const double md = baseUnit * 4;

  /// 20px - Medium-large spacing
  static const double mdLg = baseUnit * 5;

  /// 24px - Large spacing
  static const double lg = baseUnit * 6;

  /// 32px - Extra large spacing
  static const double xl = baseUnit * 8;

  /// 40px - Extra extra large spacing
  static const double xxl = baseUnit * 10;

  /// 48px - Huge spacing
  static const double huge = baseUnit * 12;

  /// 64px - Extra huge spacing
  static const double hugeX = baseUnit * 16;

  // ================================
  // PADDING CONSTANTS
  // ================================

  /// Padding for cards
  static const double cardPadding = md;

  /// Padding for list tiles
  static const double listTilePadding = sm;

  /// Padding for dialogs
  static const double dialogPadding = lg;

  /// Padding for bottom sheets
  static const double bottomSheetPadding = md;

  /// Padding for buttons (horizontal)
  static const double buttonPaddingHorizontal = lg;

  /// Padding for buttons (vertical)
  static const double buttonPaddingVertical = sm;

  /// Padding for text fields
  static const double textFieldPadding = sm;

  /// Padding for chips
  static const double chipPaddingValue = sm;

  /// Padding for chips (as EdgeInsets)
  static const EdgeInsets paddingChip = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: xs,
  );

  /// Padding for icon buttons
  static const double iconButtonPadding = sm;

  // ================================
  // MARGIN CONSTANTS
  // ================================

  /// Margin between related elements
  static const double elementSpacing = sm;

  /// Margin between sections
  static const double sectionSpacing = lg;

  /// Margin between cards
  static const double cardSpacing = sm;

  /// Margin for page edges
  static const double pageMargin = md;

  /// Margin for list items
  static const double listItemMargin = sm;

  // ================================
  // BORDER RADIUS
  // ================================

  /// Extra small border radius (4px)
  static const double radiusXs = baseUnit;

  /// Small border radius (8px)
  static const double radiusSm = baseUnit * 2;

  /// Medium border radius (12px)
  static const double radiusMd = baseUnit * 3;

  /// Large border radius (16px)
  static const double radiusLg = baseUnit * 4;

  /// Extra large border radius (24px)
  static const double radiusXl = baseUnit * 6;

  /// Full border radius for circular elements
  static const double radiusFull = double.infinity;

  // ================================
  // SIZED BOX HELPERS
  // ================================

  /// Extra small vertical space (4px)
  static const SizedBox gapXs = SizedBox(height: xs, width: xs);

  /// Small vertical space (8px)
  static const SizedBox gapSm = SizedBox(height: sm, width: sm);

  /// Small-medium vertical space (12px)
  static const SizedBox gapSmMd = SizedBox(height: smMd, width: smMd);

  /// Medium vertical space (16px)
  static const SizedBox gapMd = SizedBox(height: md, width: md);

  /// Medium-large vertical space (20px)
  static const SizedBox gapMdLg = SizedBox(height: mdLg, width: mdLg);

  /// Large vertical space (24px)
  static const SizedBox gapLg = SizedBox(height: lg, width: lg);

  /// Extra large vertical space (32px)
  static const SizedBox gapXl = SizedBox(height: xl, width: xl);

  /// Extra extra large vertical space (40px)
  static const SizedBox gapXxl = SizedBox(height: xxl, width: xxl);

  // ================================
  // EDGE INSETS
  // ================================

  /// Extra small padding on all sides
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);

  /// Small padding on all sides
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);

  /// Medium padding on all sides
  static const EdgeInsets paddingMd = EdgeInsets.all(md);

  /// Large padding on all sides
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);

  /// Extra large padding on all sides
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  /// Horizontal medium padding
  static const EdgeInsets paddingHMd = EdgeInsets.symmetric(horizontal: md);

  /// Vertical medium padding
  static const EdgeInsets paddingVMd = EdgeInsets.symmetric(vertical: md);

  /// Symmetric medium padding
  static const EdgeInsets paddingSymmetricMd = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Card padding
  static const EdgeInsets paddingCard = EdgeInsets.all(cardPadding);

  /// Dialog padding
  static const EdgeInsets paddingDialog = EdgeInsets.all(dialogPadding);

  /// Page margins
  static const EdgeInsets pageMargins = EdgeInsets.all(pageMargin);

  /// List tile padding
  static const EdgeInsets paddingListTile = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Button padding
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(
    horizontal: buttonPaddingHorizontal,
    vertical: buttonPaddingVertical,
  );

  /// Text field padding
  static const EdgeInsets paddingTextField = EdgeInsets.all(textFieldPadding);

  // ================================
  // BORDER RADIUS HELPERS
  // ================================

  /// Extra small border radius
  static BorderRadius borderRadiusXs = BorderRadius.circular(radiusXs);

  /// Small border radius
  static BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);

  /// Medium border radius
  static BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);

  /// Large border radius
  static BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);

  /// Extra large border radius
  static BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);

  // ================================
  // HELPER METHODS
  // ================================

  /// Create spacing SizedBox by scale value
  static SizedBox gap(double scale) {
    return SizedBox(
      height: baseUnit * scale,
      width: baseUnit * scale,
    );
  }

  /// Create padding by scale value
  static EdgeInsets paddingAll(double scale) {
    return EdgeInsets.all(baseUnit * scale);
  }

  /// Create symmetric padding
  static EdgeInsets paddingSymmetric({
    double horizontalScale = 0,
    double verticalScale = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: baseUnit * horizontalScale,
      vertical: baseUnit * verticalScale,
    );
  }

  /// Create only padding
  static EdgeInsets paddingOnly({
    double leftScale = 0,
    double topScale = 0,
    double rightScale = 0,
    double bottomScale = 0,
  }) {
    return EdgeInsets.only(
      left: baseUnit * leftScale,
      top: baseUnit * topScale,
      right: baseUnit * rightScale,
      bottom: baseUnit * bottomScale,
    );
  }

  /// Create border radius by scale value
  static BorderRadius borderRadius(double scale) {
    return BorderRadius.circular(baseUnit * scale);
  }
}
