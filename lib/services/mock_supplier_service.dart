import 'package:amenities_kenya/constants.dart';
import 'package:amenities_kenya/models/supplier.dart';
import 'package:amenities_kenya/models/supplier_display_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class  MockSupplierService {
  final ApiClient _dioClient;

   MockSupplierService(this._dioClient,);

  Future<Map<String, String>> _getAuthHeaders() async {
        final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

Future<List<SupplierDisplayData>> getSuppliersByCategory(String category) async {
    final headers = await _getAuthHeaders();
    final response = await _dioClient.post(
      '/users/suppliers',
      headers: headers,
       {'category': category},
    );

    if (response['result_code'] == 1) {
      final List<dynamic> suppliersData = response['suppliers'] ?? [];
      final List<SupplierDisplayData> displaySuppliers = [];

      for (final sJson in suppliersData) {
        final supplier = Supplier.fromJson(sJson);
        for (final location in supplier.locations) {
          if (!location.isDeleted!) { // Only include non-deleted locations
            displaySuppliers.add(
              SupplierDisplayData.fromSupplierAndLocation(supplier, location),
            );
          }
        }
      }
      return displaySuppliers;
    } else {
      throw Exception(response['message'] ?? 'Failed to fetch suppliers');
    }
  }
  Future<Supplier> getSupplierById(String supplierId) async {
    final headers = await _getAuthHeaders();
    final response = await _dioClient.post(
      '/users/supplier-details',
      headers: headers,
      {'supplier_id': supplierId},
    );

    if (response['result_code'] == 1) {
      return Supplier.fromJson(response['supplier']);
    } else {
      throw Exception(response['message']);
    }
  }
}
