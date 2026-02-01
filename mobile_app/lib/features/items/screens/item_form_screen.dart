import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storage_app/core/services/photo_service.dart';
import 'package:storage_app/core/models/item.dart';
import 'package:storage_app/features/items/providers.dart';
import 'package:storage_app/features/locations/providers.dart' as loc_providers;
import 'package:storage_app/core/utils/validators.dart';

/// Item form screen - for creating or editing an item
class ItemFormScreen extends ConsumerStatefulWidget {
  final String? itemId;
  final String? locationId; // For creating new item with pre-selected location

  const ItemFormScreen({super.key, this.itemId, this.locationId});

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _photoFile;
  String? _existingPhotoPath;
  String? _selectedLocationId;
  bool _isSaving = false;
  bool _hasChanges = false;
  Item? _originalItem; // Store original item when editing

  @override
  void initState() {
    super.initState();
    _selectedLocationId = widget.locationId;

    if (widget.itemId != null) {
      _loadItem();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadItem() async {
    if (widget.itemId == null) return;

    // Load items from the repository to find the one we're editing
    final itemRepo = ref.read(itemRepositoryProvider);
    final item = await itemRepo.getItemById(widget.itemId!);
    if (item != null && mounted) {
      setState(() {
        _originalItem = item;
        _nameController.text = item.name;
        _descriptionController.text = item.description ?? '';
        _existingPhotoPath = item.photoPath;
        _selectedLocationId = item.locationId;
        if (_existingPhotoPath != null && _existingPhotoPath!.isNotEmpty) {
          _photoFile = File(_existingPhotoPath!);
        }
      });
    }
  }

  Future<void> _pickPhotoFromCamera() async {
    try {
      final photoPath = await PhotoService.instance.captureFromCamera();
      if (photoPath != null) {
        setState(() {
          _photoFile = File(photoPath);
          _hasChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture photo: $e')),
        );
      }
    }
  }

  Future<void> _pickPhotoFromGallery() async {
    try {
      final photoPath = await PhotoService.instance.pickFromGallery();
      if (photoPath != null) {
        setState(() {
          _photoFile = File(photoPath);
          _hasChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick photo: $e')),
        );
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _photoFile = null;
      _existingPhotoPath = null;
      _hasChanges = true;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLocationId == null || _selectedLocationId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final name = Validators.sanitize(_nameController.text);
      final description = _descriptionController.text.trim().isEmpty
          ? null
          : Validators.sanitize(_descriptionController.text);

      String? finalPhotoPath;

      if (_photoFile != null) {
        // Photo was changed - delete old photo
        if (_existingPhotoPath != null) {
          await PhotoService.instance.deletePhoto(_existingPhotoPath);
        }
        finalPhotoPath = _photoFile!.path;
      } else if (_existingPhotoPath != null) {
        // Keep existing photo
        finalPhotoPath = _existingPhotoPath;
      }

      final notifier = ref.read(itemsByLocationProvider(_selectedLocationId!).notifier);

      final success = widget.itemId != null && _originalItem != null
          ? await notifier.updateItem(
              _originalItem!.copyWith(
                name: name,
                description: description,
                photoPath: finalPhotoPath,
                locationId: _selectedLocationId!,
                updatedAt: DateTime.now().millisecondsSinceEpoch,
              ),
            )
          : await notifier.createItem(
              name: name,
              description: description,
              photoPath: finalPhotoPath,
            );

      if (mounted && success) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save item: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.itemId != null;
    final locationsState = ref.watch(loc_providers.locationsProvider);
    final locations = locationsState.locations;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Item' : 'Add Item'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo picker
            _PhotoPickerSection(
              photoFile: _photoFile,
              existingPhotoPath: _existingPhotoPath,
              onPickFromCamera: _pickPhotoFromCamera,
              onPickFromGallery: _pickPhotoFromGallery,
              onRemove: _removePhoto,
            ),
            const SizedBox(height: 24),

            // Location selector
            DropdownButtonFormField<String>(
              value: _selectedLocationId,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'Select Location',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              items: locations.map((location) {
                return DropdownMenuItem(
                  value: location.id,
                  child: Text(location.name),
                );
              }).toList(),
              onChanged: locations.isEmpty || widget.locationId != null
                  ? null
                  : (value) {
                      setState(() {
                        _selectedLocationId = value;
                        _hasChanges = true;
                      });
                    },
              validator: (value) {
                if (value == null || value!.isEmpty) {
                  return 'Please select a location';
                }
                return null;
              },
            ),
            if (locations.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  'No locations available. Create a location first.',
                  style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., Winter Clothes, Tools, Documents',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory_2),
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: 100,
              validator: Validators.validateName,
              onChanged: (_) => setState(() => _hasChanges = true),
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Add details about this item',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              maxLength: 500,
              validator: Validators.validateDescription,
              onChanged: (_) => setState(() => _hasChanges = true),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: (_isSaving || locations.isEmpty) ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save'),
          ),
        ),
      ),
    );
  }
}

/// Photo picker section widget
class _PhotoPickerSection extends StatelessWidget {
  final File? photoFile;
  final String? existingPhotoPath;
  final VoidCallback onPickFromCamera;
  final VoidCallback onPickFromGallery;
  final VoidCallback onRemove;

  const _PhotoPickerSection({
    required this.photoFile,
    this.existingPhotoPath,
    required this.onPickFromCamera,
    required this.onPickFromGallery,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoFile != null || (existingPhotoPath != null && existingPhotoPath!.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showPhotoSourceSheet(context),
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: hasPhoto
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          photoFile ?? File(existingPhotoPath!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _ActionButton(
                          icon: Icons.close,
                          color: Colors.red,
                          backgroundColor: Colors.white,
                          onTap: onRemove,
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: _ActionButton(
                          icon: Icons.edit,
                          color: Colors.white,
                          backgroundColor: Colors.black54,
                          onTap: onPickFromGallery,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add Photo',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  void _showPhotoSourceSheet(BuildContext context) {
    final hasPhoto = photoFile != null || (existingPhotoPath != null && existingPhotoPath!.isNotEmpty);
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                onPickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                onPickFromGallery();
              },
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  onRemove();
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Action button widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
