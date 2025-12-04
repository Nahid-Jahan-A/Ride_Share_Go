import 'package:flutter/material.dart';

import '../../../../config/themes/app_theme.dart';
import '../../../../core/mock/mock_data.dart';
import '../../domain/entities/location.dart';

/// Bottom sheet for searching and selecting locations
class LocationSearchSheet extends StatefulWidget {
  final String title;
  final Location? initialLocation;
  final Function(Location) onLocationSelected;

  const LocationSearchSheet({
    super.key,
    required this.title,
    this.initialLocation,
    required this.onLocationSelected,
  });

  /// Show the location search sheet
  static Future<Location?> show(
    BuildContext context, {
    String title = 'Search Location',
    Location? initialLocation,
  }) async {
    return showModalBottomSheet<Location>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationSearchSheet(
        title: title,
        initialLocation: initialLocation,
        onLocationSelected: (location) {
          Navigator.of(context).pop(location);
        },
      ),
    );
  }

  @override
  State<LocationSearchSheet> createState() => _LocationSearchSheetState();
}

class _LocationSearchSheetState extends State<LocationSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Location> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Show popular locations initially
    _searchResults = MockData.popularLocations;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = true;
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final results = MockData.popularLocations.where((location) {
        final searchLower = query.toLowerCase();
        final nameLower = (location.placeName ?? '').toLowerCase();
        final addressLower = (location.address ?? '').toLowerCase();
        return nameLower.contains(searchLower) || addressLower.contains(searchLower);
      }).toList();

      setState(() {
        _searchResults = query.isEmpty ? MockData.popularLocations : results;
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),

              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search for a location...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Saved places shortcuts
              if (_searchController.text.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _QuickLocationButton(
                        icon: Icons.home,
                        label: 'Home',
                        onTap: () {
                          final savedHome = MockData.savedLocations
                              .where((l) => l.type == SavedLocationType.home)
                              .firstOrNull;
                          if (savedHome != null) {
                            widget.onLocationSelected(savedHome.location);
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      _QuickLocationButton(
                        icon: Icons.work,
                        label: 'Work',
                        onTap: () {
                          final savedWork = MockData.savedLocations
                              .where((l) => l.type == SavedLocationType.work)
                              .firstOrNull;
                          if (savedWork != null) {
                            widget.onLocationSelected(savedWork.location);
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      _QuickLocationButton(
                        icon: Icons.my_location,
                        label: 'Current',
                        onTap: () {
                          // Use first popular location as "current location"
                          widget.onLocationSelected(MockData.popularLocations.first);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
              ],

              // Section header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _searchController.text.isEmpty ? 'Popular Locations' : 'Search Results',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),

              // Results list
              Expanded(
                child: _isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : _searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_off,
                                  size: 64,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No locations found',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final location = _searchResults[index];
                              return _LocationTile(
                                location: location,
                                onTap: () => widget.onLocationSelected(location),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickLocationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickLocationButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  final Location location;
  final VoidCallback onTap;

  const _LocationTile({
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.location_on,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        location.placeName ?? 'Unknown',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        location.address ?? '',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
