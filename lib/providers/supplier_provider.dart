import 'package:amenities_kenya/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amenities_kenya/models/supplier.dart';
import 'package:amenities_kenya/models/supplier_display_data.dart';
import 'package:amenities_kenya/services/mock_supplier_service.dart';
import 'package:amenities_kenya/providers/location_provider.dart';
import 'package:amenities_kenya/utilities/distance_calculator.dart';

final supplierProvider =
    StateNotifierProvider.autoDispose<SupplierNotifier, AsyncValue<List<SupplierDisplayData>>>((ref) {
  return SupplierNotifier(ref);
});

class SupplierNotifier extends StateNotifier<AsyncValue<List<SupplierDisplayData>>> {
  final Ref _ref;
  final MockSupplierService _supplierService = MockSupplierService(ApiClient());
  String? _currentCategory;
  String _sortBy = 'rating';
  Coordinates? _userLocation;
  bool _isDisposed = false;

  SupplierNotifier(this._ref) : super(const AsyncValue.loading()) {
    _ref.listen<AsyncValue<Coordinates>>(locationProvider, (previous, next) {
      next.whenData((loc) {
        _userLocation = loc;
        if (_currentCategory != null && state is AsyncData) {
          final currentData = state.asData?.value as List<SupplierDisplayData>?;
          if (currentData != null) {
            // Recalculate distances with new user location
            final updatedData = currentData.map((sdd) {
              final distance = _userLocation != null
                  ? DistanceCalculator.calculateDistance(
                      _userLocation!.lat,
                      _userLocation!.lon,
                      sdd.locationCoordinates.lat,
                      sdd.locationCoordinates.lon,
                    )
                  : null;
              return SupplierDisplayData(
                supplierId: sdd.supplierId,
                supplierName: sdd.supplierName,
                category: sdd.category,
                contactPhone: sdd.contactPhone,
                imageUrl: sdd.imageUrl,
                averageRating: sdd.averageRating,
                reviewCount: sdd.reviewCount,
                reviews: sdd.reviews,
                pricing: sdd.pricing,
                promotions: sdd.promotions,
                availability: sdd.availability,
                createdAt: sdd.createdAt,
                locationId: sdd.locationId,
                locationName: sdd.locationName,
                locationAddress: sdd.locationAddress,
                locationCoordinates: sdd.locationCoordinates,
                productCatalog: sdd.productCatalog,
                distanceToUser: distance,
              );
            }).toList();
            state = AsyncValue.data(_sortSuppliers(updatedData));
          }
        }
      });
    });
    _userLocation = _ref.read(locationProvider).value;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> fetchSuppliers(String category) async {
    if (_isDisposed) return;
    _currentCategory = category;
    state = const AsyncValue.loading();
    try {
      // Fetch list of SupplierDisplayData directly from MockSupplierService
      List<SupplierDisplayData> suppliers = await _supplierService.getSuppliersByCategory(category);
      if (_isDisposed) return;

      // Calculate distance for each SupplierDisplayData if user location is available
      if (_userLocation != null) {
        suppliers = suppliers.map((sdd) {
          final distance = DistanceCalculator.calculateDistance(
            _userLocation!.lat,
            _userLocation!.lon,
            sdd.locationCoordinates.lat,
            sdd.locationCoordinates.lon,
          );
          return SupplierDisplayData(
            supplierId: sdd.supplierId,
            supplierName: sdd.supplierName,
            category: sdd.category,
            contactPhone: sdd.contactPhone,
            imageUrl: sdd.imageUrl,
            averageRating: sdd.averageRating,
            reviewCount: sdd.reviewCount,
            reviews: sdd.reviews,
            pricing: sdd.pricing,
            promotions: sdd.promotions,
            availability: sdd.availability,
            createdAt: sdd.createdAt,
            locationId: sdd.locationId,
            locationName: sdd.locationName,
            locationAddress: sdd.locationAddress,
            locationCoordinates: sdd.locationCoordinates,
            productCatalog: sdd.productCatalog,
            distanceToUser: distance,
          );
        }).toList();
      }

      final sortedSuppliers = _sortSuppliers(suppliers);
      state = AsyncValue.data(sortedSuppliers);
    } catch (e, stack) {
      if (_isDisposed) return;
      state = AsyncValue.error(e, stack);
    }
  }

  void setSortBy(String sortBy) {
    if (_isDisposed) return;
    _sortBy = sortBy;
    state.whenData((suppliers) {
      final sortedSuppliers = _sortSuppliers(suppliers);
      state = AsyncValue.data(sortedSuppliers);
    });
  }

  List<SupplierDisplayData> _sortSuppliers(List<SupplierDisplayData> suppliers) {
    final sorted = List<SupplierDisplayData>.from(suppliers);
    if (_sortBy == 'rating') {
      sorted.sort((a, b) => b.averageRating!.compareTo(a.averageRating!));
    } else if (_sortBy == 'distance' && _userLocation != null) {
      sorted.sort((a, b) {
        final distA = a.distanceToUser ?? double.infinity;
        final distB = b.distanceToUser ?? double.infinity;
        return distA.compareTo(distB);
      });
    }
    return sorted;
  }
}