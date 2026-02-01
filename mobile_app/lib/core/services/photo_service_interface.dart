/// Abstract photo service interface for platform-agnostic photo operations
abstract class PhotoServiceInterface {
  /// Capture photo from camera (not available on web)
  Future<String?> captureFromCamera();

  /// Pick photo from gallery
  Future<String?> pickFromGallery();

  /// Delete photo file from storage
  Future<void> deletePhoto(String? photoPath);

  /// Get full file URL for display
  Future<String> getPhotoUrl(String photoPath);

  /// Check if photo exists
  Future<bool> photoExists(String photoPath);

  /// Get photo file size in bytes
  Future<int> getPhotoSize(String photoPath);

  /// Clear all photos from storage
  Future<int> clearAllPhotos();

  /// Get total storage used by photos in bytes
  Future<int> getPhotosStorageSize();

  /// Check if camera permission is granted (mobile only)
  Future<bool> isCameraPermissionGranted();

  /// Check if photo library permission is granted (mobile only)
  Future<bool> isPhotoLibraryPermissionGranted();

  /// Check if camera is available on this platform
  bool get isCameraAvailable;
}

/// Photo exception class
class PhotoException implements Exception {
  final String message;
  const PhotoException(this.message);

  @override
  String toString() => message;
}
