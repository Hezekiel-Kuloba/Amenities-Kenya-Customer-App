import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

const String baseUrl = "http://localhost:8877/api";


class AppColors {
  static const Color lightPrimary = Color(0xFF1976D2); // Blue
  static const Color lightSecondary = Color(0xFF64B5F6); // Light Blue
  static const Color lightSurface = Color(0xFFFFFFFF); // White
  static const Color lightError = Color(0xFFD32F2F); // Red
  static const Color lightOnPrimary = Color(0xFFFFFFFF); // White
  static const Color lightOnSecondary = Color(0xFF000000); // Black
  static const Color lightOnSurface = Color(0xFF000000); // Black
  static const Color lightOnError = Color(0xFFFFFFFF); // White
  static const Color lightBackground = Color(0xFFF5F5F5); // Off-White
  static const Color dividerColor = Color(0xFFB0BEC5); // Grey
  static const Color grey = Color(0xFF757575);
  static const Color yellow = Color(0xFFFFC107); // Amber
  static const Color lightGray = Color(0xFFE0E0E0); // Light Grey
  static const Color green = Color(0xFF4CAF50); // Green for success

  static const Color darkPrimary = Color(0xFF42A5F5); // Lighter Blue
  static const Color darkSecondary = Color(0xFF90CAF9); // Light Blue
  static const Color darkSurface = Color(0xFF212121); // Dark Grey
  static const Color darkError = Color(0xFFEF5350); // Red
  static const Color darkOnPrimary = Color(0xFF000000); // Black
  static const Color darkOnSecondary = Color(0xFF000000); // Black
  static const Color darkOnSurface = Color(0xFFFFFFFF); // White
  static const Color darkOnError = Color(0xFF000000); // Black
  static const Color darkBackground = Color(0xFF121212); // Dark
}

class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<dynamic> post(
    String path,
    dynamic data, {
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (error) {
      throw error.response?.data ?? error.message;
    }
  }


}