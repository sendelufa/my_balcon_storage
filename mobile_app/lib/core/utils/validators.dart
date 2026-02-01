/// Validator utilities for user input
class Validators {
  Validators._();

  /// Validates a name field
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 1) {
      return 'Name must be at least 1 character';
    }
    if (trimmed.length > 100) {
      return 'Name must be less than 100 characters';
    }
    return null;
  }

  /// Validates a description field
  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Description is optional
    }
    final trimmed = value.trim();
    if (trimmed.length > 500) {
      return 'Description must be less than 500 characters';
    }
    return null;
  }

  /// Validates if a location ID is selected
  static String? validateLocationId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Location is required';
    }
    return null;
  }

  /// Sanitizes text input
  static String sanitize(String value) {
    return value.trim();
  }

  /// Truncates text to a maximum length
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
