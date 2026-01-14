import 'package:amenities_kenya/constants.dart';
import 'package:amenities_kenya/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthService {
  final ApiClient _dioClient;

  MockAuthService(this._dioClient);

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<String> sendOtp(String phoneNumber) async {
    final headers = await _getAuthHeaders();
    final response = await _dioClient.post(
      '/users/send-otp',
      headers: headers,
      {'phone_number': phoneNumber},
    );

    if (response['result_code'] == 1) {
      return response['message']; // Note: In production, OTP should not be returned in response
    } else {
      throw Exception(response['message']);
    }
  }

  Future<User> verifyOtp(String phoneNumber, String otp) async {
    final headers = await _getAuthHeaders();
    final response = await _dioClient.post(
      '/users/verify-otp',
      headers: headers,
      {'phone_number': phoneNumber, 'otp': otp},
    );

    if (response['result_code'] == 1) {
      final user = User.fromJson(response['user']);
      print("user is $user");
      return user;
    } else {
      throw Exception(response['message']);
    }
  }

  Future<User> signUp({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final headers = await _getAuthHeaders();
    final response = await _dioClient
        .post('/users/register', headers: headers, {
          'phone_number': phoneNumber,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
        });

    if (response['result_code'] == 1) {
      return User.fromJson(response['user']);
    } else {
      throw Exception(response['message']);
    }
  }

  Future<User> getUserProfile() async {
    final headers = await _getAuthHeaders();
    final response = await _dioClient.post(
      '/users/profile',
      headers: headers,
      {},
    );

    if (response['result_code'] == 1) {
      return User.fromJson(response['user']);
    } else {
      throw Exception(response['message']);
    }
  }

  Future<User> updateProfile({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final headers = await _getAuthHeaders();
    final data = {
      'phone_number': phoneNumber,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
    };

    final response = await _dioClient.post(
      '/users/profile',
      headers: headers,
      data,
    );

    if (response['result_code'] == 1) {
      return User.fromJson(response['user']);
    } else {
      throw Exception(response['message']);
    }
  }
}
