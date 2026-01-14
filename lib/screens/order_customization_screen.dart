import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:amenities_kenya/models/order.dart';
import 'package:amenities_kenya/models/supplier.dart';
import 'package:amenities_kenya/models/supplier_display_data.dart';
import 'package:amenities_kenya/models/product_item.dart';
import 'package:amenities_kenya/utilities/distance_calculator.dart';
import 'package:amenities_kenya/utilities/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

class OrderCustomizationScreen extends ConsumerStatefulWidget {
  const OrderCustomizationScreen({super.key});

  @override
  _OrderCustomizationScreenState createState() => _OrderCustomizationScreenState();
}

class _OrderCustomizationScreenState extends ConsumerState<OrderCustomizationScreen> {
  String? _selectedType;
  String? _selectedSize;
  String? _selectedBrand;
  String? _selectedAccessory;
  int _quantity = 1;
  int _bags = 1;
  int _trips = 1;
  double _liters = 100;
  double _totalCost = 0.0;
  double _deliveryFee = 0.0;

  late SupplierDisplayData _supplierDisplayData;
  late Coordinates _userDeliveryCoordinates;
  late String _userDeliveryAddress;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _supplierDisplayData = args['supplierDisplayData'] as SupplierDisplayData;
        _userDeliveryAddress = args['address'] as String;
        _userDeliveryCoordinates = args['coordinates'] as Coordinates;

