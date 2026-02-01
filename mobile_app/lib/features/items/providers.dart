import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storage_app/core/models/item.dart';
import 'package:storage_app/data/repositories/item_repository.dart';

/// Items state for a specific location
class ItemsState {
  final List<Item> items;
  final bool isLoading;
  final String? error;

  const ItemsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  ItemsState copyWith({
    List<Item>? items,
    bool? isLoading,
    String? error,
  }) {
    return ItemsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Items state notifier for a specific location
class ItemsNotifier extends StateNotifier<ItemsState> {
  final ItemRepository _repository;
  final String locationId;

  ItemsNotifier(this._repository, this.locationId) : super(const ItemsState());

  /// Load items for the location
  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final items = await _repository.getItemsByLocation(locationId);
      state = state.copyWith(isLoading: false, items: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Create a new item
  Future<bool> createItem({
    required String name,
    String? description,
    String? photoPath,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final item = Item(
        id: _generateId(),
        name: name,
        description: description,
        photoPath: photoPath,
        locationId: locationId,
        createdAt: now,
        updatedAt: now,
        sortOrder: state.items.length,
      );

      await _repository.createItem(item);
      await loadItems();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Update an existing item
  Future<bool> updateItem(Item item) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _repository.updateItem(item);
      if (success) {
        await loadItems();
      }
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Update item photo
  Future<bool> updatePhoto(String id, String? photoPath) async {
    try {
      return await _repository.updateItemPhoto(id, photoPath);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Delete an item
  Future<bool> deleteItem(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _repository.deleteItem(id);
      if (success) {
        await loadItems();
      }
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
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

/// Items by location state notifier provider
final itemsByLocationProvider = StateNotifierProvider.family<ItemsNotifier, ItemsState, String>((ref, locationId) {
  final repository = ref.watch(itemRepositoryProvider);
  return ItemsNotifier(repository, locationId);
});

/// All items provider (for search)
final allItemsProvider = FutureProvider.autoDispose<List<Item>>((ref) async {
  final repository = ref.watch(itemRepositoryProvider);
  return await repository.getAllItems();
});

/// Item repository provider
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository();
});
