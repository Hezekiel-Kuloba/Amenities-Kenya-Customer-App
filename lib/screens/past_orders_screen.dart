import 'package:amenities_kenya/constants.dart';
import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:amenities_kenya/models/order.dart';
import 'package:amenities_kenya/providers/auth_provider.dart';
import 'package:amenities_kenya/providers/order_provider.dart';
import 'package:amenities_kenya/services/mock_supplier_service.dart';
import 'package:amenities_kenya/utilities/date_formatter.dart';
import 'package:amenities_kenya/utilities/navigation_service.dart';
import 'package:amenities_kenya/widgets/order_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PastOrdersScreen extends ConsumerStatefulWidget {
  const PastOrdersScreen({super.key});

  @override
  _PastOrdersScreenState createState() => _PastOrdersScreenState();
}

class _PastOrdersScreenState extends ConsumerState<PastOrdersScreen> {
  @override
  void initState() {
    super.initState();
    final userId = ref.read(userProvider)!.userId;
    ref.read(orderProvider.notifier).fetchUserOrders(userId!);
  }

  Future<void> _reorder(Order order) async {
    final supplierService = MockSupplierService(ApiClient());
    try {
      final supplier = await supplierService.getSupplierById(order.supplierId);
      Navigator.pushNamed(
        context,
        NavigationService.orderCustomization,
        arguments: {
          'supplier': supplier,
          'address': order.deliveryAddress.address,
          'coordinates': order.deliveryAddress.coordinates,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(title: Text(translations.pastOrders)),
      body: orderState.when(
        data: (orders) => orders.isEmpty
            ? Center(child: Text(translations.noOrders))
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${translations.order} #${order.orderId!.substring(0, 8)}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            DateFormatter.formatDateTime(order.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8.0),
                          OrderItemWidget(
                            details: order.details,
                            category: order.category,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            '${translations.status}: ${order.status}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    NavigationService.orderTracking,
                                    arguments: order,
                                  );
                                },
                                child: Text(translations.viewDetails),
                              ),
                              ElevatedButton(
                                onPressed: () => _reorder(order),
                                child: Text(translations.reorder),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}