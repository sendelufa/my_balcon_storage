import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storage_app/core/platform/platform_provider.dart';
import 'package:storage_app/core/models/location.dart';
import 'package:storage_app/core/services/photo_service_web.dart';
import 'package:storage_app/features/locations/providers.dart';
import 'package:storage_app/core/utils/validators.dart';

/// Location form screen - for creating or editing a location
class LocationFormScreen extends ConsumerStatefulWidget {
  final String? locationId;

  const LocationFormScreen({super.key, this.locationId});

  @override
  ConsumerState<LocationFormScreen> createState() => _LocationFormScreenState();
}

class _LocationFormScreenState extends ConsumerState<LocationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // On mobile, we use File; on web, we store the photo path (filename)
  dynamic _photoData; // File on mobile, String (path) on web
  String? _existingPhotoPath;
  bool _isSaving = false;
  Location? _originalLocation;

  @override
  void initState() {
    super.initState();
    if (widget.locationId != null) {
      _loadLocation();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadLocation() async {
    final locationRepo = ref.read(locationRepositoryProvider);
    final location = await locationRepo.getLocationById(widget.locationId!);
    if (location != null && mounted) {
      setState(() {
        _originalLocation = location;
        _nameController.text = location.name;
        _descriptionController.text = location.description ?? '';
        _existingPhotoPath = location.photoPath;
        // On web, the photo path is just a filename (key)
        // On mobile, it's a full file path
        if (!kIsWeb && _existingPhotoPath != null && _existingPhotoPath!.isNotEmpty) {
          _photoData = File(_existingPhotoPath!);
        }
      });
    }
  }

  Future<void> _pickPhotoFromCamera() async {
    final photoService = ref.read(photoServiceProvider);

    // Check if camera is available
    if (!photoService.isCameraAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera is not available on web. Please use file upload.')),
        );
      }
      return;
    }

    try {
      final photoPath = await photoService.captureFromCamera();
      if (photoPath != null) {
        setState(() {
          if (!kIsWeb) {
            _photoData = File(photoPath);
          } else {
            _photoData = photoPath; // On web, store the path/filename
          }
          _existingPhotoPath = null;
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
    final photoService = ref.read(photoServiceProvider);

    try {
      final photoPath = await photoService.pickFromGallery();
      if (photoPath != null) {
        setState(() {
          if (!kIsWeb) {
            _photoData = File(photoPath);
          } else {
            _photoData = photoPath; // On web, store the path/filename
          }
          _existingPhotoPath = null;
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
      _photoData = null;
      _existingPhotoPath = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final name = Validators.sanitize(_nameController.text);
      final description = _descriptionController.text.trim().isEmpty
          ? null
          : Validators.sanitize(_descriptionController.text);

      final photoService = ref.read(photoServiceProvider);

      String? finalPhotoPath;

      // Determine the final photo path
      if (_photoData != null) {
        // Photo was changed - delete old photo
        if (_existingPhotoPath != null) {
          await photoService.deletePhoto(_existingPhotoPath);
        }

        if (!kIsWeb && _photoData is File) {
          finalPhotoPath = (_photoData as File).path;
        } else {
          // On web, _photoData is already the path/filename
          finalPhotoPath = _photoData as String?;
        }
      } else if (_existingPhotoPath != null) {
        // Keep existing photo
        finalPhotoPath = _existingPhotoPath;
      }

      final notifier = ref.read(locationsProvider.notifier);

      final success = widget.locationId != null && _originalLocation != null
          ? await notifier.updateLocation(
              _originalLocation!.copyWith(
                name: name,
                description: description,
                photoPath: finalPhotoPath,
                updatedAt: DateTime.now().millisecondsSinceEpoch,
              ),
            )
          : await notifier.createLocation(
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
          SnackBar(content: Text('Failed to save location: $e')),
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
    final isEditing = widget.locationId != null;
    final photoService = ref.watch(photoServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Location' : 'Add Location'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo picker
            _PhotoPickerSection(
              photoData: _photoData,
              existingPhotoPath: _existingPhotoPath,
              onPickFromCamera: photoService.isCameraAvailable ? _pickPhotoFromCamera : null,
              onPickFromGallery: _pickPhotoFromGallery,
              onRemove: _removePhoto,
            ),
            const SizedBox(height: 24),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., Garage, Basement, Box 1',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: 100,
              validator: Validators.validateName,
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Add notes about this location',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 500,
              validator: Validators.validateDescription,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _isSaving ? null : _save,
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
  final dynamic photoData; // File on mobile, String on web
  final String? existingPhotoPath;
  final VoidCallback? onPickFromCamera;
  final VoidCallback onPickFromGallery;
  final VoidCallback onRemove;

  const _PhotoPickerSection({
    required this.photoData,
    this.existingPhotoPath,
    this.onPickFromCamera,
    required this.onPickFromGallery,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoData != null ||
        (existingPhotoPath != null && existingPhotoPath!.isNotEmpty);

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
                ? _buildPhotoPreview(context)
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

  Widget _buildPhotoPreview(BuildContext context) {
    if (!kIsWeb && photoData is File) {
      // Mobile: Display from File
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              photoData as File,
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
              onTap: () => _showPhotoSourceSheet(context),
            ),
          ),
        ],
      );
    } else {
      // Web: Display from memory - needs a separate widget
      return _WebPhotoImageWrapper(
        photoPath: photoData is String ? photoData as String : existingPhotoPath,
        onRemove: onRemove,
        onTapEdit: () => _showPhotoSourceSheet(context),
      );
    }
  }

  void _showPhotoSourceSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onPickFromCamera != null)
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  onPickFromCamera!();
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
            if (photoData != null || (existingPhotoPath != null && existingPhotoPath!.isNotEmpty))
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  onRemove();
                },
              ),
            if (photoData != null || (existingPhotoPath != null && existingPhotoPath!.isNotEmpty))
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

/// Web photo image widget (displays from memory cache)
class _WebPhotoImage extends ConsumerWidget {
  final String? photoPath;

  const _WebPhotoImage({required this.photoPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (photoPath == null || photoPath!.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
    }

    final photoService = ref.watch(photoServiceProvider);
    if (photoService is! PhotoServiceWeb) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
    }

    final bytes = (photoService as PhotoServiceWeb).getPhotoBytes(photoPath!);
    if (bytes == null) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
    }

    return Image.memory(
      bytes,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
  }
}

/// Web photo image wrapper with edit buttons
class _WebPhotoImageWrapper extends ConsumerWidget {
  final String? photoPath;
  final VoidCallback onRemove;
  final VoidCallback onTapEdit;

  const _WebPhotoImageWrapper({
    required this.photoPath,
    required this.onRemove,
    required this.onTapEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _WebPhotoImage(photoPath: photoPath),
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
            onTap: onTapEdit,
          ),
        ),
      ],
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
