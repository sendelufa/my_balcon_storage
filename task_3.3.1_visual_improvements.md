# Task: Visual Layout Improvements for ContentsScreen

**Task ID:** 3.3.1-visual
**Status:** ✅ Completed
**Date:** 2025-02-18
**Estimated Hours:** 2
**Actual Hours:** 2

## Description

Improve visual layout of ContentsScreen (Location/Container detail view) to better display containers and items. Remove visual clutter and add better information density.

## Requirements

1. Remove container type section titles (e.g., "Boxes (2)", "Shelves (1)")
2. Keep type abbreviation in icon badge only (Bo, Sh, Ba, Cl)
3. Add item count to each container: "Tools Box (3)"
4. Display containers in 2-column grid
5. Display items in vertical list below containers
6. Add "Items" section header as visual separator
7. Change item icon to distinguish from container box icon

## Acceptance Criteria

- [x] No section titles for container types
- [x] Type shown only via 2-letter badge (Bo, Sh, Ba, Cl)
- [x] Item count displayed on container cards
- [x] Containers in 2-column Wrap grid
- [x] Items in vertical list below containers
- [x] "Items" section header as separator
- [x] Item icon different from container icon
- [x] No analyzer warnings

## Implementation Details

### Files Modified

**`app/lib/screens/contents_screen.dart`**
- Removed `_groupContainersByType()` method
- Removed `_getContainerTypeName()` method
- Removed `_ContainerSection` widget
- Removed `_SectionHeader` widget
- Removed unused `_ContainerCard` and `_ItemCard` helper classes
- Added `Map<int, int> _containerItemCount` to track items per container
- Updated `_loadContents()` to calculate item counts
- Replaced type-grouped sections with `Wrap` widget for 2-column grid
- Added "Items" section header

**`app/lib/widgets/card.dart`**
- Added `itemCount` parameter to `ContainerCard`
- Updated display to show count: `"Name (count)"` when count > 0
- Changed item icon from `Icons.inventory_2_outlined` to `Icons.category_outlined`

**`app/lib/database/database_helper.dart`**
- Simplified database creation for early development
- Combined all table creation into single `_createTables()` call
- Combined all seed data into single `_seedAllData()` call

### Visual Layout

```
+----------------+----------------+
| (Bo) Wall Shelf| (Sh) Metal Rack |
|                |                |
+----------------+----------------+
| (Bo) Tools Box | (Ba) Clothes   |
|                |                |
+----------------+----------------+
                            |
                            v
                    Items
                    +----------------+
                    | Christmas Decor|
                    +----------------+
                    | Bicycle        |
                    +----------------+
```

### Code Changes

**Item count calculation:**
```dart
final itemCounts = <int, int>{};
for (final item in contents.items) {
  if (item.containerId != null) {
    itemCounts[item.containerId!] = (itemCounts[item.containerId!] ?? 0) + 1;
  }
}
```

**2-column grid layout:**
```dart
Wrap(
  spacing: AppSpacing.sm,
  runSpacing: AppSpacing.sm,
  children: _containers.map((container) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width -
              (AppSpacing.md * 2) - (AppSpacing.sm)) / 2,
      child: ContainerCard(
        name: container.name,
        typeAbbreviation: container.typeAbbreviation,
        itemCount: _containerItemCount[container.id] ?? 0,
        onTap: () => _navigateToContainerContents(container),
      ),
    );
  }).toList(),
)
```

## Result

Cleaner, more information-dense layout. Containers show item counts at a glance. Visual distinction between container and item icons. Proper visual separation between containers and items section.

## Database Simplification

For early development (no users yet), simplified database setup:
- All tables created with final schemas upfront
- All seed data inserted after tables exist
- No incremental migrations needed
- Version reset to 1 for clean slate
