# Task 2.1.8: Create Reusable ImagePicker Component

**Task ID:** 2.1.8
**Status:** ⏸ Pending
**Date:** 2025-02-01
**Estimated Hours:** 4
**Actual Hours:** -

## Description

Create a reusable ImagePicker component that opens camera/gallery and returns the selected file path.

## Acceptance Criteria

- [ ] Opens camera
- [ ] Opens gallery
- [ ] Returns file path
- [ ] Handles permissions
- [ ] Shows image preview
- [ ] Handles errors

## Implementation Details

**Note:** This task requires camera and gallery permissions, which will be implemented in a future phase when photo handling is needed (Week 3: Location CRUD).

**Plan:**
- Use `image_picker` package
- Handle platform-specific permissions
- Support both camera and gallery sources
- Return File path for storage
- Error handling for denied permissions

**Dependency:**
```yaml
image_picker: ^1.0.4
```

## Status

Deferred to Week 3 when photo capture is implemented for locations and items.
