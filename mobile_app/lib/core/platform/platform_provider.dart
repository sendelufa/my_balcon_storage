import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_interface.dart';
import '../database/database_service.dart';
import '../database/database_service_web.dart';
import '../services/photo_service_interface.dart';
import '../services/photo_service.dart';
import '../services/photo_service_web.dart';

/// Platform-aware provider factory
/// Returns the appropriate implementation based on the current platform
class PlatformProvider {
  // Singleton instances
  static DatabaseInterface? _database;
  static PhotoServiceInterface? _photoService;

  /// Get the appropriate database implementation for the current platform
  static DatabaseInterface getDatabase() {
    _database ??= kIsWeb ? DatabaseServiceWeb() : DatabaseService();
    return _database!;
  }

  /// Get the appropriate photo service implementation for the current platform
  static PhotoServiceInterface getPhotoService() {
    _photoService ??= kIsWeb ? PhotoServiceWeb.instance : PhotoService.instance;
    return _photoService!;
  }

  /// Check if running on web platform
  static bool get isWeb => kIsWeb;

  /// Check if running on mobile platform
  static bool get isMobile => !kIsWeb;

  /// Reset instances (useful for testing)
  static void reset() {
    _database = null;
    _photoService = null;
  }
}

/// Database provider for Riverpod
final databaseProvider = Provider<DatabaseInterface>((ref) {
  return PlatformProvider.getDatabase();
});

/// Photo service provider for Riverpod
final photoServiceProvider = Provider<PhotoServiceInterface>((ref) {
  return PlatformProvider.getPhotoService();
});
