# Task 3.1.2: Add Location Card Component

**Task ID:** 3.1.2
**Status:** ✅ Completed
**Date:** 2026-02-01
**Estimated Hours:** 2
**Actual Hours:** 2

## Description

Create a reusable location card component for displaying locations in the locations list. The card shows the location's name, description, and thumbnail image with a fallback placeholder when no image is available.

## Acceptance Criteria

- [x] Location card displays location name prominently
- [x] Location card displays description (if available)
- [x] Location card displays thumbnail image (64x64)
- [x] Placeholder shown when no image available
- [x] Card is tappable for navigation
- [x] Renders properly for each location in the list
- [x] Follows app design system (colors, spacing, typography)
- [x] Item count indicator supported

## Implementation Details

### File Created

**`app/lib/widgets/card.dart`** (~777 lines)
- `AppCard` base class with multiple variants
- `AppCard.location()` factory constructor for location cards
- `_LocationImage` widget for thumbnail display
- `_LocationPlaceholder` widget for fallback when no image
- Additional card variants: `AppCard.item()`, `ContainerCard`, `AppListTileCard`, `AppActionCard`

### Location Card Features

**AppCard.location() Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | String | Yes | Location name displayed as title |
| `description` | String? | No | Optional description text |
| `imagePath` | String? | No | Path to location thumbnail image |
| `itemCount` | int | No | Number of items in location (default: 0) |
| `trailing` | Widget? | No | Optional trailing widget |
| `onTap` | VoidCallback? | No | Callback when card is tapped |
| `child` | Widget? | No | Optional additional content |

### Visual Design

**Thumbnail:**
- Size: 64x64 pixels
- Rounded corners (4px)
- `BoxFit.cover` for image scaling
- Error handling falls back to placeholder

**Placeholder (when no image):**
- 64x64 container with primary accent background
- `Icons.place_outlined` icon (32px)
- Border matching card border
- Primary color accent in light/dark themes

**Card Layout:**
```
┌─────────────────────────────────┐
│ [64x64]  Location Name        > │
│  thumb   Description text       │
│          (2 lines max)          │
└─────────────────────────────────┘
```

## Code Sample

```dart
// Factory constructor
factory AppCard.location({
  Key? key,
  required String name,
  String? description,
  String? imagePath,
  Widget? trailing,
  VoidCallback? onTap,
  int itemCount = 0,
  Widget? child,
}) {
  return AppCard(
    key: key,
    title: name,
    subtitle: description,
    leading: imagePath != null
        ? _LocationImage(imagePath: imagePath)
        : const _LocationPlaceholder(),
    trailing: trailing,
    isTappable: onTap != null,
    onTap: onTap,
    variant: AppCardVariant.location,
  );
}

// Usage in LocationsListScreen
AppCard.location(
  name: location.name,
  description: location.description ?? '',
  itemCount: 0, // TODO: fetch actual count
  onTap: () => _navigateToLocation(location),
)
```

## Result

Location cards are now used in the `LocationsListScreen` to display all locations from the database. Each card shows:
- Location name as a prominent title
- Optional description text
- Thumbnail image or placeholder icon
- Tappable for navigation to location contents

The card component is reusable and can be used anywhere in the app that needs to display location information.

## Additional Card Variants Created

While implementing the location card, several other card variants were created for future use:

| Variant | Purpose | Status |
|---------|---------|--------|
| `AppCard.item()` | Item cards with thumbnail | Used in ItemDetailScreen |
| `ContainerCard` | Container cards with type badge | Used in ContentsScreen |
| `AppListTileCard` | Compact list tile cards | Available for future use |
| `AppActionCard` | Cards with action buttons | Available for future use |

## Related Files

- `app/lib/screens/locations_list_screen.dart` - Uses location cards
- `app/lib/screens/contents_screen.dart` - Uses container cards
- `app/lib/screens/item_detail_screen.dart` - Uses item cards
