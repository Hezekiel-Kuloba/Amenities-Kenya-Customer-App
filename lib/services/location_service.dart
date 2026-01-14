import 'package:amenities_kenya/models/supplier.dart';

class MockLocationService {
  Future<Coordinates> getCurrentLocation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock Nairobi coordinates
    return Coordinates(lat: -1.286389, lon: 36.817223);
  }
}