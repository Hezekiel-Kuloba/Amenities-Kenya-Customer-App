
import 'package:amenities_kenya/models/product_item.dart';
import 'package:amenities_kenya/models/user.dart'; // Coordinates is here

class Coordinates {
  final double lat;
  final double lon;

  Coordinates({
    required this.lat,
    required this.lon,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lon': lon,
    };
  }
}

class Supplier {
  final String supplierId;
  final String name;
  final String category;
  final String contactPhone;
  final String imageUrl;
  final double averageRating;
  final int reviewCount;
  final Pricing pricing;
  final List<Promotion> promotions;
  final Availability availability;
  final DateTime createdAt;
  final List<SupplierLocation> locations;

  Supplier({
    required this.supplierId,
    required this.name,
    required this.category,
    required this.contactPhone,
    required this.imageUrl,
    required this.averageRating,
    required this.reviewCount,
    required this.pricing,
    required this.promotions,
    required this.availability,
    required this.createdAt,
    required this.locations,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      supplierId: json['supplier_id'],
      name: json['name'],
      category: json['category'],
      contactPhone: json['contact_phone'],
      imageUrl: json['image_url'],
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] ?? 0,
      pricing: Pricing.fromJson(json['pricing'], json['category']),
      promotions: (json['promotions'] as List)
          .map((promo) => Promotion.fromJson(promo))
          .toList(),
      availability: Availability.fromJson(json['availability']),
      createdAt: DateTime.parse(json['created_at']),
      locations: (json['locations'] as List)
          .map((loc) => SupplierLocation.fromJson(loc))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_id': supplierId,
      'name': name,
      'category': category,
      'contact_phone': contactPhone,
      'image_url': imageUrl,
      'average_rating': averageRating,
      'review_count': reviewCount,
      'pricing': pricing.toJson(category),
      'promotions': promotions.map((promo) => promo.toJson()).toList(),
      'availability': availability.toJson(),
      'created_at': createdAt.toIso8601String(),
      'locations': locations.map((loc) => loc.toJson()).toList(),
    };
  }
}

class SupplierLocation {
  final String locationId;
  final String locationName;
  final String address;
  final Coordinates coordinates;
  final List<ProductItem> productCatalog;
  final List<Review>? reviews; // NEW FIELD
  final double? averageRating; // NEW FIELD
  final int? reviewCount; // NEW FIELD
  final bool? isDeleted; // NEW FIELD

  SupplierLocation({
    required this.locationId,
    required this.locationName,
    required this.address,
    required this.coordinates,
    required this.productCatalog,
    this.reviews,
    this.averageRating,
    this.reviewCount,
    this.isDeleted,
  });

  factory SupplierLocation.fromJson(Map<String, dynamic> json) {
    return SupplierLocation(
      locationId: json['location_id'],
      locationName: json['location_name'],
      address: json['address'],
      coordinates: Coordinates.fromJson(json['coordinates']),
      productCatalog: (json['product_catalog'] as List)
          .map((item) => ProductItem.fromJson(item))
          .toList(),
      reviews: (json['reviews'] as List)
          .map((review) => Review.fromJson(review))
          .toList(),
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] ?? 0,
      isDeleted: json['is_deleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_id': locationId,
      'location_name': locationName,
      'address': address,
      'coordinates': coordinates.toJson(),
      'product_catalog': productCatalog.map((item) => item.toJson()).toList(),
      'reviews': reviews!.map((review) => review.toJson()).toList(),
      'average_rating': averageRating,
      'review_count': reviewCount,
      'is_deleted': isDeleted,
    };
  }
}

class Review {
  final String reviewId;
  final String userId;
  final String content;
  final DateTime timestamp;
  final bool isDeleted;

  Review({
    required this.reviewId,
    required this.userId,
    required this.content,
    required this.timestamp,
    required this.isDeleted,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['review_id'],
      userId: json['user_id'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      isDeleted: json['is_deleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'user_id': userId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'is_deleted': isDeleted,
    };
  }
}

class Pricing {
  final double? deliveryFeePerKm;

  Pricing({
    this.deliveryFeePerKm,
  });

  factory Pricing.fromJson(Map<String, dynamic> json, String category) {
    // Only parse deliveryFeePerKm at the top level
    return Pricing(
      deliveryFeePerKm: (json['delivery_fee_per_km'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson(String category) {
    final json = <String, dynamic>{};
    if (deliveryFeePerKm != null) json['delivery_fee_per_km'] = deliveryFeePerKm;
    return json;
  }
}

class Promotion {
  final String description;
  final String validUntil;

  Promotion({required this.description, required this.validUntil});

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      description: json['description'],
      validUntil: json['valid_until'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'valid_until': validUntil,
    };
  }
}

class Availability {
  final List<String> days;
  final String hours;

  Availability({required this.days, required this.hours});

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      days: List<String>.from(json['days']),
      hours: json['hours'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'days': days,
      'hours': hours,
    };
  }
}