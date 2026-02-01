import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storage_app/core/models/location.dart';
import 'package:storage_app/core/models/item.dart';
import 'package:storage_app/features/locations/providers.dart';
import 'package:storage_app/features/items/providers.dart';
import 'package:storage_app/features/locations/screens/location_form_screen.dart';
import 'package:storage_app/features/items/screens/item_form_screen.dart';

/// Location detail screen - shows location info and items
class LocationDetailScreen extends ConsumerStatefulWidget {
  final String locationId;

  const LocationDetailScreen({super.key, required this.locationId});

  @override
  ConsumerState<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends ConsumerState<LocationDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final asyncValue = ref.watch(locationWithItemsProvider(widget.locationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editLocation(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDeleteLocation(context),
          ),
        ],
      ),
      body: asyncValue.when(
        data: (data) => _buildContent(context, ref, data.location, data.items),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Location location, List<dynamic> items) {
    final itemList = items.cast<Item>();

    return CustomScrollView(
      slivers: [
        // Location header
        SliverToBoxAdapter(
          child: _buildLocationHeader(context, location),
        ),
        // Items section
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: _buildItemsHeader(context, itemList.length),
          ),
        ),
        // Items list
        itemList.isEmpty
            ? SliverFillRemaining(
                child: _buildEmptyItemsState(context),
              )
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = itemList[index];
                      return _ItemCard(
                        item: item,
                        onTap: () => _viewItem(context, item),
                        onEdit: () => _editItem(context, item),
                        onDelete: () => _confirmDeleteItem(context, ref, item),
                      );
                    },
                    childCount: itemList.length,
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildLocationHeader(BuildContext context, Location location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo
        if (location.photoPath != null && location.photoPath!.isNotEmpty)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.file(
              File(location.photoPath!),
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (location.description != null && location.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  location.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildItemsHeader(BuildContext context, int itemCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            'Items',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          _ItemCountBadge(count: itemCount),
        ],
      ),
    );
  }

  Widget _buildEmptyItemsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No items yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to this location',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () => _addItem(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
          ),
        ],
      ),
    );
  }

  void _editLocation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationFormScreen(locationId: widget.locationId),
      ),
    );
  }

  void _confirmDeleteLocation(BuildContext context) async {
    final locationRepo = ref.read(locationRepositoryProvider);
    final location = await locationRepo.getLocationById(widget.locationId);
    if (location == null) return;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Location'),
        content: Text('Are you sure you want to delete "${location.name}"? This will also delete all items in this location.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(locationsProvider.notifier).deleteLocation(widget.locationId);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Location deleted' : 'Failed to delete location'),
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addItem(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ItemFormScreen(locationId: widget.locationId),
      ),
    );
  }

  void _viewItem(BuildContext context, Item item) {
    // For now, just edit - in future show detail view
    _editItem(context, item);
  }

  void _editItem(BuildContext context, Item item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ItemFormScreen(itemId: item.id),
      ),
    );
  }

  void _confirmDeleteItem(BuildContext context, WidgetRef ref, Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final notifier = ref.read(itemsByLocationProvider(widget.locationId).notifier);
              final success = await notifier.deleteItem(item.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Item deleted' : 'Failed to delete item'),
                  ),
                );
                // Refresh the location data
                ref.invalidate(locationWithItemsProvider(widget.locationId));
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Item count badge widget
class _ItemCountBadge extends StatelessWidget {
  final int count;

  const _ItemCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final text = count == 1 ? '1 item' : '$count items';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Item card widget
class _ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ItemCard({
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _buildPhoto(context),
        title: Text(item.name),
        subtitle: item.description != null && item.description!.isNotEmpty
            ? Text(
                item.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: _buildActions(context),
        onTap: onTap,
      ),
    );
  }

  Widget _buildPhoto(BuildContext context) {
    if (item.photoPath != null && item.photoPath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(item.photoPath!),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
        ),
      );
    }
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.inventory_2, size: 24, color: Colors.grey),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, size: 20),
          onPressed: onEdit,
          tooltip: 'Edit',
        ),
        IconButton(
          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
          onPressed: onDelete,
          tooltip: 'Delete',
        ),
      ],
    );
  }
}
