import 'package:flutter/material.dart';
import '../domain/entities/container.dart' as domain;
import '../domain/entities/item.dart';
import '../domain/entities/location.dart';
import '../domain/repositories/container_repository.dart';
import '../domain/repositories/item_repository.dart';
import '../data/repositories/container_repository_impl.dart';
import '../data/repositories/item_repository_impl.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/card.dart';

// ================================
// CONTENTS SOURCE SEALED CLASS
// ================================

/// Sealed class representing the source of contents to display.
///
/// Allows the same ContentsScreen to work with both Locations and Containers
/// as the source of nested containers and items.
sealed class ContentsSource {
  const ContentsSource();

  /// Accepts a visitor pattern for handling different source types.
  T accept<T>(ContentsSourceVisitor<T> visitor);
}

/// Visitor interface for ContentsSource.
///
/// Provides type-safe handling of different source types.
abstract class ContentsSourceVisitor<T> {
  T visitLocation(LocationSource source);
  T visitContainer(ContainerSource source);
}

/// Location as a source for contents.
///
/// Used to display all containers and items directly within a location.
class LocationSource extends ContentsSource {
  /// The location whose contents to display.
  final Location location;

  const LocationSource(this.location);

  @override
  T accept<T>(ContentsSourceVisitor<T> visitor) => visitor.visitLocation(this);
}

/// Container as a source for contents.
///
/// Used to display all child containers and items within a container.
class ContainerSource extends ContentsSource {
  /// The container whose contents to display.
  final domain.Container container;

  const ContainerSource(this.container);

  @override
  T accept<T>(ContentsSourceVisitor<T> visitor) => visitor.visitContainer(this);
}

// ================================
// CONTENTS SCREEN
// ================================

/// Reusable screen for displaying contents of a location or container.
///
/// Shows:
/// - Child containers grouped by type
/// - Items directly stored in the source
/// - Loading and error states
/// - Navigation to nested container contents
class ContentsScreen extends StatefulWidget {
  /// The source of contents to display.
  final ContentsSource source;

  const ContentsScreen({
    super.key,
    required this.source,
  });

  @override
  State<ContentsScreen> createState() => _ContentsScreenState();
}

class _ContentsScreenState extends State<ContentsScreen> {
  late final ContainerRepository _containerRepository;
  late final ItemRepository _itemRepository;

  // State
  List<domain.Container> _containers = [];
  List<Item> _items = [];
  Map<int, int> _containerItemCount = {}; // container_id -> item count
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _containerRepository = ContainerRepositoryImpl();
    _itemRepository = ItemRepositoryImpl();
    _loadContents();
  }

  /// Loads containers and items based on the source type.
  Future<void> _loadContents() async {
    try {
      final loader = _ContentsLoader(
        containerRepository: _containerRepository,
        itemRepository: _itemRepository,
      );

      final contents = await widget.source.accept(loader);

      // Calculate item count for each container
      final itemCounts = <int, int>{};
      for (final item in contents.items) {
        if (item.containerId != null) {
          itemCounts[item.containerId!] = (itemCounts[item.containerId!] ?? 0) + 1;
        }
      }

      setState(() {
        _containers = contents.containers;
        _items = contents.items;
        _containerItemCount = itemCounts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Navigates to the contents of a container.
  void _navigateToContainerContents(domain.Container container) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentsScreen(
          source: ContainerSource(container),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sourceInfo = widget.source.accept(
      _SourceInfoExtractor(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(sourceInfo.title),
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _ErrorView(
        error: _error!,
        onRetry: _loadContents,
      );
    }

    if (_containers.isEmpty && _items.isEmpty) {
      return _EmptyView(
        sourceName: widget.source.accept(_SourceInfoExtractor()).title,
      );
    }

    return ListView(
      padding: AppSpacing.pageMargins,
      children: [
        // Containers in 2-column grid
        if (_containers.isNotEmpty) ...[
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _containers.map((container) {
              return SizedBox(
                width: (MediaQuery.of(context).size.width -
                        (AppSpacing.md * 2) -
                        (AppSpacing.sm)) /
                    2,
                child: ContainerCard(
                  name: container.name,
                  description: container.description,
                  typeAbbreviation: container.typeAbbreviation,
                  itemCount: _containerItemCount[container.id] ?? 0,
                  onTap: () => _navigateToContainerContents(container),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        // Items section with header
        if (_items.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              'Items',
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontWeight: AppTypography.weightSemiBold,
              ),
            ),
          ),
          ..._items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard.item(
                  name: item.name,
                  description: item.description,
                ),
              )),
        ],
      ],
    );
  }
}

// ================================
// INTERNAL CLASSES
// ================================

/// Data class for loaded contents.
class _LoadedContents {
  final List<domain.Container> containers;
  final List<Item> items;

  const _LoadedContents({
    this.containers = const [],
    this.items = const [],
  });
}

/// Loader that fetches contents based on source type.
class _ContentsLoader implements ContentsSourceVisitor<Future<_LoadedContents>> {
  final ContainerRepository containerRepository;
  final ItemRepository itemRepository;

  const _ContentsLoader({
    required this.containerRepository,
    required this.itemRepository,
  });

  @override
  Future<_LoadedContents> visitLocation(LocationSource source) async {
    final containers = await containerRepository.getByLocationId(source.location.id);
    final items = await itemRepository.getByLocationId(source.location.id);
    return _LoadedContents(
      containers: containers,
      items: items,
    );
  }

  @override
  Future<_LoadedContents> visitContainer(ContainerSource source) async {
    final containers = await containerRepository.getByParentContainerId(source.container.id);
    final items = await itemRepository.getByContainerId(source.container.id);
    return _LoadedContents(
      containers: containers,
      items: items,
    );
  }
}

/// Extracts display information from a source.
class _SourceInfoExtractor implements ContentsSourceVisitor<_SourceInfo> {
  @override
  _SourceInfo visitLocation(LocationSource source) {
    return _SourceInfo(
      title: source.location.name,
      subtitle: source.location.description,
    );
  }

  @override
  _SourceInfo visitContainer(ContainerSource source) {
    return _SourceInfo(
      title: source.container.name,
      subtitle: source.container.description,
    );
  }
}

/// Information about a source for display.
class _SourceInfo {
  final String title;
  final String? subtitle;

  const _SourceInfo({
    required this.title,
    this.subtitle,
  });
}

// ================================
// WIDGETS
// ================================

/// Error view with retry option.
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: AppSpacing.pageMargins,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Something went wrong',
              style: AppTypography.h5.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state view.
class _EmptyView extends StatelessWidget {
  final String sourceName;

  const _EmptyView({required this.sourceName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: AppSpacing.pageMargins,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No contents yet',
              style: AppTypography.h5.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This $sourceName is empty.',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
