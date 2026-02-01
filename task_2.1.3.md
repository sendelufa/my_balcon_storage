# Task 2.1.3: Define Spacing System

**Task ID:** 2.1.3
**Status:** ✅ Completed
**Date:** 2025-02-01
**Estimated Hours:** 1
**Actual Hours:** 1

## Description

Define the spacing system using a 4px base unit for margins, padding, and gaps throughout the app.

## Acceptance Criteria

- [x] 4px base unit defined
- [x] Spacing constants defined
- [x] Padding/margin constants
- [x] Border radius values
- [x] Gap helpers for widgets

## Implementation Details

### File Created

**`app/lib/theme/spacing.dart`** (~290 lines)

### Spacing System

**Base Unit:** 4px

**Spacing Constants:**
- xs: 4px (0.25rem)
- sm: 8px (0.5rem)
- md: 16px (1rem)
- lg: 24px (1.5rem)
- xl: 32px (2rem)
- xxl: 40px (2.5rem)
- huge: 48px (3rem)

**Border Radius:**
- xs: 2px
- sm: 4px
- md: 8px
- lg: 12px
- xl: 16px
- xxl: 24px
- circle: 9999px (for perfectly rounded)

**EdgeInsets Constants:**
- allXs: 4px on all sides
- allSm: 8px on all sides
- allMd: 16px on all sides
- etc.

**SizedBox Helpers:**
- gapXs, gapSm, gapMd, gapLg, gapXl for spacing between widgets
- vGapXs, vGapSm, etc. for vertical gaps

## Design Decisions

1. **4px Grid**: Standard 4px base unit for consistent spacing
2. **8-point Grid**: All spacing multiples of 4px (practically 8px)
3. **Material 3 Compatible**: Aligns with Material Design 3 spacing
4. **Convenience Methods**: Helper methods reduce repetitive code
5. **Minimal Design**: Smaller gaps and padding for thin, minimal aesthetic
