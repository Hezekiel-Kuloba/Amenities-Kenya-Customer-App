import 'package:amenities_kenya/models/supplier.dart';
import 'package:uuid/uuid.dart';
import 'package:amenities_kenya/models/user.dart'; // For Coordinates
import 'package:amenities_kenya/models/product_item.dart'; // Ensure ProductItem is imported if used in OrderItem

class Order {
  final String orderId;
  final String userId;
  final String supplierId;
  final String? supplierLocationId;
  final String category;
  final OrderDetails details;
  final DeliveryAddress deliveryAddress;
  final Schedule schedule;
  final String instructions;
  final String status;
  final DateTime createdAt;
  final DateTime? estimatedDeliveryTime;
  final String? paymentMethod;
  final bool isRecurring;
  String? assignedDelivererId; // Already present, but good to confirm
  final String? chatId; // NEW: Link to a chat session for this order

  Order({
    required this.orderId,
    required this.userId,
    required this.supplierId,
    this.supplierLocationId,
    required this.category,
    required this.details,
    required this.deliveryAddress,
    required this.schedule,
    required this.instructions,
    required this.status,
    required this.createdAt,
    this.estimatedDeliveryTime,
    this.paymentMethod,
    this.isRecurring = false,
    this.assignedDelivererId, // Already present
    this.chatId, // NEW: Add to constructor
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'],
      userId: json['user_id'],
      supplierId: json['supplier_id'],
      supplierLocationId: json['supplier_location_id'],
      category: json['category'],
      details: OrderDetails.fromJson(json['details'], json['category']),
      deliveryAddress: DeliveryAddress.fromJson(json['delivery_address']),
      schedule: Schedule.fromJson(json['schedule']),
      instructions: json['instructions'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      estimatedDeliveryTime: json['estimated_delivery_time'] != null
          ? DateTime.parse(json['estimated_delivery_time'])
          : null,
      paymentMethod: json['payment_method'] as String?,
      isRecurring: json['is_recurring'] as bool? ?? false,
      assignedDelivererId: json['assigned_deliverer_id'] as String?, // Already parsed
      chatId: json['chat_id'] as String?, // NEW: Parse from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'user_id': userId,
      'supplier_id': supplierId,
      'supplier_location_id': supplierLocationId,
      'category': category,
      'details': details.toJson(category),
      'delivery_address': deliveryAddress.toJson(),
      'schedule': schedule.toJson(),
      'instructions': instructions,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'estimated_delivery_time': estimatedDeliveryTime?.toIso8601String(),
      'payment_method': paymentMethod,
      'is_recurring': isRecurring,
      'assigned_deliverer_id': assignedDelivererId, // Already serialized
      'chat_id': chatId, // NEW: Serialize to JSON
    };
  }

  Order copyWith({
    String? orderId,
    String? userId,
    String? supplierId,
    String? supplierLocationId,
    String? category,
    OrderDetails? details,
    DeliveryAddress? deliveryAddress,
    Schedule? schedule,
    String? instructions,
    String? status,
    DateTime? createdAt,
    DateTime? estimatedDeliveryTime,
    String? paymentMethod,
    bool? isRecurring,
    String? assignedDelivererId,
    String? chatId, // NEW: Add to copyWith
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      supplierId: supplierId ?? this.supplierId,
      supplierLocationId: supplierLocationId ?? this.supplierLocationId,
      category: category ?? this.category,
      details: details ?? this.details,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      schedule: schedule ?? this.schedule,
      instructions: instructions ?? this.instructions,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isRecurring: isRecurring ?? this.isRecurring,
      assignedDelivererId: assignedDelivererId ?? this.assignedDelivererId,
      chatId: chatId ?? this.chatId, // NEW: Assign new field
    );
  }
}

class OrderDetails {
  final double? liters;
  final double? pricePerLiter;
  final OrderItem? item;
  final String? type; // For Garbage Disposal types: 'Collection', 'Bags Only'
  final int? bags;
  final double? basePrice; // For Collection
  final double? additionalBagPrice; // For Collection
  final int? additionalBags; // For Collection
  final double? pricePerBag; // For Bags Only
  final int? trips; // For Emptying
  final double? pricePerTrip; // For Emptying
  final double deliveryFee;
  final double totalCost;

