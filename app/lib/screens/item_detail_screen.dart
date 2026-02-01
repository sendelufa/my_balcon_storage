import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../domain/entities/item.dart';
import '../domain/entities/location.dart';
import '../domain/entities/container.dart' as domain;
import '../domain/repositories/item_repository.dart';
import '../domain/repositories/location_repository.dart';
import '../domain/repositories/container_repository.dart';
import '../data/repositories/item_repository_impl.dart';
import '../data/repositories/location_repository_impl.dart';
import '../data/repositories/container_repository_impl.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/button.dart';
import 'contents_screen.dart';

/// Breadcrumb item representing a level in the hierarchy.
class BreadcrumbItem {
  /// Display name for this breadcrumb level.
  final String name;

  /// The location at this level (if any).
  final Location? location;

  /// The container at this level (if any).
  final domain.Container? container;

  const BreadcrumbItem({
    required this.name,
    this.location,
    this.container,
  });
}

/// Item detail screen displaying full item information.
///
/// Shows:
/// - Full-width item photo with date badge overlay (tap to zoom)
/// - Breadcrumb navigation (Location > Container > Sub-container)
/// - Item title and description
/// - Edit and Delete action buttons
///
/// Accepts either an [Item] instance or an [itemId] to fetch.
class ItemDetailScreen extends StatefulWidget {
  /// The item to display. If provided, [itemId] is ignored.
  final Item? item;

  /// The ID of the item to fetch. Ignored if [item] is provided.
  final int? itemId;

  const ItemDetailScreen({
    super.key,
    this.item,
    this.itemId,
  }) : assert(item != null || itemId != null, 'Either item or itemId must be provided');

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late final ItemRepository _itemRepository;
  late final LocationRepository _locationRepository;
  late final ContainerRepository _containerRepository;

  // State
  Item? _item;
  List<BreadcrumbItem> _breadcrumbs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _itemRepository = ItemRepositoryImpl();
    _locationRepository = LocationRepositoryImpl();
    _containerRepository = ContainerRepositoryImpl();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Get item either from widget or fetch by ID
      final item = widget.item ?? await _itemRepository.getById(widget.itemId!);
      if (item == null) {
        setState(() {
          _error = 'Item not found';
          _isLoading = false;
        });
        return;
      }

      // Fetch location details
      final location = await _locationRepository.getById(item.locationId);
      if (location == null) {
        setState(() {
          _item = item;
          _isLoading = false;
        });
        return;
      }

      // Build breadcrumbs
      final breadcrumbs = <BreadcrumbItem>[
        BreadcrumbItem(name: location.name, location: location),
      ];

      // If item has a container, fetch the full hierarchy
      if (item.containerId != null) {
        final containerPath = await _getContainerPath(item.containerId!);
        for (final container in containerPath) {
          breadcrumbs.add(
            BreadcrumbItem(name: container.name, container: container),
          );
        }
      }

      setState(() {
        _item = item;
        _breadcrumbs = breadcrumbs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Fetches the full path of containers from root to the given container.
  ///
  /// Returns containers in order from outermost to innermost.
  Future<List<domain.Container>> _getContainerPath(int containerId) async {
    final path = <domain.Container>[];
    var currentContainer = await _containerRepository.getById(containerId);

    while (currentContainer != null) {
      path.insert(0, currentContainer);
      // Move to parent container if exists
      if (currentContainer.parentContainerId != null) {
        currentContainer =
            await _containerRepository.getById(currentContainer.parentContainerId!);
      } else {
        break;
      }
    }

    return path;
  }

  /// Navigates to the location contents screen.
  void _navigateToLocation(Location location) {
    Navigator.of(context, rootNavigator: false).push(
      MaterialPageRoute(
        builder: (context) => ContentsScreen(
          source: LocationSource(location),
        ),
      ),
    );
  }

  /// Navigates to the container contents screen.
  void _navigateToContainer(domain.Container container) {
    Navigator.of(context, rootNavigator: false).push(
      MaterialPageRoute(
        builder: (context) => ContentsScreen(
          source: ContainerSource(container),
        ),
      ),
    );
  }

  /// Opens full-screen image viewer.
  void _openImageViewer() {
    if (_item?.photoPath == null) return;
    Navigator.of(context, rootNavigator: false).push(
      MaterialPageRoute(
        builder: (context) => _ImageViewer(imagePath: _item!.photoPath!),
      ),
    );
  }

  /// Shows delete confirmation dialog.
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteConfirmDialog(itemName: _item?.name ?? ''),
    );
    if (confirmed == true && mounted) {
      final deleted = await _itemRepository.delete(_item!.id);
      if (deleted && mounted) {
        Navigator.pop(context, true); // Return true to indicate deletion
      }
    }
  }

