import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amenities_kenya/models/supplier.dart';
import 'package:amenities_kenya/services/location_service.dart';

final locationProvider =
    StateNotifierProvider<LocationNotifier, AsyncValue<Coordinates>>((ref) {
  return LocationNotifier(ref);
});

class LocationNotifier extends StateNotifier<AsyncValue<Coordinates>> {
  final Ref _ref;
  final MockLocationService _locationService = MockLocationService();

  LocationNotifier(this._ref) : super(const AsyncValue.loading()) {
    fetchCurrentLocation();
  }

  Future<void> fetchCurrentLocation() async {
    state = const AsyncValue.loading();
    try {
      final location = await _locationService.getCurrentLocation();
      state = AsyncValue.data(location);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void setLocation(Coordinates coordinates) {
    state = AsyncValue.data(coordinates);
  }
}