# Task 2.1.1: Define Color Palette

**Task ID:** 2.1.1
**Status:** ✅ Completed
**Date:** 2025-02-01
**Estimated Hours:** 2
**Actual Hours:** 2

## Description

Define the color palette for the Storage App based on the moodboard design. The primary accent color (teal/cyan) was selected from the moodboard at `moodboard/design/colors and style.png`.

## Acceptance Criteria

- [x] Color palette defined in code
- [x) Primary color from moodboard (teal/cyan)
- [x] Secondary color defined
- [x] Background colors (light/dark themes)
- [x] Text colors (primary, secondary, disabled, error)
- [x] Surface colors
- [x] Support for future accent color customization

## Implementation Details

### File Created

**`app/lib/theme/colors.dart`** (~270 lines)

### Color System

**Accent Color (from moodboard):**
- Primary: `#00BCD4` (Teal/Cyan)
- Light: `#4DD0E1`
- Dark: `#0097A7`

**Secondary Color:**
- Purple: `#7E57C2`

**Neutral Colors:**
- Gray scale from 50 to 900 for both light and dark themes

**Background Colors:**
- Light: White (`#FFFFFF`)
- Dark: Dark gray (`#121212`)

**Text Colors:**
- Primary: High contrast for headings
- Secondary: Medium contrast for body
- Disabled: Low contrast for inactive elements

**State Colors:**
- Error: Red (`#B00020`)
- Success: Green (`#4CAF50`)
- Warning: Orange (`#FF9800`)
- Info: Blue (`#2196F3`)

**Future Feature - Accent Color Customization:**
- `accentColors` map for defining different accent colors per location or item type
- Examples provided: home, garage, attic, basement, outdoor, tools, electronics, etc.

## Design Decisions

1. **Teal/Cyan Accent**: Matches moodboard selection for clean, modern look
2. **Material 3**: Uses Material Design 3 color system
3. **Dark Mode**: Full dark theme support from the start
4. **Extensibility**: Accent color system ready for future customization
5. **Semantic Names**: Colors named by purpose (primary, secondary, error, etc.)
