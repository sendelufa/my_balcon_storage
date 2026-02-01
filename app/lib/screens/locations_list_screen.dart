import 'package:flutter/material.dart';
import '../domain/entities/location.dart';
import '../domain/repositories/location_repository.dart';
import '../data/repositories/location_repository_impl.dart';
import '../theme/spacing.dart';
import '../widgets/card.dart';
import 'contents_screen.dart';

/// Minimal locations list screen.
///
/// Displays a list of locations from the database.
/// Shows loading state while fetching and handles errors gracefully.
/// Designed to work within a parent Scaffold (HomeScreen).
class LocationsListScreen extends StatefulWidget {
  const LocationsListScreen({super.key});

  @override
  State<LocationsListScreen> createState() => _LocationsListScreenState();
}

class _LocationsListScreenState extends State<LocationsListScreen> {
  late final LocationRepository _repository;
  List<Location> _locations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = LocationRepositoryImpl();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final locations = await _repository.getAll();
      setState(() {
        _locations = locations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Navigates to the contents screen for a specific location.
  void _navigateToLocation(Location location) {
    Navigator.of(context, rootNavigator: false).push(
      MaterialPageRoute(
        builder: (context) => ContentsScreen(
          source: LocationSource(location),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    if (_locations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.place_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No locations yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _locations.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final location = _locations[index];
        return AppCard.location(
          name: location.name,
          description: location.description ?? '',
          itemCount: 0, // TODO: fetch actual count
          onTap: () => _navigateToLocation(location),
        );
      },
    );
  }
}
