import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:amenities_kenya/models/order.dart';
import 'package:amenities_kenya/models/supplier.dart';
import 'package:amenities_kenya/models/supplier_display_data.dart';
import 'package:amenities_kenya/utilities/navigation_service.dart';
import 'package:amenities_kenya/widgets/order_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class OrderConfirmationScreen extends ConsumerWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final supplier = args['supplier'] as Supplier;
    final orderDetails = args['orderDetails'] as OrderDetails;
    final deliveryAddress = args['deliveryAddress'] as DeliveryAddress;
    final schedule = args['schedule'] as Schedule;
    final instructions = args['instructions'] as String;
    final selectedSupplierLocationId =
        args['selectedSupplierLocationId'] as String?;
    final translations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          translations.orderConfirmation,
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  translations.orderDetails,
                                  style: Theme.of(context).textTheme.titleLarge!
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            OrderItemWidget(
                              details: orderDetails,
                              category: supplier.category,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.store_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  translations.supplier,
                                  style: Theme.of(context).textTheme.titleLarge!
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              '${supplier.name} - ${supplier.locations.isNotEmpty ? supplier.locations[0].locationName : "No location available"}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '${supplier.averageRating!.toStringAsFixed(1)} (${supplier.reviewCount} reviews)',
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  translations.deliveryAddress,
                                  style: Theme.of(context).textTheme.titleLarge!
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              deliveryAddress.address,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  translations.schedule,
                                  style: Theme.of(context).textTheme.titleLarge!
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              schedule.type,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            if (schedule.dateTime != null)
                              Text(
                                DateFormat('yyyy-MM-dd HH:mm').format(
                                  DateTime.parse(schedule.dateTime!).toLocal(),
                                ),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            if (schedule.day != null)
                              Text(
                                '${translations.day}: ${schedule.day}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            if (schedule.time != null)
                              Text(
                                '${translations.time}: ${schedule.time}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            if (schedule.dayOfMonth != null)
                              Text(
                                '${translations.dayOfMonth}: ${schedule.dayOfMonth}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (instructions.isNotEmpty) ...[
                      const SizedBox(height: 8.0),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.note_outlined,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    translations.instructions,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                instructions,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8.0),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.monetization_on_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  translations.totalCost,
                                  style: Theme.of(context).textTheme.titleLarge!
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              '\$${orderDetails.totalCost.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: Text(translations.back),
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_forward),
                      label: Text("Payment Method"), // Changed label
                      onPressed: () {
                        // Pass all necessary initial data as a Map to PaymentScreen
                        Navigator.pushNamed(
                          context,
                          NavigationService.payment,
                          arguments: {
                            'supplier': supplier,
                            'orderDetails': orderDetails,
                            'deliveryAddress': deliveryAddress,
                            'schedule': schedule,
                            'instructions': instructions,
                            'selectedSupplierLocationId': selectedSupplierLocationId,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}