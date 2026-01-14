import 'package:amenities_kenya/models/user.dart'; // For Coordinates if needed in future product items

abstract class ProductItem {
  final String itemId;
  final String type;

  ProductItem({required this.itemId, required this.type});

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'bulk_water':
        return BulkWaterItem.fromJson(json);
      case 'cylinder':
        return CylinderItem.fromJson(json);
      case 'accessory':
        return AccessoryItem.fromJson(json);
      case 'bottle':
        return BottleItem.fromJson(json);
      case 'collection':
        return CollectionItem.fromJson(json);
      case 'bags_only':
        return BagsOnlyItem.fromJson(json);
      case 'emptying_trip':
        return EmptyingTripItem.fromJson(json);
      default:
        throw Exception('Unknown product item type: $type');
    }
  }

  Map<String, dynamic> toJson();
}

class BulkWaterItem extends ProductItem {
  final String name;
  final double pricePerLiter;

  BulkWaterItem({
    required super.itemId,
    required super.type,
    required this.name,
    required this.pricePerLiter,
  });

  factory BulkWaterItem.fromJson(Map<String, dynamic> json) {
    return BulkWaterItem(
      itemId: json['item_id'],
      type: json['type'],
      name: json['name'],
      pricePerLiter: (json['price_per_liter'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'type': type,
      'name': name,
      'price_per_liter': pricePerLiter,
    };
  }
}

class CylinderItem extends ProductItem {
  final String brand;
  final String size;
  final double newPrice;
  final double refillPrice;
  final double emptyCylinderPrice;

  CylinderItem({
    required super.itemId,
    required super.type,
    required this.brand,
    required this.size,
    required this.newPrice,
    required this.refillPrice,
    required this.emptyCylinderPrice,
  });

  factory CylinderItem.fromJson(Map<String, dynamic> json) {
    return CylinderItem(
      itemId: json['item_id'],
      type: json['type'],
      brand: json['brand'],
      size: json['size'],
      newPrice: (json['new_price'] as num).toDouble(),
      refillPrice: (json['refill_price'] as num).toDouble(),
      emptyCylinderPrice: (json['empty_cylinder_price'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'type': type,
      'brand': brand,
      'size': size,
      'new_price': newPrice,
      'refill_price': refillPrice,
      'empty_cylinder_price': emptyCylinderPrice,
    };
  }
}

class AccessoryItem extends ProductItem {
  final String name;
  final double price;

  AccessoryItem({
    required super.itemId,
    required super.type,
    required this.name,
    required this.price,
  });

  factory AccessoryItem.fromJson(Map<String, dynamic> json) {
    return AccessoryItem(
      itemId: json['item_id'],
      type: json['type'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'type': type,
      'name': name,
      'price': price,
    };
  }
}

class BottleItem extends ProductItem {
  final String size;
  final double newPrice;
  final double refillPrice;
  final double emptyBottlePrice;

  BottleItem({
    required super.itemId,
    required super.type,
    required this.size,
    required this.newPrice,
    required this.refillPrice,
    required this.emptyBottlePrice,
  });

  factory BottleItem.fromJson(Map<String, dynamic> json) {
    return BottleItem(
      itemId: json['item_id'],
      type: json['type'],
      size: json['size'],
      newPrice: (json['new_price'] as num).toDouble(),
      refillPrice: (json['refill_price'] as num).toDouble(),
      emptyBottlePrice: (json['empty_bottle_price'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'type': type,
      'size': size,
      'new_price': newPrice,
      'refill_price': refillPrice,
      'empty_bottle_price': emptyBottlePrice,
    };
  }
}

class CollectionItem extends ProductItem {
  final double basePrice;
  final int bagsIncluded;
  final double additionalBagPrice;

  CollectionItem({
    required super.itemId,
    required super.type,
    required this.basePrice,
    required this.bagsIncluded,
    required this.additionalBagPrice,
  });

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    return CollectionItem(
      itemId: json['item_id'],
      type: json['type'],
      basePrice: (json['base_price'] as num).toDouble(),
      bagsIncluded: json['bags_included'],
      additionalBagPrice: (json['additional_bag_price'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'type': type,
      'base_price': basePrice,
      'bags_included': bagsIncluded,
      'additional_bag_price': additionalBagPrice,
    };
  }
}

class BagsOnlyItem extends ProductItem {
  final double pricePerBag;

  BagsOnlyItem({
    required super.itemId,
    required super.type,
    required this.pricePerBag,
  });

  factory BagsOnlyItem.fromJson(Map<String, dynamic> json) {
    return BagsOnlyItem(
      itemId: json['item_id'],
      type: json['type'],
      pricePerBag: (json['price_per_bag'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'type': type,
      'price_per_bag': pricePerBag,
    };
  }
}

class EmptyingTripItem extends ProductItem {
  final double pricePerTrip;

  EmptyingTripItem({
    required super.itemId,
    required super.type,
    required this.pricePerTrip,
  });

  factory EmptyingTripItem.fromJson(Map<String, dynamic> json) {
    return EmptyingTripItem(
      itemId: json['item_id'],
      type: json['type'],
      pricePerTrip: (json['price_per_trip'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'type': type,
      'price_per_trip': pricePerTrip,
    };
  }
}