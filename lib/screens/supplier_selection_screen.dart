import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:amenities_kenya/models/supplier.dart'; // Keep for Coordinates
import 'package:amenities_kenya/models/supplier_display_data.dart'; // NEW IMPORT
import 'package:amenities_kenya/providers/supplier_provider.dart';
import 'package:amenities_kenya/utilities/distance_calculator.dart';
import 'package:amenities_kenya/utilities/navigation_service.dart';
import 'package:amenities_kenya/widgets/supplier_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupplierSelectionScreen extends ConsumerStatefulWidget {
  const SupplierSelectionScreen({super.key});

  @override
  _SupplierSelectionScreenState createState() => _SupplierSelectionScreenState();
}

class _SupplierSelectionScreenState extends ConsumerState<SupplierSelectionScreen> {
  String? _category;
  String? _address;
  Coordinates? _coordinates;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure we only process arguments once on initial load
    if (_category == null) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is Map<String, dynamic>) {
        _category = args['category'] as String?;
        _address = args['address'] as String?;
        _coordinates = args['coordinates'] as Coordinates?;
        if (_category != null && _address != null && _coordinates != null) {
          // Only fetch suppliers if all necessary arguments are present
          ref.read(supplierProvider.notifier).fetchSuppliers(_category!);
        } else {
          setState(() {
            _error =
                'Invalid arguments: Missing required fields (category, address, coordinates)';
          });
        }
      } else {
        setState(() {
          _error =
              'Invalid arguments: Expected Map<String, dynamic>, got ${args.runtimeType} (${args.toString()}). Check navigation call to SupplierSelectionScreen.';
        });
      }
    }
  }

  // Custom ordering logic for displaying suppliers
  List<SupplierDisplayData> _getOrderedSuppliers(List<SupplierDisplayData> allSuppliers) {
    if (_coordinates == null) {
      // If user location is not available, just sort by rating as a fallback
      final sorted = List<SupplierDisplayData>.from(allSuppliers);
      sorted.sort((a, b) => b.averageRating!.compareTo(a.averageRating!));
      return sorted;
    }

    // Calculate distances for all suppliers' locations if not already calculated
    // This is a safety net; ideally, distanceToUser is already set by the provider.
    for (var sdd in allSuppliers) {
      if (sdd.distanceToUser == null) {
        sdd.distanceToUser = DistanceCalculator.calculateDistance(
          _coordinates!.lat,
          _coordinates!.lon,
          sdd.locationCoordinates.lat,
          sdd.locationCoordinates.lon,
        );
      }
    }

    // Sort all locations by distance initially to find the overall closest
    allSuppliers.sort((a, b) => a.distanceToUser!.compareTo(b.distanceToUser!));

    final List<SupplierDisplayData> orderedList = [];
    final Set<String> processedSupplierIds = {}; // To track suppliers whose main entry has been processed

    // Loop until all unique suppliers (via their closest location) have been added
    while (processedSupplierIds.length < allSuppliers.map((s) => s.supplierId).toSet().length) {
      SupplierDisplayData? closestOverallSdd;

      // Find the closest supplier location that hasn't had its primary entry processed
      for (var sdd in allSuppliers) {
        if (!processedSupplierIds.contains(sdd.supplierId)) {
          if (closestOverallSdd == null || sdd.distanceToUser! < closestOverallSdd.distanceToUser!) {
            closestOverallSdd = sdd;
          }
        }
      }

      if (closestOverallSdd != null) {
        // Add the closest location of this supplier
        orderedList.add(closestOverallSdd);
        processedSupplierIds.add(closestOverallSdd.supplierId);

        // Add other locations for this specific supplier, sorted by distance,
        // excluding the one already added.
        final otherLocationsOfThisSupplier = allSuppliers
            .where((sdd) => sdd.supplierId == closestOverallSdd!.supplierId && sdd.locationId != closestOverallSdd.locationId)
            .toList();
        otherLocationsOfThisSupplier.sort((a, b) => a.distanceToUser!.compareTo(b.distanceToUser!));
        orderedList.addAll(otherLocationsOfThisSupplier);
      } else {
        break; // No more unprocessed suppliers found (shouldn't happen if logic is sound)
      }
    }
    return orderedList;
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    const Color primaryColor = Color(0xFF000048); // A dark, navy-like blue

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(translations.error)),
        body: Center(child: Text(_error!)),
      );
    }

    final supplierState = ref.watch(supplierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const IconButton(
          icon: Icon(Icons.menu, color: primaryColor, size: 30),
          onPressed: null, // TODO: Implement drawer opening
        ),
        title: Text(
          '${_category} near you',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: primaryColor,
            fontFamily: 'serif',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            height: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: primaryColor, size: 30),
            onSelected: (value) {
              ref.read(supplierProvider.notifier).setSortBy(value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'rating', child: Text(translations.sortByRating)),
              PopupMenuItem(value: 'distance', child: Text(translations.sortByDistance)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryColor, size: 30),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              _buildLocationBar(primaryColor),
              const SizedBox(height: 24),
              supplierState.when(
                data: (suppliers) {
                  // Apply custom ordering here
                  final orderedSuppliers = _getOrderedSuppliers(suppliers);
                  return Column(
                    children: List.generate(
                      orderedSuppliers.length,
                      (index) {
                        final supplierDisplayData = orderedSuppliers[index];
                        return SupplierCard(
                          supplierDisplayData: supplierDisplayData,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              NavigationService.orderCustomization,
                              arguments: {
                                'supplierDisplayData': supplierDisplayData,
                                'address': _address, // User's delivery address
                                'coordinates': _coordinates, // User's delivery coordinates
                              },
                            );
                          },
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationBar(Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.edit_outlined, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _address ?? 'Loading location...',
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}