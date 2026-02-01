import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// Available tabs in the bottom navigation bar.
enum AppTab {
  /// Locations tab - shows storage locations hierarchy
  locations,

  /// Search tab - search functionality for items and locations
  search,
}

/// Extension to provide display properties for each tab.
extension AppTabExtension on AppTab {
  /// Get the icon for this tab.
  IconData get icon {
    switch (this) {
      case AppTab.locations:
        return Icons.inventory_2_outlined;
      case AppTab.search:
        return Icons.search;
    }
  }

  /// Get the active (filled) icon for this tab.
  IconData get activeIcon {
    switch (this) {
      case AppTab.locations:
        return Icons.inventory_2;
      case AppTab.search:
        return Icons.search;
    }
  }

  /// Get the label for this tab.
  String get label {
    switch (this) {
      case AppTab.locations:
        return 'Browse';
      case AppTab.search:
        return 'Search';
    }
  }
}

/// A bottom navigation bar widget following Material Design 3 guidelines.
///
/// This widget provides navigation between the main app screens with:
/// - Consistent Material Design 3 styling
/// - Theme-aware colors (light/dark mode support)
/// - Active tab highlighting with primary color
/// - Smooth transitions between tabs
/// - Proper accessibility labels
///
/// Example usage:
/// ```dart
/// int _currentIndex = 0;
///
/// @override
/// Widget build(BuildContext context) {
///   return Scaffold(
///     body: _getBodyForIndex(_currentIndex),
///     bottomNavigationBar: AppBottomNavigationBar(
///       currentIndex: _currentIndex,
///       onTap: (index) {
///         setState(() {
///           _currentIndex = index;
///         });
///       },
///     ),
///   );
/// }
/// ```
class AppBottomNavigationBar extends StatelessWidget {
  /// Creates an app bottom navigation bar.
  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.elevation = 0,
    this.height,
  });

  /// The currently selected tab index.
  final int currentIndex;

  /// Callback when a tab is tapped.
  final ValueChanged<int> onTap;

  /// The elevation of the navigation bar.
  ///
  /// Defaults to 0 for a flat design following the app's minimal styling.
  final double elevation;

  /// Custom height for the navigation bar.
  ///
  /// If null, uses Material Design 3 standard height (80px).
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.borderDark
                : AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        height: height ?? 80.0,
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        // Material Design 3 indicator color with reduced opacity
        indicatorColor: isDark
            ? const Color(0x2F00BCD4)  // primaryTransparent adjusted for dark
            : AppColors.primaryTransparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: AppTypography.labelSmallSize,
            fontWeight: isSelected
                ? AppTypography.weightMedium
                : AppTypography.weightRegular,
            color: isSelected
                ? (isDark ? AppColors.primaryLight : AppColors.primary)
                : (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight),
          );
        }),
        destinations: AppTab.values.map((tab) {
          return NavigationDestination(
            icon: Icon(tab.icon),
            selectedIcon: Icon(tab.activeIcon),
            label: tab.label,
            tooltip: tab.label,
          );
        }).toList(),
      ),
    );
  }
}