  /// Navigates to edit screen (placeholder for future implementation).
  void _navigateToEdit() {
    // TODO: Implement edit screen navigation when ready
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit feature coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Detail'),
        actions: [
          if (_item != null && !_isLoading)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _navigateToEdit();
                    break;
                  case 'delete':
                    _confirmDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: AppSpacing.sm),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outlined, color: AppColors.error),
                      SizedBox(width: AppSpacing.sm),
                      Text('Delete', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
        ],
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
        onRetry: _loadData,
      );
    }

    if (_item == null) {
      return const _EmptyView();
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Image section with date badge
        _ItemImageSection(
          imagePath: _item!.photoPath,
          createdAt: _item!.createdAt,
          onTap: _openImageViewer,
        ),
        // Content section
        Padding(
          padding: AppSpacing.pageMargins,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              // Breadcrumbs
              if (_breadcrumbs.isNotEmpty)
                _Breadcrumbs(
                  items: _breadcrumbs,
                  onLocationTap: _navigateToLocation,
                  onContainerTap: _navigateToContainer,
                ),
              const SizedBox(height: AppSpacing.lg),
              // Title
              Text(
                _item!.name,
                style: AppTypography.h3.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Description
              if (_item!.description != null && _item!.description!.isNotEmpty)
                Text(
                  _item!.description!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    height: AppTypography.lineHeightRelaxed,
                  ),
                )
              else
                Text(
                  'No description',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textDisabledDark
                        : AppColors.textDisabledLight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const SizedBox(height: AppSpacing.xxl),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Edit Item',
                      variant: AppButtonVariant.secondary,
                      icon: Icons.edit_outlined,
                      onPressed: _navigateToEdit,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      text: 'Delete',
                      variant: AppButtonVariant.danger,
                      icon: Icons.delete_outlined,
                      onPressed: _confirmDelete,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ],
    );
  }
}

// ================================
// INTERNAL WIDGETS
// ================================

/// Breadcrumbs widget showing the navigation hierarchy.
///
/// Displays as: Location > Container > Sub-container
/// Each breadcrumb (except the last) is tappable.
class _Breadcrumbs extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final Function(Location) onLocationTap;
  final Function(domain.Container) onContainerTap;

  const _Breadcrumbs({
    required this.items,
    required this.onLocationTap,
    required this.onContainerTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final separatorColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Icon(
                Icons.chevron_right,
                size: 18,
                color: separatorColor,
              ),
            ),
          _BreadcrumbChip(
            item: items[i],
            isLast: i == items.length - 1,
            primaryColor: primaryColor,
            textColor: textColor,
            onTap: i == items.length - 1
                ? null
                : () {
                    if (items[i].location != null) {
                      onLocationTap(items[i].location!);
                    } else if (items[i].container != null) {
                      onContainerTap(items[i].container!);
                    }
                  },
          ),
        ],
      ],
    );
  }
}

/// Individual breadcrumb chip widget.
class _BreadcrumbChip extends StatelessWidget {
  final BreadcrumbItem item;
  final bool isLast;
  final Color primaryColor;
  final Color textColor;
  final VoidCallback? onTap;