  OrderDetails({
    this.liters,
    this.pricePerLiter,
    this.item,
    this.type,
    this.bags,
    this.basePrice,
    this.additionalBagPrice,
    this.additionalBags,
    this.pricePerBag,
    this.trips,
    this.pricePerTrip,
    required this.deliveryFee,
    required this.totalCost,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json, String category) {
    switch (category) {
      case 'Clean Water Services':
        return OrderDetails(
          liters: (json['liters'] as num?)?.toDouble(),
          pricePerLiter: (json['price_per_liter'] as num?)?.toDouble(),
          deliveryFee: (json['delivery_fee'] as num).toDouble(),
          totalCost: (json['total_cost'] as num).toDouble(),
        );
      case 'Gas Supply and Refill':
      case 'Drinking Water':
        return OrderDetails(
          item: json['item'] != null ? OrderItem.fromJson(json['item']) : null,
          deliveryFee: (json['delivery_fee'] as num).toDouble(),
          totalCost: (json['total_cost'] as num).toDouble(),
        );
      case 'Garbage Disposal':
        return OrderDetails(
          type: json['type'],
          bags: json['bags'],
          basePrice: (json['base_price'] as num?)?.toDouble(),
          additionalBagPrice: (json['additional_bag_price'] as num?)?.toDouble(),
          additionalBags: json['additional_bags'],
          pricePerBag: (json['price_per_bag'] as num?)?.toDouble(),
          deliveryFee: (json['delivery_fee'] as num).toDouble(),
          totalCost: (json['total_cost'] as num).toDouble(),
        );
      case 'Toilet/Latrine/Septic Tank Emptying':
        return OrderDetails(
          trips: json['trips'],
          pricePerTrip: (json['price_per_trip'] as num?)?.toDouble(),
          deliveryFee: (json['delivery_fee'] as num).toDouble(),
          totalCost: (json['total_cost'] as num).toDouble(),
        );
      default:
        return OrderDetails(
          deliveryFee: (json['delivery_fee'] as num).toDouble(),
          totalCost: (json['total_cost'] as num).toDouble(),
        );
    }
  }

  Map<String, dynamic> toJson(String category) {
    final json = <String, dynamic>{
      'delivery_fee': deliveryFee,
      'total_cost': totalCost,
    };
    if (liters != null) json['liters'] = liters;
    if (pricePerLiter != null) json['price_per_liter'] = pricePerLiter;
    if (item != null) json['item'] = item!.toJson();
    if (type != null) json['type'] = type;
    if (bags != null) json['bags'] = bags;
    if (basePrice != null) json['base_price'] = basePrice;
    if (additionalBagPrice != null) json['additional_bag_price'] = additionalBagPrice;
    if (additionalBags != null) json['additional_bags'] = additionalBags;
    if (pricePerBag != null) json['price_per_bag'] = pricePerBag;
    if (trips != null) json['trips'] = trips;
    if (pricePerTrip != null) json['price_per_trip'] = pricePerTrip;
    return json;
  }
}

class OrderItem {
  final String type;
  final String? brand;
  final String? size;
  final int quantity;
  final double price;
  final String? name; // For accessories

  OrderItem({
    required this.type,
    this.brand,
    this.size,
    required this.quantity,
    required this.price,
    this.name,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      type: json['type'],
      brand: json['brand'],
      size: json['size'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'type': type,
      'quantity': quantity,
      'price': price,
    };
    if (brand != null) json['brand'] = brand;
    if (size != null) json['size'] = size;
    if (name != null) json['name'] = name;
    return json;
  }
}

class DeliveryAddress {
  final String address;
  final Coordinates coordinates;

  DeliveryAddress({required this.address, required this.coordinates});

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      address: json['address'],
      coordinates: Coordinates.fromJson(json['coordinates']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'coordinates': coordinates.toJson(),
    };
  }
}

class Schedule {
  final String type;
  final String? dateTime;
  final String? day;
  final String? time;
  final int? dayOfMonth;

  Schedule({
    required this.type,
    this.dateTime,
    this.day,
    this.time,
    this.dayOfMonth,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      type: json['type'],
      dateTime: json['date_time'],
      day: json['day'],
      time: json['time'],
      dayOfMonth: json['day_of_month'],
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'type': type};
    if (dateTime != null) json['date_time'] = dateTime;
    if (day != null) json['day'] = day;
    if (time != null) json['time'] = time;
    if (dayOfMonth != null) json['day_of_month'] = dayOfMonth;
    return json;
  }
}