        _initializeSelections();
        _calculateCost();
        _isInitialized = true;
      }
    }
  }

  void _initializeSelections() {
    final productCatalog = _supplierDisplayData.productCatalog;
    switch (_supplierDisplayData.category) {
      case 'Clean Water Services':
        _liters = 100;
        break;
      case 'Gas Supply and Refill':
        _selectedType = 'New Cylinder with Gas';
        final firstCylinder = productCatalog.whereType<CylinderItem>().firstOrNull;
        if (firstCylinder != null) {
          _selectedBrand = firstCylinder.brand;
          _selectedSize = firstCylinder.size;
        } else {
          final firstAccessory = productCatalog.whereType<AccessoryItem>().firstOrNull;
          if (firstAccessory != null) {
            _selectedType = 'Accessory';
            _selectedAccessory = firstAccessory.name;
          }
        }
        break;
      case 'Drinking Water':
        _selectedType = 'New Bottle with Water';
        final firstBottle = productCatalog.whereType<BottleItem>().firstOrNull;
        if (firstBottle != null) {
          _selectedSize = firstBottle.size;
        }
        _quantity = 1;
        break;
      case 'Garbage Disposal':
        _selectedType = 'Collection';
        _bags = 1;
        break;
      case 'Toilet/Latrine/Septic Tank Emptying':
        _trips = 1;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          translations.customizeOrder,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.store,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _isInitialized ? '${_supplierDisplayData.supplierName} - ${_supplierDisplayData.locationName}' : 'Loading Supplier Data...',
                              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      // Display location-specific rating and review count
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isInitialized
                                ? '${_supplierDisplayData.averageRating!.toStringAsFixed(1)} (${_supplierDisplayData.reviewCount} reviews)'
                                : '0.0 (0 reviews)',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                      // Display reviews if available
                      if (_isInitialized && _supplierDisplayData.reviews!.isNotEmpty) ...[
                        const SizedBox(height: 8.0),
                        Text(
                          translations.reviews,
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8.0),
                        ..._supplierDisplayData.reviews!
                            .where((review) => !review.isDeleted)
                            .map((review) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    '"${review.content}" - ${review.timestamp.toLocal().toString().split('.')[0]}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ))
                            .toList(),
                      ],
                      const SizedBox(height: 16.0),
                      if (_isInitialized) _buildCustomizationForm(_supplierDisplayData, translations) else const CircularProgressIndicator(),
                      const SizedBox(height: 24.0),
                      Row(
                        children: [
                          Icon(
                            Icons.monetization_on,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${translations.totalCost}: \$${_totalCost.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(translations.proceed),
                  onPressed: _isInitialized
                      ? () {
                          final Supplier mockSupplier = Supplier(
                            supplierId: _supplierDisplayData.supplierId,
                            name: _supplierDisplayData.supplierName,
                            category: _supplierDisplayData.category,
                            contactPhone: _supplierDisplayData.contactPhone,
                            imageUrl: _supplierDisplayData.imageUrl,
                            averageRating: _supplierDisplayData.averageRating!,
                            reviewCount: _supplierDisplayData.reviewCount!,
                            pricing: _supplierDisplayData.pricing,
                            promotions: _supplierDisplayData.promotions,
                            availability: _supplierDisplayData.availability,
                            createdAt: _supplierDisplayData.createdAt,
                            locations: [
                              _supplierDisplayData.toSupplierLocation(),
                            ],
                          );

                          Navigator.pushNamed(
                            context,
                            NavigationService.scheduling,
                            arguments: {
                              'supplier': mockSupplier,
                              'orderDetails': _buildOrderDetails(),
                              'deliveryCoordinates': _userDeliveryCoordinates,
                              'deliveryAddress': _userDeliveryAddress,
                              'selectedSupplierLocationId': _supplierDisplayData.locationId,
                            },
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomizationForm(SupplierDisplayData supplierDisplayData, AppLocalizations translations) {
    final productCatalog = supplierDisplayData.productCatalog;
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        children: [
          const SizedBox(height: 8.0),
          switch (supplierDisplayData.category) {
            'Clean Water Services' => Column(
              children: [
                TextFormField(
                  initialValue: _liters.toStringAsFixed(0),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: translations.liters,
                    prefixIcon: const Icon(Icons.water_drop, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _liters = double.tryParse(value) ?? 0;
                      _calculateCost();
                    });
                  },
                ),
              ],
            ),
            'Gas Supply and Refill' => Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: translations.itemType,
                    prefixIcon: const Icon(Icons.propane_tank, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    'New Cylinder',
                    'New Cylinder with Gas',
                    'Refill',
                    'Accessory',
                  ].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                      _selectedSize = null;
                      _selectedBrand = null;
                      _selectedAccessory = null;

                      if (_selectedType == 'Accessory') {
                        final firstAccessory = productCatalog.whereType<AccessoryItem>().firstOrNull;
                        if (firstAccessory != null) {
                          _selectedAccessory = firstAccessory.name;
                        }
                      } else if (_selectedType != null) {
                        final firstCylinder = productCatalog.whereType<CylinderItem>().firstOrNull;
                        if (firstCylinder != null) {
                          _selectedBrand = firstCylinder.brand;
                          _selectedSize = firstCylinder.size;
                        }
                      }
                      _calculateCost();
                    });
                  },
                ),
                if (_selectedType != 'Accessory' && _selectedType != null) ...[
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _selectedBrand,
                    decoration: InputDecoration(
                      labelText: translations.brand,
                      prefixIcon: const Icon(Icons.branding_watermark, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: productCatalog.whereType<CylinderItem>()
                        .map((c) => c.brand)
                        .toSet()
                        .map((brand) => DropdownMenuItem(value: brand, child: Text(brand)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBrand = value;
                        _selectedSize = null;
                        final firstValidSizeForNewBrand = productCatalog.whereType<CylinderItem>()
                            .firstWhereOrNull((c) => c.brand == _selectedBrand)?.size;
                        if (firstValidSizeForNewBrand != null) {
                          _selectedSize = firstValidSizeForNewBrand;
                        }
                        _calculateCost();
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _selectedSize,
                    decoration: InputDecoration(
                      labelText: translations.size,
                      prefixIcon: const Icon(Icons.scale, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: productCatalog.whereType<CylinderItem>()
                        .where((c) => c.brand == _selectedBrand)
                        .map((c) => c.size)
                        .map((size) => DropdownMenuItem(value: size, child: Text(size)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSize = value;
                        _calculateCost();
                      });
                    },
                  ),
                ],
                if (_selectedType == 'Accessory') ...[
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _selectedAccessory,
                    decoration: InputDecoration(
                      labelText: translations.accessory,
                      prefixIcon: const Icon(Icons.build, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: productCatalog.whereType<AccessoryItem>()
                        .map((a) => DropdownMenuItem(value: a.name, child: Text(a.name)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAccessory = value;
                        _calculateCost();
                      });
                    },
                  ),
                ],
              ],
            ),
            'Drinking Water' => Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: translations.itemType,
                    prefixIcon: const Icon(Icons.local_drink, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    'New Bottle',
                    'New Bottle with Water',
                    'Refill',
                  ].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                      _selectedSize = null;
                      if (_selectedType != null) {
                        final firstBottle = productCatalog.whereType<BottleItem>().firstOrNull;
                        if (firstBottle != null) {
                          _selectedSize = firstBottle.size;
                        }
                      }
                      _calculateCost();
                    });
                  },
                ),
                if (_selectedType != null) ...[
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _selectedSize,
                    decoration: InputDecoration(
                      labelText: translations.size,
                      prefixIcon: const Icon(Icons.scale, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: productCatalog.whereType<BottleItem>()
                        .map((b) => DropdownMenuItem(value: b.size, child: Text(b.size)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSize = value;
                        _calculateCost();
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    initialValue: _quantity.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: translations.quantity,
                      prefixIcon: const Icon(Icons.add_circle_outline, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _quantity = int.tryParse(value) ?? 1;
                        _calculateCost();
                      });
                    },
                  ),
                ],
              ],
            ),
            'Garbage Disposal' => Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: translations.itemType,
                    prefixIcon: const Icon(Icons.delete_outline, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    'Collection',
                    'Bags Only',
                  ].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                      _calculateCost();
                    });
                  },
                ),
                if (_selectedType != null) ...[
                  const SizedBox(height: 16.0),
                  TextFormField(
                    initialValue: _bags.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: translations.bags,
                      prefixIcon: const Icon(Icons.delete, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _bags = int.tryParse(value) ?? 1;
                        _calculateCost();
                      });
                    },
                  ),
                ],
              ],
            ),
            'Toilet/Latrine/Septic Tank Emptying' => Column(
              children: [
                TextFormField(
                  initialValue: _trips.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: translations.trips,
                    prefixIcon: const Icon(Icons.local_shipping_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _trips = int.tryParse(value) ?? 1;
                      _calculateCost();
                    });
                  },
                ),
              ],
            ),
            _ => const SizedBox.shrink(),
          },
        ],
      ),
    );
  }

  void _calculateCost() {
    if (!_isInitialized) {
      return;
    }

    final productCatalog = _supplierDisplayData.productCatalog;
    final distance = DistanceCalculator.calculateDistance(
      _supplierDisplayData.locationCoordinates.lat,
      _supplierDisplayData.locationCoordinates.lon,
      _userDeliveryCoordinates.lat,
      _userDeliveryCoordinates.lon,
    );

    _deliveryFee = (_supplierDisplayData.pricing.deliveryFeePerKm ?? 0) * distance;

    double itemCost = 0.0;
    switch (_supplierDisplayData.category) {
      case 'Clean Water Services':
        final bulkWaterItem = productCatalog.whereType<BulkWaterItem>().firstOrNull;
        itemCost = _liters * (bulkWaterItem?.pricePerLiter ?? 0);
        break;
      case 'Gas Supply and Refill':
        if (_selectedType == 'Accessory' && _selectedAccessory != null) {
          final accessory = productCatalog.whereType<AccessoryItem>()
              .firstWhereOrNull((a) => a.name == _selectedAccessory);
          itemCost = accessory?.price ?? 0;
        } else if (_selectedType != null && _selectedBrand != null && _selectedSize != null) {
          final cylinder = productCatalog.whereType<CylinderItem>()
              .firstWhereOrNull((c) => c.brand == _selectedBrand && c.size == _selectedSize);
          itemCost = _selectedType == 'New Cylinder'
              ? (cylinder?.newPrice ?? 0)
              : _selectedType == 'New Cylinder with Gas'
              ? (cylinder?.newPrice ?? 0) + (cylinder?.refillPrice ?? 0)
              : (cylinder?.refillPrice ?? 0);
        }
        break;
      case 'Drinking Water':
        if (_selectedType != null && _selectedSize != null) {
          final bottle = productCatalog.whereType<BottleItem>()
              .firstWhereOrNull((b) => b.size == _selectedSize);
          itemCost = _quantity *
              (_selectedType == 'New Bottle'
                  ? (bottle?.newPrice ?? 0)
                  : _selectedType == 'New Bottle with Water'
                  ? (bottle?.newPrice ?? 0) + (bottle?.refillPrice ?? 0)
                  : (bottle?.refillPrice ?? 0));
        }
        break;
      case 'Garbage Disposal':
        if (_selectedType == 'Collection' && _bags > 0) {
          final collection = productCatalog.whereType<CollectionItem>().firstOrNull;
          itemCost = collection?.basePrice ?? 0;
          if (_bags > (collection?.bagsIncluded ?? 0)) {
            itemCost += (_bags - (collection?.bagsIncluded ?? 0)) * (collection?.additionalBagPrice ?? 0);
          }
        } else if (_selectedType == 'Bags Only' && _bags > 0) {
          final bagsOnly = productCatalog.whereType<BagsOnlyItem>().firstOrNull;
          itemCost = _bags * (bagsOnly?.pricePerBag ?? 0);
        }
        break;
      case 'Toilet/Latrine/Septic Tank Emptying':
        final emptyingTrip = productCatalog.whereType<EmptyingTripItem>().firstOrNull;
        itemCost = _trips * (emptyingTrip?.pricePerTrip ?? 0);
        break;
    }
    setState(() {
      _totalCost = itemCost + _deliveryFee;
    });
  }

  OrderDetails _buildOrderDetails() {
    if (!_isInitialized) {
      return OrderDetails(deliveryFee: 0.0, totalCost: 0.0);
    }
    ProductItem? selectedProductItem;
    CollectionItem? collectionItem;

    if (_supplierDisplayData.category == 'Clean Water Services') {
      selectedProductItem = _supplierDisplayData.productCatalog.whereType<BulkWaterItem>().firstOrNull;
    } else if (_supplierDisplayData.category == 'Gas Supply and Refill') {
      if (_selectedType == 'Accessory' && _selectedAccessory != null) {
        selectedProductItem = _supplierDisplayData.productCatalog.whereType<AccessoryItem>()
            .firstWhereOrNull((a) => a.name == _selectedAccessory);
      } else if (_selectedType != null && _selectedBrand != null && _selectedSize != null) {
        selectedProductItem = _supplierDisplayData.productCatalog.whereType<CylinderItem>()
            .firstWhereOrNull((c) => c.brand == _selectedBrand && c.size == _selectedSize);
      }
    } else if (_supplierDisplayData.category == 'Drinking Water') {
      if (_selectedType != null && _selectedSize != null) {
        selectedProductItem = _supplierDisplayData.productCatalog.whereType<BottleItem>()
            .firstWhereOrNull((b) => b.size == _selectedSize);
      }
    } else if (_supplierDisplayData.category == 'Garbage Disposal') {
      if (_selectedType == 'Collection') {
        selectedProductItem = _supplierDisplayData.productCatalog.whereType<CollectionItem>().firstOrNull;
        collectionItem = selectedProductItem as CollectionItem?;
      } else if (_selectedType == 'Bags Only') {
        selectedProductItem = _supplierDisplayData.productCatalog.whereType<BagsOnlyItem>().firstOrNull;
      }
    } else if (_supplierDisplayData.category == 'Toilet/Latrine/Septic Tank Emptying') {
      selectedProductItem = _supplierDisplayData.productCatalog.whereType<EmptyingTripItem>().firstOrNull;
    }

    double pricePerUnit = 0.0;
    if (selectedProductItem != null) {
      if (selectedProductItem is BulkWaterItem) {
        pricePerUnit = selectedProductItem.pricePerLiter;
      } else if (selectedProductItem is CylinderItem) {
        pricePerUnit = _selectedType == 'New Cylinder' ? selectedProductItem.newPrice :
        _selectedType == 'New Cylinder with Gas' ? selectedProductItem.newPrice + selectedProductItem.refillPrice :
        selectedProductItem.refillPrice;
      } else if (selectedProductItem is AccessoryItem) {
        pricePerUnit = selectedProductItem.price;
      } else if (selectedProductItem is BottleItem) {
        pricePerUnit = _selectedType == 'New Bottle' ? selectedProductItem.newPrice :
        _selectedType == 'New Bottle with Water' ? selectedProductItem.newPrice + selectedProductItem.refillPrice :
        selectedProductItem.refillPrice;
      } else if (selectedProductItem is CollectionItem) {
        pricePerUnit = collectionItem?.basePrice ?? 0;
      } else if (selectedProductItem is BagsOnlyItem) {
        pricePerUnit = selectedProductItem.pricePerBag;
      } else if (selectedProductItem is EmptyingTripItem) {
        pricePerUnit = selectedProductItem.pricePerTrip;
      }
    }

    switch (_supplierDisplayData.category) {
      case 'Clean Water Services':
        return OrderDetails(
          liters: _liters,
          pricePerLiter: pricePerUnit,
          deliveryFee: _deliveryFee,
          totalCost: _totalCost,
        );
      case 'Gas Supply and Refill':
        return OrderDetails(
          item: OrderItem(
            type: _selectedType!,
            brand: _selectedBrand,
            size: _selectedSize,
            quantity: 1,
            price: pricePerUnit,
            name: _selectedAccessory,
          ),
          deliveryFee: _deliveryFee,
          totalCost: _totalCost,
        );
      case 'Drinking Water':
        return OrderDetails(
          item: OrderItem(
            type: _selectedType!,
            size: _selectedSize,
            quantity: _quantity,
            price: pricePerUnit,
          ),
          deliveryFee: _deliveryFee,
          totalCost: _totalCost,
        );
      case 'Garbage Disposal':
        return OrderDetails(
          type: _selectedType,
          bags: _bags,
          basePrice: collectionItem?.basePrice,
          additionalBagPrice: collectionItem?.additionalBagPrice,
          additionalBags: (_selectedType == 'Collection' && collectionItem != null && _bags > collectionItem.bagsIncluded) ? _bags - collectionItem.bagsIncluded : 0,
          pricePerBag: (selectedProductItem as BagsOnlyItem?)?.pricePerBag,
          deliveryFee: _deliveryFee,
          totalCost: _totalCost,
        );
      case 'Toilet/Latrine/Septic Tank Emptying':
        return OrderDetails(
          trips: _trips,
          pricePerTrip: pricePerUnit,
          deliveryFee: _deliveryFee,
          totalCost: _totalCost,
        );
      default:
        return OrderDetails(deliveryFee: _deliveryFee, totalCost: _totalCost);
    }
  }
}