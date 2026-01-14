// order_summary_screen.dart
import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:amenities_kenya/models/order.dart';
import 'package:amenities_kenya/models/supplier.dart'; // Import Supplier model
import 'package:amenities_kenya/models/supplier_display_data.dart';
import 'package:amenities_kenya/providers/auth_provider.dart';
import 'package:amenities_kenya/providers/order_provider.dart';
import 'package:amenities_kenya/utilities/navigation_service.dart';
import 'package:amenities_kenya/widgets/order_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class OrderSummaryScreen extends ConsumerWidget {
  const OrderSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Correctly receive the arguments as a Map
    final Map<String, dynamic> receivedArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Extract the Order and Supplier objects from the map
    final Order completeOrder = receivedArgs['order'] as Order;
    final Supplier supplier =
        receivedArgs['supplier'] as Supplier; // Now receive Supplier here

    final translations = AppLocalizations.of(context)!;

    // Extract details from the completeOrder object
    final orderDetails = completeOrder.details;
    final deliveryAddress = completeOrder.deliveryAddress;
    final schedule = completeOrder.schedule;
    final instructions = completeOrder.instructions;
    final selectedSupplierLocationId =
        completeOrder.supplierLocationId; // Now available in order

    return Scaffold(
      appBar: AppBar(
        title: Text(
          translations.orderSummary,
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
                      elevation: 2,
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
                            // In your OrderSummaryScreen (or wherever this line is)
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
                                  Icons
                                      .credit_card_outlined, // Icon for payment method
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  translations.paymentMethod,
                                  style: Theme.of(context).textTheme.titleLarge!
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              '${completeOrder.paymentMethod}', // Display payment method
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            if (completeOrder.isRecurring)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "Recurring Order Enabled", // e.g., "Recurring Order Enabled"
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey[700],
                                      ),
                                ),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline), // Changed icon
                  label: Text(
                    translations.placeOrder,
                  ), // Label remains "Place Order"
                  onPressed: () async {
                    final createdOrder = await ref
                        .read(orderProvider.notifier)
                        .createOrder(
                          completeOrder.copyWith(
                            status:
                                'Waiting for Confirmation', // Set initial status after placing order
                            estimatedDeliveryTime:
                                completeOrder.schedule.dateTime != null
                                ? DateTime.parse(
                                    completeOrder.schedule.dateTime!,
                                  ).add(const Duration(hours: 2))
                                : null,
                          ),
                        );
                    if (context.mounted && createdOrder != null) {
                      // Check if createdOrder is not null
                      Navigator.pushReplacementNamed(
                        context,
                        NavigationService.orderTracking,
                        arguments:
                            createdOrder, // Pass the created order (which now has orderId)
                      );
                    }
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
        ),
      ),
    );
  }
}
