import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storage_app/core/models/location.dart';
import 'package:storage_app/data/repositories/location_repository.dart';
import 'package:storage_app/data/repositories/item_repository.dart';

/// Location repository provider
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository();
});

/// Item repository provider (re-exported for convenience)
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository();
});

/// Locations state
class LocationsState {
  final List<Location> locations;
  final bool isLoading;
  final String? error;

  const LocationsState({
    this.locations = const [],
    this.isLoading = false,
    this.error,
  });

  LocationsState copyWith({
    List<Location>? locations,
    bool? isLoading,
    String? error,
  }) {
    return LocationsState(
      locations: locations ?? this.locations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Locations state notifier
class LocationsNotifier extends StateNotifier<LocationsState> {
  final LocationRepository _repository;

  LocationsNotifier(this._repository) : super(const LocationsState()) {
    loadLocations();
  }

  /// Load all locations
  Future<void> loadLocations() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final locations = await _repository.getAllLocations();
      state = state.copyWith(isLoading: false, locations: locations);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Create a new location
  Future<bool> createLocation({
    required String name,
    String? description,
    String? photoPath,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final location = Location(
        id: _generateId(),
        name: name,
        description: description,
        photoPath: photoPath,
        createdAt: now,
        updatedAt: now,
        sortOrder: state.locations.length,
      );

      await _repository.createLocation(location);
      await loadLocations();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Update an existing location
  Future<bool> updateLocation(Location location) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _repository.updateLocation(location);
      if (success) {
        await loadLocations();
      }
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Update location photo
  Future<bool> updatePhoto(String id, String? photoPath) async {
    try {
      return await _repository.updateLocationPhoto(id, photoPath);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Delete a location
  Future<bool> deleteLocation(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _repository.deleteLocation(id);
      if (success) {
        await loadLocations();
      }
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Get a location by ID
  Location? getLocationById(String id) {
    try {
      return state.locations.firstWhere((loc) => loc.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

/// Locations provider
final locationsProvider = StateNotifierProvider<LocationsNotifier, LocationsState>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  return LocationsNotifier(repository);
});

/// Individual location provider
final locationProvider = Provider.family<Location?, String>((ref, id) {
  final state = ref.watch(locationsProvider);
  return state.locations.where((loc) => loc.id == id).firstOrNull;
});

/// Location with items provider (for detail view)
final locationWithItemsProvider = FutureProvider.family<LocationWithItems, String>((ref, id) async {
  final locationRepo = ref.watch(locationRepositoryProvider);
  final location = await locationRepo.getLocationById(id);

  if (location == null) {
    throw Exception('Location not found');
  }

  // Get items for this location
  final itemRepo = ref.read(itemRepositoryProvider);
  final items = await itemRepo.getItemsByLocation(id);

  return LocationWithItems(location: location, items: items);
});

/// Location with items wrapper
class LocationWithItems {
  final Location location;
  final List<dynamic> items;

  const LocationWithItems({
    required this.location,
    required this.items,
  });
}
