import 'package:amenities_kenya/constants.dart';
import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:amenities_kenya/models/order.dart';
import 'package:amenities_kenya/models/supplier.dart'; // Import Supplier model
import 'package:amenities_kenya/providers/order_provider.dart';
import 'package:amenities_kenya/providers/auth_provider.dart';
import 'package:amenities_kenya/utilities/dialogs.dart';
import 'package:amenities_kenya/utilities/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _paymentMethod = 'M-Pesa';
  bool _recurring = false;
  bool _isProcessing = false;

  late Order _initialOrderDetails; // To hold the order-like details from the previous screen
  late Supplier _supplierFromConfirmation; // To hold the supplier from the previous screen

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the Map of arguments passed from OrderConfirmationScreen
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    _supplierFromConfirmation = args['supplier'] as Supplier;
    final orderDetails = args['orderDetails'] as OrderDetails;
    final deliveryAddress = args['deliveryAddress'] as DeliveryAddress;
    final schedule = args['schedule'] as Schedule;
    final instructions = args['instructions'] as String;
    final selectedSupplierLocationId = args['selectedSupplierLocationId'] as String?;

    // Construct a temporary Order object from the initial details
    _initialOrderDetails = Order(
      userId: '', // Will be set correctly later
      supplierId: _supplierFromConfirmation.supplierId,
      supplierLocationId: selectedSupplierLocationId,
      category: _supplierFromConfirmation.category,
      details: orderDetails,
      deliveryAddress: deliveryAddress,
      schedule: schedule,
      instructions: instructions,
      status: 'Pending Payment Selection', // Initial status
      createdAt: DateTime.now().toUtc(), orderId: '', // Initial creation time
    );
  }

  Future<void> _proceedToSummary() async {
    setState(() => _isProcessing = true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final userId = ref.read(userProvider)!.userId!;
      final orderWithPaymentDetails = _initialOrderDetails.copyWith(
        userId: userId,
        paymentMethod: _paymentMethod,
        isRecurring: _recurring,
        status: 'Awaiting Confirmation',
      );

      if (mounted) {
        // Pass a Map containing both the complete Order and the Supplier
        Navigator.pushReplacementNamed(
          context,
          NavigationService.orderSummary,
          arguments: {
            'order': orderWithPaymentDetails,
            'supplier': _supplierFromConfirmation,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        CustomDialogs.showErrorDialog(
          context: context,
          title: AppLocalizations.of(context)!.error,
          content: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          translations.payment,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              '\$${_initialOrderDetails.details.totalCost.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.payment,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  translations.paymentMethod,
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            DropdownButtonFormField<String>(
                              value: _paymentMethod,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: AppColors.lightGray.withOpacity(0.1),
                              ),
                              items: ['M-Pesa', 'Cash on Delivery', 'Credit Card']
                                  .map((method) => DropdownMenuItem(
                                        value: method,
                                        child: Text(method),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _paymentMethod = value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.repeat_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  translations.recurringOrder,
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            CheckboxListTile(
                              value: _recurring,
                              onChanged: (value) {
                                setState(() => _recurring = value ?? false);
                              },
                              activeColor: Theme.of(context).colorScheme.primary,
                              title: null,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(translations.proceed),
                        onPressed: _isProcessing ? null : _proceedToSummary,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


