// order_provider.dart
import 'package:amenities_kenya/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amenities_kenya/models/order.dart';
import 'package:amenities_kenya/services/mock_order_service.dart';

final orderProvider = StateNotifierProvider<OrderNotifier, AsyncValue<List<Order>>>((ref) {
  return OrderNotifier(ref);
});

// NEW: Provider for a single order, used for polling in tracking screen
final specificOrderProvider = StateNotifierProvider.family<SpecificOrderNotifier, AsyncValue<Order?>, String>((ref, orderId) {
  return SpecificOrderNotifier(ref, orderId);
});

class OrderNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  final Ref _ref;
  final MockOrderService _orderService = MockOrderService(ApiClient());

  OrderNotifier(this._ref) : super(const AsyncValue.data([]));

  Future<void> fetchUserOrders(String userId) async {
    state = const AsyncValue.loading();
    try {
      final orders = await _orderService.getUserOrders(userId);
      state = AsyncValue.data(orders);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

Future<Order?> createOrder(Order order) async { // Changed return type to Future<Order?>
    try {
      final newOrder = await _orderService.createOrder(order);
      state.whenData((orders) {
        state = AsyncValue.data([...orders, newOrder]);
      });
      return newOrder; // Return the newly created order
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null; // Return null on error
    }
  }
  

  // NEW: Method to update order status, primarily for internal use or by admin/supplier logic
  Future<void> updateOrderStatus(String orderId, String status, {String? assignedDelivererId}) async {
    try {
      await _orderService.updateOrderStatus(orderId, status, assignedDelivererId: assignedDelivererId);
      // Optionally, refetch user orders or update the specific order in state
      // For a simple update, we might just rely on polling in the tracking screen
    } catch (e, stack) {
      // Handle error, e.g., show a snackbar
      print('Error updating order status: $e');
    }
  }
}

// NEW: SpecificOrderNotifier to manage the state of a single order for the tracking screen
class SpecificOrderNotifier extends StateNotifier<AsyncValue<Order?>> {
  final Ref _ref;
  final String _orderId;
  final MockOrderService _orderService = MockOrderService(ApiClient());

  SpecificOrderNotifier(this._ref, this._orderId) : super(const AsyncValue.data(null)) {
    _fetchOrder(); // Initial fetch
  }

  Future<void> _fetchOrder() async {
    state = const AsyncValue.loading();
    try {
      final order = await _orderService.getOrderById(_orderId);
      state = AsyncValue.data(order);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Method to manually refresh the order data
  Future<void> refreshOrder() async {
    await _fetchOrder();
  }
}