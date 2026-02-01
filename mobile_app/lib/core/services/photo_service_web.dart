import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'photo_service_interface.dart';
import 'package:flutter/foundation.dart';

/// Service for handling photo selection and storage on web
/// Web implementation using browser APIs
class PhotoServiceWeb implements PhotoServiceInterface {
  PhotoServiceWeb._();

  static final PhotoServiceWeb _instance = PhotoServiceWeb._();

  /// Get the singleton instance
  static PhotoServiceWeb get instance => _instance;

  static final Uuid _uuid = const Uuid();
  static final ImagePicker _picker = ImagePicker();

  // Photo constraints
  static const int maxPhotoSizeBytes = 1024 * 1024; // 1MB
  static const int maxPhotoWidth = 1920;
  static const int maxPhotoHeight = 1920;
  static const int defaultQuality = 85;

  // In-memory storage for web (uses IndexedDB under the hood via sqflite_common_ffi)
  final Map<String, Uint8List> _photoCache = {};

  @override
  bool get isCameraAvailable => kIsWeb ? false : true;

  /// Capture photo from camera - not available on web
  @override
  Future<String?> captureFromCamera() async {
    if (kIsWeb) {
      throw PhotoException('Camera capture is not available on web. Please use file upload.');
    }

    // For non-web platforms, this shouldn't be called, but handle it anyway
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: maxPhotoWidth.toDouble(),
      maxHeight: maxPhotoHeight.toDouble(),
      imageQuality: defaultQuality,
    );

    if (photo == null) return null;

    // Read and process the image
    final bytes = await photo.readAsBytes();
    return await _savePhotoBytes(bytes);
  }

  /// Pick photo from gallery/file picker
  @override
  Future<String?> pickFromGallery() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxPhotoWidth.toDouble(),
      maxHeight: maxPhotoHeight.toDouble(),
      imageQuality: defaultQuality,
    );

    if (photo == null) return null;

    try {
      // Read the image bytes
      final bytes = await photo.readAsBytes();

      // Compress if needed
      final compressedBytes = await _compressIfNeeded(bytes);

      // Save to cache
      return await _savePhotoBytes(compressedBytes);
    } catch (e) {
      throw PhotoException('Failed to process photo: $e');
    }
  }

  /// Compress image if it exceeds size limits
  Future<Uint8List> _compressIfNeeded(Uint8List bytes) async {
    // If already under limit, return as-is
    if (bytes.length <= maxPhotoSizeBytes) {
      return bytes;
    }

    // Decode and compress
    img.Image? decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) {
      throw PhotoException('Failed to decode image');
    }

    // Try reducing quality first
    Uint8List compressedBytes = _compressImage(decodedImage, defaultQuality);

    // If still too large, reduce quality and resize
    if (compressedBytes.length > maxPhotoSizeBytes) {
      final resizedImage = _resizeImage(decodedImage);
      compressedBytes = _compressImage(resizedImage, 70);

      // If still too large, reduce further
      if (compressedBytes.length > maxPhotoSizeBytes) {
        compressedBytes = _compressImage(resizedImage, 50);
      }
    }

    return compressedBytes;
  }

  /// Compress image with given quality
  Uint8List _compressImage(img.Image image, int quality) {
    return Uint8List.fromList(img.encodeJpg(image, quality: quality));
  }

  /// Resize image to fit within max dimensions
  img.Image _resizeImage(img.Image image) {
    int width = image.width;
    int height = image.height;

    if (width <= maxPhotoWidth && height <= maxPhotoHeight) {
      return image;
    }

    // Calculate new dimensions maintaining aspect ratio
    if (width > height) {
      final ratio = maxPhotoWidth / width;
      width = maxPhotoWidth;
      height = (height * ratio).round();
    } else {
      final ratio = maxPhotoHeight / height;
      height = maxPhotoHeight;
      width = (width * ratio).round();
    }

    return img.copyResize(
      image,
      width: width,
      height: height,
      interpolation: img.Interpolation.linear,
    );
  }

  /// Save photo bytes to cache (on web, stores in memory - could be persisted to IndexedDB)
  Future<String> _savePhotoBytes(Uint8List bytes) async {
    final fileName = '${_uuid.v4()}.jpg';
    _photoCache[fileName] = bytes;
    return fileName;
  }

  /// Get photo bytes from cache
  Uint8List? getPhotoBytes(String fileName) {
    return _photoCache[fileName];
  }

  /// Delete photo file from storage
  @override
  Future<void> deletePhoto(String? photoPath) async {
    if (photoPath == null || photoPath.isEmpty) return;
    _photoCache.remove(photoPath);
  }

  /// Get full file URL for display - on web, return the file name
  @override
  Future<String> getPhotoUrl(String photoPath) async {
    return photoPath;
  }

  /// Check if photo exists
  @override
  Future<bool> photoExists(String photoPath) async {
    return _photoCache.containsKey(photoPath);
  }

  /// Get photo file size in bytes
  @override
  Future<int> getPhotoSize(String photoPath) async {
    final bytes = _photoCache[photoPath];
    return bytes?.length ?? 0;
  }

  /// Check if camera permission is granted (not applicable on web)
  @override
  Future<bool> isCameraPermissionGranted() async {
    return true; // Not applicable on web
  }

  /// Check if photo library permission is granted (not applicable on web)
  @override
  Future<bool> isPhotoLibraryPermissionGranted() async {
    return true; // Not applicable on web
  }

  /// Clear all photos from storage
  @override
  Future<int> clearAllPhotos() async {
    final count = _photoCache.length;
    _photoCache.clear();
    return count;
  }

  /// Get total storage used by photos in bytes
  @override
  Future<int> getPhotosStorageSize() async {
    int totalSize = 0;
    for (final bytes in _photoCache.values) {
      totalSize += bytes.length;
    }
    return totalSize;
  }

  /// Get all cached photos (for debugging/backup)
  Map<String, Uint8List> get cachedPhotos => Map.unmodifiable(_photoCache);
}
