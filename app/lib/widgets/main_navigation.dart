import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../screens/locations_list_screen.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// AppBar titles for each tab.
const List<String> _appBarTitles = [
  'Browse',
  'Search',
];

/// Search screen placeholder - to be implemented with actual search functionality.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: brightness == Brightness.dark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            AppSpacing.gapLg,
            Text(
              'Search Coming Soon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: brightness == Brightness.dark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            AppSpacing.gapSm,
            Text(
              'Search for items and locations',
              style: TextStyle(
                fontSize: 14,
                color: brightness == Brightness.dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
  }
}

/// Main navigation wrapper that manages bottom navigation and nested navigators.
///
/// This widget provides the root navigation structure for the app,
/// handling tab switching and managing the navigation state for each tab.
///
/// Uses the nested navigator pattern to keep the bottom navigation bar
/// visible across all screens within each tab.
///
/// Example usage in main.dart:
/// ```dart
/// MaterialApp(
///   home: MainNavigation(),
///   // ... other config
/// )
/// ```
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  /// Currently selected tab index.
  int _currentIndex = 0;

  /// Global keys for each tab's navigator.
  ///
  /// These keys allow us to control each nested navigator independently,
  /// enabling state preservation across tab switches.
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  /// Handles tab selection with smart Browse behavior.
  ///
  /// **Browse tab (index 0) special behavior:**
  /// - If already on Browse and at a deeper level (Item/Container), pop to root
  /// - If on another tab, switch to Browse (preserves navigation state)
  ///
  /// This allows users to quickly return to Locations list from deep in Browse,
  /// while preserving their place when switching between tabs.
  void _onTabTapped(int index) {
    // Browse tab (index 0) special behavior
    if (index == 0 && _currentIndex == 0) {
      // Already on Browse - check if we can pop (not at root)
      final browseNavigator = _navigatorKeys[0].currentState;
      if (browseNavigator != null && browseNavigator.canPop()) {
        // Pop to root (LocationsListScreen)
        browseNavigator.popUntil((route) => route.isFirst);
      }
      // If already at root, do nothing
      return;
    }

    // Switching to a different tab - preserve navigation state
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  /// Builds the nested Navigator for a specific tab.
  ///
  /// Each tab has its own Navigator stack, allowing navigation within
  /// the tab without affecting the bottom navigation bar.
  Widget _buildNavigator(GlobalKey<NavigatorState> key) {
    return Navigator(
      key: key,
      // When a route is unknown, we'll show the appropriate screen
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            // Show the appropriate screen based on current tab index
            switch (_currentIndex) {
              case 0:
                return const LocationsListScreen();
              case 1:
                return const SearchScreen();
              default:
                return const LocationsListScreen();
            }
          },
        );
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            switch (_currentIndex) {
              case 0:
                return const LocationsListScreen();
              case 1:
                return const SearchScreen();
              default:
                return const LocationsListScreen();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // We'll handle the back button manually
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final currentNavigator = _navigatorKeys[_currentIndex].currentState;
        if (currentNavigator != null && currentNavigator.canPop()) {
          currentNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_appBarTitles[_currentIndex]),
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildNavigator(_navigatorKeys[0]),
            _buildNavigator(_navigatorKeys[1]),
          ],
        ),
        bottomNavigationBar: AppBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}