  const _BreadcrumbChip({
    required this.item,
    required this.isLast,
    required this.primaryColor,
    required this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final backgroundColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.location != null)
          Icon(
            Icons.place_outlined,
            size: 14,
            color: isLast ? primaryColor : textColor,
          )
        else if (item.container != null)
          Icon(
            _getContainerIcon(item.container!.type),
            size: 14,
            color: isLast ? primaryColor : textColor,
          ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          item.name,
          style: AppTypography.labelMedium.copyWith(
            color: isLast ? primaryColor : textColor,
            fontWeight: isLast ? AppTypography.weightSemiBold : AppTypography.weightMedium,
          ),
        ),
      ],
    );

    if (onTap != null) {
      child = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.borderRadiusSm,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: AppSpacing.borderRadiusSm,
              border: Border.all(color: borderColor, width: 1),
            ),
            child: child,
          ),
        ),
      );
    } else {
      child = Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppSpacing.borderRadiusSm,
          border: Border.all(color: borderColor, width: 1),
        ),
        child: child,
      );
    }

    return child;
  }

  IconData _getContainerIcon(domain.ContainerType type) {
    switch (type) {
      case domain.ContainerType.box:
        return Icons.inventory_2_outlined;
      case domain.ContainerType.shelf:
        return Icons.view_week_outlined;
      case domain.ContainerType.bag:
        return Icons.shopping_bag_outlined;
      case domain.ContainerType.closet:
        return Icons.door_sliding_outlined;
      case domain.ContainerType.drawer:
        return Icons.menu_outlined;
      case domain.ContainerType.cabinet:
        return Icons.inventory_outlined;
      case domain.ContainerType.other:
        return Icons.category_outlined;
    }
  }
}

/// Image section with date badge overlay.
class _ItemImageSection extends StatelessWidget {
  final String? imagePath;
  final int createdAt;
  final VoidCallback onTap;

  const _ItemImageSection({
    required this.imagePath,
    required this.createdAt,
    required this.onTap,
  });

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (imagePath == null) {
      // Placeholder when no image
      return SizedBox(
        height: 240,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 240,
              color: isDark
                  ? AppColors.backgroundDarkSecondary
                  : AppColors.dividerLight,
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 64,
                  color: isDark
                      ? AppColors.textDisabledDark
                      : AppColors.textDisabledLight,
                ),
              ),
            ),
            // Date badge
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: _DateBadge(
                date: _formatDate(createdAt),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          // Image
          GestureDetector(
            onTap: onTap,
            child: Stack(
              children: [
                Image.asset(
                  imagePath!,
                  width: double.infinity,
                  height: 240,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 240,
                      color: isDark
                          ? AppColors.backgroundDarkSecondary
                          : AppColors.dividerLight,
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 64),
                      ),
                    );
                  },
                ),
                // Overlay hint for tap to zoom
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      child: Center(
                        child: Container(
                          padding: AppSpacing.paddingSm,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Date badge overlay
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: _DateBadge(
              date: _formatDate(createdAt),
            ),
          ),
        ],
      ),
    );
  }
}

/// Date badge overlay widget.
class _DateBadge extends StatelessWidget {
  final String date;

  const _DateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingChip,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            date,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: AppTypography.weightMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen image viewer with pinch-to-zoom.
class _ImageViewer extends StatelessWidget {
  final String imagePath;

  const _ImageViewer({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.asset(
            imagePath,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.broken_image,
                color: Colors.white54,
                size: 64,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Delete confirmation dialog.
class _DeleteConfirmDialog extends StatelessWidget {
  final String itemName;

  const _DeleteConfirmDialog({required this.itemName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Item?'),
      content: Text(
        'Are you sure you want to delete "$itemName"? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

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
            AppButton(
              text: 'Retry',
              icon: Icons.refresh,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty view when item is not found.
class _EmptyView extends StatelessWidget {
  const _EmptyView();

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
              'Item not found',
              style: AppTypography.h5.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
