import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storage_app/core/models/search_result.dart';
import 'package:storage_app/data/repositories/search_repository.dart';

/// Search repository provider
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository();
});

/// Search state
class SearchState {
  final String query;
  final List<SearchResult> results;
  final bool isSearching;
  final String? error;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<SearchResult>? results,
    bool? isSearching,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      error: error,
    );
  }

  bool get hasQuery => query.trim().isNotEmpty;
  bool get hasResults => results.isNotEmpty;
}

/// Search state notifier
class SearchNotifier extends StateNotifier<SearchState> {
  final SearchRepository _repository;

  SearchNotifier(this._repository) : super(const SearchState());

  /// Update the search query
  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }

  /// Perform search
  Future<void> search() async {
    final query = state.query.trim();

    if (query.isEmpty) {
      state = state.copyWith(results: [], isSearching: false, error: null);
      return;
    }

    state = state.copyWith(isSearching: true, error: null);

    try {
      final results = await _repository.search(query);
      state = state.copyWith(
        isSearching: false,
        results: results,
      );
    } catch (e) {
      state = state.copyWith(isSearching: false, error: e.toString());
    }
  }

  /// Clear the search
  void clear() {
    state = const SearchState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Search state notifier provider
final searchNotifierProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return SearchNotifier(repository);
});

/// Debounced search provider
final debouncedSearchProvider = Provider.autoDispose<void Function(String)>((ref) {
  final notifier = ref.watch(searchNotifierProvider.notifier);

  return (String query) {
    notifier.updateQuery(query);
    notifier.search();
  };
});
