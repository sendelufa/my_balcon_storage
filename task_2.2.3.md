# Task 2.2.3: Create Bottom Tab Navigation

**Task ID:** 2.2.3
**Status:** ✅ Completed
**Date:** 2026-02-01
**Estimated Hours:** 2
**Actual Hours:** 2

## Description

Implement bottom tab navigation for the Storage App with two main sections: Browse and Search. The bottom navigation bar follows Material Design 3 guidelines and integrates with the existing app theme system.

**Key Implementation:** Uses the **Nested Navigator pattern** so the bottom navigation bar persists across all screens, allowing users to access Browse and Search from anywhere in the app.

## Acceptance Criteria

- [x] Bottom navigation bar with 2 tabs visible
- [x] Bottom navigation **persists on all screens** (nested navigator pattern)
- [x] Browse tab shows locations list
- [x] Search tab shows search placeholder screen
- [x] Tab switching works correctly with state preservation
- [x] Active tab is highlighted with primary color
- [x] Follows Material Design 3 guidelines
- [x] Supports light and dark themes
- [x] Back button works correctly within nested navigators

## Implementation Details

### Files Created

**`app/lib/widgets/bottom_navigation_bar.dart`** (~153 lines)
- `AppTab` enum defining available tabs (locations, search)
- `AppTabExtension` with icon, activeIcon, and label properties
- `AppBottomNavigationBar` widget using Material Design 3's `NavigationBar`

**`app/lib/widgets/main_navigation.dart`** (~178 lines)
- `MainNavigation` widget using **IndexedStack** with nested navigators
- `SearchScreen` placeholder for future search implementation
- `GlobalKey<NavigatorState>` for each tab's independent navigation stack
- `PopScope` for proper back button handling

### Files Modified

**`app/lib/main.dart`**
- Updated home from `LocationsListScreen()` to `MainNavigation()`
- Added import for `widgets/main_navigation.dart`

**`app/lib/screens/locations_list_screen.dart`**
- Updated navigation to use `Navigator.of(context, rootNavigator: false).push()`

**`app/lib/screens/contents_screen.dart`**
- Updated navigation to use nested navigator for both container and item navigation

**`app/lib/screens/item_detail_screen.dart`**
- Updated navigation to use nested navigator for location, container, and image viewer

**`app/test/widget_test.dart`**
- Updated test to look for "Browse" instead of "Locations"

## Tab Configuration

| Tab | Icon | Label | Screen |
|-----|------|-------|--------|
| Browse | `Icons.inventory_2_outlined` / `Icons.inventory_2` | "Browse" | `LocationsListScreen` |
| Search | `Icons.search` | "Search" | `SearchScreen` (placeholder) |

## Design Features

**Navigation Bar Styling:**
- Height: 80px (Material Design 3 standard)
- Elevation: 0 (flat design)
- Top border for visual separation
- Indicator color: Semi-transparent primary color
- Active tabs: Primary color with filled icons
- Inactive tabs: Secondary text color with outlined icons

**Nested Navigator Pattern:**
- Each tab has its own `Navigator` stack
- `IndexedStack` preserves state when switching tabs
- Bottom nav remains visible on all screens
- Back button correctly navigates within the current tab's stack

**Smart Browse Navigation:**
- When on Item/Container screen → tapping Browse goes to Locations list (root)
- When on another tab (Search/Settings) → tapping Browse returns to last viewed Item/Container
- This allows quick "home" action while preserving navigation state when switching tabs

## Code Sample

```dart
// Tab enum
enum AppTab {
  locations,  // Browse tab
  search,
}

// Navigation structure with nested navigators
class MainNavigation extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          final currentNavigator = _navigatorKeys[_currentIndex].currentState;
          if (currentNavigator != null && currentNavigator.canPop()) {
            currentNavigator.pop();
          }
        }
      },
      child: Scaffold(
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

// Smart Browse navigation behavior
void _onTabTapped(int index) {
  if (index == 0 && _currentIndex == 0) {
    // Already on Browse - pop to root if at deeper level
    final browseNavigator = _navigatorKeys[0].currentState;
    if (browseNavigator != null && browseNavigator.canPop()) {
      browseNavigator.popUntil((route) => route.isFirst);
    }
    return;
  }
  // Switching tabs - preserve state
  if (_currentIndex != index) {
    setState(() {
      _currentIndex = index;
    });
  }
}

// Navigation within tabs uses nested navigator
void _navigateToLocation(Location location) {
  Navigator.of(context, rootNavigator: false).push(
    MaterialPageRoute(
      builder: (context) => ContentsScreen(source: LocationSource(location)),
    ),
  );
}
```

## Result

App now has a persistent bottom navigation bar that:
1. **Stays visible** on all screens (LocationsListScreen, ContentsScreen, ItemDetailScreen)
2. **Browse** tab - displays the locations list with hierarchical navigation
3. **Search** tab - shows placeholder for future search functionality (Task 5)
4. **State preservation** - switching tabs preserves navigation state
5. **Back button** - correctly navigates within the current tab's stack

Users can now:
- Access Search from anywhere in the app
- Quickly return to Browse from deep navigation
- Switch between tabs without losing their place

## Navigation Flow

```
MainNavigation (IndexedStack - bottom nav ALWAYS visible)
├── Browse Tab (Navigator)
│   └── LocationsListScreen
│       └── ContentsScreen (Location) ← bottom nav visible!
│           └── ContentsScreen (Container) ← bottom nav visible!
│               └── ItemDetailScreen ← bottom nav visible!
└── Search Tab (Navigator)
    └── SearchScreen (placeholder)
```

## Smart Browse Button Behavior

The Browse tab button has context-aware behavior:

| Current Screen | Tapping Browse |
|----------------|----------------|
| LocationsListScreen | No effect (already at root) |
| ContentsScreen (any level) | Go to LocationsListScreen |
| ItemDetailScreen | Go to LocationsListScreen |
| Search tab | Return to last screen in Browse (preserves state) |
| Settings tab (future) | Return to last screen in Browse (preserves state) |

**Example flows:**

```
User flow 1: Deep in Browse
Locations → Contents → ItemDetail
    ↓ tap Browse
LocationsList (pop to root)

User flow 2: Switch between tabs
Locations → Contents → ItemDetail
    ↓ tap Search
SearchScreen
    ↓ tap Browse
ItemDetail (returns to where user left off)
```

## Future Work

- Task 5: Implement full search functionality with real-time search, filters, and search history
- Task 2.2.4: Implement proper back button handling for both platforms (partially done with PopScope)
- Consider adding third tab (Settings) when needed
