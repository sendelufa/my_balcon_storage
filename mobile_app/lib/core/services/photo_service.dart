import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'photo_service_interface.dart';

/// Service for handling photo capture, selection, compression, and storage
/// Mobile implementation (Android/iOS)
class PhotoService implements PhotoServiceInterface {
  PhotoService._();

  static final PhotoService _instance = PhotoService._();

  /// Get the singleton instance
  static PhotoService get instance => _instance;

  static final Uuid _uuid = Uuid();
  static final ImagePicker _picker = ImagePicker();

  // Photo constraints
  static const int maxPhotoSizeBytes = 1024 * 1024; // 1MB
  static const int maxPhotoWidth = 1920;
  static const int maxPhotoHeight = 1920;
  static const int defaultQuality = 85;

  @override
  bool get isCameraAvailable => true;

  /// Capture photo from camera
  @override
  Future<String?> captureFromCamera() async {
    // Check camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      throw PhotoException('Camera permission denied');
    }

    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: maxPhotoWidth.toDouble(),
      maxHeight: maxPhotoHeight.toDouble(),
      imageQuality: defaultQuality,
    );

    if (photo == null) return null;

    // Compress and save
    return await _processAndSavePhoto(File(photo.path));
  }

  /// Pick photo from gallery
  @override
  Future<String?> pickFromGallery() async {
    // Check photo library permission
    var status = await Permission.photos.request();
    if (!status.isGranted) {
      // Fallback to storage permission for older Android versions
      status = await Permission.storage.request();
    }

    if (!status.isGranted) {
      throw PhotoException('Photo library permission denied');
    }

    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxPhotoWidth.toDouble(),
      maxHeight: maxPhotoHeight.toDouble(),
      imageQuality: defaultQuality,
    );

    if (photo == null) return null;

    // Compress and save
    return await _processAndSavePhoto(File(photo.path));
  }

  /// Process and save photo to app directory
  Future<String> _processAndSavePhoto(File imageFile) async {
    try {
      // Read the image
      final bytes = await imageFile.readAsBytes();
      img.Image? decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        throw PhotoException('Failed to decode image');
      }

      // Compress if needed
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

      // Save to app directory
      final savedPath = await _savePhoto(compressedBytes);

      // Delete temp file if different from source
      if (await imageFile.exists() && imageFile.path != savedPath) {
        try {
          await imageFile.delete();
        } catch (e) {
          // Ignore error
        }
      }

      return savedPath;
    } catch (e) {
      throw PhotoException('Failed to process photo: $e');
    }
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

  /// Save photo bytes to app documents directory
  Future<String> _savePhoto(Uint8List bytes) async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${appDir.path}/photos');

    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final fileName = '${_uuid.v4()}.jpg';
    final filePath = path.join(photosDir.path, fileName);
    final file = File(filePath);

    await file.writeAsBytes(bytes);
    return filePath;
  }

  /// Delete photo file from storage
  @override
  Future<void> deletePhoto(String? photoPath) async {
    if (photoPath == null || photoPath.isEmpty) return;

    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Log error but don't throw - photo deletion is not critical
      // ignore: avoid_print
      print('Warning: Failed to delete photo: $e');
    }
  }

  /// Get full file URL for display
  @override
  Future<String> getPhotoUrl(String photoPath) async {
    return photoPath;
  }

  /// Check if photo exists
  @override
  Future<bool> photoExists(String photoPath) async {
    try {
      final file = File(photoPath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get photo file size in bytes
  @override
  Future<int> getPhotoSize(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Check if camera permission is granted
  @override
  Future<bool> isCameraPermissionGranted() async {
    return await Permission.camera.isGranted;
  }

  /// Check if photo library permission is granted
  @override
  Future<bool> isPhotoLibraryPermissionGranted() async {
    return await Permission.photos.isGranted ||
           await Permission.storage.isGranted;
  }

  /// Clear all photos from the photos directory
  @override
  Future<int> clearAllPhotos() async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${appDir.path}/photos');

    if (!await photosDir.exists()) return 0;

    int count = 0;
    try {
      await for (final entity in photosDir.list()) {
        if (entity is File) {
          await entity.delete();
          count++;
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Warning: Error clearing photos: $e');
    }

    return count;
  }

  /// Get total storage used by photos in bytes
  @override
  Future<int> getPhotosStorageSize() async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${appDir.path}/photos');

    if (!await photosDir.exists()) return 0;

    int totalSize = 0;
    try {
      await for (final entity in photosDir.list()) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Warning: Error calculating photos size: $e');
    }

    return totalSize;
  }
}
