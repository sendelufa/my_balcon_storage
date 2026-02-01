# Task: Visual Layout Improvements for ContentsScreen

**Date:** 2025-02-18

## Requirements

1. Remove container type section titles (e.g., "Boxes (2)", "Shelves (1)")
2. Keep type abbreviation in icon badge only (Bo, Sh, Ba, Cl)
3. Add item count to each container: "Tools Box (3)"
4. Display containers in 2-column grid
5. Display items in vertical list below containers
6. Add "Items" section header as visual separator
7. Change item icon to distinguish from container box icon

## Changes Made

### lib/screens/contents_screen.dart

- Removed `_groupContainersByType()` method
- Removed `_getContainerTypeName()` method
- Removed `_ContainerSection` widget
- Removed `_SectionHeader` widget
- Removed unused `_ContainerCard` and `_ItemCard` helper classes
- Added `Map<int, int> _containerItemCount` to track items per container
- Updated `_loadContents()` to calculate item counts for containers
- Replaced type-grouped sections with `Wrap` widget for 2-column grid layout
- Added "Items" section header with proper styling

### lib/widgets/card.dart

- Added `itemCount` parameter to `ContainerCard`
- Updated display to show count in name: `"Name (count)"` when count > 0
- Changed item placeholder icon from `Icons.inventory_2_outlined` (box-like) to `Icons.category_outlined` (tag-like)

### lib/database/database_helper.dart

- Simplified database creation for early development (no users)
- Combined all table creation into single `_createTables()` call
- Combined all seed data into single `_seedAllData()` call
- Reset version to 1 for clean slate

### lib/database/schema.dart

- Reset version to 1

## Result

- Containers display in 2-column grid with type badge and item count
- Items display in vertical list below with "Items" section header
- Visual distinction between container and item icons
- No analyzer warnings

## Screenshot

```
+----------------+----------------+
| [Bo] Wall Shelf| [Sh] Metal Rack |
|                |                |
+----------------+----------------+
| [Bo] Tools Box | [Ba] Clothes   |
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
