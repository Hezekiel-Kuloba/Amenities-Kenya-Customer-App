import 'package:amenities_kenya/models/supplier.dart';
import 'package:amenities_kenya/models/product_item.dart';
import 'package:amenities_kenya/models/user.dart'; // For Coordinates

class SupplierDisplayData {
  final String supplierId;
  final String supplierName;
  final String category;
  final String contactPhone;
  final String imageUrl;
  final double? averageRating; // Now uses location-specific rating
  final int? reviewCount; // Now uses location-specific review count
  final List<Review>? reviews; // NEW FIELD for location-specific reviews
  final Pricing pricing; // Supplier-level pricing (delivery fee)
  final List<Promotion> promotions;
  final Availability availability;
  final DateTime createdAt;

  // Specific location details
  final String locationId;
  final String locationName;
  final String locationAddress;
  final Coordinates locationCoordinates;
  final List<ProductItem> productCatalog; // Location-specific product catalog

  double? distanceToUser; // For sorting

  SupplierDisplayData({
    required this.supplierId,
    required this.supplierName,
    required this.category,
    required this.contactPhone,
    required this.imageUrl,
    required this.averageRating,
    required this.reviewCount,
    required this.reviews,
    required this.pricing,
    required this.promotions,
    required this.availability,
    required this.createdAt,
    required this.locationId,
    required this.locationName,
    required this.locationAddress,
    required this.locationCoordinates,
    required this.productCatalog,
    this.distanceToUser,
  });

  // Factory constructor to create from Supplier and SupplierLocation
  factory SupplierDisplayData.fromSupplierAndLocation(
    Supplier supplier,
    SupplierLocation location,
  ) {
    return SupplierDisplayData(
      supplierId: supplier.supplierId,
      supplierName: supplier.name,
      category: supplier.category,
      contactPhone: supplier.contactPhone,
      imageUrl: supplier.imageUrl,
      averageRating: location.averageRating, // Use location-specific rating
      reviewCount: location.reviewCount, // Use location-specific review count
      reviews: location.reviews, // Use location-specific reviews
      pricing: supplier.pricing,
      promotions: supplier.promotions,
      availability: supplier.availability,
      createdAt: supplier.createdAt,
      locationId: location.locationId,
      locationName: location.locationName,
      locationAddress: location.address,
      locationCoordinates: location.coordinates,
      productCatalog: location.productCatalog,
    );
  }
}

// Extension to convert SupplierDisplayData to SupplierLocation
extension SupplierDisplayDataExtension on SupplierDisplayData {
  SupplierLocation toSupplierLocation() {
    return SupplierLocation(
      locationId: locationId,
      locationName: locationName,
      address: locationAddress,
      coordinates: locationCoordinates,
      productCatalog: productCatalog,
      reviews: reviews,
      averageRating: averageRating,
      reviewCount: reviewCount,
      isDeleted: false, // Assume not deleted for this conversion
    );
  }
}