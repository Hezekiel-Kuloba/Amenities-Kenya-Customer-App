// mock_order_service.dart
import 'package:amenities_kenya/constants.dart';
import 'package:amenities_kenya/models/order.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockOrderService {
  final ApiClient _dioClient;

  MockOrderService(this._dioClient);

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Order>> getUserOrders(String userId) async {
    final headers = await _getAuthHeaders();
    final response = await _dioClient.post('/orders/by-user', {
      'user_id': userId,
    }, headers: headers);

    if (response['result_code'] == 1) {
      final List<dynamic> ordersData = response['orders'] ?? [];
      return ordersData.map((o) => Order.fromJson(o)).toList();
    } else {
      throw Exception(response['message']);
    }
  }

 Future<Order> createOrder(Order order) async {
    final headers = await _getAuthHeaders();
    final response = await _dioClient.post(
      '/users/create-order',
      order.toJson(),
      headers: headers,
    );

    if (response['result_code'] == 1) {
      return Order.fromJson(response['order']); // This is crucial: return the parsed Order
    } else {
      throw Exception(response['message']);
    }
  }

  // NEW METHOD: Get Order by ID
  Future<Order> getOrderById(String orderId) async {
    final headers = await _getAuthHeaders();
    final response = await _dioClient.post(
      '/users/get-order-by-id', // This is the new API endpoint for fetching a single order
            headers: headers,
      {
        'order_id': orderId,
      },
    );

    if (response['result_code'] == 1) {
      return Order.fromJson(response['order']);
    } else {
      throw Exception(response['message']);
    }
  }

  // NEW METHOD: Update Order Status (for potential future use from client, or internal simulation)
  // This method calls the backend endpoint we created earlier.
  Future<void> updateOrderStatus(String orderId, String status, {String? assignedDelivererId}) async {
    final headers = await _getAuthHeaders();
    final response = await _dioClient.post(
      '/users/update-order-status', // The new API endpoint for updating status
      {
        'order_id': orderId,
        'status': status,
        if (assignedDelivererId != null) 'assigned_deliverer_id': assignedDelivererId,
      },
      headers: headers,
    );

    if (response['result_code'] != 1) {
      throw Exception(response['message']);
    }
  }

  Future<void> placeOrder(Order order) async {
    // This method seems incomplete or might be a placeholder.
    // Ensure it integrates with your actual backend payment logic.
    // For now, it will simply call createOrder (if not done already)
    // or simulate a successful placement.
    try {
      // Assuming createOrder already handles sending the order to the backend
      // If 'placeOrder' is meant for a separate backend call after creation,
      // you'd need a specific endpoint for it.
      // For now, just a placeholder.
      print('Simulating order placement for order: ${order.orderId}');
      // In a real scenario, this would interact with a payment gateway
      // and update the order status.
    } catch (e) {
      rethrow;
    }
  }
}


 