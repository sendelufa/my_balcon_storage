# Task 2.1.7: Create Reusable Card Component

**Task ID:** 2.1.7
**Status:** ✅ Completed
**Date:** 2025-02-01
**Estimated Hours:** 2
**Actual Hours:** 2

## Description

Create a reusable Card component with minimal styling, thin borders, and variants for location and item cards.

## Acceptance Criteria

- [x] Consistent styling for location/item cards
- [x] Minimal aesthetic
- [x] Thin borders
- [x] Support for leading/trailing widgets
- [x] Support for media/images
- [x] Multiple variants

## Implementation Details

### File Created

**`app/lib/widgets/card.dart`** (~620 lines)

### Components

**AppCard:**
- Base card component
- Minimal border with subtle shadow
- Configurable padding and margin
- Optional elevation
- Border radius customization
- Color customization

**Specialized Card Types:**
- `AppCard.location()` - Factory for location cards
- `AppCard.item()` - Factory for item cards
- `AppCard.list()` - Factory for list items

**AppListTileCard:**
- Compact list item card
- Leading widget support
- Trailing widget support
- Title and subtitle
- Minimal styling

**AppActionCard:**
- Card with action button
- onTap callback
- Optional leading icon

**AppMediaCard:**
- Card with image/media
- Placeholder support
- Overlay content

### Usage Examples

```dart
// Basic card
AppCard(
  title: 'Card Title',
  subtitle: 'Card subtitle',
  trailing: AppButton.text(child: Text('Action')),
)

// Location card
AppCard.location(
  title: 'Garage',
  subtitle: '5 items',
  imagePath: '/path/to/image.jpg',
  onTap: () => _navigateToLocation(),
)

// Item card
AppCard.item(
  title: 'Hammer',
  subtitle: 'In Garage',
  imagePath: '/path/to/hammer.jpg',
)

// List tile card
AppListTileCard(
  leading: Icon(Icons.location_on),
  title: 'Garage',
  trailing: Icon(Icons.chevron_right),
  onTap: () => _selectLocation(),
)
```

### Design Features

- 1px thin border (minimal aesthetic)
- Subtle elevation (1-2 for light theme)
- Rounded corners (AppSpacing.md)
- White surface with subtle shadow
- Proper inkwell effect for taps
- Placeholder support for missing images
